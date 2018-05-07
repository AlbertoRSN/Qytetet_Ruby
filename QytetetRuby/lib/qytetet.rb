#encoding: utf-8

module ModeloQytetet
  
  require "singleton"
  
  class Qytetet
    
    include Singleton

    MAXJUGADORES = 4
    MAXCARTAS = 10
    MAXCASILLAS = 20
    PRECIOLIBERTAD = 200
    SALDOSALIDA = 1000
    
    def initialize
      @cartaActual = nil
      @mazo = Array.new
      @jugadores = Array.new
      @jugadorActual = nil
      @tablero = nil
      @dado = Dado.instance
    end
   
    def aplicarSorpresa
      tienePropietario = false
      if (@cartaActual != nil)
      if (@cartaActual.tipo == TipoSorpresa::PAGARCOBRAR)
        @jugadorActual.modificarSaldo(@cartaActual.valor)
      elsif(@cartaActual.tipo == TipoSorpresa::IRACASILLA)
        esCarcel = @tablero.esCasillaCarcel(@cartaActual.valor)
        if (esCarcel)
          encarcelarJugador
        else
          nuevaCasilla = @tablero.obtenerCasillaNumero(@cartaActual.valor)
          tienePropietario = @jugadorActual.actualizarPosicion(nuevaCasilla)
        end
      elsif (@cartaActual.tipo == TipoSorpresa::PORCASAHOTEL)
        @jugadorActual.pagarCobrarPorCasaYHotel(@cartaActual.valor)
      elsif (@cartaActual.tipo == TipoSorpresa::PORJUGADOR)
        @jugadores.each{ |jugador|
          if (jugador != @jugadorActual)
            jugador.modificarSaldo(@cartaActual.valor)
          else
            @jugadorActual.modificarSaldo(@cartaActual.valor)
          end
        }
      elsif (@cartaActual.tipo == TipoSorpresa::CONVERTIRME)
        e = @jugadorActual.convertirme(@cartaActual.valor)
        @jugadores.delete(@jugadorActual)
        @jugadorActual = e
        @jugadores << e
      end
        
      if (@cartaActual.tipo == TipoSorpresa::SALIRCARCEL)
        @jugadorActual.setCartaLibertad(@cartaActual)
      else
        # Ver después porque no lo tengo claro
        @mazo << @cartaActual
      end
      tienePropietario
      end
    end
    
    def cancelarHipoteca(casilla)
      cancelarHipoteca = false
      if (casilla.estaHipotecada and @jugadorActual.puedoPagarHipoteca(casilla))
        cantidadRecibida = casilla.getCosteHipoteca
        @jugadorActual.modificarSaldo(-cantidadRecibida) 
        cancelarHipoteca = true
      end
      cancelarHipoteca 
    end
    
    def comprarTituloPropiedad
      puedoComprar = @jugadorActual.comprarTitulo
      puedoComprar
    end
    
    def edificarCasa(casilla)
      puedoEdificar = false
      if (casilla.soyEdificable)
        sePuedeEdificar = casilla.sePuedeEdificarCasa(@jugadorActual.getFactorEspeculador)
        if (sePuedeEdificar)
          puedoEdificar = @jugadorActual.puedoEdificarCasa(casilla)
          if(puedoEdificar)
            costeEdificarCasa = casilla.edificarCasa
            @jugadorActual.modificarSaldo(-costeEdificarCasa)
          end
        end
      end
      puedoEdificar
    end
    
    def edificarHotel(casilla)
      puedoEdificar = false
      if (casilla.soyEdificable)
        sePuedeEdificar = casilla.sePuedeEdificarHotel(@jugadorActual.getFactorEspeculador)
        if (sePuedeEdificar)
          puedoEdificar = @jugadorActual.puedoEdificarHotel(casilla)
          if(puedoEdificar)
            costeEdificarHotel = casilla.edificarHotel
            @jugadorActual.modificarSaldo(-costeEdificarHotel)
          end
        end
      end
      puedoEdificar
    end
    
    def getCartaActual
      @cartaActual
    end
    
    def getJugadorActual
      @jugadorActual
    end
    
    def getJugadores
      @jugadores
    end
    
    def hipotecarPropiedad(casilla)
      puedoHipotecar = false
      if (casilla.soyEdificable)
        sePuedeHipotecar = !casilla.estaHipotecada
        if (sePuedeHipotecar)
          puedoHipotecar = @jugadorActual.puedoHipotecar(casilla)
          if (puedoHipotecar)
            cantidadRecibida = casilla.hipotecar
            @jugadorActual.modificarSaldo(cantidadRecibida)
          end
        end
      end
      puedoHipotecar
    end
    
    def inicializarJuego(nombres)
      inicializarJugadores(nombres)
      inicializarTablero
      inicializarCartasSorpresa
      salidaJugadores
    end
    
    def intentarSalirCarcel(metodo)
      libre = false
      if (metodo == MetodoSalirCarcel::TIRANDODADO)
        valorDado = @dado.tirar
        libre = valorDado>5
      else
        tengoSaldo = @jugadorActual.pagarLibertad(Qytetet::PRECIOLIBERTAD)
        libre = tengoSaldo 
      end
      if (libre)
        @jugadorActual.setEncarcelado(false)
      end
      libre
    end
    
    def jugar
      valorDado = @dado.tirar
      casillaPosicion = @jugadorActual.getCasillaActual
      nuevaCasilla = @tablero.obtenerNuevaCasilla(casillaPosicion,valorDado)
      tienePropietario = @jugadorActual.actualizarPosicion(nuevaCasilla)
      #if(nuevaCasilla != nil)
      if (!nuevaCasilla.soyEdificable)
        if (nuevaCasilla.tipo == TipoCasilla::JUEZ)
          encarcelarJugador
        elsif (nuevaCasilla.tipo == TipoCasilla::SORPRESA)
          @cartaActual = @mazo[0]
          # Se borra la carta del mazo
          @mazo.delete(@cartaActual)
        end
      end
      #end
      tienePropietario
    end
    
    def obtenerRanking
      ranking = Array.new
      @jugadores.each { |jugador|
        capital = jugador.obtenerCapital
        puntuacion = "#{jugador.getNombre} #{capital}"
        ranking << puntuacion
      }
      ranking
    end
    
    #Añadido getCasilla, hecho a partir del de Jugador
    def propiedadesHipotecadasJugador(hipotecadas)
      titulos = @jugadorActual.obtenerPropiedadesHipotecadas(hipotecadas)
      casillas = Array.new
      titulos.each{ |titulo|
        casillas << (titulo.getCasilla)
      }
      casillas
    end
    
    def siguienteJugador
      indice = @jugadores.index(@jugadorActual)
      indice +=1
      indice %= @jugadores.size
      @jugadorActual = @jugadores[indice]
      @jugadorActual
    end
    
    def venderPropiedad(casilla)
      puedoVender = false
      if (casilla.soyEdificable)
        puedoVender = @jugadorActual.puedoVenderPropiedad(casilla)
        if (puedoVender)
          @jugadorActual.venderPropiedad(casilla)
        end
      end
      puedoVender
    end
    
    private
    
    def encarcelarJugador
      if (!@jugadorActual.tengoCartaLibertad)
        casillaCarcel = @tablero.carcel
        @jugadorActual.irACarcel(casillaCarcel)
      else
        carta = @jugadorActual.devolverCartaLibertad
        @mazo << (carta)
        # Revisar
      end
    end
    
    def inicializarCartasSorpresa
      @mazo << Sorpresa.new("Han pillado alguno de tus chanchullos. Ve a la cárcel.",TipoSorpresa::IRACASILLA,@tablero.carcel.numeroCasilla)
      @mazo << Sorpresa.new("Un extraño tornado te arrastra hasta la casilla 13.",TipoSorpresa::IRACASILLA,13)
      @mazo << Sorpresa.new("El poder de la fuerza te atrae hasta la casilla 2.",TipoSorpresa::IRACASILLA,2)
      @mazo << Sorpresa.new("Quedas libre de la cárcel. No es aplicable en la vida real",TipoSorpresa::SALIRCARCEL,0)
        
      @mazo << Sorpresa.new("Al fin han reconocido tu talento y tu belleza... Recibes dinero.",TipoSorpresa::PAGARCOBRAR,200)
      @mazo << Sorpresa.new("Pagas al banco con la esperanza de que no descubran lo que te traes entre manos.",TipoSorpresa::PAGARCOBRAR,-250)
        
      @mazo << Sorpresa.new("Recibes dinero por cada una de tus maravillosas propiedades.",TipoSorpresa::PORCASAHOTEL,150)
      @mazo << Sorpresa.new("No cumples la normativa, así que debes pagar por cada una de tus odiosas propiedades.",TipoSorpresa::PORCASAHOTEL,-175)
        
      @mazo << Sorpresa.new("Los demás jugadores sospechan de ti. Los sobornas para que no te delaten.",TipoSorpresa::PORJUGADOR,-100)
      @mazo << Sorpresa.new("El resto de jugadores te obsequia con un sobre para comprar tu silencio.",TipoSorpresa::PORJUGADOR,100)
      
      @mazo << Sorpresa.new("Enhorabuena, al fin has conseguido convertirte en especulador.",TipoSorpresa::CONVERTIRME,3000)
      @mazo << Sorpresa.new("La fortuna te sonríe. Únete a los especuladores.",TipoSorpresa::CONVERTIRME,5000)
        
      @mazo.shuffle!
    end
    
    def inicializarJugadores(nombres)
      nombres.each{ |j|
            n = Jugador.new(j)
            @jugadores << n
      } 
    end
    
    def inicializarTablero
      @tablero = Tablero.new
    end
    
    def salidaJugadores
      @jugadores.each{ |j|
        j.setCasillaActual(@tablero.obtenerCasillaNumero(0))
      }
      # Comprobar
      numero = rand(@jugadores.size)
      @jugadorActual = @jugadores[numero]
    end
    
    public
    
    def to_s
        "Qytetet \n carta actual= #{@cartaActual} \n cartas sorpresa= #{@mazo} \n
                jugador actual= #{@jugadorActual} \n jugadores= #{@jugadores} \n tablero=
                #{@tablero} \n dado= #{@dado} \n"
    end
    
  end
end
