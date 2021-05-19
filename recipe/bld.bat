@ECHO ON

rem Set the assembler to `nasm`
set AS=%BUILD_PREFIX%\Library\bin\nasm.exe

bash ./configure --enable-pic --enable-shared --prefix=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

make -j%CPU_COUNT%
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1
