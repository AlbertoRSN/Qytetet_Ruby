#encoding: utf-8

module InterfazTextualQytetet
  require_relative "qytetet.rb"
  require_relative "vista_textual_qytetet.rb"
  require_relative "dado.rb"
  require_relative "jugador.rb"
  require_relative "sorpresa.rb"
  require_relative "tipo_sorpresa.rb"
  require_relative "tablero.rb"
  require_relative "casilla.rb"
  require_relative "tipo_casilla.rb"
  require_relative "titulo_propiedad.rb"
  require_relative "metodo_salir_carcel.rb"
  require_relative "especulador.rb"
  
  class ControladorQytetet
    
    def initialize
      @juego = nil
      @jugador = nil
      @casilla = nil
      @vista = VistaTextualQytetet.new
    end
  
    def desarrolloJuego
      bancarrota = false
      tienePropietario = false
        
      while (!bancarrota)
        espaciado
        @vista.mostrar("Es el turno de #{@jugador.getNombre} \n")
        @casilla = @jugador.getCasillaActual
        @vista.mostrar("----Su posición actual es: \n #{@casilla} \n")
        libre = !@jugador.getEncarcelado
            
        if (!libre)
          @vista.mostrar("----El jugador está en la cárcel :( \n")
                
          if (salirCarcel)
            @vista.mostrar("----El jugador vuelve a ser libre \n")
          else
            @vista.mostrar("----El jugador no ha conseguido salir de prisión \n")
          end
          pausa
        end
            
        if (!@jugador.getEncarcelado)
          tienePropietario = @juego.jugar
          @jugador = @juego.getJugadorActual
          @casilla = @jugador.getCasillaActual
          @vista.mostrar("----Se tira el dado \n")
          @vista.mostrar("----El jugador #{@jugador.getNombre} ha caído en la casilla \n #{@casilla} \n")
          pausa
                
          eleccionSegunCasilla(@casilla.tipo,tienePropietario)
          gestionInmobiliaria
        end
            
        if (@jugador.getSaldo > 0)
          siguienteTurno
          bancarrota = finJuego
        else
          bancarrota = finJuego
        end
      end
    end
    
    def espaciado
      @vista.mostrar("-----------------------------------\n")
    end
    
    def finJuego
      fin = false
      if (@jugador.getSaldo<=0)
        @vista.mostrar(@juego.obtenerRanking)
        fin = true
        @vista.mostrar("El juego ha terminado \n");
      end
      fin
    end

    def siguienteTurno
      @jugador = @juego.siguienteJugador
    end
    
    def salirCarcel
      opcion = @vista.menu_salir_carcel
      libre = false
      metodo = nil
      if (opcion == 0)
        metodo = ModeloQytetet::MetodoSalirCarcel::TIRANDODADO
      elsif (opcion == 1)
        metodo = ModeloQytetet::MetodoSalirCarcel::PAGANDOLIBERTAD
      end
        
      libre = @juego.intentarSalirCarcel(metodo)
      libre
    end
    
    def eleccionSegunCasilla(tipo, tienePropietario)
        
        if (@jugador.getSaldo>0 and !@jugador.getEncarcelado)
            if (@casilla.tipo == ModeloQytetet::TipoCasilla::CALLE)
              if(!tienePropietario)
                if(@vista.elegir_quiero_comprar == 0)
                  if(@juego.comprarTituloPropiedad)
                    @jugador = @juego.getJugadorActual
                    @vista.mostrar("----Se ha realizado la compra \n")
                  else
                    @vista.mostrar("----No se ha podido comprar \n")
                  end
                else
                  @vista.mostrar("----No se ha comprado la calle \n")
                  pausa
                end
              end
            elsif (@casilla.tipo == ModeloQytetet::TipoCasilla::SORPRESA)
              tienePropietario = @juego.aplicarSorpresa
              @jugador = @juego.getJugadorActual
              @casilla = @jugador.getCasillaActual
              espaciado
              @vista.mostrar("----Se coge una carta sorpresa: \n #{@juego.getCartaActual} \n")
              pausa
              @vista.mostrar("----La casilla actual es \n #{@casilla} \n")
              @vista.mostrar("----El estado del jugador tras la sorpresa es \n #{@jugador} \n")
              espaciado
              pausa
              if (@jugador.getSaldo>0 and !@jugador.getEncarcelado and @casilla.tipo == ModeloQytetet::TipoCasilla::CALLE)
                if(!tienePropietario)
                  if(@vista.elegir_quiero_comprar == 0)
                    if(@juego.comprarTituloPropiedad)
                      @jugador = @juego.getJugadorActual
                      @vista.mostrar("----Se ha realizado la compra \n")
                      @vista.mostrar("----Vemos las propiedades del jugador: \n #{@jugador.getPropiedades()}\n")
                    else
                      @vista.mostrar("----No se ha podido comprar \n")
                    end
                  else
                    @vista.mostrar("----No se ha comprado la calle \n")
                    pausa
                  end
                end
              end
            end
        end
    end
     
    def gestionInmobiliaria
        if (!@jugador.getEncarcelado() and @jugador.getSaldo() > 0 and @jugador.tengoPropiedades())
          opcion = -1
          while(opcion != 0)
            opcion = @vista.menu_gestion_inmobiliaria
            if (opcion == 5)
              espaciado
              @casilla = elegir_propiedad(@juego.propiedadesHipotecadasJugador(true))
              espaciado
            elsif (opcion != 0)
              espaciado
              @casilla = elegir_propiedad(@juego.propiedadesHipotecadasJugador(false))
              espaciado
            end
            
            menuInmobiliario(opcion)
            @jugador = @juego.getJugadorActual
            @vista.mostrar("----El estado del jugador tras la acción es \n #{@jugador}\n")
            pausa
          end
        end
    end
    
    def menuInmobiliario(opcion)
      case opcion
        when 1
          if @juego.edificarCasa(@casilla)
            @vista.mostrar("----Se ha edificado la casa \n")
          else
            @vista.mostrar("----No se ha podido edificar la casa \n")
          end
        when 2
          if @juego.edificarHotel(@casilla)
            @vista.mostrar("----Se ha edificado el hotel \n")
          else
            @vista.mostrar("----No se ha podido edificar el hotel \n")
          end
        when 3
          if @juego.venderPropiedad(@casilla)
            @vista.mostrar("----Se ha vendido la propiedad \n")
          else
            @vista.mostrar("----No se ha podido vender la propiedad \n")
          end
        when 4
          if @juego.hipotecarPropiedad(@casilla)
            @vista.mostrar("----Se ha hipotecado la propiedad \n")
          else
            @vista.mostrar("----No se ha podido hipotecar la propiedad \n")
          end
        when 5
          if @juego.cancelarHipoteca(@casilla)
            @vista.mostrar("----Se ha cancelado la hipoteca \n")
          else
            @vista.mostrar("----No se ha podido cancelar la hipoteca \n")
          end
      else
        
      end
    end
    
    def inicializacionJuego
      @juego = ModeloQytetet::Qytetet.instance  
      nombres = Array.new
      nombres = @vista.obtener_nombre_jugadores
      @juego.inicializarJuego(nombres)
      @jugador = @juego.getJugadorActual
      @casilla = @jugador.getCasillaActual
      @vista.mostrar("-------------ESTADO INICIAL------------\n")
      @vista.mostrar("#{@juego}")
      espaciado
      pausa
    end
    
    def pausa
      puts "Pulsa \'intro\' para continuar"
      gets
    end
    
    #   # --------------------el siguiente método va en ControladorQytetet
    def elegir_propiedad(propiedades) # lista de propiedades a elegir
      @vista.mostrar("\tCasilla\tTitulo");
        
      listaPropiedades= Array.new
      for prop in propiedades  # crea una lista de strings con números y nombres de propiedades
        propString= prop.numeroCasilla.to_s+' '+prop.titulo.nombre; 
        listaPropiedades<<propString
      end
      seleccion=@vista.menu_elegir_propiedad(listaPropiedades)  # elige de esa lista del menu
      propiedades.at(seleccion)
    end
   
    
    def main
      inicializacionJuego
      desarrolloJuego
    end
 
  end
  c = ControladorQytetet.new
  c.main
end
