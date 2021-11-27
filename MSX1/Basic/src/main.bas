1 'MSX 1'
10 a=usr4(0):defint a-z
1 'Inicializamos el personaje'
130 gosub 10000
1 'Rutina barra espaciadora pulsada
520 strig(0) on:on strig gosub 5200
530 gosub 11000: gosub 11100
540 gosub 11400
560 on interval=50 gosub 11600:interval on

1 'Solo se saldrá de este bucle si se ha llegado al final de la pantalla'
1 ' ----------------------'
1 '      MAIN LOOP
1 ' ----------------------'
    1 'bluce principal'
    1 'Capturamos las teclas'
    2000 gosub 2500
    1 'render player, el update lo hacemos en el sistema de input'
    2020 gosub 10100
    1 'Chequeamos las colisiones'
    2030 gosub 3100
2090 goto 2000
1 ' ----------------------'
1 '    FINAL MAIN LOOP
1 ' ----------------------'





1 'Reproductor de efectos d sonido'
    2300 a=usr2(0)
    2310 if re=1 then PLAY"O5 L8 V4 M8000 A A D F G2 A A A A r60 G E F D C D G R8 A2 A2 A8","o1 v4 c r8 o2 c r8 o1 v6 c r8 o2 v4 c r8 o1 c r8 o2 v6 c r8"
    1 'Tirando el paquete'
    2350 if re=5 then play "l10 o4 v4 g c"
    1 'Paquete cogido'
    2360 if re=6 then play"t250 o5 v12 d v9 e" 
    1 'Pitido normal'
    2370 if re=7 then play "O5 L8 V4 M8000 A A D F G2 A A A A"
    1 'Toque fino'
    2380 if re=8 then PLAY"S1M2000T150O7C32"
    1 'Pasos'
    2390 if re=9 then PLAY"o2 l64 t255 v10 m6500 c"
    2400 if re=10 then sound 6,5:sound 8,16:sound 12,6:sound 13,9
2420 return



1 ' ----------------------'
1 '     INPUT SYSTEM'
1 ' ----------------------'
1 '2 Sistema de input'
    1 'Nos guardamos las posiciones del player antes de cambiarlas'
    2500 on stick(0) gosub 2700,2500,2600,2500,2800,2500,2640
    2520 if pa=1 then py=py-pj
    1 '12 es la distancia máxima a la que puede saltar'
    2530 if py<po-20 then pj=-pj
    2540 if py>po then py=po:pj=0:pj=-pj:pa=0'strig(0)on
2545 return
1 're=8 es el efecto de sonido 8 de la rutina de reprodución de sonidos 2300
1 '3 derecha'
    2600 px=px+pv
    2610 p1=0:p2=1:p4=4
    2620 swap p(0),p(1):p3=p(1)
2630 return
1 '7 izquierda'
    2640 px=px-pv:'gosub 9000
    2650 p1=5:p2=6:p4=9
    2660 swap p(2),p(3):p3=p(3)
2670 return
1 '1 Arriba'
    1 'Saltamos y reproducimos un sonido'
    2700 if pa<>1 then po=py:pj=2:pa=1:re=10: gosub 2300:'strig(0)off
2750 return
1 '5 abajo'
    2800 'nada'
2850 return

1 ' ----------------------'
1 '    Collision system'
1 ' ----------------------'
1'chequeando contorno sprite personaje
    1 'Chequeando arriba'
    3100 'Colsion bloque derecha'
    3110 tx=px/8:ty=py/8
    1 'nuestro sprite son 2 sprites de alto'
    1 'Queremos saber el tile que hay en la derecha del sprite,como son de 8px es +2'
    3130 t3=m(tx+mc+2,ty+2)
    3140 if t3>95 then beep:px=px-pv
    1 'Colsión bloque abajo'
    3150 t5=m(tx+mc,ty+4)
    3160 if t5>95 then beep:py=py-pv
3190 return


1 ' ----------------------'
1 '     HUD'
1 ' ----------------------'
    9000 line (0,0)-(80,60),7,bf
    9050 preset (0,0):print #1,"mc: "mc
9090 return






1 'Init player'
    1 'Componente position'
    1 'la posición se define en las pantallas, pw=ancho, ph=alto, pv=velocidad, capturas, etc'
    1 'pj=indica si el salto está activado para desactivar la comprobación del teclado'
    1 'po=player y old'
    1 'pa=player salto activado'
    1 'pj=distancia que recorre cuando el salto está activado'
    10000 px=32:py=18*8:pw=16:ph=16:pv=2:pj=0:po=py:pa=0
    1 'Apartir del 5 sprite es la izquierda'
    1 'p1 tronco superior'
    1 'p2 tronco superior color 2'
    1 'p3 tono inferior'
    1' p4 arma
    10010 dim p(3):p(0)=2:p(1)=3:p(2)=7:p(3)=8:p1=0:p2=1:p3=2:p4=4
    1 'Componente render:'
    10020 pp=0:ps=0
    1 'Componente RPG=player capturas y energía o vida, se define en las pantallas'
    10030 pc=0:pe=100
10040 return



1 'Update player'
1 'pasado al sistema de input'

1 'render player'
    1 'Parte de arriba 1'
    10100 put sprite pp,(px,py),9,p1
    1 'Parte de arriba 2'
    10110 put sprite pp+1,(px,py),10,p2
    1 'Piernas 1'
    10120 put sprite pp+2,(px,py+16),9,p3
    1 'Arma '
    10130 put sprite pp+3,(px,py+8),15,p4
10190 return

1 ' Rutina barra espaciadora pulsada'
    1 'Ponemos un sonido de salto'
    5200 re=10: gosub 2300
    1 'Guardamos la posición vieja de y en po'
    1 'pj=2 distancia en pixeles que se le va a sumar o restar en el input system'
    5210 'po=py:pj=2:strig(0)off
5290 return



1 '-----------------------------------'
1 '-------------MAP-------------------'
1 '-----------------------------------'
1 'Init map'
11000 dim m(100,24):mc=1
11010 return

1 'Cargar mundo con los mapas de los niveles en el buffer o array'
    11100 bload"world0.bin",r
    11110 md=&hd001
    11120 for f=0 to 24-1
        11130 for c=0 to 100-1
            11140 tn=peek(md):md=md+1
            11150 m(c,f)=tn
        11170 next c
    11180 next f
11190 return

1 'Cargar mapa de disco y meterlo en la VRAM
    11400 md=6144: 'Hasta 6912'
    11450 for f=0 to 24-1
        11460 for c=0 to 32-1
            1 'Como los tiles los habíamos cargado previamente en RAM ahora solo los pasamos a VRAM'
            11470 vpoke md,m(c,f)
            11480 md=md+1
        11490 next c
    11500 next f  
11510 return

1 ' desplazar mapa a la izquierda'
    11600 if mc=100-32 then return
    11601 _turbo on(m(),mc)
    11605 md=6144:mc=mc+1
    11610 for f=0 to 24-1
        11620 for c=0 to 32-1
            11630 vpoke md,m(c+mc,f)
            11640 md=md+1
        11650 next c
    11660 next f  
    11665 _turbo off
11670 return