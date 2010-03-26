module WorldsHelper
  def bitly_world_url(world)
     BitlyAPI.shorten(world_url(world))
  end
  
  def bitly_world_stats(world)
     BitlyAPI.stats(world_url(world))
  end
end
