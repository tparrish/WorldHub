require 'zip/zip'

class WorldsController < ApplicationController
  inherit_resources

  before_filter :find_by_slug, :only => [:show, :manage]

  def index
    @worlds = World.paginate(:page => params[:page])
  end

  def create
    @world = World.new(params[:world])
    
    if @world.save
      flash[:message] = "Congratulations you're world is now ready!"
      cookies[:worlds] = (cookies[:worlds].nil? ? @world.id.to_s : cookies[:worlds]+" "+@world.id.to_s)
      
      #Now email the appropriate authorities
      WorldCreation.confirmation(@world).deliver
      WorldCreation.notify(@world).deliver
      
      redirect_to manage_world_path(@world)
    else
      render :action => 'new'
    end
  end
  
  def show
    render :action => 'show', :layout => 'blank'
  end
  
  private
  
  def find_by_slug
    @world = World.find_by_slug params[:id]
  end
end
