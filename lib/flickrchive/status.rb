module Flickrchive
  module Status
    def status
      time = Time.now
      self.db.lock do
        @all_count = self.db.size
        @uploaded = self.db.reject { |k,v| !v[:flickr_id] }
        @uploaded_count = @uploaded.size
      end
      self.db.close
      puts '===== Flickrchive ====='
      puts 'Current Time: ' + time.inspect
      puts 'Photos in DB: ' + @all_count.to_s
      puts 'Uploaded photos: ' + @uploaded_count.to_s
    end
  end
end
