REM dir="bin"
@setlocal

@if not exist msvcup.exe (
    echo msvcup.exe: installing...
    curl -L -o msvcup.zip https://github.com/marler8997/msvcup/releases/download/v2026_02_24/msvcup-x86_64-windows.zip
    tar xf msvcup.zip
    del msvcup.zip
) else (
    echo msvcup.exe: already installed
)
@if not exist msvcup.exe exit /b 1

set MSVC=msvc-14.44.17.14
set SDK=sdk-10.0.22621.7


msvcup install --lock-file msvcup.lock --manifest-update-off msvc autoenv %MSVC% %SDK%
@if %errorlevel% neq 0 (exit /b %errorlevel%)
