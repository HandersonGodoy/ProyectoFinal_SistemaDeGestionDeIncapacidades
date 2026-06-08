@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem LOG DE ERRORES - Si se cierra la ventana, lee este archivo:
rem    Instalar_LOG.txt
rem ============================================================
set "LOGFILE=%~dp0Instalar_LOG.txt"
echo ============================================ > "%LOGFILE%"
echo  LOG DE INSTALACION >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"
echo. >> "%LOGFILE%"
echo [INICIO] %date% %time% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo ============================================
echo  INSTALADOR - Sistema de Gestion de Incapacidades
echo  Corporate Solutions
echo ============================================
echo.
echo [INFO] Si esta ventana se cierra, revisa el archivo:
echo        Instalar_LOG.txt en esta misma carpeta
echo.

rem ============================================================
rem PASO 0: FORZAR RUTAS DE PHP Y COMPOSER
rem ============================================================
echo [0] Configurando PATH...
echo [0] Configurando PATH... >> "%LOGFILE%"
set "PHP_PATH=C:\xampp\php"
set "COMPOSER_PATH=C:\ProgramData\ComposerSetup\bin"
set "PATH=%PHP_PATH%;%COMPOSER_PATH%;%PATH%"
echo [OK] PATH configurado >> "%LOGFILE%"

rem ============================================================
rem PASO 1: DETECTAR RUTAS
rem ============================================================
echo [1] Detectando rutas...
echo [1] Detectando rutas... >> "%LOGFILE%"

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
echo [DEBUG] Script en: %SCRIPT_DIR% >> "%LOGFILE%"

set "BACKEND_PATH=%SCRIPT_DIR%"
echo [DEBUG] Backend: %BACKEND_PATH% >> "%LOGFILE%"

rem FRONTEND - Intentar ruta exacta primero
set "FRONTEND_PATH=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
echo [DEBUG] Probando ruta exacta: %FRONTEND_PATH% >> "%LOGFILE%"

if exist "%FRONTEND_PATH%\index.html" (
    echo [OK] Frontend encontrado en ruta exacta >> "%LOGFILE%"
    goto frontend_ok
)

rem Opcion 1: Dentro del backend
set "FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades"
echo [DEBUG] Probando opcion 1: %FRONTEND_PATH% >> "%LOGFILE%"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok

rem Opcion 2: Al lado del backend
for %%D in ("%SCRIPT_DIR%\..") do set "PARENT_DIR=%%~fD"
set "FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
echo [DEBUG] Probando opcion 2: %FRONTEND_PATH% >> "%LOGFILE%"
if exist "%FRONTEND_PATH%\index.html" goto frontend_ok

rem Opcion 3: Buscar en perfil de usuario
set "USERPROFILE_PATH=%USERPROFILE%"
echo [DEBUG] Buscando en perfil: %USERPROFILE_PATH% >> "%LOGFILE%"
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend-incapacidades\index.html" 2^>nul') do (
    set "FRONTEND_PATH=%%~dpa"
    set "FRONTEND_PATH=!FRONTEND_PATH:~0,-1!"
    echo [OK] Frontend encontrado en perfil: !FRONTEND_PATH! >> "%LOGFILE%"
    goto frontend_ok
)

rem Opcion 4: Buscar carpeta especifica
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" 2^>nul') do (
    set "FRONTEND_PATH=%%~dpa"
    set "FRONTEND_PATH=!FRONTEND_PATH:~0,-1!"
    echo [OK] Frontend encontrado en busqueda: !FRONTEND_PATH! >> "%LOGFILE%"
    goto frontend_ok
)

rem Si no se encontro, pedir manual
echo [ADVERTENCIA] No se encontro el frontend automaticamente.
echo [ADVERTENCIA] No se encontro el frontend automaticamente. >> "%LOGFILE%"
echo.
echo Escribe o pega la ruta COMPLETA de la carpeta que contiene index.html
echo Ejemplo: C:\Users\Nombre\...\frontend-incapacidades
echo.
set /p MANUAL_PATH="Ruta del frontend: "
echo [DEBUG] Usuario ingreso: %MANUAL_PATH% >> "%LOGFILE%"

rem QUITAR COMILLAS que Windows agrega al arrastrar
set "MANUAL_PATH=%MANUAL_PATH:"=%"
echo [DEBUG] Sin comillas: %MANUAL_PATH% >> "%LOGFILE%"

set "FRONTEND_PATH=%MANUAL_PATH%"

if exist "%FRONTEND_PATH%\index.html" (
    echo [OK] index.html encontrado directamente >> "%LOGFILE%"
    goto frontend_ok
)

if exist "%FRONTEND_PATH%\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades"
    echo [OK] Corregido a subcarpeta frontend-incapacidades >> "%LOGFILE%"
    goto frontend_ok
)

if exist "%FRONTEND_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%FRONTEND_PATH%\frontend_incapacidades\frontend-incapacidades"
    echo [OK] Corregido a doble subcarpeta >> "%LOGFILE%"
    goto frontend_ok
)

echo [ERROR] No se encontro index.html en ninguna ubicacion.
echo [ERROR] No se encontro index.html. Ruta final: %FRONTEND_PATH% >> "%LOGFILE%"
pause
cmd /k

:frontend_ok
echo [OK] Backend: %BACKEND_PATH%
echo [OK] Frontend: %FRONTEND_PATH%
echo [OK] Backend: %BACKEND_PATH% >> "%LOGFILE%"
echo [OK] Frontend: %FRONTEND_PATH% >> "%LOGFILE%"
echo.

rem ============================================================
rem PASO 2: VERIFICAR BACKEND
rem ============================================================
echo [2] Verificando estructura backend...
echo [2] Verificando estructura backend... >> "%LOGFILE%"
if not exist "%BACKEND_PATH%\Backend_ms-auth" (
    echo [ERROR] No se encontro Backend_ms-auth en: %BACKEND_PATH%
    echo [ERROR] No se encontro Backend_ms-auth >> "%LOGFILE%"
    pause
    cmd /k
)
echo [OK] Estructura backend verificada.
echo [OK] Estructura backend verificada. >> "%LOGFILE%"
echo.

rem ============================================================
rem PASO 3: VERIFICAR PHP
rem ============================================================
echo [3] Verificando PHP...
echo [3] Verificando PHP... >> "%LOGFILE%"

"C:\xampp\php\php.exe" -v >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PHP no encontrado en C:\xampp\php\php.exe
    echo [ERROR] PHP no encontrado >> "%LOGFILE%"
    echo.
    echo Posibles soluciones:
    echo 1. Instala XAMPP desde https://www.apachefriends.org/
    echo 2. O si XAMPP esta en otra unidad (D:, E:, etc.),
    echo    edita este archivo y cambia la linea:
    echo    set "PHP_PATH=C:\xampp\php"
    echo    por tu ruta real.
    echo.
    pause
    cmd /k
)
echo [OK] PHP detectado.
echo [OK] PHP detectado. >> "%LOGFILE%"
echo.

rem ============================================================
rem PASO 4: VERIFICAR COMPOSER
rem ============================================================
echo [4] Verificando Composer...
echo [4] Verificando Composer... >> "%LOGFILE%"

composer -V >nul 2>&1
if errorlevel 1 (
    echo [ADVERTENCIA] Composer no esta en PATH. Buscando...
    echo [ADVERTENCIA] Composer no en PATH >> "%LOGFILE%"
    
    if exist "C:\ProgramData\ComposerSetup\bin\composer.bat" (
        set "COMPOSER_CMD=C:\ProgramData\ComposerSetup\bin\composer.bat"
        echo [OK] Composer encontrado en ruta alternativa.
        echo [OK] Composer alternativo >> "%LOGFILE%"
        goto composer_ok
    )
    
    if exist "C:\xampp\php\composer.phar" (
        set "COMPOSER_CMD=C:\xampp\php\php.exe C:\xampp\php\composer.phar"
        echo [OK] Composer encontrado como phar.
        echo [OK] Composer phar >> "%LOGFILE%"
        goto composer_ok
    )
    
    echo [ERROR] Composer no encontrado en ninguna ruta.
    echo [ERROR] Composer no encontrado >> "%LOGFILE%"
    echo.
    echo Descarga Composer desde: https://getcomposer.org/download/
    echo.
    pause
    cmd /k
)

set "COMPOSER_CMD=composer"
echo [OK] Composer detectado.
echo [OK] Composer detectado. >> "%LOGFILE%"
echo.

:composer_ok
echo [DEBUG] Usando Composer: %COMPOSER_CMD% >> "%LOGFILE%"

rem ============================================================
rem PASO 5: INSTALAR MICROSERVICIOS
rem ============================================================

rem 5.1 ms-auth
echo [5/9] Instalando ms-auth...
echo [5/9] Instalando ms-auth... >> "%LOGFILE%"
if not exist "%BACKEND_PATH%\Backend_ms-auth\ms-auth" (
    echo [ERROR] No existe: %BACKEND_PATH%\Backend_ms-auth\ms-auth
    echo [ERROR] Falta Backend_ms-auth\ms-auth >> "%LOGFILE%"
    pause
    cmd /k
)
cd /d "%BACKEND_PATH%\Backend_ms-auth\ms-auth"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a ms-auth
    echo [ERROR] No se pudo entrar a ms-auth >> "%LOGFILE%"
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-auth. Revisa tu internet.
    echo [ERROR] Fallo composer ms-auth >> "%LOGFILE%"
    pause
    cmd /k
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_auth>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo [OK] ms-auth listo.
echo [OK] ms-auth listo. >> "%LOGFILE%"
echo.

rem 5.2 ms-empleados
echo [6/9] Instalando ms-empleados...
echo [6/9] Instalando ms-empleados... >> "%LOGFILE%"
if not exist "%BACKEND_PATH%\Backend_ms-empleados\ms-empleados" (
    echo [ERROR] No existe: %BACKEND_PATH%\Backend_ms-empleados\ms-empleados
    echo [ERROR] Falta Backend_ms-empleados >> "%LOGFILE%"
    pause
    cmd /k
)
cd /d "%BACKEND_PATH%\Backend_ms-empleados\ms-empleados"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a ms-empleados
    echo [ERROR] No se pudo entrar a ms-empleados >> "%LOGFILE%"
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-empleados.
    echo [ERROR] Fallo composer ms-empleados >> "%LOGFILE%"
    pause
    cmd /k
)
echo DB_HOST=localhost> .env
echo DB_NAME=db_empleados>> .env
echo DB_USER=root>> .env
echo DB_PASS=>> .env
echo MS_AUTH_URL=http://127.0.0.1:8001>> .env
echo [OK] ms-empleados listo.
echo [OK] ms-empleados listo. >> "%LOGFILE%"
echo.

rem 5.3 ms-incapacidades
echo [7/9] Instalando ms-incapacidades...
echo [7/9] Instalando ms-incapacidades... >> "%LOGFILE%"
if not exist "%BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades" (
    echo [ERROR] No existe: %BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades
    echo [ERROR] Falta Backend_ms-incapacidades >> "%LOGFILE%"
    pause
    cmd /k
)
cd /d "%BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a ms-incapacidades
    echo [ERROR] No se pudo entrar a ms-incapacidades >> "%LOGFILE%"
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-incapacidades.
    echo [ERROR] Fallo composer ms-incapacidades >> "%LOGFILE%"
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
echo [OK] ms-incapacidades listo. >> "%LOGFILE%"
echo.

rem 5.4 ms-seguimiento
echo [8/9] Instalando ms-seguimiento...
echo [8/9] Instalando ms-seguimiento... >> "%LOGFILE%"
if not exist "%BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento" (
    echo [ERROR] No existe: %BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento
    echo [ERROR] Falta Backend_ms-seguimiento >> "%LOGFILE%"
    pause
    cmd /k
)
cd /d "%BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a ms-seguimiento
    echo [ERROR] No se pudo entrar a ms-seguimiento >> "%LOGFILE%"
    pause
    cmd /k
)
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-seguimiento.
    echo [ERROR] Fallo composer ms-seguimiento >> "%LOGFILE%"
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
echo [OK] ms-seguimiento listo. >> "%LOGFILE%"
echo.

rem ============================================================
rem PASO 6: CREAR BASE DE DATOS
rem ============================================================
echo [9/9] Creando bases de datos...
echo [9/9] Creando bases de datos... >> "%LOGFILE%"
cd /d "%BACKEND_PATH%"
"C:\xampp\php\php.exe" -r "try { new PDO('mysql:host=localhost;dbname=mysql', 'root', ''); echo 'OK'; } catch (Exception $e) { echo 'ERROR'; }" >nul 2>&1
if errorlevel 1 (
    echo [ADVERTENCIA] No se pudo conectar a MySQL.
    echo [ADVERTENCIA] MySQL no conecta >> "%LOGFILE%"
    echo         Solucion manual:
    echo         1. Abre XAMPP Control Panel
    echo         2. Dale Start a MySQL
    echo         3. Importa setup.sql en phpMyAdmin
) else (
    mysql -u root -e "source setup.sql" 2>nul
    if errorlevel 1 (
        echo [ADVERTENCIA] Fallo setup.sql. Importalo manualmente.
        echo [ADVERTENCIA] Fallo setup.sql >> "%LOGFILE%"
    ) else (
        echo [OK] Bases de datos creadas.
        echo [OK] Bases de datos creadas. >> "%LOGFILE%"
    )
)
echo.

rem ============================================================
rem PASO 7: GUARDAR RUTAS
rem ============================================================
echo Guardando rutas para INICIAR_SERVIDORES.bat...
echo Guardando rutas... >> "%LOGFILE%"
echo BACKEND_PATH=%BACKEND_PATH%> "%BACKEND_PATH%\.paths.ini"
echo FRONTEND_PATH=%FRONTEND_PATH%>> "%BACKEND_PATH%\.paths.ini"
echo [OK] Rutas guardadas.
echo [OK] Rutas guardadas. >> "%LOGFILE%"
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
echo [FINALIZADO] %date% %time% >> "%LOGFILE%"
pause
cmd /k