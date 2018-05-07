#encoding: utf-8

module ModeloQytetet
  class Sorpresa
    
    def initialize(texto, tipo, valor)
      @texto = texto
      @tipo = tipo
      @valor = valor
    end
    
    attr_reader :texto, :tipo, :valor
    
    def to_s
      "Texto: #{@texto} \n Valor: #{@valor} \n Tipo: #{@tipo}"
    end
  end
end
