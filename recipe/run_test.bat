@echo on
cl /nologo /MD /DX264_API_IMPORTS /I"%LIBRARY_INC%" example.c /Fex264-example.exe /link /LIBPATH:"%LIBRARY_LIB%" libx264.lib
if errorlevel 1 exit /b 1
cl /nologo /MD test_windows.c /Fetest-windows.exe
if errorlevel 1 exit /b 1
test-windows.exe prepare "%LIBRARY_BIN%\libx264-164.dll" "%LIBRARY_BIN%\x264.exe" x264-example.exe test-windows.exe
if errorlevel 1 exit /b 1
x264-example.exe 32x32 < input.yuv > api.h264
if errorlevel 1 exit /b 1
x264 --demuxer raw --input-res 32x32 --input-csp i420 --fps 24 --frames 8 --threads 1 --output cli.h264 input.yuv
if errorlevel 1 exit /b 1
test-windows.exe verify api.h264 cli.h264
if errorlevel 1 exit /b 1
