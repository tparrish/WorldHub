require 'zip/zip'

class World < ActiveRecord::Base
  
  cattr_accessor :base_path
  
  delegate :base_path, :to => self
  
  ZIP_REQUIRED_FILES = {
    "avatar/stand.swf" => 'a stand animation for the avatar',
    "avatar/walk.swf" => 'a walk animation for the avatar',
    "config/logging.xml" => 'logging configuration',
    "config/properties.xml" => 'a properties file',
    "config/rooms/session.xml" => 'a session room GAML definition'
  }
  
  before_save :validate_zip, :on => :create
  before_save :create_slug, :on => :create

  after_save :copy_prototype, :on => :create
  after_save :install_zip, :on => :create
  
  
  validates_uniqueness_of :slug
  
  attr_accessor :zip
  
  def zip=(file)
    @zip = file
  end
  
  def asset_path(file = "/")
    File.join(base_path, self.id.to_s, file)
  end
  
  def asset_uri(file = "")
    "world_assets/#{self.id}"
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
  
  def copy_prototype
    FileUtils.cp_r Configuration.world.prototype_path asset_path
  end
  
  def install_zip
    Zip::ZipFile.open(zip.path).each do | file |
      to = File.join(base_path, self.id.to_s, file.name)
      FileUtils.mkdir_p(File.dirname(to))
      file.extract(asset_path())
    end
  end
end
