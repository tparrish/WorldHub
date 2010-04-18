require 'zip/zip'

class World < ActiveRecord::Base
  
  ZIP_REQUIRED_FILES = {
    "config/logging.xml" => 'logging configuration',
    "config/properties.xml" => 'a properties file',
    "config/rooms/session.xml" => 'a session room GAML definition'
  }
  
  before_save :validate_zip, :on => :create
  before_save :create_slug, :on => :create  
  
  after_save :copy_prototype, :on => :create
  after_save :copy_zip
  after_save :insert_default_properties!
  
  validates_uniqueness_of :slug
  
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create
  
  attr_accessor :zip, :email
  
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

    file = asset_path("config/properties.xml")
    
    unless File.exist?(file)
      Rails.logger.warn "found no configuration file"
      return
    end

    environments = Properties::Environments.from_xml(File.read(file))

    environment = environments.environments.first
    
    environment.properties = environment.properties.reject { | property | ["setting.useServer", "app.name", "path.game-server"].include?(property.name) }
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
  
  def copy_prototype
    FileUtils.cp_r Configuration.world.prototype_path, asset_path
  end
  
  def copy_zip
    return if zip.nil?
    
    #Now copy across the zip contents
    Zip::ZipFile.open(zip.path).each do | file |
      to = asset_path(file.name)
      FileUtils.mkdir_p(File.dirname(to))
      FileUtils.rm to, :force => true #Remove the old file if it is there
      file.extract(to)
    end
  end
  
  def validate_zip
    if zip.nil?
      self.errors.add(:zip, "Must be uploaded")
      false
    else
      begin
        require 'zip/zip'
        Zip::ZipFile.open(zip.path) do | file |
          ZIP_REQUIRED_FILES.each_pair do | required_file, reason |
            self.errors.add(:zip, "must contain #{reason} at #{required_file}") if file.find_entry(required_file).nil?
          end
        end
      rescue => e
        Rails.logger.warn("Invalid zip file '#{e.to_s}'")
        self.errors.add(:zip, "must be a valid zip file")
      end
    end
    
    return self.errors.empty?
  end
  
  def create_slug
    self.slug = /\d{4}\w{3}/.gen
  end
end
