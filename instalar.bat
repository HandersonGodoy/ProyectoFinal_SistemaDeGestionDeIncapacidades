@echo off

rem ============================================================
rem TRUCO ANTI-CIERRE: Si se ejecuta con doble clic, reabrir en CMD
rem ============================================================
if "%1"=="reabrir" goto inicio_real

echo %cmdcmdline% | find /i "%~nx0" >nul 2>&1
if %errorlevel% equ 0 (
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
rem DETECTAR PHP AUTOMATICAMENTE
rem ============================================================
echo Detectando PHP...

set PHP_EXE=

rem Opcion 1: XAMPP en C:
if exist C:\xampp\php\php.exe (
    set PHP_EXE=C:\xampp\php\php.exe
    set PHP_PATH=C:\xampp\php
    echo OK PHP encontrado en C:\xampp\php
    goto php_ok
)

rem Opcion 2: XAMPP en D:
if exist D:\xampp\php\php.exe (
    set PHP_EXE=D:\xampp\php\php.exe
    set PHP_PATH=D:\xampp\php
    echo OK PHP encontrado en D:\xampp\php
    goto php_ok
)

rem Opcion 3: XAMPP en E:
if exist E:\xampp\php\php.exe (
    set PHP_EXE=E:\xampp\php\php.exe
    set PHP_PATH=E:\xampp\php
    echo OK PHP encontrado en E:\xampp\php
    goto php_ok
)

rem Opcion 4: WAMP
if exist C:\wamp64\bin\php\php.exe (
    set PHP_EXE=C:\wamp64\bin\php\php.exe
    set PHP_PATH=C:\wamp64\bin\php
    echo OK PHP encontrado en WAMP
    goto php_ok
)

rem Opcion 5: Buscar en PATH
for /f "delims=" %%a in ('where php 2^>nul') do (
    set PHP_EXE=%%a
    set PHP_PATH=%%~dpa
    set PHP_PATH=%PHP_PATH:~0,-1%
    echo OK PHP encontrado en PATH: %%a
    goto php_ok
)

echo ERROR: PHP no encontrado.
echo Instala XAMPP desde https://www.apachefriends.org/
pause
exit

:php_ok
echo.

rem ============================================================
rem DETECTAR MySQL (hermano de PHP en XAMPP)
rem ============================================================
echo Detectando MySQL...
set MYSQL_BIN=%PHP_PATH%\..\mysql\bin
if exist "%MYSQL_BIN%\mysql.exe" (
    set PATH=%MYSQL_BIN%;%PATH%
    echo OK MySQL encontrado en %MYSQL_BIN%
) else (
    for /f "delims=" %%a in ('where mysql 2^>nul') do (
        set MYSQL_BIN=%%~dpa
        set PATH=%MYSQL_BIN%;%PATH%
        echo OK MySQL encontrado en PATH
        goto mysql_ok
    )
    echo ADVERTENCIA: No se encontro mysql.exe. Buscando en ejecucion...
)
:mysql_ok
echo.

rem ============================================================
rem DETECTAR COMPOSER AUTOMATICAMENTE
rem ============================================================
echo Detectando Composer...

set COMPOSER_CMD=

rem Opcion 1: Composer en PATH (comando directo)
for /f "delims=" %%a in ('where composer 2^>nul') do (
    set COMPOSER_CMD=composer
    echo OK Composer encontrado en PATH
    goto composer_ok
)

rem Opcion 2: Composer en ProgramData
if exist C:\ProgramData\ComposerSetup\bin\composer.bat (
    set COMPOSER_CMD=C:\ProgramData\ComposerSetup\bin\composer.bat
    echo OK Composer encontrado en C:\ProgramData\ComposerSetup\bin
    goto composer_ok
)

rem Opcion 3: Composer en XAMPP (php + composer.phar)
if exist %PHP_PATH%\composer.phar (
    set COMPOSER_CMD=%PHP_EXE% %PHP_PATH%\composer.phar
    echo OK Composer encontrado como phar en XAMPP
    goto composer_ok
)

rem Opcion 4: Composer en carpeta composer junto a XAMPP
if exist C:\xampp\composer\composer.bat (
    set COMPOSER_CMD=C:\xampp\composer\composer.bat
    echo OK Composer encontrado en C:\xampp\composer
    goto composer_ok
)

rem Opcion 5: Composer en Program Files
if exist C:\Program Files\Composer\bin\composer.bat (
    set COMPOSER_CMD=C:\Program Files\Composer\bin\composer.bat
    echo OK Composer encontrado en Program Files
    goto composer_ok
)

rem Opcion 6: Composer en AppData (instalacion por usuario)
if exist %LOCALAPPDATA%\Composer\composer.bat (
    set COMPOSER_CMD=%LOCALAPPDATA%\Composer\composer.bat
    echo OK Composer encontrado en AppData
    goto composer_ok
)

if exist %APPDATA%\Composer\vendor\bin\composer.bat (
    set COMPOSER_CMD=%APPDATA%\Composer\vendor\bin\composer.bat
    echo OK Composer encontrado en AppData\vendor
    goto composer_ok
)

echo ERROR: Composer no encontrado.
echo Descarga desde: https://getcomposer.org/download/
pause
exit

:composer_ok
echo Usando Composer: %COMPOSER_CMD%
echo.

rem ============================================================
rem CONFIGURAR PATH CON PHP Y COMPOSER
rem ============================================================
set PATH=%PHP_PATH%;%PATH%

rem ============================================================
rem DETECTAR RUTAS DEL PROYECTO
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
call %COMPOSER_CMD% install --no-interaction
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
call %COMPOSER_CMD% install --no-interaction
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
call %COMPOSER_CMD% install --no-interaction
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
call %COMPOSER_CMD% install --no-interaction
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
rem CREAR BASE DE DATOS  (CORREGIDO)
rem ============================================================
echo Creando bases de datos...
cd /d %BACKEND_PATH%

rem Verificar que setup.sql existe
if not exist "%BACKEND_PATH%\setup.sql" (
    echo ERROR: No se encontro setup.sql en %BACKEND_PATH%
    pause
    exit
)

rem Verificar conexion a MySQL (PDO con exit code real)
%PHP_EXE% -r "try { new PDO('mysql:host=localhost;dbname=mysql', 'root', ''); exit(0); } catch (Exception $e) { exit(1); }" >nul 2>&1
if errorlevel 1 (
    echo ADVERTENCIA: MySQL no conecta.
    echo Abre XAMPP, inicia MySQL e importa setup.sql manualmente.
    pause
    exit
)

rem Ejecutar setup.sql (ahora mysql.exe SI esta en PATH)
mysql -u root -e "source %BACKEND_PATH%\setup.sql"
if errorlevel 1 (
    echo ADVERTENCIA: Fallo setup.sql. Importalo manualmente.
    pause
    exit
) else (
    echo OK Bases de datos creadas.
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