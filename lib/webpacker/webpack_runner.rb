module Webpacker
  class WebpackRunner < Webpacker::Runner

    def run
      env = { "NODE_PATH" => escaped_node_modules_path }
      cmd = [ "#{config.node_modules_path}/.bin/webpack", "--config", escaped_env_config_path ] + @argv

      logger.info "Compling..."
      sterr, stdout, status = Open3.capture3(env, *cmd)

      if status.success?
        logger.info "Compiled all packs in #{config.public_output_path}"
      else
        logger.error "Compilation failed:\n#{sterr}\n#{stdout}"
      end

      status.success?
    end

    def escaped_node_modules_path
      Shellwords.escape(config.node_modules_path)
    end

    def escaped_env_config_path
      Shellwords.escape(config.env_config_path)
    end
  end
end
