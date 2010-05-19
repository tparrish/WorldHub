require 'zip/zip'
require 'ftools'

class WorldsController < ApplicationController
  inherit_resources

  skip_before_filter :verify_authenticity_token, :only => :upload
  before_filter :find_by_slug, :only => [:show, :manage, :embed]

  def index
    @worlds = World.paginate(:page => params[:page])
  end

  def create
    @world = World.new(params[:world])
    
    if params[:world][:zip].blank?
      @world.zip = File.new("tmp/#{params[:upload_token]}-world.zip")
    end
    
    if @world.save
      File.delete("tmp/#{params[:upload_token]}-world.zip") rescue nil#Remove the ajax uploaded file if necessary
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
  
  def embed
    @embed = Embed.new(params[:embed])
    @embed.world = @world
    @embed.host = request.host_with_port
    
    respond_to do |wants|
      wants.html { 
        render :action => 'manage'
      }
      wants.text {
        if @embed.valid?
          render :text => @embed.code
        else
          render :partial =>'embeds/errors', :locals => {:embed => @embed }, :status => 400
        end
      }
    end
  end
  
  def show
    render :action => 'show', :layout => 'blank'
  end
  
  def upload
    @file = params[:world][:zip]
    
    File.move(@file.path, "tmp/#{params[:upload_token]}-world.zip")
    render :nothing => true
  end
  
  private
  
  def find_by_slug
    @world = World.find_by_slug params[:id]
  end
end
