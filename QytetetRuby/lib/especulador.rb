#encoding: utf-8

module ModeloQytetet
  
  class Especulador < Jugador
    
    protected
    
    def initialize(jugador,fianza)
      copia(jugador)
      @factorEspeculador = 2
      @fianza = fianza
    end
    
    def pagarImpuestos(cantidad)
      super(cantidad/2)
    end
    
    public
    def irACarcel(casilla)
      if(!pagarFianza(@fianza))
        irACarcel(casilla)
      end
    end
    
    protected
    def convertirme(fianza)
      self
    end
    
    private
    def pagarFianza(cantidad)
      pagar = false
      if (getSaldo >= cantidad)
        modificarSaldo(-cantidad)
        pagar = true
      end
    end
    
    public
    def to_s
      return super + "\nSe trata de un especulador cuya fianza es #{@fianza}\n"
    end
    
  end
end
