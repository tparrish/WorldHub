namespace :properties do
  task :regenerate => :environment do
    World.all.each do | world |
      world.insert_default_properties!
    end
  end
end