10definta-z
20defusr=&h003B:a=usr(0):defusr1=&h003E:a=usr1(0):defusr2=&H90:a=usr2(0)
20defusr3=&H41:defusr4=&H44
100 print #1, "Cargando mapa en array (en RAM)"
110gosub13000:gosub13100
130gosub10200
520'strig(0)on:onstriggosub10500
530'intervalon:oninterval=500gosub12500:beep
550gosub14000
560gosub13300
570gosub10100
580gosub10000
2000gosub6000
2020gosub8000
2040gosub9000
2050gosub10140
2060'gosub10000
2090goto2000
6000'_turboon(px,py,pv,pa,po,p1,p2,p3,p4,p())'
6010onstick(0)gosub6200,6400,6600,6800,7000,7200,7400,7600
6190return
6200ifpa<>1thenpo=py:pa=1
6290return
6400ifpa<>1thenpo=py:pa=1
6410px=px+pv
6420p1=0:p2=1:p4=4
6430swapp(0),p(1):p3=p(1)
6490return
6600px=px+pv
6620p1=0:p2=1:p4=4
6630swapp(0),p(1):p3=p(1)
6690return
6800'nada'
6890return
7000'nada'
7090return
7200'nada'
7290return
7400px=px-pv
7420p1=5:p2=6:p4=9
7440swapp(2),p(3):p3=p(3)
7490return
7600ifpa<>1thenpo=py:pa=1
7610px=px-pv
7620p1=5:p2=6:p4=9
7630swapp(2),p(3):p3=p(3)
7690return
8000_turboon(mc,px,py,pv,p1,po,tf)
8005'px=px+pv
    8010 if mc>=200-32 then print #1,"FINAL": return
8020ifpx<0thenpx=0
8030ifpy>180thengoto10400
8040ifpx>256-16thenpx=-32:gosub10300:gosub13600:py=18*8:px=0
8050tx=px/8+mc:ty=py/8
8060t3=m(tx+1,ty+3)
8070t5=m(tx,ty+4)
8080t7=m(tx,ty+3)
8090ift3>=tfthenpx=px-pv
8000ift7>=tfthenpx=px+pv
8110ifpa=1andt5>=tfandpl<0thenpa=0:pl=-pl
8120ifpa=1thenpy=py-pl
8130ifpa=1andpy<po-12thenpl=-pl
8140ifpa=1andpy>pothenpy=po:pl=-pl:pa=0
8150ifpa=0andt5<tfthenpy=py+pl
8160_turbooff
8290return
9000_turboon(px,py,pp,ps,en,ex(),ey(),ev(),ec(),ep(),es(),p1,p3,p4)
9005'putspritepp,(px,py),9,p1
9010'putspritepp+1,(px,py),10,p2
9020putspritepp+2,(px,py+16),9,p3
9030'putspritepp+3,(px,py+8),15,p4
9070ex(1)=ex(1)-ev(1):ec(1)=ec(1)+1
9080ifex(1)mod5=0thenev(1)=-ev(1)
9090putspriteep(1),(ex(1),ey(1)),6,es(1)
9980_turbooff
9990return
10000line(0,180)-(256,212),1,bf
10010preset(10,180):print#1,"Muestras:0/Oxigeno:100%"
10020preset(10,190):print#1,"Vidas:10,libre:"fre(0)
10030return
10100wg=8:j=0
10110tf=160
10120return
10140'ifmathen
10150return
10200px=0:py=13*8:pw=16:ph=16:pv=4:pl=4:pj=0:pa=0:dimj(7):po=0
10210j(0)=-8:j(1)=-8:j(2)=-8:j(3)=0:j(4)=8:j(5)=8:j(6)=8
10220t1=0:t3=0:t5=0:t7=0
10230dimp(3):p(0)=2:p(1)=3:p(2)=7:p(3)=8:p1=0:p2=1:p3=2:p4=4
10240pp=0:ps=0:pc=0
10250pe=100
10290return
10300'nada'
10390return
10400py=18*8:px=0
10410'restar1vida'
10490return
10500're=5:gosub4300
10510'po=py:pj=2:strig(0)off
10590return
11000dn=0:dd=0
11060return
12000em=3
12010DIMex(em),ey(em),ev(em),el(em),es(em),ep(em),ec(em),ee(em)
12020en=0
12030return
12500ifen>5thenreturn
12505'en=en+1
12510ex(en)=0:ey(en)=0
12530ev(en)=8:el(en)=8
12540es(en)=11+en*2:ep(en)=4+en:ec(en)=6
12550'ifec(en)<2thengoto11540
12560ee(en)=100
12570en=en+1
12580return
12600ex(ed)=ex(en):ey(ed)=ey(en):ev(ed)=ev(en):el(ed)=el(en):es(ed)=es(en):ep(ed)=ep(en):ec(ed)=ec(en):ee(ed)=ee(en)
12610putspriteep(en),(-16,-16),ec(en),es(en)
12650en=en-1
12660return
12700'nada'
12810return
    13000 print #1, "Pintando mapa"
13010dimm(200,26):mc=0:mu=0
13020return
13100'estoalmacenar??elarrayapartirdelaposici??n8dc8delaRAM'
13110ifmu=0thenbload"world0.bin",r:gosub20000
13120md=&hc001
13130forf=0to23-1
13140forc=0to200-1
13150tn=peek(md):md=md+1
13160m(c,f)=tn
13170nextc
13180nextf
13190return
13300_turboon(m())
13310forf=0to23-1
13360forc=0to32-1
13370tn=m(c,f)
13380iftn>=0andtn<32thencopy(tn*8,0*8)-((tn*8)+8,(0*8)+8),1to(c*8,f*8),0,tpset
13390iftn>=32andtn<64thencopy((tn-32)*8,1*8)-(((tn-32)*8)+8,(1*8)+8),1to(c*8,f*8),0,tpset
13400iftn>=64andtn<96thencopy((tn-64)*8,2*8)-(((tn-64)*8)+8,(2*8)+8),1to(c*8,f*8),0,tpset
13410iftn>=96andtn<128thencopy((tn-96)*8,3*8)-(((tn-96)*8)+8,(3*8)+8),1to(c*8,f*8),0,tpset
13420iftn>=128andtn<160thencopy((tn-128)*8,4*8)-(((tn-128)*8)+8,(4*8)+8),1to(c*8,f*8),0,tpset
13430iftn>=160andtn<192thencopy((tn-160)*8,5*8)-(((tn-160)*8)+8,(5*8)+8),1to(c*8,f*8),0,tpset
13440iftn>=192andtn<224thencopy((tn-192)*8,6*8)-(((tn-192)*8)+8,(6*8)+8),1to(c*8,f*8),0,tpset
13450iftn>=224andtn<256thencopy((tn-224)*8,7*8)-(((tn-224)*8)+8,(7*8)+8),1to(c*8,f*8),0,tpset
13510nextc
13520nextf
13540_turbooff
13570return
13600ifmc=200-32thenreturn
13601_turboon(m(),mc)
13602fori=0to32
13605mc=mc+1
13610copy(8,0)-(256,212),0to(0,0),0,pset
13620forf=3to23-1
13630tn=m(31+mc,f)
13640iftn>=0andtn<32thencopy(tn*8,0*8)-((tn*8)+8,(0*8)+8),1to(31*8,f*8),0
13650iftn>=32andtn<64thencopy((tn-32)*8,1*8)-(((tn-32)*8)+8,(1*8)+8),1to(31*8,f*8),0
13660iftn>=64andtn<96thencopy((tn-64)*8,2*8)-(((tn-64)*8)+8,(2*8)+8),1to(31*8,f*8),0
13670iftn>=96andtn<128thencopy((tn-96)*8,3*8)-(((tn-96)*8)+8,(3*8)+8),1to(31*8,f*8),0
13680iftn>=128andtn<160thencopy((tn-128)*8,4*8)-(((tn-128)*8)+8,(4*8)+8),1to(31*8,f*8),0
13690iftn>=160andtn<192thencopy((tn-160)*8,5*8)-(((tn-160)*8)+8,(5*8)+8),1to(31*8,f*8),0
13700iftn>=192andtn<224thencopy((tn-192)*8,6*8)-(((tn-192)*8)+8,(6*8)+8),1to(31*8,f*8),0
13710iftn>=224andtn<256thencopy((tn-224)*8,7*8)-(((tn-224)*8)+8,(7*8)+8),1to(31*8,f*8),0
13720nextf
13730nexti
13735_turbooff
13736gosub10000
13740return
    14000 cls:preset (10,30):  print #1,"@@@@  @  @@@@  @ @@@@@ @  @   @"
    14010 preset (10,40):      print #1,"@    @ @ @@@@  @   @  @ @ @ @ @"
    14020 preset (10,50):      print #1,"@@@@@   @@     @   @ @   @@  @@"
    14030 preset (10,70):      print #1,"10540,capita Kik, debes ir a recoger las muestras fabricadas en otros entornos planetarios."
    14040 preset (10,110):     print #1,"Pero ten cuidado los esbirros de worst que te obstaculizan."
    14050 preset (10,160): print #1, "Cursores para mover, pulsa una tecla para continuar"
    14060 preset (10,180): print #1, "libre: "fre(0)
14070ifinkey$=""thengoto14070
14090return
20000gosub12500:ex(en-1)=4*8:ey(en-1)=20*8
20030gosub12500:ex(en-1)=26*8:ey(en-1)=20*8
20090return
