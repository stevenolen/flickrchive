require 'filemagic'
require 'digest'
require 'rake' # for FileList

module Flickrchive
  module Prepare
    def prepare
      fm = FileMagic.new
      Flickrchive.logger.info("Recursively inspecting directory for images, this may take awhile...")
      self.db.synchronize do
        @existing_files = self.db.map { |k,v| v[:filename]}
      end
      files = FileList.new("#{self.directory}/**/*") do |fl|
        self.excludes.each do |exclude_matcher|
          fl.exclude(Regexp.new(exclude_matcher))
        end
      end
      # get out list of files to attempt to process
      to_do = files - @existing_files

      to_do.each do |fn|
        new_photo = {filename: fn}
        begin
          new_photo[:type] = fm.file(fn)
          case new_photo[:type]
          # maybe filemagic isn't such a good idea after all.
          when /^(setgid )?JPEG/, /^(setgid )?PNG/, /^(setgid )?GIF/
            create_file_metadata(new_photo)
            add_to_db(new_photo)
          else
            Flickrchive.logger.debug("Ignoring non-photo file: #{fn}")
          end
        rescue FileMagic::FileMagicError
          Flickrchive.logger.warn("FileMagic explosion, ignoring file: #{fn}")
        rescue Errno::ENOENT
          Flickrchive.logger.warn("File no longer exists: #{fn}")
        end
      end
      self.db.close
    end

    def add_to_db(photo)
      if self.db.keys.include? photo[:md5]
        Flickrchive.logger.debug("Ignoring previously added file #{photo[:filename]}")
      else
        self.db.synchronize do
          db[photo[:md5]] = photo
        end
        Flickrchive.logger.debug("Added photo: #{photo[:filename]}")
      end
    end

    def create_file_metadata(photo)
      photo[:md5] = Digest::MD5.file(photo[:filename]).hexdigest
      photo[:path_arr], photo[:tags] = photo_arrays(photo[:filename])
      photo[:set] = photo[:path_arr][-2] || '' # files in base dir get blank set
      photo[:name] = photo[:path_arr].last
    end

    def photo_arrays(fn)
      path_arr = fn.sub(self.directory, '').split('/')
      path_arr.delete("")
      tags_arr = path_arr.collect { |x| x.gsub(' ', '') }
      _filename = tags_arr.pop #pop off the filename, no need to have that as a tag
      tags = tags_arr.join(" ")
      return path_arr, tags
    end
  end
end
