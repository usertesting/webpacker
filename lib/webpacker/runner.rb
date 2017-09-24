require "shellwords"
require "open3"

module Webpacker
  class Runner
    delegate :root_path, :config_path, :logger, :dev_server, :config, to: :@webpacker

    def self.run(argv)
      $stdout.sync = true
      new(argv: argv).run
      # runner.run if runner.valid?
    end

    def initialize(argv: nil, webpacker: nil)
      @argv = argv || []
      @webpacker = webpacker || load_webpacker
    end

    def node_env
      ENV["NODE_ENV"] ||= rails_env
    end

    def rails_env
      ENV["RAILS_ENV"] ||= ENV.fetch("RACK_ENV", Rails.env)
    end

    private

    def load_webpacker
      Webpacker::Instance.new(root_path: ENV["RAILS_ROOT"])
    end

    def escaped_node_modules_path
      Shellwords.escape(config.node_modules_path)
    end

    def escaped_env_config_path
      Shellwords.escape(config.env_config_path)
    end

    def set_global_env
      ENV["RAILS_ENV"] ||= ENV["RACK_ENV"] || @webpacker.env
      ENV["NODE_ENV"]  ||= ENV["RAILS_ENV"]
    end
  end
end
