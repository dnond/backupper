module Backupper
  class LocalFile
    def archive(local_dir_name)
      clean_workdir

      Dir::glob("#{local_dir_name}/*").each do |file_link|
        dir_in_workdir = copy_to_workdir file_link
        archive_dir(dir_in_workdir)
        FileUtils.rm_rf(dir_in_workdir)
      end
      archive_dir(work_dir)
    end

    def copy_to_workdir(dir)
      FileUtils.cp_r(dir, work_dir, { dereference_root: true } )
      "#{work_dir}/#{File.basename(dir)}"
    end

    def clean_workdir
      remove_dir = File.dirname(work_dir)
      FileUtils.rm_rf(remove_dir) if File.exist? remove_dir

      # archived_file_name = archived_dir_file_name(work_dir)
      # FileUtils.rm(archived_file_name) if File.exist? archived_file_name

      FileUtils.mkdir_p(work_dir)
    end

    def archive_dir(dir, archived_file = nil)
      archived_file = archived_dir_file_name(dir) if archived_file.nil?
      `tar cvzf #{archived_file} -C #{File.dirname(dir)} #{File.basename(dir)}`
      archived_file
    end

    private

    def archived_dir_file_name(dir)
      "#{File.dirname(dir)}/#{File.basename(dir)}.tar.gz"
    end

    def work_dir
      "#{::Backupper::WORKDIR}/#{Date.today.strftime('%Y-%m-%d')}"
    end
  end
end
