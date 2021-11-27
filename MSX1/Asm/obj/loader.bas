1 ' MSX 1
1 'Inicilizamos dispositivo: 003B, inicilizamos teclado: 003E'
10 defusr=&h003B:a=usr(0):defusr1=&h003E:a=usr1(0):defusr2=&H90:a=usr2(0)
20 defusr3=&H41:defusr4=&H44
1 ' color letra negro, fondo letra: azul claro, borde blanco, quitamos las letras que aparecen abajo'
30 color 1,15,15:key off:defint a-z
40 screen 2,2,0
50 open "grp:" as #1
60 'print #1,"Loading xbasic"
70 bload"xbasic.bin",r
80 'print #1,"Loading sprites"
1 'Cargamos los sprites'
90 gosub 10000
120 'print #1,"Cargando tilset"
125 a=usr3(0)
130 bload"tileset.bin",s
1 '160 a=usr4(0)
500 'print #1,"Loading game"
510 load"game.bas",r
1 '520 goto 520



1 '---------------------------------------------------------'
1 '------------------------Carga de srites------------------'
1 '---------------------------------------------------------'


1 ' Patrones:'
1 'Plano 0. Player--sprites del 1 al 7'
1 'Rutina cargar sprites con datas basic'
    10000 RESTORE
    1 ' vamos a meter 5 definiciones de sprites nuevos que serán 4 para el personaje y uno para la bola'
    10010 FOR I=0 TO 9:SP$=""
        10020 FOR J=1 TO 32:READ A$
            10025 SP$=SP$+CHR$(VAL(A$))
        10030 NEXT J
        10040 SPRITE$(I)=SP$
    10050 NEXT I
    10060 return 





    1 'Personaje parte superior 1 derecha'
    10120 DATA 3,7,6,7,1,7,29,57
    10130 DATA 60,31,7,1,12,14,6,6
    10140 DATA 192,64,0,0,128,160,160,128
    10150 DATA 0,0,128,204,0,192,224,224
    1 'Personaje parte superior 2 derecha'
    10160 DATA 0,0,1,1,0,0,1,1
    10170 DATA 0,0,0,0,0,0,0,0
    10180 DATA 0,192,224,192,0,64,224,240
    10190 DATA 216,0,3,0,0,0,0,0
     1 'Personaje piernas 1 derecha'
    10200 DATA 7,14,14,14,14,28,28,2
    10210 DATA 30,28,60,56,48,112,120,252
    10220 DATA 224,112,120,56,56,56,48,56
    10230 DATA 56,8,56,48,56,24,60,63
    1 'Personaje piernas 2 derecha'
    10240 DATA 7,14,15,15,7,7,7,7
    10250 DATA 7,7,7,95,127,97,51,7
    10260 DATA 192,112,112,48,176,176,240,224
    10270 DATA 192,192,128,128,128,128,128,224
    1 'Arma derecha'
    10280 DATA 15,112,255,127,31,4,28,16
    10290 DATA 16,0,0,0,0,0,0,0
    10300 DATA 128,224,255,247,128,0,0,0
    10310 DATA 0,0,0,0,0,0,0,0

    1 'Personaje parte superior 1 izquierda'
    10320 DATA 3,2,0,0,1,5,5,1
    10330 DATA 0,0,1,51,0,3,7,7
    10340 DATA 192,224,96,224,128,224,184,156
    10350 DATA 60,248,224,128,48,112,96,96
    1 'Personaje parte superior 2 izquierda'
    10360 DATA 0,3,7,3,0,2,7,15
    10370 DATA 27,0,192,0,0,0,0,0
    10380 DATA 0,0,128,128,0,0,128,128
    10390 DATA 0,0,0,0,0,0,0,0
    1 'Personaje piernas 1 izquierda'
    10400 DATA 7,14,30,28,28,28,12,28
    10410 DATA 28,16,28,12,28,24,60,252
    10420 DATA 224,112,112,112,112,56,56,64
    10430 DATA 120,56,60,28,12,14,30,63
    1 'Personaje piernas 2 izquierda'
    10440 DATA 3,14,14,12,13,13,15,7
    10450 DATA 3,3,1,1,1,1,1,7
    10460 DATA 224,112,240,240,224,224,224,224
    10470 DATA 224,224,224,250,254,134,204,224
    1 'Arma izquierda'
    10480 DATA 1,7,255,239,1,0,0,0
    10490 DATA 0,0,0,0,0,0,0,0
    10500 DATA 240,14,255,254,248,32,56,8
    10510 DATA 8,0,0,0,0,0,0,0
10900 return



1 '1 'Cargar mundo con los mapas de los niveles en el buffer o array'
1 '    11100 bload"world0.bin",r
1 '    11101 dim m(100,24)
1 '    11105 _turbo on (m())
1 '    11110 md=&hd001
1 '    11120 for f=0 to 24-1
1 '        11130 for c=0 to 100-1
1 '            11140 tn=peek(md):md=md+1
1 '            11150 m(c,f)=tn
1 '        11170 next c
1 '    11180 next f
1 '    11185 _turbo off
1 '11190 return



1 '1 'Cargar mapa de disco y meterlo en la VRAM
1 '    11400 'md=&hd001
1 '    11410 md=6144: 'Hasta 6912'
1 '    11450 for f=0 to 24-1
1 '        11460 for c=0 to 32-1
1 '            1 'Como los tiles los habíamos cargado previamente en RAM ahora solo los pasamos a VRAM'
1 '            11470 vpoke md,m(c,f)
1 '            11480 md=md+1
1 '        11490 next c
1 '    11500 next f  
1 '11510 return
