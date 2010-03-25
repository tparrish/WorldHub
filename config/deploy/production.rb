set :deploy_to, "/var/www/worldhub"
set :user, "twilliams"

role :web, "worldhub.dubitplatform.com"                          # Your HTTP server, Apache/etc
role :app, "worldhub.dubitplatform.com"                          # This may be the same as your `Web` server
role :db,  "worldhub.dubitplatform.com", :primary => true # This is where Rails migrations will run