module Backupper
  WORKDIR = '/tmp/backupper'.freeze
  ROTATE_KEEP_FILE_COUNT = 10
end

require 'backupper/local_file'
require 'backupper/remote'
require 'backupper/cli'
