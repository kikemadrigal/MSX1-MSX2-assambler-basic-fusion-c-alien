sprites_player:
    ; 'Personaje parte superior 1 derecha'
    db 3,7,6,7,1,7,29,57
    db 60,31,7,1,12,14,6,6
    db 192,64,0,0,128,160,160,128
    db 0,0,128,204,0,192,224,224
    ; 'Personaje parte superior 2 derecha'
    db 0,0,1,1,0,0,1,1
    db 0,0,0,0,0,0,0,0
    db 0,192,224,192,0,64,224,240
    db 216,0,3,0,0,0,0,0
    ; 'Personaje piernas 1 derecha'
    db 7,14,14,14,14,28,28,2
    db 30,28,60,56,48,112,120,252
    db 224,112,120,56,56,56,48,56
    db 56,8,56,48,56,24,60,63
    ; 'Personaje piernas 2 derecha'
    db 7,14,15,15,7,7,7,7
    db 7,7,7,95,127,97,51,7
    db 192,112,112,48,176,176,240,224
    db 192,192,128,128,128,128,128,224
    ; 'Arma derecha'
    db 15,112,255,127,31,4,28,16
    db 16,0,0,0,0,0,0,0
    db 128,224,255,247,128,0,0,0
    db 0,0,0,0,0,0,0,0
    ; 'Personaje parte superior 1 izquierda'
    db 3,2,0,0,1,5,5,1
    db 0,0,1,51,0,3,7,7
    db 192,224,96,224,128,224,184,156
    db 60,248,224,128,48,112,96,96
    ; 'Personaje parte superior 2 izquierda'
    db 0,3,7,3,0,2,7,15
    db 27,0,192,0,0,0,0,0
    db 0,0,128,128,0,0,128,128
    db 0,0,0,0,0,0,0,0
    ; 'Personaje piernas 1 izquierda'
    db 7,14,30,28,28,28,12,28
    db 28,16,28,12,28,24,60,252
    db 224,112,112,112,112,56,56,64
    db 120,56,60,28,12,14,30,63
    ; 'Personaje piernas 2 izquierda'
    db 3,14,14,12,13,13,15,7
    db 3,3,1,1,1,1,1,7
    db 224,112,240,240,224,224,224,224
    db 224,224,224,250,254,134,204,224
    ; 'Arma izquierda'
    db 1,7,255,239,1,0,0,0
    db 0,0,0,0,0,0,0,0
    db 240,14,255,254,248,32,56,8
    db 8,0,0,0,0,0,0,0
;posición x, poisición y, patrón, color
posicion_y: db 0
posicion_x: db 0
patron: db 0
color: db 0
anda: db 0


inicializacion_variables_player_sprite:
    ld a,18*8 
    ld (posicion_y),a
    ld a,10 
    ld (posicion_x),a
    ld a, 0
    ld (patron),a
    ld a, 13 ; el 13 es el color rosa
    ld (color),a
    ret

poner_sprites_player_en_VRAM:
    ld hl, sprites_player
    ld de, 14336; #3800
    ld bc, 32*10 
    call  LDIRVM 
    ret

;Update player
poner_sprite_player_atributos_en_VRAM:
    ;atributo 0, el tronco superior
    ld hl, posicion_y ; la rutina LDIRVM necesita haber cargado previamente la dirección de inicio de la RAM, para saber porqué he puesto 0000 fíjate este dibujo https://sites.google.com/site/multivac7/files-images/TMS9918_VRAMmap_G2_300dpi.png ,así es como está formado el VDP en screen 2
    ld de, #1b00; 6912, la rutina necesita haber cargado previamente con de la dirección de inicio de la VRAM          
    ld bc,4; bytes
    call  LDIRVM ; Mira arriba, pone la explicación
    ;--------------sprite 1 tronco superior-----------
    ;Metemos la y
    ld hl,6916;&h#1b04
    ld a,(posicion_y)
    call WRTVRM
    ;Metemos la x
    ld hl,6917
    ld a,(posicion_x)
    call WRTVRM
    ;Metemos el plano
    ld hl,6918
    ld a,4
    call WRTVRM
    ;Metemos el color
    ld hl,6919
    ld a,10
    call WRTVRM
    ;--------------sprite 2 piernas-----------
    ;Metemos la y
    ld hl,#1b08
    ld a,(posicion_y)
    add 16
    call WRTVRM
    ;Metemos la x
    ld hl,#1b09
    ld a,(posicion_x)
    call WRTVRM
    ;Metemos el plano
    ld hl,#1b0a
    ld a,8
    call WRTVRM
    ;Metemos el color
    ld hl,#1b0b
    ld a,13
    call WRTVRM
    ;--------------sprite 3 arma-----------
    ;Metemos la y
    ld hl,#1b0c
    ld a,(posicion_y)
    add 8
    call WRTVRM
    ;Metemos la x
    ld hl,#1b0d
    ld a,(posicion_x)
    call WRTVRM
    ;Metemos el plano
    ld hl,#1b0e
    ld a,16
    call WRTVRM
    ;Metemos el color
    ld hl,#1b0f
    ld a,15
    call WRTVRM

    ret


    ;---------------------CONTROLES----------------------------
mover_player_derecha:
    ld a,(posicion_x); obetenemos el valor actual de la posicion x
    add 1; incrementamos en 1 el valor
    ld (posicion_x), a ; se lo metemos al atributo
    ;ld a, 4 ; maover a la derecha es el patrón 4
    ;ld (patron),a
    ret
mover_player_izquierda:
    ld a,(posicion_x); obetenemos el valor actual de la posicion x
    sub 1 ; incrementamos en 1 el valor
    ld (posicion_x), a ; se lo metemos al atributo posicion x sprite 1
    ;ld a, 12 ; maover a la izquierda es el patrón 12
    ;ld (patron),a
    ret

