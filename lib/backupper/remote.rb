require 'forwardable'
require_relative 'g_drive'

module Backupper
  class Remote
    extend Forwardable

    def_delegators :@remote_strage, :upload_file, :rotate

    def initialize(options)
      @remote_strage = g_drive(options)
    end

    private

    def g_drive(options)
      oauth_json = options[:oauth_json]
      oauth_json = ENV['BACKUPPER_GOOLE_OAUTH_JSON'] if oauth_json.nil?
      ::Backupper::GDrive.new(oauth_json)
    end
  end
end
