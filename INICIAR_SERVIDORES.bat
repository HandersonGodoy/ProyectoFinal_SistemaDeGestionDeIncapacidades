@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

echo ============================================
echo  INICIANDO SERVIDORES - Corporate Solutions
echo ============================================
echo.

:: ============================================================
:: FORZAR RUTAS DE PHP
:: ============================================================
echo [DEBUG] Configurando PATH...
set "PHP_PATH=C:\xampp\php"
set "COMPOSER_PATH=C:\ProgramData\ComposerSetup\bin"
set "PATH=%PHP_PATH%;%COMPOSER_PATH%;%PATH%"
echo [DEBUG] PATH listo.

:: ============================================================
:: OBTENER RUTA DEL SCRIPT
:: ============================================================
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
echo [DEBUG] Script en: %SCRIPT_DIR%

set "BACKEND_PATH=%SCRIPT_DIR%"
echo [DEBUG] Backend: %BACKEND_PATH%

:: ============================================================
:: DETECTAR FRONTEND - RUTA EXACTA PRIMERO
:: ============================================================
echo [DEBUG] Buscando frontend...
set "FRONTEND_PATH="

:: RUTA EXACTA DEL USUARIO (hardcodeada para que funcione siempre)
set "RUTA_KNOWN=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
echo [DEBUG] Verificando ruta conocida: %RUTA_KNOWN%
if exist "%RUTA_KNOWN%\index.html" (
    echo [DEBUG] ENCONTRADO en ruta conocida!
    set "FRONTEND_PATH=%RUTA_KNOWN%"
    goto frontend_ok
)

:: Leer .paths.ini si existe
echo [DEBUG] Buscando .paths.ini...
if exist "%BACKEND_PATH%\.paths.ini" (
    echo [DEBUG] Leyendo .paths.ini...
    for /f "usebackq tokens=1,* delims==" %%a in ("%BACKEND_PATH%\.paths.ini") do (
        if "%%a"=="FRONTEND_PATH" (
            set "FRONTEND_PATH=%%b"
            echo [DEBUG] Leido de .paths.ini: %%b
        )
    )
)

:: Verificar si la ruta leida sigue siendo valida
if not "%FRONTEND_PATH%"=="" (
    if exist "%FRONTEND_PATH%\index.html" (
        echo [DEBUG] Ruta de .paths.ini valida.
        goto frontend_ok
    ) else (
        echo [DEBUG] Ruta de .paths.ini ya no existe.
        set "FRONTEND_PATH="
    )
)

:: Buscar automaticamente
echo [DEBUG] Buscando automaticamente...

:: Opcion 1: Dentro del backend
if exist "%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades"
    goto frontend_ok
)

:: Opcion 2: Al lado del backend
for %%D in ("%SCRIPT_DIR%\..") do set "PARENT_DIR=%%~fD"
if exist "%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
    goto frontend_ok
)

:: Opcion 3: Buscar en perfil de usuario
set "USERPROFILE_PATH=%USERPROFILE%"
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend-incapacidades\index.html" 2^>nul') do (
    set "FRONTEND_PATH=%%~dpa"
    set "FRONTEND_PATH=!FRONTEND_PATH:~0,-1!"
    goto frontend_ok
)

:: Opcion 4: Buscar por nombre de carpeta
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" 2^>nul') do (
    set "FRONTEND_PATH=%%~dpa"
    set "FRONTEND_PATH=!FRONTEND_PATH:~0,-1!"
    goto frontend_ok
)

:: Si no se encontro, pedir manual
echo.
echo [ADVERTENCIA] No se encontro el frontend automaticamente.
echo.
echo INSTRUCCIONES:
echo 1. Abre el Explorador de archivos
echo 2. Ve a tu carpeta frontend
echo 3. Entra hasta la carpeta que contiene "index.html"
echo    (debe ser: ...\frontend-incapacidades)
echo 4. Copia la ruta completa de la barra de direcciones
echo 5. Pegala aqui y presiona Enter
echo.
echo Ejemplo correcto:
echo C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades
echo.
set /p MANUAL_PATH="Pega la ruta completa aqui: "

:: LIMPIAR COMILLAS (Windows agrega comillas al copiar desde la barra de direcciones)
set "MANUAL_PATH=%MANUAL_PATH:"=%"
echo [DEBUG] Ruta ingresada: %MANUAL_PATH%

set "FRONTEND_PATH=%MANUAL_PATH%"

:: Verificar directamente
echo [DEBUG] Verificando: %FRONTEND_PATH%\index.html
if exist "%FRONTEND_PATH%\index.html" (
    echo [DEBUG] index.html encontrado directamente!
    goto frontend_ok
)

:: Si no, verificar si es carpeta padre
if exist "%FRONTEND_PATH%\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades"
    echo [DEBUG] Corregido a subcarpeta frontend-incapacidades
    goto frontend_ok
)

if exist "%FRONTEND_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%FRONTEND_PATH%\frontend_incapacidades\frontend-incapacidades"
    echo [DEBUG] Corregido a doble subcarpeta
    goto frontend_ok
)

echo.
echo [ERROR] No se encontro index.html en ninguna ubicacion.
echo.
echo Ruta final que se verifico: %FRONTEND_PATH%
echo.
echo Asegurate de pegar la ruta de la carpeta que CONTIENE index.html.
echo No la carpeta padre, sino la carpeta donde esta el archivo.
echo.
echo Si tu estructura es:
echo   ...\frontend_incapacidades\frontend-incapacidades\index.html
echo.
echo Debes pegar la ruta completa hasta:
echo   ...\frontend_incapacidades\frontend-incapacidades
echo.
pause
exit /b 1

:frontend_ok
echo [OK] Backend: %BACKEND_PATH%
echo [OK] Frontend: %FRONTEND_PATH%
echo.

:: Verificar backend
echo [DEBUG] Verificando backend...
if not exist "%BACKEND_PATH%\Backend_ms-auth" (
    echo [ERROR] No se encontro la estructura del backend.
    echo         Este .bat debe estar en la carpeta raiz del proyecto.
    pause
    exit /b 1
)

echo [DEBUG] Todo verificado. Iniciando servidores...
echo.
echo Se abriran 5 ventanas:
echo   - 4 microservicios (puertos 8001-8004)
echo   - 1 frontend (puerto 8080)
echo.
timeout /t 2 /nobreak >nul

:: Terminal 1: ms-auth (puerto 8001)
echo [1/5] Iniciando ms-auth en puerto 8001...
start "MS-AUTH :8001" cmd /k "set PATH=C:\xampp\php;C:\ProgramData\ComposerSetup\bin;%PATH% && cd /d %BACKEND_PATH%\Backend_ms-auth\ms-auth && php -S 127.0.0.1:8001 -t public"
timeout /t 3 /nobreak >nul

:: Terminal 2: ms-empleados (puerto 8002)
echo [2/5] Iniciando ms-empleados en puerto 8002...
start "MS-EMPLEADOS :8002" cmd /k "set PATH=C:\xampp\php;C:\ProgramData\ComposerSetup\bin;%PATH% && cd /d %BACKEND_PATH%\Backend_ms-empleados\ms-empleados && php -S 127.0.0.1:8002 -t public"
timeout /t 3 /nobreak >nul

:: Terminal 3: ms-incapacidades (puerto 8003)
echo [3/5] Iniciando ms-incapacidades en puerto 8003...
start "MS-INCAPACIDADES :8003" cmd /k "set PATH=C:\xampp\php;C:\ProgramData\ComposerSetup\bin;%PATH% && cd /d %BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades && php -S 127.0.0.1:8003 -t public"
timeout /t 3 /nobreak >nul

:: Terminal 4: ms-seguimiento (puerto 8004)
echo [4/5] Iniciando ms-seguimiento en puerto 8004...
start "MS-SEGUIMIENTO :8004" cmd /k "set PATH=C:\xampp\php;C:\ProgramData\ComposerSetup\bin;%PATH% && cd /d %BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento && php -S 127.0.0.1:8004 -t public"
timeout /t 3 /nobreak >nul

:: Terminal 5: frontend (puerto 8080)
echo [5/5] Iniciando frontend en puerto 8080...
start "FRONTEND :8080" cmd /k "set PATH=C:\xampp\php;C:\ProgramData\ComposerSetup\bin;%PATH% && cd /d %FRONTEND_PATH% && php -S 127.0.0.1:8080"

timeout /t 2 /nobreak >nul
echo.
echo ============================================
echo  TODOS LOS SERVIDORES INICIADOS!
echo ============================================
echo.
echo Accede al sistema: http://127.0.0.1:8080
echo.
echo Credenciales:
echo   Admin:          admin / admin123
echo   Gestion Humana: gestionhumana / gh123
echo.
echo Para detener, cierra las 5 ventanas.
echo.
pause