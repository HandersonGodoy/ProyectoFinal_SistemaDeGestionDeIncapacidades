@echo off
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

echo [INFO] Detectando rutas automaticamente...
echo.

rem Obtener la ruta donde esta este archivo .bat (sin barra final)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo [INFO] Este archivo esta en: %SCRIPT_DIR%
echo.

rem La carpeta backend es donde esta este .bat
set "BACKEND_PATH=%SCRIPT_DIR%"

rem Buscar la carpeta del frontend
set "FRONTEND_PATH="

rem OPCION 0: Ruta exacta del usuario (TU RUTA)
if exist "C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
    goto frontend_found
)

rem Opcion 1: Frontend esta en la misma carpeta que el backend
if exist "%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades"
    goto frontend_found
)

rem Opcion 2: Frontend esta al lado del backend (mismo nivel)
for %%D in ("%SCRIPT_DIR%\..") do set "PARENT_DIR=%%~fD"
if exist "%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
    goto frontend_found
)

rem Opcion 3: Buscar en toda la carpeta del usuario
set "USERPROFILE_PATH=%USERPROFILE%"
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend-incapacidades\index.html" 2^>nul') do (
    set "FRONTEND_PATH=%%~dpa"
    set "FRONTEND_PATH=%FRONTEND_PATH:~0,-1%"
    goto frontend_found
)

rem Opcion 4: Buscar frontend_incapacidades en cualquier lugar
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" 2^>nul') do (
    set "FRONTEND_PATH=%%~dpa"
    set "FRONTEND_PATH=%FRONTEND_PATH:~0,-1%"
    goto frontend_found
)

rem Si no se encontro, pedir al usuario
:frontend_not_found
echo [ADVERTENCIA] No se pudo encontrar el frontend automaticamente.
echo.
echo Rutas buscadas:
echo   - C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades
echo   - %SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades
echo   - %PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend
echo   - En todo %USERPROFILE_PATH%
echo.
set /p MANUAL_PATH="Arrastra la carpeta frontend-incapacidades aqui y presiona Enter: "

rem ELIMINAR COMILLAS DOBLES si Windows las agrego al arrastrar
set "MANUAL_PATH=%MANUAL_PATH:"=%"

set "FRONTEND_PATH=%MANUAL_PATH%"

rem Si arrastro la carpeta padre (frontend_incapacidades), buscar adentro
if not exist "%FRONTEND_PATH%\index.html" (
    if exist "%FRONTEND_PATH%\frontend-incapacidades\index.html" (
        set "FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades"
        goto frontend_found
    )
    if exist "%FRONTEND_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" (
        set "FRONTEND_PATH=%FRONTEND_PATH%\frontend_incapacidades\frontend-incapacidades"
        goto frontend_found
    )
    echo [ERROR] Esa carpeta no contiene index.html
    echo         Ruta verificada: %FRONTEND_PATH%
    pause
    exit /b 1
)

:frontend_found
echo [OK] Backend detectado: %BACKEND_PATH%
echo [OK] Frontend detectado: %FRONTEND_PATH%
echo.

rem ============================================================
rem VERIFICAR QUE EXISTEN LAS CARPETAS DEL BACKEND
rem ============================================================
if not exist "%BACKEND_PATH%\Backend_ms-auth" (
    echo [ERROR] No se encontro Backend_ms-auth en:
    echo         %BACKEND_PATH%
    echo.
    echo         Asegurate de que este .bat este en la carpeta raiz del proyecto.
    pause
    exit /b 1
)

echo [OK] Estructura del backend verificada.
echo.

rem ============================================================
rem VERIFICAR PHP Y COMPOSER
rem ============================================================
echo [0/5] Verificando PHP...
"C:\xampp\php\php.exe" -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] PHP no encontrado en C:\xampp\php\php.exe
    echo         Verifica que XAMPP este instalado en C:\xampp
    echo         O edita este .bat y cambia la ruta de PHP.
    pause
    exit /b 1
)
echo [OK] PHP detectado.

echo [0/5] Verificando Composer...
composer -V >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Composer no encontrado en el PATH.
    echo         Descarga desde: https://getcomposer.org/download/
    echo         O agrega Composer al PATH de Windows.
    pause
    exit /b 1
)
echo [OK] Composer detectado.
echo.

rem ============================================================
rem 1. INSTALAR ms-auth
rem ============================================================
echo [1/5] Instalando ms-auth...
if not exist "%BACKEND_PATH%\Backend_ms-auth\ms-auth" (
    echo [ERROR] No existe la carpeta: %BACKEND_PATH%\Backend_ms-auth\ms-auth
    pause
    exit /b 1
)
cd /d "%BACKEND_PATH%\Backend_ms-auth\ms-auth"
if exist composer.lock del composer.lock >nul 2>&1
composer install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Fallo composer install en ms-auth
    echo         Verifica tu conexion a internet.
    pause
    exit /b 1
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
if not exist "%BACKEND_PATH%\Backend_ms-empleados\ms-empleados" (
    echo [ERROR] No existe la carpeta: %BACKEND_PATH%\Backend_ms-empleados\ms-empleados
    pause
    exit /b 1
)
cd /d "%BACKEND_PATH%\Backend_ms-empleados\ms-empleados"
if exist composer.lock del composer.lock >nul 2>&1
composer install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Fallo composer install en ms-empleados
    pause
    exit /b 1
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
if not exist "%BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades" (
    echo [ERROR] No existe la carpeta: %BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades
    pause
    exit /b 1
)
cd /d "%BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades"
if exist composer.lock del composer.lock >nul 2>&1
composer install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Fallo composer install en ms-incapacidades
    pause
    exit /b 1
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
if not exist "%BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento" (
    echo [ERROR] No existe la carpeta: %BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento
    pause
    exit /b 1
)
cd /d "%BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento"
if exist composer.lock del composer.lock >nul 2>&1
composer install --no-interaction
if %errorlevel% neq 0 (
    echo [ERROR] Fallo composer install en ms-seguimiento
    pause
    exit /b 1
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
"C:\xampp\php\php.exe" -r "try { new PDO('mysql:host=localhost;dbname=mysql', 'root', ''); echo 'OK'; } catch (Exception $e) { echo 'ERROR'; }" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ADVERTENCIA] No se pudo conectar a MySQL automaticamente.
    echo         Posibles causas:
    echo         - MySQL no esta corriendo (abre XAMPP Control Panel)
    echo         - El usuario root tiene contrasena
    echo         - El archivo setup.sql no esta en: %BACKEND_PATH%
    echo.
    echo         Solucion manual:
    echo         1. Abre XAMPP Control Panel
    echo         2. Dale Start a MySQL
    echo         3. Abre phpMyAdmin
    echo         4. Importa el archivo setup.sql
) else (
    mysql -u root -e "source setup.sql" 2>nul
    if %errorlevel% neq 0 (
        echo [ADVERTENCIA] Fallo al ejecutar setup.sql. Intenta importarlo manualmente en phpMyAdmin.
    ) else (
        echo [OK] Bases de datos creadas exitosamente.
    )
)
echo.

rem ============================================================
rem GUARDAR RUTAS PARA INICIAR_SERVIDORES.BAT
rem ============================================================
echo BACKEND_PATH=%BACKEND_PATH%> "%BACKEND_PATH%\.paths.ini"
echo FRONTEND_PATH=%FRONTEND_PATH%>> "%BACKEND_PATH%\.paths.ini"

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
echo Accede al sistema en:
echo   http://127.0.0.1:8080
echo.
echo Credenciales:
echo   admin / admin123
echo   gestionhumana / gh123
echo.
pause