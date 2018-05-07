#encoding: utf-8

require_relative "sorpresa"
require_relative "tipo_sorpresa"
require_relative "tablero"
require_relative "casilla"
require_relative "tipo_casilla"
require_relative "titulo_propiedad"
require_relative "jugador"
require_relative "qytetet"
require_relative "dado"

module ModeloQytetet
  class PruebaQytetet
    @@mazo = Array.new
    @@tablero = Tablero.new
    
    def self.inicializar_sorpresas
      @@mazo << Sorpresa.new("Han pillado alguno de tus chanchullos. Ve a la cárcel.",TipoSorpresa::IRACASILLA,@@tablero.carcel.numeroCasilla)
      @@mazo << Sorpresa.new("Un extraño tornado te arrastra hasta la casilla 13.",TipoSorpresa::IRACASILLA,13)
      @@mazo << Sorpresa.new("El poder de la fuerza te atrae hasta la casilla 2.",TipoSorpresa::IRACASILLA,2)
      @@mazo << Sorpresa.new("Quedas libre de la cárcel. No es aplicable en la vida real",TipoSorpresa::SALIRCARCEL,0)
        
      @@mazo << Sorpresa.new("Al fin han reconocido tu talento y tu belleza... Recibes dinero.",TipoSorpresa::PAGARCOBRAR,200)
      @@mazo << Sorpresa.new("Pagas al banco con la esperanza de que no descubran lo que te traes entre manos.",TipoSorpresa::PAGARCOBRAR,-250)
        
      @@mazo << Sorpresa.new("Recibes dinero por cada una de tus maravillosas propiedades.",TipoSorpresa::PORCASAHOTEL,150)
      @@mazo << Sorpresa.new("No cumples la normativa, así que debes pagar por cada una de tus odiosas propiedades.",TipoSorpresa::PORCASAHOTEL,-175)
        
      @@mazo << Sorpresa.new("Los demás jugadores sospechan de ti. Los sobornas para que no te delaten.",TipoSorpresa::PORJUGADOR,-100)
      @@mazo << Sorpresa.new("El resto de jugadores te indemniza para comprar tu silencio.",TipoSorpresa::PORJUGADOR,100)
    end
    
    def self.mayorQue0
      mayores = Array.new
      @@mazo.each{ |m|
        if (m.valor > 0)
          mayores << m
        end
      }
      mayores
    end
    
    def self.tipoCasilla
      tipo = Array.new
      @@mazo.each{ |t|
        if (t.tipo == TipoSorpresa::IRACASILLA)
          tipo << t
        end
      }
      tipo
    end
    
    def self.tipoEspecifico(t)
      especifico = Array.new
      @@mazo.each{ |e|
        if (e.tipo == t)
          especifico << e
        end
      }
      especifico
    end
    
    def self.main
      inicializar_sorpresas
      #puts @@mazo
      
      #puts mayorQue0
      #puts tipoCasilla
      #puts tipoEspecifico(TipoSorpresa::SALIRCARCEL)
      
      j = Jugador.new("Aurelia")
      t = Tablero.new
      s = Sorpresa.new("Hola, ve a la casilla 4",TipoSorpresa::IRACASILLA,4)
      c = Casilla.newCasillaNoCalle(0,TipoCasilla::SALIDA)
      ti = TituloPropiedad.new("Catedral",75,11,600,500);
      q = Qytetet.instance
      nombres = Array.new
      nombres << "Yo"
      nombres << "Tú"
      q.inicializarJuego(nombres)  
      puts q.tablero.obtenerNuevaCasilla(c, 6)
      #puts j
      #puts t
      #puts s
      #puts c
      #puts ti
      #puts q
      
      #puts @@tablero
    end
  end
  PruebaQytetet.main
end
