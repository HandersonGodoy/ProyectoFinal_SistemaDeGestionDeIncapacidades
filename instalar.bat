@echo off

rem ============================================================
rem TRUCO ANTI-CIERRE: Si se ejecuta con doble clic, reabrir en CMD
rem ============================================================
if "%1"=="reabrir" goto inicio_real

rem Detectar si se ejecuta con doble clic (no hay ventana padre CMD)
echo %cmdcmdline% | find /i "%~nx0" >nul 2>&1
if %errorlevel% equ 0 (
    rem Se ejecuto con doble clic, reabrir en CMD con /k
    cmd /k "%~f0" reabrir
    exit
)

:inicio_real

echo ============================================
echo  INSTALADOR - Sistema de Gestion de Incapacidades
echo  Corporate Solutions
echo ============================================
echo.

rem ============================================================
rem CONFIGURAR PATH
rem ============================================================
set PHP_PATH=C:\xampp\php
set COMPOSER_PATH=C:\ProgramData\ComposerSetup\bin
set PATH=%PHP_PATH%;%COMPOSER_PATH%;%PATH%

rem ============================================================
rem DETECTAR RUTAS
rem ============================================================
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
set BACKEND_PATH=%SCRIPT_DIR%

rem FRONTEND - Ruta exacta hardcodeada
set FRONTEND_PATH=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades
if exist %FRONTEND_PATH%\index.html goto frontend_ok

rem Opcion 1: Dentro del backend
set FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades
if exist %FRONTEND_PATH%\index.html goto frontend_ok

rem Opcion 2: Al lado del backend
for %%D in (%SCRIPT_DIR%\..) do set PARENT_DIR=%%~fD
set FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades
if exist %FRONTEND_PATH%\index.html goto frontend_ok

rem Opcion 3: Buscar en perfil de usuario
set USERPROFILE_PATH=%USERPROFILE%
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend-incapacidades\index.html" 2^>nul') do (
    set FRONTEND_PATH=%%~dpa
    set FRONTEND_PATH=%FRONTEND_PATH:~0,-1%
    goto frontend_ok
)

rem Opcion 4: Buscar carpeta especifica
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" 2^>nul') do (
    set FRONTEND_PATH=%%~dpa
    set FRONTEND_PATH=%FRONTEND_PATH:~0,-1%
    goto frontend_ok
)

rem Si no se encontro, pedir manual
echo.
echo No se encontro el frontend automaticamente.
echo.
echo Escribe la ruta COMPLETA de la carpeta que contiene index.html:
echo.
set /p MANUAL_PATH=Ruta: 
set MANUAL_PATH=%MANUAL_PATH:"=%
set FRONTEND_PATH=%MANUAL_PATH%

if exist %FRONTEND_PATH%\index.html goto frontend_ok
if exist %FRONTEND_PATH%\frontend-incapacidades\index.html set FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades
if exist %FRONTEND_PATH%\index.html goto frontend_ok

echo ERROR: No se encontro index.html.
pause
exit

:frontend_ok
echo OK Backend: %BACKEND_PATH%
echo OK Frontend: %FRONTEND_PATH%
echo.

rem ============================================================
rem VERIFICAR BACKEND
rem ============================================================
echo Verificando backend...
if not exist %BACKEND_PATH%\Backend_ms-auth echo ERROR: No Backend_ms-auth & pause & exit
echo OK Backend verificado.
echo.

rem ============================================================
rem VERIFICAR PHP
rem ============================================================
echo Verificando PHP...
"C:\xampp\php\php.exe" -v >nul 2>&1
if errorlevel 1 (
    echo ERROR: PHP no encontrado.
    echo Instala XAMPP desde https://www.apachefriends.org/
    pause
    exit
)
echo OK PHP detectado.
echo.

rem ============================================================
rem VERIFICAR COMPOSER
rem ============================================================
echo Verificando Composer...
composer -V >nul 2>&1
if errorlevel 1 (
    echo ERROR: Composer no encontrado.
    echo Descarga desde: https://getcomposer.org/download/
    pause
    exit
)
echo OK Composer detectado.
echo.

rem ============================================================
rem INSTALAR MICROSERVICIOS
rem ============================================================
echo ============================================
echo  INSTALANDO MICROSERVICIOS
echo ============================================
echo.
echo NOTA: Cada uno puede tardar 20-30 segundos.
echo NO CIERRES esta ventana.
echo.

echo [1/4] Instalando ms-auth...
cd /d %BACKEND_PATH%\Backend_ms-auth\ms-auth
if errorlevel 1 (
    echo ERROR: No se pudo entrar a ms-auth
    pause
    exit
)
if exist composer.lock del composer.lock >nul 2>&1
echo Ejecutando composer install para ms-auth...
call composer install --no-interaction
if errorlevel 1 (
    echo ERROR: Fallo composer install en ms-auth
    pause
    exit
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_auth>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo OK ms-auth listo.
echo.

echo [2/4] Instalando ms-empleados...
cd /d %BACKEND_PATH%\Backend_ms-empleados\ms-empleados
if errorlevel 1 (
    echo ERROR: No se pudo entrar a ms-empleados
    pause
    exit
)
if exist composer.lock del composer.lock >nul 2>&1
echo Ejecutando composer install para ms-empleados...
call composer install --no-interaction
if errorlevel 1 (
    echo ERROR: Fallo composer install en ms-empleados
    pause
    exit
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_empleados>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo OK ms-empleados listo.
echo.

echo [3/4] Instalando ms-incapacidades...
cd /d %BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades
if errorlevel 1 (
    echo ERROR: No se pudo entrar a ms-incapacidades
    pause
    exit
)
if exist composer.lock del composer.lock >nul 2>&1
echo Ejecutando composer install para ms-incapacidades...
call composer install --no-interaction
if errorlevel 1 (
    echo ERROR: Fallo composer install en ms-incapacidades
    pause
    exit
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_incapacidades>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo MS_EMPLEADOS_URL=http://127.0.0.1:8002>> .env
echo OK ms-incapacidades listo.
echo.

echo [4/4] Instalando ms-seguimiento...
cd /d %BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento
if errorlevel 1 (
    echo ERROR: No se pudo entrar a ms-seguimiento
    pause
    exit
)
if exist composer.lock del composer.lock >nul 2>&1
echo Ejecutando composer install para ms-seguimiento...
call composer install --no-interaction
if errorlevel 1 (
    echo ERROR: Fallo composer install en ms-seguimiento
    pause
    exit
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_seguimiento>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo MS_INCAPACIDADES_URL=http://127.0.0.1:8003>> .env
echo APP_PORT=8004>> .env
echo OK ms-seguimiento listo.
echo.

rem ============================================================
rem CREAR BASE DE DATOS
rem ============================================================
echo Creando bases de datos...
cd /d %BACKEND_PATH%
"C:\xampp\php\php.exe" -r "try { new PDO('mysql:host=localhost;dbname=mysql', 'root', ''); echo 'OK'; } catch (Exception $e) { echo 'ERROR'; }" >nul 2>&1
if errorlevel 1 (
    echo ADVERTENCIA: MySQL no conecta.
    echo Abre XAMPP, inicia MySQL e importa setup.sql manualmente.
) else (
    mysql -u root -e "source setup.sql" 2>nul
    if errorlevel 1 (
        echo ADVERTENCIA: Fallo setup.sql. Importalo manualmente.
    ) else (
        echo OK Bases de datos creadas.
    )
)
echo.

rem ============================================================
rem GUARDAR RUTAS
rem ============================================================
echo Guardando rutas...
echo BACKEND_PATH=%BACKEND_PATH%> %BACKEND_PATH%\.paths.ini
echo FRONTEND_PATH=%FRONTEND_PATH%>> %BACKEND_PATH%\.paths.ini
echo OK Rutas guardadas.
echo.

rem ============================================================
rem FIN
rem ============================================================
echo ============================================
echo  INSTALACION COMPLETA!
echo ============================================
echo.
echo Para iniciar: Doble clic en INICIAR_SERVIDORES.bat
echo Accede: http://127.0.0.1:8080
echo.
echo Credenciales:
echo   admin / admin123
echo   gestionhumana / gh123
echo.
pause