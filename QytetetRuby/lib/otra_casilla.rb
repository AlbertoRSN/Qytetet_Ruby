#encoding: utf-8

module ModeloQytetet
  class OtraCasilla < Casilla
    
    def initialize(nC,t)
      super(nC,t)
    end
    
    def soyEdificable
      false
    end
  end
end
