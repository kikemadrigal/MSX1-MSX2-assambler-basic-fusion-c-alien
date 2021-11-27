
1 IF P(0)=0 THEN PRINT"ERROR: Este ordenador no tiene al menos 128K de RAM mapeada.":PRINT:END
2 IF P(0)=1 THEN PRINT"ERROR: Error de disco al cargar NestorBASIC.":PRINT:END
3 IF P(0)=2 THEN PRINT"ERROR: No hay al menos un segmento libre en el mapeador primario.":PRINT:END
4 IF P(0)=4 THEN PRINT"ERROR 4, que en teoria no existe... avisa a Konami Man!!":PRINT:END
5 IF P(0)=3 THEN PRINT"NestorBASIC ya estaba instalado.":P(0)=2:E=USR(73) ELSE PRINT"NestorBASIC ha sido instalado."
6 E=USR(1):IF P(0)<7 THEN PRINT:PRINT"No hay memoria suficiente para cargar la musica !!":PRINT
7 IF P(0)<8 THEN PRINT"ATENCION: Solo pueden cargarse ficheros de musica menores de 16K!"

1 ' color letra negro, fondo letra: azul claro, borde blanco, quitamos las letras que aparecen abajo'
30 color 15,1,1:key off
40 screen 5,2,0
50 DEFINT A-Z:DIM P(15): Z=USR(1)
60 bload"loader.sc5",s
1 'Cargamos los sprites'
85 gosub 10000
100 _TURBO ON(P(),Z)
1 'Tenemos que definir esta variable para los archivos
1 'nextorbasic nos obliga a defnir los arrays en la primera línea del turbo bloque'
110 DIM F$(1)
120 F$(0)="RAM disponible:"+str$(P(0)*16)+"K.": E=USR(60)
1 'ponemos la pantalla de carga'
1 'Esto almacenará a partir en la page 0 o la direción 0 de la VRAM'
1 '140 F$(0)="loader.sc5": Z=USR(31): P(2)=0: P(3)=0: P(4)=&h8000: Z=USR(34): Z=USR(32)
1 'SCREEN 4'
1 '140 F$(0)="tiles.chr": Z=USR(31): P(2)=0: P(3)=0: P(4)=2048*3: Z=USR(34): Z=USR(32)
1 '150 F$(0)="tiles.clr": Z=USR(31): P(2)=0: P(3)=8192: P(4)=2048*3: Z=USR(34): Z=USR(32)
1 ' SCREEN 5, ponemos el tileset el la page 1 de la VRAM &h8000 o 32768Kb'
1 '140 F$(0)="TILESET.SC5": Z=USR(31): P(2)=0: P(3)=&H8000: P(4)=&h4000: Z=USR(34): Z=USR(32)
1 'Esto almacenará a partir en la page 2 o la direción &h10000 o  65536Kb'
130 preset(0,10):F$(0)="Loading tileset": E=USR(60)
150 F$(0)="TILESET.SC5": Z=USR(31): P(2)=1: P(3)=1: P(4)=16536: Z=USR(34): E=USR(32)

170 preset(0,20):F$(0)="Loading basic file": E=USR(60)
180 _TURBO OFF
540 load"game.bas",r
1 '550 goto 550






1 '---------------------------------------------------------'
1 '------------------------Carga de srites------------------'
1 '---------------------------------------------------------'


1 ' Patrones:'
1 'Plano 0. Player--sprites del 1 al 7'
1 'Rutina cargar sprites con datas basic'
    10000 RESTORE
    1 ' vamos a meter 5 definiciones de sprites nuevos que serán 4 para el personaje y uno para la bola'
    10010 FOR I=0 TO 18:SP$=""
        10020 FOR J=1 TO 32:READ A$
            10025 SP$=SP$+CHR$(VAL(A$))
        10030 NEXT J
        10040 SPRITE$(I)=SP$
    10050 NEXT I
   
    10055 for sp=0 to 18
        10060 a$=""
        10065 for i=0 to (16)-1
            10070 read a
            10075 'vpoke &h7400+i, a
            10080 a$=a$+chr$(a)
        10085 next i
        10090 color sprite$(sp)=a$
    10095 next sp
10100 return 





10120 REM alien
10130 REM SPRITE DATA
10140 DATA 124,248,248,248,124,48,112,248
10150 DATA 187,188,144,248,120,72,200,236
10160 DATA 0,0,0,0,0,0,0,0
10170 DATA 0,0,0,0,0,0,0,0
10180 DATA 124,248,248,248,124,48,112,248
10190 DATA 187,188,144,240,240,96,224,240
10200 DATA 0,0,0,0,0,0,0,0
10210 DATA 0,0,0,0,0,0,0,0
10220 DATA 62,31,31,31,62,12,14,31
10230 DATA 221,61,9,31,30,18,19,55
10240 DATA 0,0,0,0,0,0,0,0
10250 DATA 0,0,0,0,0,0,0,0
10260 DATA 62,31,31,31,62,12,14,31
10270 DATA 221,61,9,15,15,6,7,15
10280 DATA 0,0,0,0,0,0,0,0
10290 DATA 0,0,0,0,0,0,0,0
10300 DATA 15,14,14,15,0,26,16,36
10310 DATA 104,112,112,240,160,192,224,0
10320 DATA 0,0,0,0,0,0,0,0
10330 DATA 0,0,0,0,0,0,0,0
10340 DATA 240,112,112,240,0,88,8,36
10350 DATA 22,14,14,15,5,3,7,0
10360 DATA 0,0,0,0,0,0,0,0
10370 DATA 0,0,0,0,0,0,0,0
10380 DATA 224,224,0,0,0,0,0,0
10390 DATA 0,0,0,0,0,0,0,0
10400 DATA 0,0,0,0,0,0,0,0
10410 DATA 0,0,0,0,0,0,0,0
10420 DATA 3,1,1,1,1,1,1,3
10430 DATA 3,1,1,1,3,3,3,3
10440 DATA 224,128,128,224,192,192,224,240
10450 DATA 240,240,216,232,240,48,24,28
10460 DATA 3,1,1,1,1,1,1,3
10470 DATA 3,6,6,12,12,12,12,12
10480 DATA 224,128,128,224,192,192,224,248
10490 DATA 248,216,248,96,112,24,24,24
10500 DATA 7,1,1,7,3,3,7,15
10510 DATA 15,15,27,23,15,12,24,56
10520 DATA 192,128,128,128,128,128,128,192
10530 DATA 192,128,128,128,192,192,192,192
10540 DATA 7,1,1,7,3,3,7,31
10550 DATA 31,27,31,6,14,24,24,24
10560 DATA 192,128,128,128,128,128,128,192
10570 DATA 192,96,96,48,48,48,48,48
10580 DATA 1,1,1,1,1,1,1,1
10590 DATA 31,18,10,5,5,0,0,0
10600 DATA 240,240,240,240,240,128,128,128
10610 DATA 248,72,68,98,16,0,0,0
10620 DATA 1,1,1,1,1,1,1,1
10630 DATA 31,18,38,72,1,0,0,0
10640 DATA 240,240,240,240,240,128,128,128
10650 DATA 248,72,80,128,0,0,0,0
10660 DATA 15,15,15,15,15,1,1,1
10670 DATA 31,18,34,70,8,0,0,0
10680 DATA 128,128,128,128,128,128,128,128
10690 DATA 248,72,80,160,160,0,0,0
10700 DATA 15,15,15,15,15,1,1,1
10710 DATA 31,18,10,1,0,0,0,0
10720 DATA 128,128,128,128,128,128,128,128
10730 DATA 248,72,100,18,128,0,0,0
10740 DATA 3,7,14,28,56,112,224,255
10750 DATA 255,3,7,14,28,56,112,224
10760 DATA 0,0,0,0,0,0,0,0
10770 DATA 0,0,0,0,0,0,0,0
10780 DATA 48,120,52,54,251,121,123,126
10790 DATA 248,120,120,120,120,120,48,48
10800 DATA 0,0,0,0,0,0,0,0
10810 DATA 0,0,0,0,0,0,0,0
10820 DATA 195,195,255,255,255,255,126,126
10830 DATA 126,126,126,255,255,255,255,129
10840 DATA 0,0,0,0,0,0,0,0
10850 DATA 0,0,0,0,0,0,0,0
10860 DATA 28,28,56,121,113,227,227,195
10870 DATA 195,195,195,227,97,48,60,60
10880 DATA 0,0,96,192,140,8,24,16
10890 DATA 16,16,152,140,192,192,96,0

10900 REM COLOR MODE2 DATA
10910 DATA 7,7,7,7,7,14,4,4
10920 DATA 4,4,4,4,4,6,6,6
10930 DATA 7,7,7,7,7,14,4,4
10940 DATA 4,4,4,4,4,6,6,6
10950 DATA 7,7,7,7,7,14,4,4
10960 DATA 4,4,4,4,4,6,6,6
10970 DATA 7,7,7,7,7,14,4,4
10980 DATA 4,4,4,4,4,6,6,6
10990 DATA 7,7,7,7,4,4,4,4
11000 DATA 4,4,6,6,6,6,8,6
11010 DATA 7,7,7,7,4,4,4,4
11020 DATA 4,4,6,6,6,6,8,6
11030 DATA 8,8,15,15,15,15,15,15
11040 DATA 15,15,15,15,15,15,15,15
11050 DATA 8,8,8,8,8,8,8,8
11060 DATA 8,10,10,10,10,10,10,10
11070 DATA 8,8,8,8,8,8,8,8
11080 DATA 8,10,10,10,10,10,10,10
11090 DATA 8,8,8,8,8,8,8,8
11100 DATA 8,10,10,10,10,10,10,10
11110 DATA 8,8,8,8,8,8,8,8
11120 DATA 8,10,10,10,10,10,10,10
11130 DATA 8,8,7,7,8,8,8,8
11140 DATA 10,10,10,10,15,15,15,15
11150 DATA 8,8,7,7,8,8,8,8
11160 DATA 10,10,10,10,15,15,15,15
11170 DATA 8,8,7,7,8,8,8,8
11180 DATA 10,10,10,10,15,15,15,15
11190 DATA 8,8,7,7,8,8,8,8
11200 DATA 10,10,10,10,15,15,15,15
11210 DATA 10,10,10,10,10,10,10,10
11220 DATA 10,10,10,10,10,10,10,10
11230 DATA 9,9,9,8,8,8,8,8
11240 DATA 8,8,8,8,8,8,9,9
11250 DATA 10,10,13,13,13,13,13,13
11260 DATA 13,13,13,13,13,13,13,13
11270 DATA 6,6,6,6,6,6,6,6
11280 DATA 6,6,6,6,6,6,6,6
















1 '1 'Cargar mundo con los mapas de los niveles en el buffer o array'
1 '    11100 bload"world0.bin",r
1 '    11110 md=&hd001
1 '    11120 for f=0 to 24-1
1 '        11130 for c=0 to 100-1
1 '            11140 tn=peek(md):md=md+1
1 '            11150 m(c,f)=tn
1 '        11170 next c
1 '    11180 next f
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
