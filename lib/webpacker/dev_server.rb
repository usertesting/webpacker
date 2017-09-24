class Webpacker::DevServer
  # Configure dev server connection timeout (in seconds), default: 0.01
  # Webpacker.dev_server.connect_timeout = 1
  mattr_accessor(:connect_timeout) { 0.01 }

  delegate :config, to: :@webpacker

  def initialize(webpacker)
    @webpacker = webpacker
    exit_missing_env_config! unless File.exist?(config.env_config_path)
  end

  def running?
    Socket.tcp(host, port, connect_timeout: connect_timeout).close
    true
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, NoMethodError
    false
  end

  def hot_module_replacing?
    fetch(:hmr)
  end

  def host
    fetch(:host)
  end

  def port
    fetch(:port)
  end

  def https?
    fetch(:https)
  end

  def protocol
    https? ? "https" : "http"
  end

  def host_with_port
    "#{host}:#{port}"
  end

  private

    def exit_missing_env_config!
      puts "Webpack config #{config.env_config_path} not found, please run 'bundle exec rails webpacker:install' to install webpacker with default configs or add the missing config file for your custom environment."
      exit!
    end

    def fetch(key)
      config.dev_server.fetch(key, defaults[key])
    end

    def defaults
      config.send(:defaults)[:dev_server]
    end
end
