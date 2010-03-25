require 'roxml'

module Properties
  class Property
    include ROXML

    def initialize(name = nil, value = nil)
      self.name = name
      self.value = value
    end

    xml_name 'property'    
    xml_accessor :name, :from => "@name"
    xml_accessor :value, :from => "@value"
    
  end
  
  class Environment
    include ROXML
    
    xml_name 'environment'
    xml_accessor :type, :from => "@type"
    xml_accessor :properties, :from => "property", :as => [Property]
    
  end
  
  class Environments
    include ROXML
    
    xml_name 'environments'  
    xml_accessor :current, :from => "@current"
    xml_accessor :environments, :from => 'environment', :as => [Environment]
  end

end