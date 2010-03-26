ActionMailer::Base.smtp_settings = { 
  :address => 'localhost', 
  :domain => 'dubitplatform.com', 
  :port => 25 
}
ActionMailer::Base.default_url_options[:host] = case Rails.env
when "development" then "worldhub.local"
when "production" then "worldhub.dubitplatform.com"
else "localhost"
end