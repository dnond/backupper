require 'thor'

module Backupper
  class CLI < Thor
    EXPIRE_SEC = 3600
    class_option :debug, type: :boolean

    desc 'backup', 'execute backup'
    method_option :local_target_dir, default: nil, desc: 'backup dir in local pc'
    method_option :remote_dir, default: nil, desc: 'destination dir in remote strage'
    method_option :oauth_json, default: nil, desc: 'json file path for Google Drive oauth certification'
    def backup
      local_target_dir = options[:local_target_dir] || ENV['BACKUPPER_LOCAL_TARGET_DIR']

      puts '------ archiving'
      archived = ::Backupper::LocalFile.new.archive(local_target_dir)
      puts "archived: #{archived}"

      puts '--- rotating....'
      remote = ::Backupper::Remote.new(options)

      remote_dir = options[:remote_dir]
      remote_dir = 'backupper' if remote_dir.nil?
      old_files = remote.rotate(remote_dir)
      puts "deleted: #{old_files.join(',')}"

      puts '---- uploading'
      remote.upload_file(archived, remote_dir)
      puts "backup: #{archived} -> #{remote_dir}"

      puts '-------- end'
    end

    private

    def remote(options)
      return @remote unless @remote.nil?
      
      oauth_json = options[:oauth_json] || ENV['BACKUPPER_GOOLE_OAUTH_JSON']
      @remote = ::Backupper::GDrive.new(oauth_json)
    end
  end
end
