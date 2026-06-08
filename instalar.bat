@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

echo ============================================
echo  INSTALADOR - Sistema de Gestion de Incapacidades
echo  Corporate Solutions
echo ============================================
echo.

rem ============================================================
rem FORZAR RUTAS DE PHP Y COMPOSER EN EL PATH
rem ============================================================
set "PHP_PATH=C:\xampp\php"
set "COMPOSER_PATH=C:\ProgramData\ComposerSetup\bin"
set "PATH=%PHP_PATH%;%COMPOSER_PATH%;%PATH%"

rem ============================================================
rem DETECCION AUTOMATICA DE RUTAS
rem ============================================================

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "BACKEND_PATH=%SCRIPT_DIR%"

rem OPCION 0: Ruta exacta del usuario (hardcodeada)
set "FRONTEND_PATH=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok

rem Opcion 1: Dentro del backend
set "FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok

rem Opcion 2: Al lado del backend
for %%D in ("%SCRIPT_DIR%\..") do set "PARENT_DIR=%%~fD"
set "FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok

rem Si no se encontro, pedir al usuario
echo [ADVERTENCIA] No se encontro el frontend automaticamente.
echo.
echo Pega la ruta COMPLETA de la carpeta que contiene index.html
echo Ejemplo: C:\Users\blanc\...\frontend-incapacidades
echo.
set /p MANUAL_PATH="Ruta: "
set "MANUAL_PATH=%MANUAL_PATH:"=%"
set "FRONTEND_PATH=%MANUAL_PATH%"

if exist "%FRONTEND_PATH%\index.html" goto frontend_ok
if exist "%FRONTEND_PATH%\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades"
    goto frontend_ok
)

echo [ERROR] No se encontro index.html en: %FRONTEND_PATH%
pause
cmd /k

:frontend_ok
echo [OK] Backend: %BACKEND_PATH%
echo [OK] Frontend: %FRONTEND_PATH%
echo.

rem ============================================================
rem VERIFICAR BACKEND
rem ============================================================
if not exist "%BACKEND_PATH%\Backend_ms-auth" (
    echo [ERROR] No se encontro Backend_ms-auth en: %BACKEND_PATH%
    pause
    cmd /k
)
echo [OK] Estructura backend verificada.
echo.

rem ============================================================
rem VERIFICAR PHP
rem ============================================================
echo [0/5] Verificando PHP...
"C:\xampp\php\php.exe" -v >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PHP no encontrado en C:\xampp\php\php.exe
    echo         Instala XAMPP o cambia la ruta en este archivo.
    pause
    cmd /k
)
echo [OK] PHP detectado.
echo.

rem ============================================================
rem VERIFICAR COMPOSER
rem ============================================================
echo [0/5] Verificando Composer...
composer -V >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Composer no encontrado.
    echo         Descarga desde: https://getcomposer.org/download/
    pause
    cmd /k
)
echo [OK] Composer detectado.
echo.

rem ============================================================
rem 1. INSTALAR ms-auth
rem ============================================================
echo [1/5] Instalando ms-auth...
cd /d "%BACKEND_PATH%\Backend_ms-auth\ms-auth"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a Backend_ms-auth\ms-auth
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
composer install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-auth. Revisa tu internet.
    pause
    cmd /k
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_auth>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo [OK] ms-auth listo.
echo.

rem ============================================================
rem 2. INSTALAR ms-empleados
rem ============================================================
echo [2/5] Instalando ms-empleados...
cd /d "%BACKEND_PATH%\Backend_ms-empleados\ms-empleados"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a Backend_ms-empleados\ms-empleados
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
composer install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-empleados.
    pause
    cmd /k
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_empleados>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo [OK] ms-empleados listo.
echo.

rem ============================================================
rem 3. INSTALAR ms-incapacidades
rem ============================================================
echo [3/5] Instalando ms-incapacidades...
cd /d "%BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a Backend_ms-incapacidades\ms-incapacidades
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
composer install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-incapacidades.
    pause
    cmd /k
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_incapacidades>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo MS_EMPLEADOS_URL=http://127.0.0.1:8002>> .env
echo [OK] ms-incapacidades listo.
echo.

rem ============================================================
rem 4. INSTALAR ms-seguimiento
rem ============================================================
echo [4/5] Instalando ms-seguimiento...
cd /d "%BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a Backend_ms-seguimiento\ms-seguimiento
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
composer install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-seguimiento.
    pause
    cmd /k
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_seguimiento>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo MS_INCAPACIDADES_URL=http://127.0.0.1:8003>> .env
echo APP_PORT=8004>> .env
echo [OK] ms-seguimiento listo.
echo.

rem ============================================================
rem 5. CREAR BASE DE DATOS
rem ============================================================
echo [5/5] Creando bases de datos...
cd /d "%BACKEND_PATH%"
mysql -u root -e "source setup.sql" 2>nul
if errorlevel 1 (
    echo [ADVERTENCIA] No se pudo crear la BD automaticamente.
    echo         Abre XAMPP, inicia MySQL e importa setup.sql manualmente.
) else (
    echo [OK] Bases de datos creadas.
)
echo.

rem ============================================================
rem GUARDAR RUTAS PARA INICIAR_SERVIDORES.BAT
rem ============================================================
echo BACKEND_PATH=%BACKEND_PATH%> "%BACKEND_PATH%\.paths.ini"
echo FRONTEND_PATH=%FRONTEND_PATH%>> "%BACKEND_PATH%\.paths.ini"
echo [OK] Rutas guardadas.
echo.

rem ============================================================
rem FIN
rem ============================================================
echo ============================================
echo  INSTALACION COMPLETA!
echo ============================================
echo.
echo Para iniciar los servidores:
echo   Doble clic en INICIAR_SERVIDORES.bat
echo.
echo Accede al sistema: http://127.0.0.1:8080
echo.
echo Credenciales:
echo   admin / admin123
echo   gestionhumana / gh123
echo.
pause
cmd /k