class World < ActiveRecord::Base
  
  ZIP_REQUIRED_FILES = {
    "avatar/stand.swf" => 'a stand animation for the avatar',
    "avatar/walk.swf" => 'a walk animation for the avatar',
    "config/logging.xml" => 'logging configuration',
    "config/properties.xml" => 'a properties file',
    "config/rooms/session.xml" => 'a session room GAML definition'
  }
  
  before_save :validate_zip, :on => :create
  before_save :create_slug, :on => :create  
  
  validates_uniqueness_of :slug
  
  attr_accessor :zip
  
  def zip=(file)
    @zip = file
  end
  
  def asset_path(file = "/")
    File.join(Configuration.world.base_path, self.id.to_s, file)
  end
  
  def asset_uri(file = "")
    "/world_assets/#{self.id}/#{file}"
  end
  
  def to_param
    slug
  end
  
  def includes_platform_swf?
    File.exist?(asset_path("PlatformDemo.swf"))
  end
  
  def platform_swf_uri
    asset_uri("PlatformDemo.swf")
  end
  
  def insert_default_properties!
    #Now we need to insert custom elements into the properties.xml

    environments = Properties::Environments.from_xml(File.read(asset_path("config/properties.xml")))

    environment = environments.environments.first
    
    new_properties = []
    
    environment.properties.each do | property |

      new_properties << property unless ["setting.useServer", "app.name", "path.game-server"].include?(property.name)
    end
    
    environment.properties = new_properties
    environment.properties << Properties::Property.new("setting.useServer", "true")
    environment.properties << Properties::Property.new("app.name", slug)
    environment.properties << Properties::Property.new("path.game-server", Configuration.world.nexus_endpoint)
    
    environments.current = environments.environments.first.type
    environments.environments = [environment]
    
    doc = ROXML::XML::Document.new
    doc.root = environments.to_xml
    doc.save(asset_path("config/properties.xml"))
    
  end
  
  protected
  
  def validate_zip
    if zip.nil?
      self.errors.add(:zip, "Must be uploaded")
      false
    else
      begin
        Zip::ZipFile.open(zip.path) do | file |
          ZIP_REQUIRED_FILES.each_pair do | required_file, reason |
            self.errors.add(:zip, "must contain #{reason} at #{required_file}") if file.find_entry(required_file).nil?
          end
        end
      rescue
        self.errors.add(:zip, "must be a valid zip file")
      end
    end
    
    return self.errors.empty?
  end
  
  def create_slug
    self.slug = /\d{4}\w{3}/.gen
  end
end
