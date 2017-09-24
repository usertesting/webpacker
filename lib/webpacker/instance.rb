require "active_support/string_inquirer"
require "yaml"

class Webpacker::Instance
  delegate :node_env, :rails_env, to: :@webpack_runner

  cattr_accessor(:logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT)) }

  attr_reader :root_path, :config_path, :webpack_runner

  def initialize(root_path: Rails.root, config_path: nil, webpack_runner: nil)
    @root_path = Pathname.new(root_path.to_s)
    @config_path = Pathname.new(define_config_path(config_path).to_s)
    @webpack_runner = webpack_runner || load_webpack_runner
  end

  def env
     ActiveSupport::StringInquirer.new(valid_environments.first)
  end

  def valid_environments
    considered_environments & available_environments
  end

  def considered_environments
    [
      node_env,
      rails_env,
      "production".freeze
    ].compact
  end

  def root_path
    @root_path ||= File.expand_path(".", Dir.pwd)
  end

  def config_path
    @config_path ||= root_path.join("config/webpacker.yml")
  end

  def config
    @config ||= Webpacker::Configuration.new self
  end

  def compiler
    @compiler ||= Webpacker::Compiler.new self
  end

  def dev_server
    @dev_server ||= Webpacker::DevServer.new self
  end

  def manifest
    @manifest ||= Webpacker::Manifest.new self
  end

  def commands
    @commands ||= Webpacker::Commands.new self
  end

  private

  def load_webpack_runner
    Webpacker::WebpackRunner.new(webpacker: self)
  end

  def define_config_path(init_config_path)
    init_config_path || File.join(root_path, "config/webpacker.yml")
  end

  def available_environments
    if File.exist?(config_path)
      YAML.load(File.read(config_path)).keys
    else
      [].freeze
    end
  end
end
