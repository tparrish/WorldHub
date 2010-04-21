require 'spec_helper'

describe World do
  
  before(:each) do
    World.destroy_all
  end
  
  it "should be invalid" do
    World.new.should_not be_valid
  end
  
  it "should be valid with an email address and a unique slug" do
    world = World.new
    world.email = "test@biscuits.com"
    world.slug = "banana"
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
  
  pending "should rewrite properties file to include the hostname from the config file"
  pending "should insert app.name into config file"
  pending "should use own platform implementation if PlatformDemo.swf present"
  pending "should unpack assets correctly if they are in a subdirectory"
end
