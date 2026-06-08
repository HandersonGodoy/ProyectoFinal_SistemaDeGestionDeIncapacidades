@echo off
chcp 65001 >nul
echo ============================================
echo  INSTALADOR - Sistema de Gestion de Incapacidades
echo  Corporate Solutions
echo ============================================
echo.

:: Verificar que existe PHP
echo [0/5] Verificando PHP...
php -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PHP no encontrado. Instala XAMPP o PHP primero.
    pause
    exit /b 1
)
echo [OK] PHP detectado.
echo.

:: Verificar que existe Composer
echo [0/5] Verificando Composer...
composer -V >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Composer no encontrado. Descarga de https://getcomposer.org/
    pause
    exit /b 1
)
echo [OK] Composer detectado.
echo.

:: Verificar que existe MySQL
echo [0/5] Verificando MySQL...
mysql -V >nul 2>&1
if %errorlevel% neq 0 (
    echo [ADVERTENCIA] MySQL no encontrado en PATH. Asegurate de tener XAMPP corriendo.
)
echo.

:: ============================================================
:: 1. INSTALAR ms-auth
:: ============================================================
echo [1/5] Instalando ms-auth...
cd Backend_ms-auth\ms-auth
if exist composer.lock del composer.lock
composer install --no-interaction

:: Crear .env con contenido
echo DB_HOST=localhost> .env
echo DB_NAME=db_auth>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env

cd ..\..
echo [OK] ms-auth listo.
echo.

:: ============================================================
:: 2. INSTALAR ms-empleados
:: ============================================================
echo [2/5] Instalando ms-empleados...
cd Backend_ms-empleados\ms-empleados
if exist composer.lock del composer.lock
composer install --no-interaction

:: Crear .env con contenido
echo DB_HOST=localhost> .env
echo DB_NAME=db_empleados>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env

cd ..\..
echo [OK] ms-empleados listo.
echo.

:: ============================================================
:: 3. INSTALAR ms-incapacidades
:: ============================================================
echo [3/5] Instalando ms-incapacidades...
cd Backend_ms-incapacidades\ms-incapacidades
if exist composer.lock del composer.lock
composer install --no-interaction

:: Crear .env con contenido
echo DB_HOST=localhost> .env
echo DB_NAME=db_incapacidades>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo MS_EMPLEADOS_URL=http://127.0.0.1:8002>> .env

cd ..\..
echo [OK] ms-incapacidades listo.
echo.

:: ============================================================
:: 4. INSTALAR ms-seguimiento
:: ============================================================
echo [4/5] Instalando ms-seguimiento...
cd Backend_ms-seguimiento\ms-seguimiento
if exist composer.lock del composer.lock
composer install --no-interaction

:: Crear .env con contenido
echo DB_HOST=localhost> .env
echo DB_NAME=db_seguimiento>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo MS_INCAPACIDADES_URL=http://127.0.0.1:8003>> .env
echo APP_PORT=8004>> .env

cd ..\..
echo [OK] ms-seguimiento listo.
echo.

:: ============================================================
:: 5. CREAR BASE DE DATOS
:: ============================================================
echo [5/5] Creando bases de datos...
mysql -u root -e "source setup.sql" 2>nul
if %errorlevel% neq 0 (
    echo [ADVERTENCIA] No se pudo crear la base de datos automaticamente.
    echo         Ejecuta manualmente: mysql -u root ^< setup.sql
) else (
    echo [OK] Bases de datos creadas.
)
echo.

:: ============================================================
:: FIN
:: ============================================================
echo ============================================
echo  INSTALACION COMPLETA!
echo ============================================
echo.
echo Para iniciar los servidores, ejecuta INICIAR_SERVIDORES.bat
echo O abre 5 terminales y ejecuta los comandos del archivo INICIO.txt
echo.
echo Accede al sistema en: http://127.0.0.1:8080
echo.
pause
