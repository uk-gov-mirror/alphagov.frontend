class UnavailableService
  attr_reader :country, :lgsl, :config

  def initialize(lgsl, country, config)
    raise StandardError, "Must supply an LGSL code" if lgsl.blank?
    raise StandardError, "Must supply a valid config" unless config.is_a?(Hash)

    @lgsl = lgsl.to_i
    @country = country
    @config = config
    @service_path = ["services", lgsl]
  end

  def unavailable?
    config.dig(*@service_path).present? && config.dig(*@service_path).include?(country)
  end

  def self.load_config
    YAML.safe_load(File.open(Rails.root.join("config/unavailable_services.yml")))
  end
end
