@echo off
set TARGET_DSK=disco.dsk

rem sjasm (http://www.xl2s.tk/) es un compilador de ensamblador z80 que puedo convertir tu código ensamblador en los archivos binarios.rom y .bin
rem necesitamos el .bin de la pantalla de carga y del reproductor de música

rem start /wait tools/sjasm/sjasm.exe src/world0.asm
rem move /y world0.bin .\bin
rem start /wait tools/sjasm/sjasm.exe src/world1.asm
rem move /y world1.bin .\bin
rem start /wait tools/sjasm/sjasm.exe src/world2.asm
rem move /y world2.bin .\bin
rem start /wait java -jar tools/csv2bin/CSVFenris.jar assets/tilemap0.csv obj/world0.bin
start /wait tools/sjasm/sjasm.exe src/music.asm
move /Y music.bin ./bin
move /Y src\music.lst ./bin

java -jar tools/csv2bin/CSVFenris.jar assets/tilemap0.csv bin/tilemap0.bin
java -jar tools/csv2bin/CSVFenris.jar assets/tilemap1.csv bin/tilemap1.bin
java -jar tools/csv2bin/CSVFenris.jar assets/tilemap2.csv bin/tilemap2.bin


rem Copiando los archivos.bas de la carpeta src
rem los pegamos en objects y mostramos un mensajito
copy src\autoexec.bas dsk
copy src\loader.bas dsk
rem Copiando todos los archivos.bin de la carpeta bin
rem los pegamos en objects y mostramos un mensajito
for /R bin %%a in (*.*) do (
    copy "%%a" dsk & echo %%a)


rem Le quitamos los comentarios a game.bas
java -jar tools\deletecomments\deletecomments1.4.jar src\main.bas dsk\game.bas  

rem Lo tokenizamos
rem start /wait tools/tokenizer/msxbatoken.py obj/game.asc obj/game.bas 

rem copiamos los bin 
rem move assets\*.bin obj


rem             if exist %TARGET_DSK% del /f /Q %TARGET_DSK%
rem             copy tools\Disk-Manager\main.dsk .\%TARGET_DSK%
rem añadimos todos los .bas de la carpeta obj al disco
rem por favor mirar for /?
rem for /R obj/ %%a in (*.bas) do (
rem             start /wait tools/Disk-Manager/DISKMGR.exe -A -F -C %TARGET_DSK% "%%a")  
rem             start /wait tools/Disk-Manager/DISKMGR.exe -A -F -C %TARGET_DSK% obj/autoexec.bas  
rem             start /wait tools/Disk-Manager/DISKMGR.exe -A -F -C %TARGET_DSK% obj/loader.bas  
rem             start /wait tools/Disk-Manager/DISKMGR.exe -A -F -C %TARGET_DSK% obj/game.bas 

rem añadimos todos los arhivos binarios de la carpeta bin al disco
rem recuerda que un sc2, sc5, sc8 es también un archivo binario, renombralo
rem por favor mirar for /?
rem                for /R bin/ %%a in (*.*) do (
rem                     start /wait tools/Disk-Manager/DISKMGR.exe -A -F -C %TARGET_DSK% "%%a")   

rem abrimos nuestro emulador preferido
rem copy %TARGET_DSK% tools\emulators\BlueMSX
rem start /wait tools/emulators/BlueMSX/blueMSX.exe -diska %TARGET_DSK%
rem start /wait emulators/fMSX/fMSX.exe -diska %TARGET_DSK%


rem MSX 1
rem start /wait tools/emulators/openmsx/openmsx.exe  -ext Sony_HBD-50 -ext ram32k -diska %TARGET_DSK% 
rem start /wait tools/emulators/openmsx/openmsx.exe -script tools/emulators/openmsx/emul_start_config.txt
rem MSX2
rem                 start /wait tools/emulators/openmsx/openmsx.exe -machine Philips_NMS_8255 -diska %TARGET_DSK%
rem start /wait tools/emulators/openmsx/openmsx.exe -machine Philips_NMS_8255 -diska ./obj
rem start /wait tools/emulators/openmsx/openmsx.exe -machine Panasonic_FS-A1ST -diska ./obj
start tools\emulators\openmsx\openmsx.exe -script tools\emulators\openmsx\emul_start_config.txt
rem MSX2+
rem start /wait tools/emulators/openmsx/openmsx.exe -machine Sony_HB-F1XV -diska %TARGET_DSK%