10_TURBOON
20_TURBOOFF
30DEFINTA-Z:DIMP(15):Z=USR(1)
40_TURBOON(P(),Z)
50DIMF$(1)
51DIMdx(4),dy(4),di(4),dv(4),dp(4),ds(4)
55DIMex(3),ey(3),ev(3),el(3),es(3),ep(3),ec(3),ee(3),et(3)
60mc=0:ma=0:ms=0:mu=0:mw=200
70al=0:tf=0:td=0:te=0:tw=0:time=0:t1=0:t3=0:t5=0:t7=0:wc=0
90pg=2:md=&h8000
100px=0:py=18*8:pw=8:ph=16:pv=1:pl=1:pj=0:pa=0:pd=3:pe=5
110p1=0:p2=1:p3=2:p4=3
120pp=0:ps=0
130dm=4:dn=0:dd=0:ds=6:dc=6:dp=0:dw=8:dh=2
140em=3:en=0:es=11
150bo=0:bx=0:bw=24:bh=16:bz=0:bi=0:by=0:be=100:bv=8:bd=3:ba=0:bb=0
160se=0:fx=0
170strig(0)on:onstriggosub10500
180gosub7000
210gosub14000
220remnada
230P(0)=0:P(1)=&h41:Z=USR(58)
240gosub13000
250P(0)=0:P(1)=&h44:Z=USR(58)
400gosub6000
420se=1:gosub7100
1000gosub2000
1020gosub4000
1040gosub5000
1050ifpe<=0thengoto130
1055ifmu=1thenputsprite0,(0,212),,p1:ma=ma+1:ms=ms+1:gosub13000:mu=0:ifma>4thengoto14100
1060'gosub6100
1080fori=0to100:nexti
1090goto1000
2000onstick(0)gosub2200,2400,2600,2800,3000,3200,3400,3600
2190return
2200ifpa=0andt5>=tfthenpo=py:pa=1:pl=1
2210'py=py-4
2290return
2400ifpa<>1thenpo=py:pa=1
2410px=px+pv
2420pd=3
2430ifpxmod8=0thenswapp1,p2
2490return
2600px=px+pv
2610pd=3
2630ifpxmod8=0thenswapp1,p2
2690return
2800'nada'
2890return
3000'py=py+4
3090return
3200'nada'
3290return
3400px=px-pv
3410pd=7
3440ifpxmod8=0thenswapp3,p4
3490return
3600ifpa<>1thenpo=py:pa=1
3610px=px-pv
3620pd=7
3630ifpxmod8=0thenswapp3,p4
3690return
4000'Player'
4010'ifmc>=200thenreturn
4020ifpx>255thenputsprite0,(0,212),,p1:gosub13600:py=18*8:px=0:ms=ms+1:gosub12700:gosub13900:gosub6000
4030ifpx<0thenpx=0
4040ifpy>180thengosub10400
4050ifpd=3thentx=(px)/8+(ms*32)elsetx=(px+8)/8+(ms*32)
4055ty=(py/8)+1:ifpx<=0thentx=0:ifpy<=0thenty=0
4060t0=vpeek(md+tx+((ty)*mw))
4070ift0<26thenvpokemd+tx+(ty*mw),tw:line(px-8,py+8)-(px+8,py+15),14,bf:wc=wc-1:gosub6000:fx=3:gosub7400
4080ift0=tdthengosub10400:fx=1:gosub7400
4090ift0=tethenmu=1
4100t3=vpeek(md+tx+1+((ty)*mw))
4110t5=vpeek(md+tx+((ty+1)*mw))
4120t7=vpeek(md+tx+((ty)*mw))
4130ift3>=tfandpa=0thenpx=px-pvelseift7>=tfandpa=0thenpx=px+pv
4150ifpa=1andt5>=tfandpl<0thenpa=0:pl=-pl
4160ifpa=1thenpy=py-pl
4170ifpa=1andpy<po-20thenpl=-2:'pl=-pl
4180ifpa=1andpy>pothenpy=po:pl=-pl:pa=0
4190ifpa=0andt5<tfthenpy=py+pl
4290return
5000ifbo=1thengosub12950
5010ifpd=3orpd=1orpd=2thenputsprite0,(px,py),,p1
5020ifpd=7thenputsprite0,(px,py),,p3
5100gosub11700
5110gosub12800
5990return
6000line(0,184)-(256,212),1,bf
    6010 preset (10,186):F$(0)="Capturas que faltan: "+str$(wc): Z=USR(60)
    6020 preset (10,194):F$(0)="Level: "+str$(mu)+"-"+str$(ms)+" vidas: "+str$(pe): Z=USR(60)
    6025 preset (10,200):P(0)=0:F$(0)="Libre: "+str$(P(1)*P(3)*512): Z=USR(60): Z=USR(45)
    6030 if bo=1 then preset (10,202):F$(0)="Energia boss: "+str$(be): Z=USR(60)
6090return
6100preset(0,30):F$(0)="mc"+str$(mc)+"mu"+str$(mu):Z=USR(60)
6190return
7000F$(0)="UWOL_P.z80":E=USR(31)
7010f=P(0):P(2)=5:P(3)=0:P(4)=5737:P(6)=0:E=USR(33)
7020P(0)=f:E=USR(32)
7030P(0)=5:P(1)=&H8000:E=USR(59)
7040P(0)=1:P(1)=5:P(2)=&H8006:E=USR(66)
7090return
7100P(0)=5:P(1)=&H8003:P(2)=mu*256:E=USR(59)
7190return
7200P(0)=5:P(1)=&H8009:E=USR(59)
7290return
7300P(0)=5:E=USR(77)
7390return
7400P(0)=5:P(1)=&H800C:P(3)=fx*256:E=USR(59)
7490return
10400ba=0:bb=240:putsprite9,(ba,bb),,18
10405py=18*8:px=0:putsprite0,(px,py),,p1
10410pe=pe-1
10415pa=0:ifpl<=0thenpl=-pl
10420gosub6000
10490return
10500gosub11500
10510fx=2:gosub7400
10590return
11500ifdn>=dmthenreturnelsedn=dn+1
11510dx(dn)=px+8:dy(dn)=py+8
11520di(dn)=pd
11530dv(dn)=8
11540dp(dn)=dn
11550ds(dn)=ds
11580return
11600ifdn<=0thenreturn
11605dx(dd)=dx(dn):dy(dd)=dy(dn)
11610putspritedp(dd),(0,212),,ds(dd)
11620dp(dd)=dn-1
11650dn=dn-1
11690return
11700ifdn<=0thenreturn
11710fori=1todn
11715dx=dx(i)/8+(ms*32):dy=(dy(i)/8)
11716d0=vpeek(md+dx+((dy)*mw))
11717'ifd0>=tfthendd=i:gosub11600
11720ifdi(i)=1ordi(i)=2ordi(i)=3thendx(i)=dx(i)+dv(i)elsedx(i)=dx(i)-dv(i)
11730putspritedp(i),(dx(i),dy(i)),dc,ds(i)
11740ifdx(i)<0ordx(i)>256-16thendd=i:gosub11600
11742ifbo=1thenifdx(i)<bx+bwanddx(i)+dw>bxanddy(i)<by+bhanddy(i)+dh>bythenbe=be-10:dd=i:gosub11600:beep:gosub6000
11750nexti
11790return
12500ifen>=emthenreturnelseen=en+1
12510ex(en)=0:ey(en)=0
12530ev(en)=1:el(en)=8
12540es(en)=0:ep(en)=9+en
12550ec(en)=0
12560ee(en)=100
12570et(en)=0
12590return
12600ifen<=0thenreturn
12600ex(ed)=ex(en):ey(ed)=ey(en):ev(ed)=ev(en):el(ed)=el(en):es(ed)=es(en):ep(ed)=ep(en):ec(ed)=ec(en):ee(ed)=ee(en)
12610putspriteep(ed),(0,212),,es(ed)
12650en=en-1
12660return
12700en=0
12790return
12800ifen<=0thenreturn
12810fori=1toen
12820ex(i)=ex(i)+ev(i)
12830ifex(i)mod25=0thenev(i)=-ev(i)
12840ec(i)=ec(i)+1
12850ifet(i)=0thenifev(i)>0thenifec(i)mod4=0thenes(i)=7:ec(i)=0elsees(i)=8
12860ifet(i)=0thenifev(i)<=0thenifec(i)mod4=0thenes(i)=9:ec(i)=0elsees(i)=10
12861ifet(i)=1thenifev(i)>0thenifec(i)mod4=0thenes(i)=11:ec(i)=0elsees(i)=12
12862ifet(i)=1thenifev(i)<=0thenifec(i)mod4=0thenes(i)=13:ec(i)=0elsees(i)=14
12870putspriteep(i),(ex(i),ey(i)),,es(i)
12880ifpx<ex(i)+16andpx+16>ex(i)andpy<ey(i)+16and16+py>ey(i)thengosub10400
12890forw=1todn
12891ifdx(w)<ex(i)+16anddx(w)+15>ex(i)anddy(w)<ey(i)+16and2+dy(w)>ey(i)thened=i:gosub12600:dd=w:gosub11600::fx=6:gosub7400
12892nextw
12895nexti
12899return
12950bi=bx:bz=by:by=by-bv
12955ifbn=0thenline(bx,bz)-(bx+bw,bz+bh),14,bf:copy(48,64)-(64,80),2to(bx,by),0,tpset:ifby<100orby>154thenbv=-bv
12960ifbe<=0thenbo=0:line(bx,by)-(bx+bw,bz+bh),14,bf:copy(te*8,0*8)-((te*8)+8,(0*8)+8),2to(30*8,21*8),0,tpset:putsprite9,(0,212),,18:vpokemd+29+(21*mw),te
12970ifbo=1andtime/60>8thentime=0:ba=bx:bb=by
12980ifbo=1thenba=ba-8:ifba<1thenputsprite9,(0,212),,18:ba=0elseputsprite9,(ba,bb),,18
12999return
13000ifma=0thenF$(0)="tilemap0.bin":Z=USR(31):P(2)=0:P(3)=&H8000:P(4)=&h4000:Z=USR(34):Z=USR(32):gosub20000:gosub13900
13010ifma=1thenF$(0)="tilemap1.bin":Z=USR(31):P(2)=0:P(3)=&H8000:P(4)=&h4000:Z=USR(34):Z=USR(32):gosub21000
13020ifma=2thenF$(0)="tilemap2.bin":Z=USR(31):P(2)=0:P(3)=&H8000:P(4)=&h4000:Z=USR(34):Z=USR(32):gosub22000
13195gosub13600
13199return
13600ifmc>200thenreturn
13603fori=0to31
13610copy(8,0)-(256,184),0to(0,0),0,pset
13620forf=0to23-1
13630tn=vpeek(md+mc+f*mw):tn=tn+2
13640iftn>=0andtn<32thencopy(tn*8,0*8)-((tn*8)+8,(0*8)+8),pgto(31*8,f*8),0
13650iftn>=32andtn<64thencopy((tn-32)*8,1*8)-(((tn-32)*8)+8,(1*8)+8),pgto(31*8,f*8),0
13660iftn>=64andtn<96thencopy((tn-64)*8,2*8)-(((tn-64)*8)+8,(2*8)+8),pgto(31*8,f*8),0
13670iftn>=96andtn<128thencopy((tn-96)*8,3*8)-(((tn-96)*8)+8,(3*8)+8),pgto(31*8,f*8),0
13680iftn>=128andtn<160thencopy((tn-128)*8,4*8)-(((tn-128)*8)+8,(4*8)+8),pgto(31*8,f*8),0
13690iftn>=160andtn<192thencopy((tn-160)*8,5*8)-(((tn-160)*8)+8,(5*8)+8),pgto(31*8,f*8),0
13700iftn>=192andtn<224thencopy((tn-192)*8,6*8)-(((tn-192)*8)+8,(6*8)+8),pgto(31*8,f*8),0
13710iftn>=224andtn<256thencopy((tn-224)*8,7*8)-(((tn-224)*8)+8,(7*8)+8),pgto(31*8,f*8),0
13720nextf
13725mc=mc+1
13730nexti
13740return
13900ifms=0thengosub20100
13901ifms=1thengosub20200
13910ifms=2thengosub20300
13920ifms=3thengosub20400
13930ifms=4thengosub20500
13940ifms=5thengosub20600
13990return
14000se=1:gosub7100
    14005 cls:preset (10,30):  F$(0)="@@@@  @  @@@@  @ @@@@@ @  @   @": Z=USR(60)
    14010 preset (10,40):      F$(0)="@    @ @ @@@@  @   @  @ @ @ @ @": Z=USR(60)
    14020 preset (10,50):      F$(0)="@@@@@   @@     @   @ @   @@  @@": Z=USR(60)
    14030 preset (10,70):      F$(0)="10540,capita Kik, debes ir a recoger las muestras fabricadas en otros entornos planetarios.": Z=USR(60)
    14040 preset (10,110):     F$(0)="Pero ten cuidado los esbirros de worst que te obstaculizan.": Z=USR(60)
    14050 preset (10,160): F$(0)= "Cursores para mover, pulsa una tecla para continuar": Z=USR(60)
14070ifinkey$=""thengoto14070
14080gosub7200
14090goto220
14100cls:preset(10,70):F$(0)="Felicidades"+str$(ma):Z=USR(60)
    14110 preset (10,80):      F$(0)="Has completado la mision": Z=USR(60)
    14120 preset (10,90):      F$(0)="Lgica:Kikemadrigal": Z=USR(60)
    14130 preset (10,100):      F$(0)="gráficos:Kikemadrigal": Z=USR(60)
14140ifinkey$=""thengoto14040
14190goto150
20000tf=160:te=26:tw=80:td=42
20010wc=6
20090return
20100gosub12500:ex(en)=26*8:ey(en)=20*8:et(en)=0
20110gosub12500:ex(en)=12*8:ey(en)=18*8:et(en)=1
20190return
20200gosub12500:ex(en)=(17*8):ey(en)=17*8
20290return
20300gosub12500:ex(en)=20*8:ey(en)=20*8
20390return
20400gosub12500:ex(en)=16*8:ey(en)=10*8
20490return
20500gosub12500:ex(en)=26*8:ey(en)=20*8
20590return
20600gosub12800:bo=1:bn=0:be=100:bx=150:by=120:gosub6000
20690return
21000tf=160:te=26:tw=80
21010wc=6:wf=0
21090return
22000tf=160:te=26:tw=80
22010wc=6:wf=0
22090return
23000_TURBOOFF
