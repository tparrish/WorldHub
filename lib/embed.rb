require 'active_model'

class Embed
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  validates :width, :numericality => true, :unless => :fullscreen?
  validates :height, :numericality => true, :unless => :fullscreen?
  validates :world, :presence => true
  validates :host, :presence => true
    
  attr_accessor_with_default :width, 750
  attr_accessor_with_default :height, 560
  attr_accessor :world, :host
  
  def fullscreen=(fullscreen)
    
    if fullscreen == true || fullscreen =="true" || fullscreen == "1"
      @fullscreen = true
    else
      @fullscreen = false
    end
  end
  
  def fullscreen
    @fullscreen
  end
  
  def fullscreen?
    @fullscreen
  end
  
  def initialize(options = {})
    @fullscreen = false
    options.each { |name, value| send("#{name}=", value) }
  end
  
  def code
    url = "http://#{host}"
    if world.includes_platform_swf?
      url += world.platform_swf_uri
    else
      url += "/flash/platform.swf"
    end
    url += "?base.url=http://#{host}#{world.asset_uri}"
    dimensions = fullscreen? ? 'width="100%" height="100%"' : "width=\"#{width}\" height=\"#{height}\""
    generated = <<-END
    <object #{dimensions}><param name="allowscriptaccess" value="always" /><param name="movie" value="#{url}" /><embed src="#{url}" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" #{dimensions}></embed></object>
    END
    
    generated.strip
  end
end