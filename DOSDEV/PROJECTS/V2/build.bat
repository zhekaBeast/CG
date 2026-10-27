tasm gen.asm
if errorlevel 1 goto err
tlink gen.obj
if errorlevel 1 goto err
gen.exe
:err