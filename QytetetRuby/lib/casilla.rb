#encoding: utf-8

module ModeloQytetet
  class Casilla
    def initialize(nc, t)
      @numeroCasilla = nc
      @tipo = t
    end
    
    attr_reader :numeroCasilla, :tipo
    
    def to_s
      "Casilla: \n número de casilla= #{@numeroCasilla} \n tipo de casilla= #{@tipo} \n"
    end
  end
end
