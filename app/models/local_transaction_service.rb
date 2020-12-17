module LocalTransactionService
  CONFIG_PATH = Rails.root.join("config/unavailable_services.yml")

  def self.unavailable?(lgsl, country_name)
    @config ||= YAML.safe_load(File.open(CONFIG_PATH))
    @config.dig("services", lgsl).present? && @config.dig("services", lgsl).include?(country_name)
  end
end
