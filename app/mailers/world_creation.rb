class WorldCreation < ActionMailer::Base
  default :from => "worldhub@dubitplatform.com"
  
  def confirmation(world)
    @world = world
    mail(:to => "#{world.author} <#{world.email}>", :subject => "You've created #{world.name} with Dubit Virtual World creator!")
  end
  
  def notify(world)
    @world = world
    mail(:to => "matthew.warneford@dubitlimited.com", :subject => "[WORLDHUB] #{world.name}")
  end
end
