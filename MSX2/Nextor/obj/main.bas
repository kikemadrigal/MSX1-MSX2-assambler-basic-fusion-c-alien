
10 _TURBO ON
20 _TURBO OFF
1 '25 screen 1,0
1 '26 print " "fre(0)
1 '27 goto 27

30 DEFINT A-Z: DIM P(15): Z=USR(1)
40 _TURBO ON(P(),Z)
1 'nextorbasic nos obliga a defnir los arrays en la primera línea del turbo bloque'
1 'Según la documentación, se debe de crer un array para los archivos'
50 DIM F$(1)
1 'reservamos espacio para manejar 4 disparos'
1 'dx= coordenada disparo x'
1 'dy= coordenada disapro y'
1 'di= disparo dirección
1 'dv= velocidad disapro horizintal'
1 'dp= plano diparo asignado'
1 'dt= disparo tipo, determina si es del player (0), del boss (1) o de un enemigo (2)'
1 'ds=disparo sprite, tendrá el valor 6 si es el disparo del player y xx i es el disparo del boss'
51 DIM dx(4),dy(4),di(4),dv(4),dp(4),ds(4)
1 'Componente de posicion'
1 'ex()=coordenada x, ey=coordenada y', e1=coordenada previa x, e2=coordenada previa y
1 'Componente de fisica'
1 'ev()=velocidad enemigo eje x, el=velocidad eje y'
1 'Componente de render'
1 'es()=enemigo sprite, ep()=enemigo plano'
1 'Componente RPG'
1 'ee()=enemigo energia '
1' ec()=enemigo contador para hacer la animación de andar
1 'et()=enemigo tipo'
55 DIM ex(3),ey(3),ev(3),el(3),es(3),ep(3),ec(3),ee(3),et(3)
1 'mc=counter map, nos dice en que columna debemos de empezar a escribir, tans solo se utiliza en el desplazamiento de la pantalla
1 'ma=mapa activo, según el mapa activo cargaremos un archivo.bin u otro del disco en el array (en la RAM)'
1 'ms=mapa screen, nos dice la pantalla en la que estamos dentro del mundo va del 0 al 15 mundo 1, 6 al 11 mundo 2 y del 12 al 17 mundo 3'
1 'mu=si está a 1 tendremos que volver a llamar a la rutina cargar mundo para redibujar los mapas'
1 'mw=mapa width, mapa ancho'
60 mc=0:ma=0:ms=0:mu=0:mw=200
1 'Inicializamos la variables globales del juego''
1 'tf=tile floor, tile suelo, corresponde al tile 160 hasta el 160+32'
1 'te=tile end, determina el final del mundo'
1 'td=tile death, se lo tocas te mata'
1 'tc=tile collectable, los que se pueden recoger'
1 'tw=tile world el tile que se tiene que pintar cuando se recoja un collectable
1 'Del t1 al t7 son variables player para detectar colisiones en los alrededores de un tile''
1 'wc=world captures, las capturas que necesitas para pasar el mundo' 
70 al=0:tf=0:td=0:te=0:tw=0:time=0:t1=0:t3=0:t5=0:t7=0:wc=0  
1 'Variables de ayuda para el manejo de las páginas y lectura de datas'
1 'pg=página
1 'md=mapa dirección'
90 pg=2:md=&h8000
1 'Inicializamos el player'
1 'px y py coordenadas player'
1 'pw y ph=player width y player height'
1 'pv y pl =player velocidad hotizontal y vertical'
1 'pa=player salto activado'
1 'pj=distancia que recorre cuando el salto está activado'
1 'pd=player dirección'
1 'pe=player energía, vidas'
1 'Variables player para la física'
100 px=0:py=18*8:pw=8:ph=16:pv=1:pl=1:pj=0:pa=0:pd=3:pe=5
1 'p0 player mirando a la derecha 1'
1 'p1 player mirando a la derecha 2'
1 'p2 player mirando a la izquierda 1'
1' p3 player mirando a la izquierda 2
1 'p4 player saltando a la derecha'
1 'p5 player saltando a la izquierda'
110 p1=0:p2=1:p3=2:p4=3
1 'pp=player plano'
1 'ps=player sprite'
120 pp=0:ps=0
1 'dm= disparos maximos, maximo expacio reservado para los disparos en un array'
1 'dn= disparo número, sirve para ir creando disparos ya que despues se incrementa'
1 'dd= disparo destruido, variable utilizada para eliminar disparo (ver linea 11600 y 11690)'
1 'ds= disparo sprite'
1 'dc= disparo color'
1 'dp= valor de inicio en el plano para los disparos, como queremos que comience en el plano 1 le ponemos un 0, el plano 0 es el del player'
1 'dw=disparo ancho'
1 'dh=dispar alto'
130 dm=4:dn=0:dd=0:ds=6:dc=6:dp=0:dw=8:dh=2
1 'Definiendo el espacio para los arrays con los valores de los enemigos' 
1 'em=enemigos maximos,reservamos el espacio en RAM para 3 enemigos''
1 'en=enemigo numero, variable utilizar para gestionar la creación y destrucción de enemigos'
1 'es =variable utilizada para hacer la animación del enemigo'
140 em=3:en=0:es=11
1 'bo=indica si el modo boss está activado'
1 'be=boss energía'
1 'bi=posicion antigua eje x
1 'bz=posición antigua eje y'
1 'bd=boss dirección 2,3,5 derecha, 6,7,8 izquierda'
1 'ba=posición x de la bala'
1 'bb=posición y de la bala del enemigo'
150 bo=0:bx=0:bw=24:bh=16:bz=0:bi=0:by=0:be=100:bv=1:bd=3:ba=0:bb=0
1 'se=canción a reproducir, fx= efecto a reproducir'
160 se=0:fx=0
1 'Al pulsar el espacio disparamos'
170 strig(0) on:on strig gosub 10500
1 'Inicializamos la música y efectos'
180 gosub 7000
1 'Mostramos la pantalla de menu / bienvenida / records'
210 gosub 14000
1 'No quites este rem que da error'
220 rem nada

1 'BASIC VERSION'
1 '1 'Inicilizamos dispositivo: 003B, inicilizamos teclado: 003E, incializamos y preparamos el sonido:&H90'
1 '35 defusr=&h003B:a=usr(0):defusr1=&h003E:a=usr1(0):defusr2=&H90:a=usr2(0)
1 '1 'Enlazamos con las rutinas de la bios para aparagar y encender la pantalla'
1 '36 defusr3=&H41:defusr4=&H44
1 'Apagamos la pantalla con la rutina &h41 de la bios'
230 P(0)=0:P(1)=&h41:Z=USR(58)
1 '13000 Cargar mapa con ma=mundo activo'
240 gosub 13000
1 'Encendemos la pantalla con la rutina &h44 de la bios'
250 P(0)=0:P(1)=&h44:Z=USR(58)







1' Mostramos el HUD / soreboard
400 gosub 6000

1 'reproducimos la múscia'
420 'se=1:gosub 7100


1 'Solo se saldrá de este bucle si se ha llegado al final de la pantalla'
1 ' ----------------------'
1 '      MAIN LOOP
1 ' ----------------------' 
    1 'bluce principal'
    1 'Capturamos las teclas'
    1000 gosub 2000
    1 'Chequeamos la física'
    1020 gosub 4000
    1 'render'
    1040 gosub 5000
    1 'Si al player no le quedan vidas, volvemos al principio'
    1050 if pe<=0 then goto 130
    1 'Si el player ha hecho colisión con el tile end (te), al hacer colisión pone la variable mu=1 y eso es que vamos a cambiar de mundo:
    1 '         Quitamos el sprite del player para que no se vea
    1 '         Aumentamos el mapa activo (ma) y llamamos a la rutina de cargar mapa 13000 que a suv esta llama a la que tiene los datos de tf(tile suelo), te (tile fina),etc
    1 '         aumentamos el screen y llamamos a la rutina 13000 que tiene los rutinas de carga de los screens,también el número y posición de enemigos'
    1 '         Si se ha llegado al último mundo hemos ganado y vamos a la pantalla ganadora'
    1 '         aunmentamos el número del screen'
    1 '1055 if mu=1 then put sprite 0,(0,212),,p1:ma=ma+1:ms=ms+1:gosub 13000:mu=0:gosub 6000:if ma>4 then goto 14100
    1055 if mu=1 then put sprite 0,(0,212),,p1:ma=ma+1:mc=0:mu=0:gosub 13000:gosub 6000:if ma>4 then goto 14100
    1 'Debug
    1060 'gosub 6100
    1 'Pausa'
    1080 for i=0 to 100:next i
1090 goto 1000


1 ' ----------------------------------------------------------------------------------------'
1 '                                     SYSTEMS
1 ' ----------------------------------------------------------------------------------------'

1 ' ----------------------'
1 '     INPUT SYSTEM
1 ' ----------------------'
1 '2 Sistema de input'
    1 'Nos guardamos las posiciones del player antes de cambiarlas'
    2000 on stick(0) gosub 2200,2400,2600,2800,3000,3200,3400,3600
2190 return
1 '1 Arriba'
    1 'Saltamos y reproducimos un sonido'
    2200 if pa=0 and t5>=tf then po=py:pa=1:pl=1
    2210 'py=py-4
2290 return
1 '2-saltando-derecha'
    2400 if pa<>1 then po=py:pa=1
    2410 px=px+pv
    2420 pd=3
    1 'Ponemos que el layer va en dirección derecha'
    2430 if px mod 8=0 then swap p1,p2
2490 return
1 '3 derecha'
    2600 px=px+pv
    2610 pd=3
    2630 if px mod 8=0 then swap p1,p2
2690 return
1 '4-abajo derecha'
     2800 'nada'
2890 return
1 '5 abajo'
    3000 'py=py+4
3090 return
1 '6-abajo-izquierda'
    3200 'nada'
3290 return
1 '7 izquierda'
    3400 px=px-pv
    3410 pd=7
    3440 if px mod 8=0 then swap p3,p4
3490 return
1 '8 salktando izquierda'
    3600 if pa<>1 then po=py:pa=1
    3610 px=px-pv
    3620 pd=7
    3630 if px mod 8=0 then swap p3,p4
3690 return



1 ' ----------------------'
1 '    Physics system
1 ' ----------------------'
1'chequeando contorno sprite personaje
    4000 'Player'
    1 'Chekeo de llegar al final del mundo, mc=mapa contador'
    1 'Si hemos llegado al final del nivel cambiamos de mundo'
    4010 'if mc>=200 then return
    1 'Chequeo final del screen, cuando la posición del player eje x llegue a la derecha de la pantalla:
        1 'sacamos al personaje de la pantalla, 
        1 'movemos la pantalla 13600
        1 'Reposicionamos al principio al player'
        1 'Aumentamos el screen'
        1 'eliminamos todos los enemigos 12700
        1 'aumentamos el contador de pantalla y actualizamos para que pinte los enemigos y los objetos 13900'
        1 'Pintamos el marcador 6000'
    4020 if px>255 then put sprite 0,(0,212),,p1:gosub 13600:py=18*8:px=0:ms=ms+1:gosub 12700: gosub 13900:gosub 6000
    1 'Chekeo pantalla'
    4030 if px<0 then px=0
    1 'Si la posición y es mayor que 180 es que te has caido y morimos'
    4040 if py>180 then gosub 10400
    1 'Obtenemos el tile actual del player' 
    1 'ms=mapa screen nos dice en la pantalla en la que estamos'
    4050 if pd=3 then tx=(px)/8+(ms*32) else tx=(px+8)/8+(ms*32)
    4055 ty=(py/8)+1:if px <=0 then tx = 0:if py<=0 then ty=0 
    1 'tf=tile floor, o tile suelo o sólido, a partir de las posición 160 empiezan a definirse los tiles que no se pueden pasar, ver imagen tileset: https://github.com/kikemadrigal/MSX1-MSX2-assambler-basic-fusion-c-alien'
    4060 t0=vpeek(md+tx+((ty)*mw))
    1 'Si el tile 0 es un objeto collectable:
    1 'Metemos en el array el tile del fondo del mundo por defecto (linea 20000)'
    1 'pintamos 2 veces (para cubrir el bloque antiguo) el tile world definido en el mundo (línea 20000)
    1 'restamos 1 a os que faltan por coger'
    1 'Pintamos el HUD 6000'
    1 'hacemos un sonido'
    1 '4045 copy ((tw-64)*8,2*8)-(((tw-64)*8)+7,(2*8)+7),1 to (px,py+8),0:copy ((tw-64)*8,2*8)-(((tw-64)*8)+7,(2*8)+7),1 to (px+4,py+8),0:copy ((tw-64)*8,2*8)-(((tw-64)*8)+7,(2*8)+7),1 to (px-4,py+8),0'
    4070 if t0<26 then vpoke md+tx+(ty*mw),tw:line (px-8,py+8)-(px+8,py+15),14,bf: wc=wc-1:gosub 6000:fx=3:gosub 7400
    1 'Si es un bloque de muerte, morimos'
    4080 if t0=td then gosub 10400:fx=1:gosub 7400

    1 'Si chocamos con un tile de final de pantalla  volvemos a cargar el mundo'
    4090 if t0=te then mu=1
    1 'Obtenemos el tile que hay en la derecha'
    4100 t3=vpeek(md+tx+1+((ty)*mw))
    1 'Tile de abajo' 
    4110 t5=vpeek(md+tx+((ty+1)*mw))
    1 'tile de la izquierda'
    4120 t7=vpeek(md+tx+((ty)*mw)) 


    1 'Si el tile de la derecha es mayor que tf le hacemos que retroceda' 
    4130 if t3>=tf and pa=0 then px=px-pv else if t7>=tf and pa=0 then px=px+pv

    1 ' Control del salto'
    1' Si el tile del suelo es mayor que el del suelo guardado y estamos cayendo reiniciamos
    4150 if pa=1 and t5>=tf and pl<0 then pa=0:pl=-pl
    1 'Si estamos salrando hacia arriba sumamos la velocidad vertical'
    4160 if pa=1 then py=py-pl 
    1 'Si llegamos a 20 pixeles arriba, cambiamos la velocidad para que vaya más rápido'
    4170 if pa=1 and py<po-30 then pl=-2:'pl=-pl 
    4180 if pa=1 and py>po then py=po:pl=-pl:pa=0

    

    1 'Sin saltar '
    1 'Gravedad: si el tile de debajo es menor que el definido de tipo suelo le sumamos la velocidad y'
    1 'Asi solo parará de bajar al player cuando p5 sea mayor 160'
    4190 if pa=0 and t5<tf then py=py+pl
4290 return

1 ' --------------------------------------------'
1 '         RENDER SYSTEM & COLLISION
1 ' --------------------------------------------'
    1'Boss
    5000 if bo=1 then gosub 12950
    1 'Player'
    5010 if pd=3 or pd=1 or pd=2 then put sprite 0,(px,py),,p1 
    5020 if pd=7 then put sprite 0,(px,py),,p3
    1 'Shots'
    5100 gosub 11700
    1 'Enemies'
    5110 gosub 12800
5990 return

1 ' ----------------------'
1 '    HUD/Score board
1 ' ----------------------'
    6000 line (0,184)-(256,212),1,bf 
    6010 preset (10,186):F$(0)="!Capturas que faltan: "+str$(wc): Z=USR(60)
    6020 preset (10,194):F$(0)="!Level: "+str$(ma)+"-"+str$(ms)+" vidas: "+str$(pe): Z=USR(60)
    6025 preset (10,200):P(0)=0:F$(0)="!Libre: "+str$(P(0)*16): Z=USR(60): Z=USR(45)
    6030 if bo=1 then preset (10,202):F$(0)="!Energia boss: "+str$(be): Z=USR(60)
    1 'BASIC VERSION'
    1 '6000 line (0,184)-(256,212),1,bf 
    1 '6010 preset (10,186):print #1,"!Capturas que faltan: "wc
    1 '6020 preset (10,194):print #1,"!Vidas: "pe" Level: "mu"-"ms
    1 '6030 if bo=1 then preset (10,202):print #1,"!Energia boss: "be
6090 return


1 'Debug'
    1 '6100 preset (0,30):F$(0)="!tx "+str$(tx)+" ty "+str$(ty): Z=USR(60)
    6100 preset (0,30):F$(0)="!ma "+str$(ma)+" mu "+str$(mu)+" mc "+str$(mc): Z=USR(60)
    6110 preset (0,40):F$(0)="!t0 "+str$(t0)+" t5 "+str$(t5): Z=USR(60)
    1 '6110 preset (0,40):F$(0)="!t0 "+str$(t0)+" t3 "+str$(t3)+" t5 "+str$(t5)+" t7 "+str$(t7): Z=USR(60)
    1 '6120 preset (0,50):F$(0)="!tf "+str$(tf)+"px "+str$(px)+"ms "+str$(ms): Z=USR(60)
    1 'BASIC VERSION'
    1 '6100 preset (10,30):F$(0)="dn "+str$(dn): Z=USR(60)
    1 '6110 preset (10,40):F$(0)="dx0 "+str$(dx(0)): Z=USR(60)
    1 '6120 preset (10,50):F$(0)="dx1 "+str$(dx(1)): Z=USR(60)
    1 '6130 preset (10,60):F$(0)="dx2  "+str$(dx(2)): Z=USR(60)
    1 '1 '6140 preset (10,70):F$(0)="dx3 "+str$(dx(3)): Z=USR(60)
    1 '1 '6150 preset (10,80):F$(0)="dx4  "+str$(dx(4)): Z=USR(60)

    1 '6160 preset (80,40):F$(0)="dp0 "+str$(dp(0)): Z=USR(60)
    1 '6170 preset (80,50):F$(0)="dp1 "+str$(dp(1)): Z=USR(60)
    1 '6175 preset (80,60):F$(0)="dp2  "+str$(dp(2)): Z=USR(60)
    1 '6180 preset (80,70):F$(0)="dp3  "+str$(dp(3)): Z=USR(60)
    1 '6185 preset (80,80):F$(0)="dp4  "+str$(dp(4)): Z=USR(60)
6190 return





1 '*********************'
1 ' CON PSG FORMATO WYZ'
1 '*********************'
1 'Inicialización player'
1 '14080 paramos la música'
1' Reproducimos efecto 7 en línea 10510
1 'función 31 apertura de fichero
7000 F$(0)="UWOL_P.z80":E=USR(31)
    1 'Cargamos los datos del archivo del dsk a RAM'
    1 '33 volcado datos a ramm P(2) segmento, P(3) dirección,P(4) tamaño, P6(0) Incrementar P(3) si <>0'
    7010 f=P(0):P(2)=5:P(3)=0:P(4)=5737:P(6)=0:E=USR(33)
    1 '32 cierre de fichero'
    7020 P(0)=f:E=USR(32)
    1 ' Inicializamos el player'
    1 '59 ejecución de una rutina de usuario. P(0) segemento de la rutina, P(1) dirección de inicio rutina'
    7030 P(0)=5:P(1)=&H8000:E=USR(59)
    1 '66 Definici¢n o suspensi¢n de una interrupci¢n de usuario, P(0)=1 1 para definir y establecer una interrupci¢n,P(1) segemento de la interrupcion, P(2)=Dirección interrupción
    7040 P(0)=1:P(1)=5:P(2)=&H8006:E=USR(66)
7090 return
1 'Reprocucir canción, necesita la variable mu con el número de canción establecida del 0 al 10'
1 'se=Musicas (0-A)
1 'Líneaa 420'
1 'linea 14000 reproduce la canción 1'
    7100 P(0)=5:P(1)=&H8003:P(2)=se*256:E=USR(59)
7190 return

1 'Parar canción'
1 '14080 parar canción'
    7200 P(0)=5:P(1)=&H8009:E=USR(59)
7290 return
1 'Desvanecemos la música'
    7300 P(0)=5:E=USR(77)
7390 return

1 'Reproducir efecto, necesita la variable fx establecida del 0 al 8'
1 'Efectos reproducidos en las líneas 10510,'
1 '0=grave corte, para salto'
1 '1=2 graves cortos'
1 '2=1corto sonido mas grave'
1 '3=3 chasquidos agudos medios como premio'
1 '4=4 chasdios cortos medios, como un grillo'
1 '5=como el anterior pero mas aguado'
1 '6=grave corto'
1 '7=2 sonidos agusdos, como salto'
1 '8=agudo fino'
    7400 P(0)=5:P(1)=&H800C:P(3)=fx*256:E=USR(59)
7490 return

1 '*********************'
1 ' CON PSG FORMATO PT3'
1 '*********************'
    1 'inicializamos el reproductor'
    1 '7000 F$(0)="music.bin" 
    1 '    1 '1 'función 31 apertura de fichero, P(2) segmento y P(3) dirección'
    1 '    7020 E=USR(31)
    1 '    7030 P(2)=7: P(3)=0:P(4)=&H80f:E=USR(33)
    1 '    7040 Z=USR(32)
    1 '    7050 P(0)=7:P(1)=&he000:Z=USR(59)
    1 '    7060 'P(0)=8:P(1)=&he009:Z=USR(59)
    1 '7090 return
    1 '1 'Reproducimos bloque de música'
    1 '    7100 P(0)=7:P(1)=&he009:Z=USR(59)
1 '7190 return
1 '*******************************************************************'
1'   CON MSX MUSIC (solo cartuchos y MSX2+), necesita variable mu 
1 '*******************************************************************'
    1 '1 'Para poder reproducir la música he tenido que elegir el Panasonic_FS-A1ST en el openMSX ya que tiene 160Kb de memoria RAM'
    1 '7000 if se=0 then F$(0)="takeit.mbm" 
    1 '7005 if se=1 then F$(0)="MIMUSICA.MBM"
    1 '1 'Cargamos el reproductor de música, función 71, ncesita en P(0) el reproductor a cargar:0 moonblaster 1.4(mdm),1mooblaster wave 1.05(mwm)'
    1 '7010 P(0)=0: Z=USR(71)
    1 '1 'Cargamos la música, lectura de fichero a RAM, función 33 '
    1 '1 'función 31 apertura de fichero, P(2) segmento y P(3) dirección'
    1 '7020 E=USR(31)
    1 '1 'Lectura de un fichero a RAM, función 33, p(2) segmento destino, p(3) dirección ddestino, p(4) número de bytes a leer'
    1 '7030 P(2)=6: P(3)=0:P(4)=&Hf39:E=USR(33)
    1 '1 'Cierre de un fichero, función 32'
    1 '7040 Z=USR(32)
    1 '1 'Reproduciendo la música, función 74'
    1 '7050 P(0)=6:P(1)=0:E=USR(74)
1 '1 '7190 return


1 '1 ' ----------------------'
1 '1 '      End music 
1 '1 ' ----------------------'














1 '---------------------------------------------------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1 '----------------------------------Entities---------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'


1 '-----------------------------------'
1  '            PLAYER 10200-10999
1 '-----------------------------------'


1 'Rutina player muere'
    1 ' Si el modo bos está activado quitamos la bala del boss'
    10400 ba=0:bb=240:put sprite 9,(ba,bb),,18
    10405 py=18*8:px=0: put sprite 0,(px,py),,p1  
    1 'player energía (pe) son las vidas'
    10410 pe=pe-1
    1 ' Si en el momento de morir estamos saltando quitamos el salto'
    10415 pa=0:if pl <= 0 then pl=-pl
    1 'Pintamos el HUD'
    10420 gosub 6000
10490 return

1 ' Rutina barra espaciadora pulsada'
    1 'Creamos el disparo en la posición del player
    10500 gosub 11500
    1 'Reproducimos el efecto de sonido 7'
    10510 fx=2:gosub 7400
10590 return

1' ------------------------------------------------------------------------------'
1' -------------------------Rutinas disparos / fires / Shots---------------------'
1' ------------------------------------------------------------------------------'

1 ' Crear disparo'
    1 'No podemos crear más disparos que em'
    11500 if dn>=dm  then return else dn=dn+1
    1' posicionamos la bala, el 8 es para que la bala aparezca junto al cañón
    11510 dx(dn)=px+8:dy(dn)=py+8
    1 'Le asugnamos la dirección del player al disparo'
    11520 di(dn)=pd
    1 'Le asignamos la velocidad horizontal'
    11530 dv(dn)=8
    1 'El plano de los disparos comienza en 1 porque el 0 es el player, despues se hirá incrementando según el número de disparos'
    11540 dp(dn)=dn
    11550 ds(dn)=ds
11580 return


1 ' Rutina eliminar disparos'
    11600 if dn<=0 then return
    11601 'put sprite dp(dn),(0,212),,ds(dd)
    1 'primero metemos en el disparo eliminado el último disparo que se está dibujando'
    11605 dx(dd)=dx(dn):dy(dd)=dy(dn)
    1 'Sacamos el plano a elimiar de la pantalla'
    11610 put sprite dp(dd),(0,212),,ds(dd)
    1 'Le ponemos de plano el penultimo en el plano'
    11620 dp(dd)=dn-1
    1 'put sprite ep(ed),(0,212),,es(ed)'
    11650 dn=dn-1
11690 return

1 'Render / Update Shots'
    11700 if dn<=0 then return 
    1 'El dn(0) no se utiliza porque es una plantilla'
    11710 for i=1 to dn
        11715 dx=dx(i)/8+(ms*32):dy=(dy(i)/8)
        11716 d0=vpeek(md+dx+((dy)*mw))
        11717 'if d0>=tf then dd=i:gosub 11600
        1 ' A cada uno le restamos o sumamos la velocidad según su dirección'
        11720 if di(i)=1 or di(i)=2 or di(i)=3 then dx(i)=dx(i)+dv(i) else dx(i)=dx(i)-dv(i)   
        11730 put sprite dp(i),(dx(i),dy(i)),dc,ds(i)
        11740 if dx(i)<0 or dx(i)>256-16 then dd=i:gosub 11600
        1 'Colisión del disparo del enemigo con el player, dt=1 determina que la bala es del boss, si hay colisión el player muere (10400)'
        11741 'if bo=1 and dt(i)=1 then if px < dx(i) + dw and  px + 8 > dx(i) and py < dy(i) + dh and 16 + py > dy(i) then gosub 10400:gosub 11600:beep
        1 'Colision del disparo del player con el boss'
        1 'Si el modo boss está activado y la bala es del player dt()=0 comprobamos la colisión'
        1 'Si hay colisión:'
        1 '     Le restamos la enemrgia al boss'
        1 '     Mostramos la energia del boss 6000'
        1 '     Eliminamos el disparo dd=i:gosub 11600'
        1 '     Hacemos un sonido'
        11742 if bo=1 then if dx(i) < bx + bw and  dx(i) + dw > bx and dy(i) < by + bh and dy(i) + dh > by then be=be-10:dd=i:gosub 11600:beep:gosub 6000     
    11750 next i
11790 return





1 '---------------------------------------------------------'
1 '------------------------ENEMIES -------------------------'
1 '---------------------------------------------------------'
1 'ex()=coordenada x, ey=coordenada y', e1=coordenada previa x, e2=coordenada previa y
1 'Componente de fisica'
1 'ev()=velocidad enemigo eje x, el=velocidad eje y'
1 'Componente de render'
1 'es()=enemigo sprite, ep()=enemigo plano'
1 'Componente RPG'
1 'ee()=enemigo energia '
1' ec()=enemigo contador
1 'et()=enemigo tipo'

1 'em=enemigos maximos,reservamos el espacio en RAM para 3 enemigos''
1 'en=enemigo numero, variable utilizar para gestionar la creación y destrucción de enemigos'
1 'es =variable utilizada para hacer la animación del enemigo'

1 ' Crear enemigo'
    1 ' si el numero de enemigos creados es mayor que enemigos máximos volvemos para no crear más'
    12500 if en>=em then return else en=en+1
    1 'Establecemos las posiciones del enemigo por defecto, después cuando definamos el screen las modificaremos'
    12510 ex(en)=0:ey(en)=0
    1 'Le asignamos la velocidad horizontal y vertical'
    12530 ev(en)=1:el(en)=8
    1 'Los enemigos son a partir del plano 10
    12540 es(en)=0:ep(en)=9+en
    12550 ec(en)=0
    12560 ee(en)=100
    12570 et(en)=0
12590 return

1 ' Rutina eliminar enemigo'
    12600 if en<=0 then return
    12600 ex(ed)=ex(en):ey(ed)=ey(en):ev(ed)=ev(en):el(ed)=el(en):es(ed)=es(en):ep(ed)=ep(en):ec(ed)=ec(en):ee(ed)=ee(en)
    12610 put sprite ep(ed),(0,212),,es(ed)
    12650 en=en-1
12660 return

1 'Rutina eliminar todos los enemigos'
    12700 en=0
    1 '12705 for i=1 to en
    1 '    12710 ed=i: gosub 12600
    1 '12720 next i
12790 return

1' Render & update physics enemies
12800 if en<=0 then return 
    12810 for i=1 to en
        12820 ex(i)=ex(i)+ev(i)  
        1 'Si recorre 20 pasos le cambiamos la velocidad'
        12830 if ex(i) mod 25=0 then ev(i)=-ev(i)
        1 ' Son enemigo 1 el sprite 7 y 8 derecha, 9 y 10 izquierda'
        1 'Si loa velocidad es mayor que 0 es que va andando hacia la derecha, para la animación ponemos un contador (ec(i))'
        12840 ec(i)=ec(i)+1
        12850 if et(i)=0 then if ev(i)>0 then if ec(i) mod 4=0 then es(i)=7:ec(i)=0 else es(i)=8      
        12860 if et(i)=0 then if ev(i)<=0 then if ec(i) mod 4=0 then es(i)=9:ec(i)=0 else es(i)=10 
        12861 if et(i)=1 then if ev(i)>0 then if ec(i) mod 4=0 then es(i)=11:ec(i)=0 else es(i)=12      
        12862 if et(i)=1 then if ev(i)<=0 then if ec(i) mod 4=0 then es(i)=13:ec(i)=0 else es(i)=14  
        12870 put sprite ep(i),(ex(i),ey(i)),,es(i) 
        1 'Colisión del enemigo con el player'
        12880 if px < ex(i) + 16 and  px + 16 > ex(i) and py < ey(i) + 16 and 16 + py > ey(i) then gosub 10400
        1 'Colision del enemigo con un disparo'
        12890 for w=1 to dn
            1 '15 es el ancho del disparo, 16 es el ancho y el alto del enemigo, 2 es el alto del disparo'
            1 'fx=3:gosub 7400 reproducimos un efecto de sonido'
            12891 if dx(w) < ex(i) + 16 and  dx(w) + 15 > ex(i) and dy(w) < ey(i) + 16 and 2 + dy(w) > ey(i) then ed=i:gosub 12600:dd=w:gosub 11600::fx=6:gosub 7400
        12892 next w
    12895 next i
12899 return

1 '---------------------------------------------------------'
1 '------------------------boss -------------------------'
1 '---------------------------------------------------------'

1 ' Render & coliision booss'
    12950  bi=bx:bz=by:by=by-bv
    1 '     Si es el boss número 0 (el del primer nivel)vamos a aplicarle este comportamiento: borramos la antigua imagen con un line relleno de gris y lo volvemos a copiar en la nueva posición'
    1 '     Si se sale de 100 y 154 invertimos la velocidad'
    12955 if bn=0 then line (bx,bz)-(bx+bw,bz+bh),14,bf :copy (48,64)-(64,80),2 to (bx,by),0,tpset: if by<100 or by>154 then bv=-bv 
    1 '     Si al boss no le queda energía:
    1 '         Quitamos el modo boss'
    1 '         Dibujamos un rectángulo gris encima'
    1 '         Metemos en la posición de la VRAM el tile end para que cuando colisione con él nos mande al siguiente mundo, recuerda que son 2 menos en realidad'
    1 '         Copiamos en la posición 28*8,21*8) la imagen del tile end'
    1 '         Hacemos un sonido'
    1 '     Si le queda energía al boss'
    1 '         Creamos un número aleatorio
    1 '         Si el número aleatorio es mayor que 9 creamos un disparo, ponemos que es del booss(dt(en)=1) le ponemos la posición del boss, la dirección (di) hacia la izquierda'
    12960 if be<=0 then bo=0:line (bx,by)-(bx+bw,bz+bh),14,bf:copy (te*8,0*8)-((te*8)+8,(0*8)+8),2 to (15*8,21*8),0,tpset:put sprite 9,(0,212),,18:vpoke md+15+(21*mw),te
    1 'Modo debug para que aparezca en el scrren 0 el boss'
    1 '12890 if be<=0 then bo=0:line (bx,by)-(bx+bw,bz+bh),14,bf:m(28,20)=te:copy (te*8,0*8)-((te*8)+8,(0*8)+8),1 to (28*8,21*8),0,tpset:re=2:gosub 7000: put sprite 9,(0,212),,18
    12970 if bo=1 and time/60>8 then time=0:ba=bx:bb=by
    1 'Fijate que el 32 se lo ponemos para que no colisiones el disparo del player con el del
    12980 if bo=1 then ba=ba-8:if ba<1 then put sprite 9,(0,212),,18:ba=0 else put sprite 9,(ba,bb),,18
12999 return

























1 '-----------------------------------'
1 '-------------MAP & SCROLL-----------'
1 '-----------------------------------'
1 'mc=counter map, nos dice en que columna debemos de empezar a escribir, tans solo se utiliza en el desplazamiento de la pantalla
1 'ma=mapa activo, según el mapa activo cargaremos un archivo.bin u otro del disco en el array (en la RAM)'
1 'ms=mapa screen, nos dice la pantalla en la que estamos dentro del mundo va del 0 al 15 mundo 1, 6 al 11 mundo 2 y del 12 al 17 mundo 3'
1 'mu=si está a 1 tendremos que volver a llamar a la rutina cargar mundo para redibujar los mapas'
1 'mw=mapa width, mapa ancho'
    1 'Apertura de un ficher función 31'
    1 'lectura de un fichero a VRAM, funcion 34'
    1 'Entrada: P(0) = N£mero de fichero
	1 ' P(2) = Bloque VRAM de destino
	1 ' P(3) = Direcci¢n de destino
	1 ' P(4) = N£mero de bytes a leer (m ximo &H4000)
	1 ' P(6) = Incrementar P(3) si <>0
    1 'Salida:  P(7) = N£mero de bytes le¡dos
	1 ' P(2):P(3) = P(2):P(3)+P(4) si P(6)<>0
    1 'Cierre de un fichero, función 32'
    1 'Esto copiará los datas del fichero tilemap en la direción &h10000 o  65536Kb de la VRAM, page 2 '
    1 '13000 if ma=0 then F$(0)="tilemap.bin": Z=USR(31): P(2)=1: P(3)=&H0: P(4)=&h4000: Z=USR(34): Z=USR(32)
    1 'Esto copiará los datas del fichero tilemap en la direción de la VRAM &h8000 o 32768Kb, page 1'
    1 'Con gosub 20000 inicializamos el mundo 0'
    1 'gosub 20000, 21000 y 22000 inicializa los mundos o la variables que son suelo, coleccionables, etc'
    1 'gosub 13900 es la pantalla 1'
    1 'gosub 6000 pintamos la pantalla'
    13000 if ma=0 then F$(0)="tilemap0.bin": Z=USR(31): P(2)=0: P(3)=&H8000: P(4)=&h4000: Z=USR(34): Z=USR(32):gosub 20000:gosub 13900
    13010 if ma=1 then F$(0)="tilemap1.bin": Z=USR(31): P(2)=0: P(3)=&H8000: P(4)=&h4000: Z=USR(34): Z=USR(32):gosub 21000
    13020 if ma=2 then F$(0)="tilemap2.bin": Z=USR(31): P(2)=0: P(3)=&H8000: P(4)=&h4000: Z=USR(34): Z=USR(32):gosub 22000
    13195 gosub 13600
13199 return



1 '1 'Aquí vamos dibujando las pantallas de un mundo,pintamos en la VRAM page 0, los valores definidos en el array hasta la columna 32
1 '    13300 cls:md=&h8000
1 '        13310 for f=0 to 23-1
1 '            13320 for c=0 to 200-1
1 '                13330 tn= vpeek(md):md=md+1
1 '                1 ' Lamentablemente tengo que poner +2 y que el nextorbasic solo está preparado para screen4'
1 '                13340 tn=tn+2
1 '                    13350 if tn >=0 and tn <32 then copy (tn*8,0*8)-((tn*8)+8,(0*8)+8),pg to (c*8,f*8),0,tpset
1 '                    13360 if tn >=32 and tn <64 then copy ((tn-32)*8,1*8)-(((tn-32)*8)+8,(1*8)+8),pg to (c*8,f*8),0,tpset
1 '                    13370 if tn >=64 and tn <96 then copy ((tn-64)*8,2*8)-(((tn-64)*8)+8,(2*8)+8),pg to (c*8,f*8),0,tpset
1 '                    13380 if tn>=96 and tn <128 then copy ((tn-96)*8,3*8)-(((tn-96)*8)+8,(3*8)+8),pg to (c*8,f*8),0,tpset
1 '                    13390 if tn>=128 and tn <160 then copy ((tn-128)*8,4*8)-(((tn-128)*8)+8,(4*8)+8),pg to (c*8,f*8),0,tpset
1 '                    13400 if tn>=160 and tn <192 then copy ((tn-160)*8,5*8)-(((tn-160)*8)+8,(5*8)+8),pg to (c*8,f*8),0,tpset
1 '                    13410 if tn>=192 and tn <224 then copy ((tn-192)*8,6*8)-(((tn-192)*8)+8,(6*8)+8),pg to (c*8,f*8),0,tpset
1 '                    13420 if tn>=224 and tn <256 then copy ((tn-224)*8,7*8)-(((tn-224)*8)+8,(7*8)+8),pg to (c*8,f*8),0,tpset
1 '            13430 next c
1 '            13440 'md=&h8000:md=md+(f*mw)
1 '    13450 next f 
1 '    13460 md=&h8000
1 '13570 return

1 'Mover mapa a la izquierda y pintar ultima columna
    1 'Si llegamos al final salimos'
    13600 if mc>200 then return
    1 'Repetimos la copia del ultimo tile y desplazamiento de la pantalla 32 veces'
    13603 for i=0 to 31
        13610 copy (8,0)-(256,184),0 to (0,0),0,pset  
        13620 for f=0 to 23-1
            1 'tenemos que poner tn=tn+2 porque nextorbasic no está preparado para screen5'
            1 '13630 tn=vpeek(md+(31+mc)+f*mw):tn=tn+2
            13630 tn=vpeek(md+mc+f*mw):tn=tn+2
            13640 if tn >=0 and tn <32 then copy (tn*8,0*8)-((tn*8)+8,(0*8)+8),pg to (31*8,f*8),0
            13650 if tn >=32 and tn <64 then copy ((tn-32)*8,1*8)-(((tn-32)*8)+8,(1*8)+8),pg to (31*8,f*8),0
            13660 if tn >=64 and tn <96 then copy ((tn-64)*8,2*8)-(((tn-64)*8)+8,(2*8)+8),pg to (31*8,f*8),0
            13670 if tn>=96 and tn <128 then copy ((tn-96)*8,3*8)-(((tn-96)*8)+8,(3*8)+8),pg to (31*8,f*8),0
            13680 if tn>=128 and tn <160 then copy ((tn-128)*8,4*8)-(((tn-128)*8)+8,(4*8)+8),pg to (31*8,f*8),0
            13690 if tn>=160 and tn <192 then copy ((tn-160)*8,5*8)-(((tn-160)*8)+8,(5*8)+8),pg to (31*8,f*8),0
            13700 if tn>=192 and tn <224 then copy ((tn-192)*8,6*8)-(((tn-192)*8)+8,(6*8)+8),pg to (31*8,f*8),0
            13710 if tn>=224 and tn <256 then copy ((tn-224)*8,7*8)-(((tn-224)*8)+8,(7*8)+8),pg to (31*8,f*8),0
        13720 next f
        13725 mc=mc+1
    13730 next i
13740 return



1 ' actualizar pantalla / screen'
1 'según en que pantalla estemos se crearán un os enemigos u objetos distintos'
    1 'Mundo 0'

    13900 if ms=0 then gosub 20100
    13901 if ms=1 then gosub 20200
    13910 if ms=2 then gosub 20300
    13920 if ms=3 then gosub 20400
    13930 if ms=4 then gosub 20500
    1 'Boss'
    13940 if ms=5 then gosub 20600


13990 return

























1 '---------------------------------------------------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1 '----------------------------------Screens---------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1 '---------------------------------------------------------------------------------------------------------'
1'------------------------------------'
1'  Pantalla de Bienvenida y records 
1'------------------------------------'
    1 'Reproducimos la 1 canción'
    14000 se=1:gosub 7100
    14005 cls:preset (10,30):  F$(0)="!@@@@  @  @@@@  @ @@@@@ @  @   @": Z=USR(60)
    14010 preset (10,40):      F$(0)="!@    @ @ @@@@  @   @  @ @ @ @ @": Z=USR(60)
    14020 preset (10,50):      F$(0)="!@@@@@   @@     @   @ @   @@  @@": Z=USR(60)
    14030 preset (10,70):      F$(0)="!10540,capita Kik, debes ir a recoger las muestras fabricadas en otros entornos planetarios.": Z=USR(60)
    14040 preset (10,110):     F$(0)="!Pero ten cuidado los esbirros de worst que te obstaculizan.": Z=USR(60)
    14050 preset (10,160): F$(0)= "!Cursores para mover, pulsa una tecla para continuar": Z=USR(60)
    1 '14060 preset (10,180): F$(0)= "!libre: ": Z=USR(60)
    1 'Si no se pulsa una tecla se queda en blucle infinito reproduciebdo una música, si se pulsa se para la música'
    1 '11870 re=1:gosub 4300
    14070 if inkey$="" then goto 14070
    1 'Paramos la música'
    14080 gosub 7200
    1 'BASIC VERSION'
    1 '14000 cls:preset (10,30):  print #1,"!@@@@  @  @@@@  @ @@@@@ @  @   @"
    1 '14010 preset (10,40):      print #1,"!@    @ @ @@@@  @   @  @ @ @ @ @"
    1 '14020 preset (10,50):      print #1,"!@@@@@   @@     @   @ @   @@  @@"
    1 '14030 preset (10,70):      print #1,"!10540,capita Kik, debes ir a recoger las muestras fabricadas en otros entornos planetarios."
    1 '14040 preset (10,110):     print #1,"!Pero ten cuidado los esbirros de worst que te obstaculizan."
    1 '14050 preset (10,160): print #1, "!Cursores para mover, pulsa una tecla para continuar"
    1 '14060 preset (10,180): print #1, "!libre: "fre(0)
    1 '14070 if inkey$="" then goto 14070
1 '160 es donde se carga la pantalla del nivel 0'
14090 goto 220
1'------------------------------------'
1'  Pantalla final ganadora
1'------------------------------------'
    14100 cls:preset (10,70):  F$(0)="Felicidades"+str$(ma): Z=USR(60)
    14110 preset (10,80):      F$(0)="!Has completado la mision": Z=USR(60)
    14120 preset (10,90):      F$(0)="!Lgica:Kikemadrigal": Z=USR(60)
    14130 preset (10,100):      F$(0)="!gráficos:Kikemadrigal": Z=USR(60)
    14140 if inkey$="" then goto 14040
    1 'Borramos los arris para poder volver a cargarlos'
    1 '14150 erase ex,ey,ev,el,es,ep,ec,ee,dx,dy,dv,dp

    1 'BASIC VERSION'
    1 '14100 cls:preset (10,70):  print #1,"Felicidades"ma
    1 '14110 preset (10,80):      print #1,"!Has completado la mision"
    1 '14120 preset (10,90):      print #1,"!Lgica:Kikemadrigal"
    1 '14130 preset (10,100):      print #1,"!gráficos:Kikemadrigal"
    1 '14140 if inkey$="" then goto 14040
    1 '14150 gosub 1100
1 '150 es la pantalla de menú de bienvenida o scoreboard'
14190 goto 150

1'------------------------------------'
1'          World 0
1'------------------------------------'
    1 'Tiles'
    1 'tf=tile floor, tile suelo, corresponde al tile 160 hasta el 160+32'
    1 'te=tile end, determina el final del mundo'
    1 'tc=tile collectable, los que se pueden recoger'
    1 'tw=tile world el tile que se tiene que pintar cuando se recoja un collectable
    20000 tf=160:te=28:tw=80:td=42
    1 'World caprturas, las capturas que necesitas para pasar el mundo'
    20010 wc=6
20090 return


1'------------------------------------'
1'          Screen 0
1'------------------------------------'
    1 'creamos 1 enemigo'
    20100 'gosub 12500:ex(en)=26*8:ey(en)=20*8:et(en)=0
    20110 'gosub 12500:ex(en)=12*8:ey(en)=18*8:et(en)=1
    20120 gosub 12800:bo=1:bn=0:be=10:bx=150:by=120:gosub 6000
20190 return
1'------------------------------------'
1'          Screen 1
1'------------------------------------'
    1 'creamos 1 enemigo'
    20200 gosub 12500:ex(en)=(17*8):ey(en)=17*8
20290 return
1'------------------------------------'
1'          Screen 2
1'------------------------------------'
    1 'creamos 1 enemigo'
    20300 gosub 12500:ex(en)=20*8:ey(en)=20*8
20390 return
1'------------------------------------'
1'          Screen 3
1'------------------------------------'
    1 'creamos 1 enemigo'
    20400 gosub 12500:ex(en)=16*8:ey(en)=10*8
20490 return
1'------------------------------------'
1'          Screen 4
1'------------------------------------'
    1 'creamos 1 enemigo'
    20500 gosub 12500:ex(en)=26*8:ey(en)=20*8
20590 return
1'------------------------------------'
1'          Screen 5
1'------------------------------------'
    1 '12800 Inicializamos variables boss'
    1 'Le decimos que el boss está activo'
    1 'le ponemos una energía (be)'
    1 'Mostramos el HUD'
    20600 gosub 12800:bo=1:bn=0:be=100:bx=150:by=120:gosub 6000
20690 return
1'------------------------------------'
1'          World 1
1'------------------------------------'
    1 'Tiles'
    1 'tf=tile floor, tile suelo, corresponde al tile 160 hasta el 160+32'
    1 'te=tile end, determina el final del mundo'
    1 'tc=tile collectable, los que se pueden recoger'
    1 'tw=tile world el tile que se tiene que pintar cuando se recoja un collectable
    21000 tf=160:te=26:tw=80
    1 'World caprturas, las capturas que necesitas para pasar el mundo'
    1 'wf=world false, variable utilizada por si volv'
    21010 wc=6:wf=0
    21020 cls:for i=0 to 1000:next i:preset(256/2,212/2):F$(0)="Level 2":Z=USR(60)
21090 return
1'------------------------------------'
1'          Screen 6
1'------------------------------------'
1'------------------------------------'
1'          Screen 7
1'------------------------------------'
1'------------------------------------'
1'          Screen 8
1'------------------------------------'
1'------------------------------------'
1'          Screen 9
1'------------------------------------'
1'------------------------------------'
1'          Screen 10
1'------------------------------------'
1'------------------------------------'
1'          World 2
1'------------------------------------'
    1 'Tiles'
    1 'tf=tile floor, tile suelo, corresponde al tile 160 hasta el 160+32'
    1 'te=tile end, determina el final del mundo'
    1 'tc=tile collectable, los que se pueden recoger'
    1 'tw=tile world el tile que se tiene que pintar cuando se recoja un collectable
    22000 tf=160:te=26:tw=80
    1 'World caprturas, las capturas que necesitas para pasar el mundo'
    1 'wf=world false, variable utilizada por si volv'
    22010 wc=6:wf=0
22090 return
1'------------------------------------'
1'          Screen 11
1'------------------------------------'
1'------------------------------------'
1'          Screen 12
1'------------------------------------'
1'------------------------------------'
1'          Screen 13
1'------------------------------------'
1'------------------------------------'
1'          Screen 14
1'------------------------------------'
1'------------------------------------'
1'          Screen 15
1'------------------------------------'


1 ' ----------------------------------------------------------------------------------------'
1 '                                END SCREENS
1 ' ----------------------------------------------------------------------------------------'



23000 _TURBO OFF