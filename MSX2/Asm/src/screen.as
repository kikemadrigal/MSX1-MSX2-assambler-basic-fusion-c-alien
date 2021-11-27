inicializar_pantalla:
    ; Vamos a cambiar los colores
	ld hl,FORCLR ; Forclr es una constante que contiene la dirección de la memoria donde está el color de la tinta
	ld (hl),15 ; le poneos el 1 en tinta que es negra

	inc hl ;incrmeentamos 1 para leer el valor de la constante BAKCLR
	ld (hl),1 ; le metemos 1 en fondo que es el negro

	inc	hl ; Incrementamos en 1 para leer el valor de la constante BDRCLR
	ld	(hl),1 ;en borde también el negro

	call CHGCLR ;Aplicamos los valores establecidos en FORCLR,BAKCLR,BDRCLR

    ;Cambiamos el modo de pantalla
    ld  a,5     ; La rutina CHGMOD nos obliga a poner en el registro a el modo de pantalla que queremos 
    call CHGMOD ; Mira arriba, pone la explicación, pone screen 2 y sprite de 16 sin apliar

    ld a,(RG1SAV) ;en esta dirección está el valor del el 1 registro de soo escritura del VDP, en el se controla el tamaño de los sprites
    or 00000010b ;vamos a obligarle a que trabaje con los sprites de 16 pixeles

    ld b,a 
    ld c,1
    call WRTVDP ;rutina que es escribe el valor en el reistro de solo escritura indicado previamente en c con el valor de a

    ret


cargar_tiles_colores_y_mapa_en_VRAM:
;Tileset
    ;screen1 es el splash_screen o pantalla incial con la foto de presentación
    xor a
    ld hl, #0000 ; la rutina LDIRVM necesita haber cargado previamente la dirección de inicio de la RAM, para saber porqué he puesto 0000 fíjate este dibujo https://sites.google.com/site/multivac7/files-images/TMS9918_VRAMmap_G2_300dpi.png ,así es como está formado el VDP en screen 2
    call SetVdp_Write
    ;La rutina esta rutina SetVdp_Writede graw: http://map.grauw.nl/articles/vdp_tut.php
    ; necesita que en a=la primera parte de la dirección y en hl=la segunda parte
    ; en el caso de &h8000, en a iría 0 y en hl=8000
    xor a
    ld hl, tileset+8
    ld de, tileset-final_tileset
    call mandar_datos    
    ret
mandar_datos:
    ld		a,[hl]							;leemos el dato
    out 	[#98],a							;lo mandamos a VRAM
    inc		hl								;preparate para leer el siguiente dato de la rom
    dec		de								;un byte menos que leer
    ld		a,d
    or		e								;miramos si DE es cero para terminar
    jr.		nz,mandar_datos
    ret
    ;esta rutina necesita que en a=la segunda parte de la dirección y en hl=la primera parte
    ; en el caso de &h8000, en a hiría 0 y en hl=8000
SetVdp_Write:
    rlc h
    rla
    rlc h
    rla
    srl h
    srl h
    di
    out (#99),a
    ld a,14 + 128
    out (#99),a
    ld a,l
    nop
    out (#99),a
    ld a,h
    or 64
    ;ei				;no activamos interrupciones
    out (#99),a
    ret


init_COMMAND_HMMM:
	DW	0,256											;sx,sy
	DW	100,100											;dx,dy	
	DW	28,47											;nx,ny
	DB	0,0,#D0											;HMMM IMP

; Es posible incluir estos datos como archivos binarios
; Si eliges comprimirlos con pletter, tendrás que icluirlo "include "src/PL_VRAM_Depack.asm", crear un buffer "buffer_de_colsiones: ds 768  y poner "call unpack"
tileset:
    incbin "../bin/tileset.bin"
final_tileset:
; color_screen1:
;     incbin "src/screens/screen1/screen1.tileset.clr.plet5"
; map_screen1: 
;     incbin "src/screens/screen1/screen1.tileset.map.plet5"



    















