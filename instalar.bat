@echo off

echo ============================================
echo  INSTALADOR - Sistema de Gestion de Incapacidades
echo  Corporate Solutions
echo ============================================
echo.

set PHP_PATH=C:\xampp\php
set COMPOSER_PATH=C:\ProgramData\ComposerSetup\bin
set PATH=%PHP_PATH%;%COMPOSER_PATH%;%PATH%

set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
set BACKEND_PATH=%SCRIPT_DIR%

set FRONTEND_PATH=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades
if exist %FRONTEND_PATH%\index.html goto frontend_ok

set FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades
if exist %FRONTEND_PATH%\index.html goto frontend_ok

for %%D in (%SCRIPT_DIR%\..) do set PARENT_DIR=%%~fD
set FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades
if exist %FRONTEND_PATH%\index.html goto frontend_ok

echo No se encontro frontend automaticamente.
echo Escribe la ruta COMPLETA de la carpeta con index.html:
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

echo Verificando backend...
if not exist %BACKEND_PATH%\Backend_ms-auth echo ERROR: No Backend_ms-auth & pause & exit
echo OK Backend verificado.
echo.

echo Verificando PHP...
"C:\xampp\php\php.exe" -v >nul 2>&1
if errorlevel 1 echo ERROR: PHP no encontrado & pause & exit
echo OK PHP detectado.
echo.

echo Verificando Composer...
composer -V >nul 2>&1
if errorlevel 1 echo ERROR: Composer no encontrado & pause & exit
echo OK Composer detectado.
echo.

echo ============================================
echo  INSTALANDO MICROSERVICIOS
echo ============================================
echo.
echo NOTA: Cada uno puede tardar 20-30 segundos.
echo NO CIERRES esta ventana.
echo.

echo [1/4] Instalando ms-auth...
cd /d %BACKEND_PATH%\Backend_ms-auth\ms-auth
if errorlevel 1 echo ERROR: No se pudo entrar & pause & exit
if exist composer.lock del composer.lock >nul 2>&1
echo Ejecutando composer install para ms-auth...
call composer install --no-interaction
if errorlevel 1 echo ERROR: Fallo ms-auth & pause & exit
echo DB_HOST=localhost> .env
echo DB_NAME=db_auth>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo OK ms-auth listo.
echo.

echo [2/4] Instalando ms-empleados...
cd /d %BACKEND_PATH%\Backend_ms-empleados\ms-empleados
if errorlevel 1 echo ERROR: No se pudo entrar & pause & exit
if exist composer.lock del composer.lock >nul 2>&1
echo Ejecutando composer install para ms-empleados...
call composer install --no-interaction
if errorlevel 1 echo ERROR: Fallo ms-empleados & pause & exit
echo DB_HOST=localhost> .env
echo DB_NAME=db_empleados>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo OK ms-empleados listo.
echo.

echo [3/4] Instalando ms-incapacidades...
cd /d %BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades
if errorlevel 1 echo ERROR: No se pudo entrar & pause & exit
if exist composer.lock del composer.lock >nul 2>&1
echo Ejecutando composer install para ms-incapacidades...
call composer install --no-interaction
if errorlevel 1 echo ERROR: Fallo ms-incapacidades & pause & exit
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
if errorlevel 1 echo ERROR: No se pudo entrar & pause & exit
if exist composer.lock del composer.lock >nul 2>&1
echo Ejecutando composer install para ms-seguimiento...
call composer install --no-interaction
if errorlevel 1 echo ERROR: Fallo ms-seguimiento & pause & exit
echo DB_HOST=localhost> .env
echo DB_NAME=db_seguimiento>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo MS_INCAPACIDADES_URL=http://127.0.0.1:8003>> .env
echo APP_PORT=8004>> .env
echo OK ms-seguimiento listo.
echo.

echo Creando bases de datos...
cd /d %BACKEND_PATH%
"C:\xampp\php\php.exe" -r "try { new PDO('mysql:host=localhost;dbname=mysql', 'root', ''); echo 'OK'; } catch (Exception $e) { echo 'ERROR'; }" >nul 2>&1
if errorlevel 1 (
    echo ADVERTENCIA: MySQL no conecta.
    echo Importa setup.sql manualmente en phpMyAdmin.
) else (
    mysql -u root -e "source setup.sql" 2>nul
    if errorlevel 1 (
        echo ADVERTENCIA: Fallo setup.sql. Importalo manualmente.
    ) else (
        echo OK Bases de datos creadas.
    )
)
echo.

echo Guardando rutas...
echo BACKEND_PATH=%BACKEND_PATH%> %BACKEND_PATH%\.paths.ini
echo FRONTEND_PATH=%FRONTEND_PATH%>> %BACKEND_PATH%\.paths.ini
echo OK Rutas guardadas.
echo.

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