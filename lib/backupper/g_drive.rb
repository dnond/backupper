require 'google_drive'
require 'json'

module Backupper
  class GDrive
    def initialize(oauth_json)
      @session = GoogleDrive.saved_session(oauth_json)
    end

    def upload_file(localfile, remote_dir_name)
      remote_filename = remote_filename_via localfile

      uploaded_file = @session.upload_from_file(localfile, remote_filename, convert: false)
      mv(uploaded_file, remote_dir_name)
      [remote_dir_name, remote_filename]
    end

    def rotate(remote_dir_name)
      files = files_in_dir(remote_dir_name).sort_by(&:created_time)

      old_files = (files - files.first(::Backupper::ROTATE_KEEP_FILE_COUNT))
      old_files.map(&:delete)
      old_files
    end

    private

    def remote_collection(dir_name)
      @session.collection_by_title(dir_name) ||
        @session.root_collection.create_subcollection(dir_name)
    end

    def files_in_dir(dir_name)
      remote_collection(dir_name).files
    end

    def remote_filename_via(localfile)
      File.basename localfile
    end

    def mv(remote_file, remote_dir_name)
      remote_collection(remote_dir_name).add(remote_file)
      # 移動元（GoogleDrive直下）は削除しておく
      @session.root_collection.remove(remote_file)
    end
  end
end
