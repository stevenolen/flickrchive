module Flickrchive
  module Execute
    def execute
      get_sets
      self.db.load
      to_upload = []
      self.db.synchronize do
        to_upload = self.db.reject { |k,v| v[:flickr_id] }
        Flickrchive.logger.debug("Grabbing un-uploaded photos from db.")
      end
      to_upload.each do |k,v|
        upload_photo(v)
        add_to_set(v)
      end
      self.db.close
    end

    def upload_photo(photo)
      begin
        id = flickr.upload_photo photo[:filename], is_public: 0, is_friend: 0, is_family: 0, hidden: 2, tags: photo[:tags]
      rescue FlickRaw::FailedResponse => e
        handle_flickr_fail(e)
        retry
      end
      Flickrchive.logger.info("Uploaded file: #{photo[:filename]}")
      photo[:flickr_id] = id
      self.db.synchronize do
        self.db[photo[:md5]] = photo
      end
    end

    def add_to_set(photo)
      set = self.sets.find { |i| photo[:set] == i['title'] }
      if !set.nil?
        begin
          flickr.photosets.addPhoto photoset_id: set['id'], photo_id: photo[:flickr_id]
        rescue FlickRaw::FailedResponse => e
          handle_flickr_fail(e)
          retry
        end
        Flickrchive.logger.info("Photo added to set: #{photo[:filename]}, #{photo[:set]}")
      elsif photo[:set] == ''
        Flickrchive.logger.debug("Photo in base, not adding to set: #{photo[:filename]}")
      else
        begin
          flickr.photosets.create title: photo[:set], primary_photo_id: photo[:flickr_id]
        rescue FlickRaw::FailedResponse => e
          handle_flickr_fail(e)
          retry
        end
        Flickrchive.logger.info("Created set, added photo: #{photo[:set]}, #{photo[:filename]}")
        get_sets # refresh for new set
      end
    end

    def get_sets
      begin
        self.sets = flickr.photosets.getList
      rescue FlickRaw::FailedResponse => e
        handle_flickr_fail(e)
        retry
      end
    end

    def handle_flickr_fail(e)
      if [3, 105, 106].include?(e.code)
        sleep 60 # sleep 60, returning to code which will retry
      else
        Flickrchive.logger.fail("Uncatchable response from flickr. Check and restart: #{e.msg}")
        self.db.close
        exit
      end
    end
  end
end
