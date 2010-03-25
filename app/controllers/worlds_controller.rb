require 'zip/zip'

class WorldsController < ApplicationController
  inherit_resources

  def index
    @worlds = World.paginate(:page => params[:page])
  end

  def create
    @world = World.new(params[:world])
    
    if @world.save
    
      #Copy across the prototype
      FileUtils.cp_r Configuration.world.prototype_path, @world.asset_path

      #Now copy across the zip contents
      Zip::ZipFile.open(@world.zip.path).each do | file |
        to = @world.asset_path(file.name)
        FileUtils.mkdir_p(File.dirname(to))
        FileUtils.rm to, :force => true #Remove the old file if it is there
        file.extract(to)
      end
      
      
      #Now we need to insert custom elements into the properties.xml
      @world.insert_default_properties!
      
      redirect_to world_path(@world)
    else
      render :action => 'new'
    end
  end
  
  def show
    @world = World.find_by_slug params[:id]
    render :action => 'show', :layout => 'blank'
  end
end
