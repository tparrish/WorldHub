module WorldsHelper
  def bitly_world_url(world)
     BitlyAPI.shorten(world_url(world))
  end
  
  def bitly_world_stats(world)
     BitlyAPI.stats(world_url(world))
  end
  
  def user_world_ids
    world_ids = cookies[:worlds]
    
    if world_ids
      world_ids.split
    else
      []
    end
  end
  
  def user_worlds
    World.find user_world_ids
  end
end
