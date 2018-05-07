#encoding: utf-8

module ModeloQytetet
  class TituloPropiedad
    
    def initialize(n, aB, fR, hB, pE)
      @nombre = n
      @alquilerBase = aB
      @factorRevalorizacion = fR
      @hipotecaBase = hB
      @precioEdificar = pE
      @hipotecada = false
      @propietario = nil
      @casilla = nil
    end
    
    attr_reader :nombre, :hipotecada, :alquilerBase, :factorRevalorizacion, :hipotecaBase, :precioEdificar
    
    attr_writer :hipotecada
    
    def cobrarAlquiler(coste)
      @propietario.modificarSaldo(coste)
    end
    
    # para propiedadesHipotecaJugador
    def getCasilla
      @casilla
    end
    
    def propietarioEncarcelado
      @propietario.getEncarcelado
    end
    
    def setCasilla(casilla)
      @casilla = casilla
    end
    
    def setHipotecada(hipotecada)
      @hipotecada = hipotecada
    end
      
    def setPropietario(propietario)
      @propietario = propietario
    end
    
    def tengoPropietario
      tengo = false
      if (@propietario != nil)
        tengo = true
      end
      tengo
    end
    
    def to_s
      "Título propiedad: \n nombre= #{@nombre} \n hipotecado= #{@hipotecada} 
      \n alquiler base= #{@alquilerBase} \n factor revalorización= #{@factorRevalorizacion}
      \n hipoteca base= #{@hipotecaBase} \n precio edificar= #{@precioEdificar}"
    end
  end
end
