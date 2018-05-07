#encoding:. utf-8

module ModeloQytetet
  
  require "singleton"
  
  class Dado
    include Singleton
   
    def initialize
      
    end
    
    def tirar
      rand(6)+1
    end
    
  end
end
