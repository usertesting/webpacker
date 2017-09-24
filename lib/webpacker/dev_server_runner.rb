require "webpacker/runner"
require "socket"

module Webpacker
  class DevServerRunner < Webpacker::Runner
    def run
      detect_port!
      execute_cmd
    end

    private

    def load_webpacker
      Webpacker::Instance.new(root_path: ENV["RAILS_ROOT"])
    end

    def detect_port!
      server = TCPServer.new(listen_host_addr, port)
      server.close

    rescue Errno::EADDRINUSE
      logger.error "Another program is running on port #{port}. Set a new port in #{config_file} for dev_server"
      exit!
    end

    def execute_cmd
      argv = @argv.dup

      # Delete supplied host, port and listen-host CLI arguments
      ["--host", "--port", "--listen-host"].each do |arg|
        argv.delete(args(arg))
        argv.delete(arg)
      end

      env = { "NODE_PATH" => escaped_node_modules_path }

      cmd = [
        "#{config.node_modules_path}/.bin/webpack-dev-server", "--progress", "--color",
        "--config", escaped_env_config_path,
        "--host", listen_host_addr,
        "--public", "#{host}:#{port}",
        "--port", port.to_s
      ] + argv

      # sterr, stdout, status = Open3.capture3(env, *cmd)

      Dir.chdir(root_path) do
        exec env, *cmd
      end
    end

    def host
      @host ||= args("--host") || dev_server.host
    end

    def port
      @port ||= args("--port") || dev_server.port
    end

    def https?
      @argv.include?("--https") || dev_server.https?
    end

    def protocol
      https? ? "https" : "http"
    end

    def listen_host_addr
      @listen_host_addr ||= args("--listen-host") || default_listen_host_addr
    end

    def default_listen_host_addr
      node_env == "development" ? "localhost" : "0.0.0.0"
    end

    def args(key)
      index = @argv.index(key)
      index ? @argv[index + 1] : nil
    end
  end
end
