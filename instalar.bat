@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

echo ============================================
echo  INSTALADOR - Sistema de Gestion de Incapacidades
echo  Corporate Solutions
echo ============================================
echo.

:: ============================================================
:: BUSCAR PHP EN TODAS LAS RUTAS COMUNES
:: ============================================================
echo [DEBUG] Buscando PHP en tu sistema...
echo.

set "PHP_EXE="

:: Ruta 1: XAMPP estandar
if exist "C:\xampp\php\php.exe" (
    set "PHP_EXE=C:\xampp\php\php.exe"
    echo [OK] PHP encontrado en: C:\xampp\php\php.exe
    goto php_found
)

:: Ruta 2: XAMPP en otra unidad
for %%D in (D E F G H) do (
    if exist "%%D:\xampp\php\php.exe" (
        set "PHP_EXE=%%D:\xampp\php\php.exe"
        echo [OK] PHP encontrado en: %%D:\xampp\php\php.exe
        goto php_found
    )
)

:: Ruta 3: WAMP
if exist "C:\wamp64\bin\php\php.exe" (
    set "PHP_EXE=C:\wamp64\bin\php\php.exe"
    echo [OK] PHP encontrado en: C:\wamp64\bin\php\php.exe
    goto php_found
)

:: Ruta 4: Buscar en PATH
where php >nul 2>&1
if %errorlevel%==0 (
    for /f "delims=" %%a in ('where php') do (
        set "PHP_EXE=%%a"
        echo [OK] PHP encontrado en PATH: %%a
        goto php_found
    )
)

:: Ruta 5: Buscar en disco C
echo [DEBUG] Buscando php.exe en todo C:\ (puede tardar unos segundos)...
for /f "delims=" %%a in ('dir /s /b "C:\php.exe" 2^>nul') do (
    set "PHP_EXE=%%a"
    echo [OK] PHP encontrado en: %%a
    goto php_found
)

:: No se encontro
echo [ERROR] PHP NO ENCONTRADO en ninguna ubicacion comun.
echo.
echo PHP debe estar instalado para continuar.
echo.
echo Rutas buscadas:
echo   - C:\xampp\php\php.exe
echo   - D:\xampp\php\php.exe (y otras unidades)
echo   - C:\wamp64\bin\php\php.exe
echo   - En el PATH de Windows
echo   - C:\php.exe
echo.
echo SOLUCION:
echo 1. Instala XAMPP desde: https://www.apachefriends.org/
echo 2. O si ya lo tienes instalado, dime la ruta exacta donde esta php.exe
echo    (ejemplo: D:\xampp\php\php.exe)
echo.
set /p PHP_MANUAL="Escribe la ruta completa de php.exe: "
set "PHP_MANUAL=%PHP_MANUAL:"=%"
if exist "%PHP_MANUAL%" (
    set "PHP_EXE=%PHP_MANUAL%"
    echo [OK] PHP confirmado en: %PHP_EXE%
    goto php_found
) else (
    echo [ERROR] Esa ruta no existe: %PHP_MANUAL%
    pause
    cmd /k
)

:php_found
echo [OK] Usando PHP: %PHP_EXE%
echo.

:: ============================================================
:: VERIFICAR QUE PHP FUNCIONA
:: ============================================================
echo [DEBUG] Verificando que PHP ejecuta correctamente...
"%PHP_EXE%" -v
if %errorlevel% neq 0 (
    echo [ERROR] PHP existe pero no ejecuta correctamente.
    echo         Puede estar corrupto o bloqueado por antivirus.
    pause
    cmd /k
)
echo [OK] PHP funciona correctamente.
echo.

:: ============================================================
:: BUSCAR COMPOSER
:: ============================================================
echo [DEBUG] Buscando Composer...
set "COMPOSER_CMD="

composer -V >nul 2>&1
if %errorlevel%==0 (
    set "COMPOSER_CMD=composer"
    echo [OK] Composer encontrado en PATH.
    goto composer_found
)

if exist "C:\ProgramData\ComposerSetup\bin\composer.bat" (
    set "COMPOSER_CMD=C:\ProgramData\ComposerSetup\bin\composer.bat"
    echo [OK] Composer encontrado en: C:\ProgramData\ComposerSetup\bin\composer.bat
    goto composer_found
)

if exist "C:\xampp\php\composer.phar" (
    set "COMPOSER_CMD=%PHP_EXE% C:\xampp\php\composer.phar"
    echo [OK] Composer encontrado como phar en XAMPP.
    goto composer_found
)

echo [ERROR] Composer NO ENCONTRADO.
echo         Descarga desde: https://getcomposer.org/download/
pause
cmd /k

:composer_found
echo [OK] Usando Composer: %COMPOSER_CMD%
echo.

:: ============================================================
:: DETECCION DE RUTAS
:: ============================================================
echo [INFO] Detectando rutas automaticamente...
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "BACKEND_PATH=%SCRIPT_DIR%"

:: FRONTEND - Ruta exacta del usuario
set "FRONTEND_PATH=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok

:: Opcion 1: Dentro del backend
set "FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok

:: Opcion 2: Al lado del backend
for %%D in ("%SCRIPT_DIR%\..") do set "PARENT_DIR=%%~fD"
set "FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok

:: Pedir manual
echo [ADVERTENCIA] No se encontro el frontend automaticamente.
echo.
set /p MANUAL_PATH="Pega la ruta de la carpeta con index.html: "
set "MANUAL_PATH=%MANUAL_PATH:"=%"
set "FRONTEND_PATH=%MANUAL_PATH%"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok
if exist "%FRONTEND_PATH%\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades"
    goto frontend_ok
)
echo [ERROR] No se encontro index.html.
pause
cmd /k

:frontend_ok
echo [OK] Backend: %BACKEND_PATH%
echo [OK] Frontend: %FRONTEND_PATH%
echo.

:: ============================================================
:: VERIFICAR BACKEND
:: ============================================================
if not exist "%BACKEND_PATH%\Backend_ms-auth" (
    echo [ERROR] No se encontro Backend_ms-auth en: %BACKEND_PATH%
    pause
    cmd /k
)
echo [OK] Estructura backend verificada.
echo.

:: ============================================================
:: INSTALAR MICROSERVICIOS
:: ============================================================

:: 1. ms-auth
echo [1/5] Instalando ms-auth...
cd /d "%BACKEND_PATH%\Backend_ms-auth\ms-auth"
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo entrar a Backend_ms-auth\ms-auth
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Fallo composer install en ms-auth
    pause
    cmd /k
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_auth>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo [OK] ms-auth listo.
echo.

:: 2. ms-empleados
echo [2/5] Instalando ms-empleados...
cd /d "%BACKEND_PATH%\Backend_ms-empleados\ms-empleados"
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo entrar a Backend_ms-empleados\ms-empleados
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Fallo composer install en ms-empleados
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

:: 3. ms-incapacidades
echo [3/5] Instalando ms-incapacidades...
cd /d "%BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades"
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo entrar a Backend_ms-incapacidades\ms-incapacidades
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Fallo composer install en ms-incapacidades
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

:: 4. ms-seguimiento
echo [4/5] Instalando ms-seguimiento...
cd /d "%BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento"
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo entrar a Backend_ms-seguimiento\ms-seguimiento
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Fallo composer install en ms-seguimiento
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

:: ============================================================
:: BASE DE DATOS
:: ============================================================
echo [5/5] Creando bases de datos...
cd /d "%BACKEND_PATH%"
"%PHP_EXE%" -r "try { new PDO('mysql:host=localhost;dbname=mysql', 'root', ''); echo 'OK'; } catch (Exception $e) { echo 'ERROR'; }" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ADVERTENCIA] MySQL no conecta. Importa setup.sql manualmente en phpMyAdmin.
) else (
    mysql -u root -e "source setup.sql" 2>nul
    if %errorlevel% neq 0 (
        echo [ADVERTENCIA] Fallo setup.sql. Importalo manualmente.
    ) else (
        echo [OK] Bases de datos creadas.
    )
)
echo.

:: ============================================================
:: GUARDAR RUTAS
:: ============================================================
echo BACKEND_PATH=%BACKEND_PATH%> "%BACKEND_PATH%\.paths.ini"
echo FRONTEND_PATH=%FRONTEND_PATH%>> "%BACKEND_PATH%\.paths.ini"
echo [OK] Rutas guardadas.

:: ============================================================
:: FIN
:: ============================================================
echo ============================================
echo  INSTALACION COMPLETA!
echo ============================================
echo.
echo Accede: http://127.0.0.1:8080
echo Credenciales: admin / admin123
echo.
pause
cmd /k