require 'spec_helper'

describe World do
  
  before(:each) do
    World.destroy_all
  end
  
  it "should be invalid" do
    World.new.should_not be_valid
  end
  
  it "should be valid with an email address, a unique slug and a zip" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    world.zip = File.open(File.join(File.dirname(__FILE__),'invalid.zip'))
    world.should be_valid
  end
  
  it "should require a zip to save" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    
    world.save.should == false
    
    world.errors.first.should == [:zip, "Must be uploaded"]
  end
  
  it "needs a zip file with all the required files in it" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    world.zip = File.open(File.join(File.dirname(__FILE__),'invalid.zip'))
    world.save.should == false
  end
  
  it "should unpack the zip on save" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    world.zip = File.open(File.join(File.dirname(__FILE__),'valid.zip'))
    world.save.should == true
  end
  
  it "should fill in the blanks with the flash prototype" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    world.zip = File.open(File.join(File.dirname(__FILE__),'valid.zip'))
    world.save.should == true
    
    copied = File.read(world.asset_path('config/security.xml'))
    used_prototype = File.read(File.join(Configuration.world.prototype_path, 'config/security.xml'))
    
    copied.should == used_prototype
    
  end
  
  it "should not overwrite uploaded files with the prototype" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    world.zip = File.open(File.join(File.dirname(__FILE__),'valid.zip'))
    world.save.should == true
    
    own = File.read(world.asset_path('config/logging.xml'))
    ignored_prototype = File.read(File.join(Configuration.world.prototype_path, 'config/logging.xml'))
    
    own.should_not == ignored_prototype
  end
  
  it "should rewrite properties file to include the hostname from the config file and the app.name" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    world.zip = File.open(File.join(File.dirname(__FILE__),'valid.zip'))
    world.save.should == true
    
    properties = Properties::Environments.from_xml(File.read(world.asset_path('config/properties.xml')))
    properties = properties.environments.first.properties
    properties = Hash[*properties.collect{ | p | [p.name, p.value]}.flatten]
    
    properties['setting.useServer'].should == "true"
    properties['app.name'].should == world.slug
    properties['path.game-server'].should == Configuration.world.nexus_endpoint
  end
  
  it "should use own platform implementation if PlatformDemo.swf present" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    world.zip = File.open(File.join(File.dirname(__FILE__),'own_swf.zip'))
    world.save
    
    world.includes_platform_swf?.should == true
    world.platform_swf_uri.should == "#{world.asset_uri}PlatformDemo.swf"
  end
  
  it "should unpack assets correctly if they are in a subdirectory" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
    world.zip = File.open(File.join(File.dirname(__FILE__),'subdirectory.zip'))
    world.save.should == true
    
    File.readable?(world.asset_path('config/properties.xml')).should == true
    File.exists?(world.asset_path('config/properties.xml')).should == true
  end
end
