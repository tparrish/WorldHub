yaml_file = Rails.root.join("config", "environments", "#{Rails.env}.yml")

Configuration = Configr::Configuration.configure(yaml_file) do |config|
  config.my.configuration.value = "value"
end

require 'zip/zip'