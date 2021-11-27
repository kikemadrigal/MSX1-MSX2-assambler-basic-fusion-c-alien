@echo off
rem variables globales
Set nombrePrograma=main

rem Copiamos todos los archivos a la carpeta objects para trabajar con ellos
for /R src %%a in (*.*) do (
    copy /Y "%%a" obj & echo %%a)

rem http://www.xl2s.tk/sjasmman3.html
rem Compilando..
start /wait tools\sjasm\sjasm.exe -s obj\main.as
move /Y main.bin obj
rem el archivo .bin generado por sjasm


rem Creando el .dsk, para ver los comandos abrir archivo DISKMGR.chm
start /wait tools\Disk-Manager\DISKMGR.exe -A -F -C disco.dsk obj\autoexec.BAS
start /wait tools\Disk-Manager\DISKMGR.exe -A -F -C disco.dsk obj\main.bin
rem start /wait tools\Disk-Manager\DISKMGR.exe -A -F -C disco.dsk bin\tileset.bin
rem start /wait tools\Disk-Manager\DISKMGR.exe -A -F -C disco.dsk bin\tilesetcolor.bin
rem start /wait tools\Disk-Manager\DISKMGR.exe -A -F -C disco.dsk bin\tilesetmap.bin
rem abrimos nuestro emulador preferido
rem copy %TARGET_DSK% tools\emulators\BlueMSX
rem start /wait tools/emulators/BlueMSX/blueMSX.exe -diska %TARGET_DSK%
rem start /wait emulators/fMSX/fMSX.exe -diska %TARGET_DSK%


rem MSX 1
rem start /wait tools/emulators/openmsx/openmsx.exe  -ext Sony_HBD-50 -ext ram32k -diska %TARGET_DSK% 
rem start /wait tools/emulators/openmsx/openmsx.exe -script tools/emulators/openmsx/emul_start_config.txt
rem MSX2
start /wait tools/emulators/openmsx/openmsx.exe -machine Philips_NMS_8255 -diska disco.dsk
rem MSX2+
rem start /wait tools/emulators/openmsx/openmsx.exe -machine Sony_HB-F1XV -diska %TARGET_DSK%