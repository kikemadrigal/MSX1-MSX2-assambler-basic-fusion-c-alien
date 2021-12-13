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
    12500 if en>=em then return 
    12505 et(en)=0
    1 'Establecemos las posiciones del enemigo por defecto, después cuando definamos el screen las modificaremos'
    12510 ex(en)=0:ey(en)=0
    1 'Le asignamos la velocidad horizontal y vertical'
    12530 ev(en)=1:el(en)=8
    1 'Los enemigos son a partir del plano 10
    12540 es(en)=9:ep(en)=9+en
    12550 ec(en)=0
    12560 ee(en)=100
    12580 ea(en)=1
    12585 en=en+1
12590 return

1 ' Rutina eliminar enemigo'
    12600 'if en<=0 then return
    12600 'ev(ed)=ev(en-1):el(ed)=el(en-1):es(ed)=es(en-1):ep(ed)=ep(en-1):ec(ed)=ec(en-1):ee(ed)=ee(en-1):et(ed)=et(en-1)
    12601 ea(ed)=0
    12610 ex(ed)=0:ey(ed)=212:put sprite ep(ed),(ex(ed),ey(ed)),,es(ed)
    12650 'en=en-1
12660 return

1 'Rutina eliminar todos los enemigos'
    12700 'en=0
    12705 for i=0 to en-1
        12710 ed=i: gosub 12600
    12720 next i
12790 return

1' Render & update physics enemies
12800 'if en<=0 then return 
    12810 for i=0 to en-1
        12820 if ea(i)=1 then ex(i)=ex(i)-ev(i)  
        1 'Si recorre 20 pasos le cambiamos la velocidad'
        12830 if ex(i) mod 25=0 and et(i)<>2 then ev(i)=-ev(i)
        1 ' Son enemigo 1 el sprite 7 y 8 derecha, 9 y 10 izquierda'
        1 'Si loa velocidad es mayor que 0 es que va andando hacia la derecha, para la animación ponemos un contador (ec(i))'
        12840 ec(i)=ec(i)+1:if ec(i) mod 10=0 then ec(i)=0
        12850 if et(i)=0 and ea(i)=1 then if ev(i)>0 then if ec(i)>4 then es(i)=11 else es(i)=12     
        12860 if et(i)=0 and ea(i)=1 then if ev(i)<=0 then if ec(i)>4 then es(i)=9 else es(i)=10
        12861 if et(i)=1 and ea(i)=1 then if ev(i)>0 then if ec(i)>4 then es(i)=13 else es(i)=14     
        12862 if et(i)=1 and ea(i)=1 then if ev(i)<=0 then if ec(i)>4 then es(i)=15 else es(i)=16  
        12863 if et(i)=2 and ea(i)=1 then if ex(i)<-16 then ex(i)=30*8:ey(i)=rnd(1)*20 else if ec(i)>4 then es(i)=21 else es(i)=22  
        12870 put sprite ep(i),(ex(i),ey(i)),,es(i) 
        1 'Colisión del enemigo con el player'
        12880 if px < ex(i) + 16 and  px + 16 > ex(i) and py < ey(i) + 16 and 16 + py > ey(i) then gosub 10400
        1 'Colision del enemigo con un disparo'
        12890 for w=1 to dn
            1 '15 es el ancho del disparo, 16 es el ancho y el alto del enemigo, 2 es el alto del disparo'
            1 'fx=3:gosub 7400 reproducimos un efecto de sonido'
            12891 if dx(w) < ex(i) + 16 and  dx(w) + 15 > ex(i) and dy(w) < ey(i) + 16 and 2 + dy(w) > ey(i) then ed=i:gosub 12600:dd=w:gosub 11600:fx=6:gosub 7400
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
    1 '12960 if be<=0 then bo=0:line (bx,by)-(bx+bw,bz+bh),14,bf:copy (te*8,0*8)-((te*8)+8,(0*8)+8),2 to (25*8,21*8),0,tpset:put sprite 9,(0,212),,18:vpoke md+(mc-32)+25+(21*mw),te
    12960 if be<=0 then bo=0:line (bx,by)-(bx+bw,bz+bh),14,bf:copy (te*8,0*8)-((te*8)+8,(0*8)+8),2 to (25*8,21*8),0,tpset:put sprite 9,(0,212),,18:vpoke md+(mc-32)+25+(21*mw),te
    1 'Modo debug para que aparezca en el scrren 0 el boss'
    1 '12890 if be<=0 then bo=0:line (bx,by)-(bx+bw,bz+bh),14,bf:m(28,20)=te:copy (te*8,0*8)-((te*8)+8,(0*8)+8),1 to (28*8,21*8),0,tpset:re=2:gosub 7000: put sprite 9,(0,212),,18
    12970 if bo=1 and time/60>8 then time=0:ba=bx:bb=by
    1 'Fijate que el 32 se lo ponemos para que no colisiones el disparo del player con el del
    12980 if bo=1 then ba=ba-8:if ba<1 then put sprite 9,(0,212),,18:ba=0 else put sprite 9,(ba,bb),,18
12999 return
