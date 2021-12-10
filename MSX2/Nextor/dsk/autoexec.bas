
10 cls:key off
20 print "Checking.."
1 'En la dirección &h2D el MSX almacena la versión e MSX: 0=MSX1, 1=MSX2, 2=MSX2+, 3=MSXturboR'
30 if PEEK(&H2D)=0 then print "Sistema MSX 1":ms=1
1 'Si no es un MSX2+ vamos al final del programa'
60 ''VDP(10)or2 Estableve los 50 kz'
70 if PEEK(&H2D)=1 then print "Sistema MSX 2":VDP(10)=VDP(10)OR2:ms=2
80 if PEEK(&H2D)<>0 and PEEK(&H2D)<>1 then print "Sistema MSX 2+" :ms=3
1 'Inicializamos disposituvo y teclado'
90 defusr=&h003B:a=usr(0):defusr1=&h003E
110 if ms=1 then print "Espera a que implemente la version de MSX 1"
120 if ms=2 then print "Reading loader...":BLOAD"NBASIC.BIN",R:CLEAR:load"loader.bas",r
130 if ms=3 then print "Reading loader...":BLOAD"NBASIC.BIN",R:CLEAR:load"loader.bas",r

