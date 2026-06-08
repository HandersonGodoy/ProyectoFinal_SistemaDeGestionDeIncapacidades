@echo off
chcp 65001 >nul
echo ============================================
echo  INICIANDO SERVIDORES - Corporate Solutions
echo ============================================
echo.

:: ============================================================
:: FORZAR RUTAS DE PHP Y COMPOSER EN EL PATH
:: ============================================================
set "PHP_PATH=C:\xampp\php"
set "COMPOSER_PATH=C:\ProgramData\ComposerSetup\bin"
set "PATH=%PHP_PATH%;%COMPOSER_PATH%;%PATH%"

:: ============================================================
:: DETECCION AUTOMATICA DE RUTAS
:: ============================================================

:: Obtener la ruta donde esta este archivo .bat
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: La carpeta backend es donde esta este .bat
set "BACKEND_PATH=%SCRIPT_DIR%"

:: Intentar leer rutas guardadas por Instalar.bat
set "FRONTEND_PATH="
if exist "%BACKEND_PATH%\.paths.ini" (
    for /f "tokens=1,* delims==" %%a in ('type "%BACKEND_PATH%\.paths.ini"') do (
        if "%%a"=="FRONTEND_PATH" set "FRONTEND_PATH=%%b"
    )
)

:: Verificar que la ruta guardada sigue siendo valida
if not "%FRONTEND_PATH%"=="" (
    if not exist "%FRONTEND_PATH%\index.html" (
        set "FRONTEND_PATH="
    )
)

:: Si no hay .paths.ini o la ruta guardada es invalida, buscar el frontend
if "%FRONTEND_PATH%"=="" (
    :: OPCION 0: Ruta exacta del usuario (TU RUTA)
    if exist "C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades\index.html" (
        set "FRONTEND_PATH=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
        goto :frontend_found
    )

    :: Opcion 1: Frontend en la misma carpeta
    if exist "%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades\index.html" (
        set "FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades"
        goto :frontend_found
    )

    :: Opcion 2: Frontend al lado (mismo nivel)
    for %%D in ("%SCRIPT_DIR%\..") do set "PARENT_DIR=%%~fD"
    if exist "%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades\index.html" (
        set "FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
        goto :frontend_found
    )

    :: Opcion 3: Buscar en todo el perfil de usuario
    set "USERPROFILE_PATH=%USERPROFILE%"
    for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend-incapacidades\index.html" 2^>nul') do (
        set "FRONTEND_PATH=%%~dpa"
        set "FRONTEND_PATH=%FRONTEND_PATH:~0,-1%"
        goto :frontend_found
    )

    :: Opcion 4: Buscar por nombre de carpeta
    for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" 2^>nul') do (
        set "FRONTEND_PATH=%%~dpa"
        set "FRONTEND_PATH=%FRONTEND_PATH:~0,-1%"
        goto :frontend_found
    )

    :: Si no se encontro, pedir al usuario
    echo [ADVERTENCIA] No se pudo encontrar el frontend automaticamente.
    echo.
    set /p MANUAL_PATH="Arrastra la carpeta frontend-incapacidades aqui y presiona Enter: "
    set "FRONTEND_PATH=%MANUAL_PATH%"

    :: Si la carpeta arrastrada no tiene index.html, revisar si tiene subcarpeta frontend-incapacidades
    if not exist "%FRONTEND_PATH%\index.html" (
        if exist "%FRONTEND_PATH%\frontend-incapacidades\index.html" (
            set "FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades"
            goto :frontend_found
        )
        if exist "%FRONTEND_PATH%\frontend-incapacidades\frontend-incapacidades\index.html" (
            set "FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades\frontend-incapacidades"
            goto :frontend_found
        )
        echo [ERROR] Esa carpeta no contiene index.html
        pause
        exit /b 1
    )
)

:frontend_found
echo [INFO] Backend: %BACKEND_PATH%
echo [INFO] Frontend: %FRONTEND_PATH%
echo.

:: Verificar que existe el backend
if not exist "%BACKEND_PATH%\Backend_ms-auth" (
    echo [ERROR] No se encontro la estructura del backend.
    echo         Este archivo debe estar en la carpeta raiz del proyecto.
    pause
    exit /b 1
)

echo Se abriran 5 ventanas de comandos:
echo   - 4 microservicios backend (puertos 8001-8004)
echo   - 1 servidor frontend (puerto 8080)
echo.
echo Espera 3 segundos entre cada una...
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
echo Credenciales de prueba:
echo   Admin:          admin / admin123
echo   Gestion Humana: gestionhumana / gh123
echo   Inactivo:       inactivo / inactivo123  (no puede entrar)
echo.
echo Para detener todos los servidores, cierra las 5 ventanas.
echo.
pause
