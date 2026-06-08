@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo ============================================
echo  INSTALADOR - Sistema de Gestion de Incapacidades
echo  Corporate Solutions
echo ============================================
echo.
echo [DEBUG] Script iniciado correctamente.
echo [DEBUG] Si ves esto, el batch esta funcionando.
echo.

rem ============================================================
rem FORZAR RUTAS DE PHP Y COMPOSER
rem ============================================================
echo [DEBUG] Configurando PATH...
set "PHP_PATH=C:\xampp\php"
set "COMPOSER_PATH=C:\ProgramData\ComposerSetup\bin"
set "PATH=%PHP_PATH%;%COMPOSER_PATH%;%PATH%"
echo [DEBUG] PATH configurado.

rem ============================================================
rem DETECCION DE RUTAS
rem ============================================================
echo [DEBUG] Detectando rutas...
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
echo [DEBUG] Script esta en: %SCRIPT_DIR%

set "BACKEND_PATH=%SCRIPT_DIR%"
echo [DEBUG] Backend: %BACKEND_PATH%

rem ============================================================
rem FRONTEND - RUTA EXACTA DEL USUARIO
rem ============================================================
echo [DEBUG] Buscando frontend...
set "RUTA_USUARIO=C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
echo [DEBUG] Verificando ruta: %RUTA_USUARIO%

if exist "%RUTA_USUARIO%\index.html" (
    echo [DEBUG] ENCONTRADO en ruta exacta!
    set "FRONTEND_PATH=%RUTA_USUARIO%"
    goto frontend_ok
)

rem Opcion 1: Dentro del backend
if exist "%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%SCRIPT_DIR%\frontend_incapacidades\frontend-incapacidades"
    goto frontend_ok
)

rem Opcion 2: Al lado del backend
for %%D in ("%SCRIPT_DIR%\..") do set "PARENT_DIR=%%~fD"
if exist "%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%PARENT_DIR%\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades"
    goto frontend_ok
)

rem Opcion 3: Buscar en perfil de usuario
set "USERPROFILE_PATH=%USERPROFILE%"
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend-incapacidades\index.html" 2^>nul') do (
    set "FRONTEND_PATH=%%~dpa"
    set "FRONTEND_PATH=!FRONTEND_PATH:~0,-1!"
    goto frontend_ok
)

rem Opcion 4: Buscar carpeta especifica
for /f "delims=" %%a in ('dir /s /b "%USERPROFILE_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" 2^>nul') do (
    set "FRONTEND_PATH=%%~dpa"
    set "FRONTEND_PATH=!FRONTEND_PATH:~0,-1!"
    goto frontend_ok
)

rem Si no se encontro, pedir manual
echo.
echo [ADVERTENCIA] No se encontro el frontend automaticamente.
echo.
echo Escribe o pega la ruta COMPLETA donde esta el archivo index.html
echo.
echo Ejemplo correcto:
echo C:\Users\blanc\ProyectoFinal_SistemaDeGestionDeIncapacidades_Frontend\frontend_incapacidades\frontend-incapacidades
echo.
set /p MANUAL_PATH="Ruta del frontend: "

rem LIMPIAR COMILLAS
set "MANUAL_PATH=%MANUAL_PATH:"=%"
echo [DEBUG] Ruta ingresada: %MANUAL_PATH%

set "FRONTEND_PATH=%MANUAL_PATH%"

if exist "%FRONTEND_PATH%\index.html" (
    echo [DEBUG] index.html encontrado directamente.
    goto frontend_ok
)

if exist "%FRONTEND_PATH%\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%FRONTEND_PATH%\frontend-incapacidades"
    echo [DEBUG] Corregido a subcarpeta.
    goto frontend_ok
)

if exist "%FRONTEND_PATH%\frontend_incapacidades\frontend-incapacidades\index.html" (
    set "FRONTEND_PATH=%FRONTEND_PATH%\frontend_incapacidades\frontend-incapacidades"
    echo [DEBUG] Corregido a doble subcarpeta.
    goto frontend_ok
)

echo [ERROR] No se encontro index.html.
echo         Ruta verificada: %FRONTEND_PATH%
pause
exit /b 1

:frontend_ok
echo [OK] Backend: %BACKEND_PATH%
echo [OK] Frontend: %FRONTEND_PATH%
echo.

rem ============================================================
rem VERIFICAR BACKEND
rem ============================================================
echo [DEBUG] Verificando estructura backend...
if not exist "%BACKEND_PATH%\Backend_ms-auth" (
    echo [ERROR] No se encontro Backend_ms-auth en: %BACKEND_PATH%
    echo         Asegurate de que este .bat este en la carpeta raiz del proyecto.
    pause
    goto fin_error
)
echo [OK] Estructura backend verificada.
echo.

rem ============================================================
rem VERIFICAR PHP
rem ============================================================
echo [0/5] Verificando PHP...
echo [DEBUG] Ejecutando: C:\xampp\php\php.exe -v
"C:\xampp\php\php.exe" -v >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PHP no encontrado en C:\xampp\php\php.exe
    echo         Verifica que XAMPP este instalado en C:\xampp
    pause
    goto fin_error
)
echo [OK] PHP detectado.
echo.

rem ============================================================
rem VERIFICAR COMPOSER
rem ============================================================
echo [0/5] Verificando Composer...
echo [DEBUG] Ejecutando: composer -V
composer -V >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Composer no encontrado en PATH.
    echo         Buscando en rutas alternativas...
    
    if exist "C:\ProgramData\ComposerSetup\bin\composer.bat" (
        set "COMPOSER_CMD=C:\ProgramData\ComposerSetup\bin\composer.bat"
        echo [OK] Composer encontrado en ruta alternativa.
    ) else (
        if exist "C:\xampp\php\composer.phar" (
            set "COMPOSER_CMD=C:\xampp\php\php.exe C:\xampp\php\composer.phar"
            echo [OK] Composer encontrado como phar.
        ) else (
            echo [ERROR] Composer no encontrado en ninguna ruta.
            echo         Descarga desde: https://getcomposer.org/download/
            pause
            goto fin_error
        )
    )
) else (
    set "COMPOSER_CMD=composer"
)
echo [OK] Composer listo: %COMPOSER_CMD%
echo.

rem ============================================================
rem 1. INSTALAR ms-auth
rem ============================================================
echo [1/5] Instalando ms-auth...
if not exist "%BACKEND_PATH%\Backend_ms-auth\ms-auth" (
    echo [ERROR] No existe: %BACKEND_PATH%\Backend_ms-auth\ms-auth
    pause
    goto fin_error
)

cd /d "%BACKEND_PATH%\Backend_ms-auth\ms-auth"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a la carpeta ms-auth
    pause
    goto fin_error
)

echo [DEBUG] Ejecutando composer install en ms-auth...
if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-auth
    echo         Verifica tu conexion a internet.
    pause
    goto fin_error
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
    echo [ERROR] No existe: %BACKEND_PATH%\Backend_ms-empleados\ms-empleados
    pause
    goto fin_error
)

cd /d "%BACKEND_PATH%\Backend_ms-empleados\ms-empleados"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a ms-empleados
    pause
    goto fin_error
)

if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-empleados
    pause
    goto fin_error
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
    echo [ERROR] No existe: %BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades
    pause
    goto fin_error
)

cd /d "%BACKEND_PATH%\Backend_ms-incapacidades\ms-incapacidades"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a ms-incapacidades
    pause
    goto fin_error
)

if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-incapacidades
    pause
    goto fin_error
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
    echo [ERROR] No existe: %BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento
    pause
    goto fin_error
)

cd /d "%BACKEND_PATH%\Backend_ms-seguimiento\ms-seguimiento"
if errorlevel 1 (
    echo [ERROR] No se pudo entrar a ms-seguimiento
    pause
    goto fin_error
)

if exist composer.lock del composer.lock >nul 2>&1
%COMPOSER_CMD% install --no-interaction
if errorlevel 1 (
    echo [ERROR] Fallo composer install en ms-seguimiento
    pause
    goto fin_error
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
echo [DEBUG] Intentando conectar a MySQL...

"C:\xampp\php\php.exe" -r "try { new PDO('mysql:host=localhost;dbname=mysql', 'root', ''); echo 'OK'; } catch (Exception $e) { echo 'ERROR'; }" >nul 2>&1
if errorlevel 1 (
    echo [ADVERTENCIA] No se pudo conectar a MySQL.
    echo         1. Abre XAMPP Control Panel
    echo         2. Dale Start a MySQL
    echo         3. Importa setup.sql manualmente en phpMyAdmin
) else (
    echo [DEBUG] MySQL conectado. Ejecutando setup.sql...
    mysql -u root -e "source setup.sql" 2>nul
    if errorlevel 1 (
        echo [ADVERTENCIA] Fallo setup.sql. Importalo manualmente.
    ) else (
        echo [OK] Bases de datos creadas.
    )
)
echo.

rem ============================================================
rem GUARDAR RUTAS
rem ============================================================
echo [DEBUG] Guardando rutas en .paths.ini...
echo BACKEND_PATH=%BACKEND_PATH%> "%BACKEND_PATH%\.paths.ini"
echo FRONTEND_PATH=%FRONTEND_PATH%>> "%BACKEND_PATH%\.paths.ini"
echo [OK] Rutas guardadas.

rem ============================================================
rem FIN EXITOSO
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
goto fin

:fin_error
echo.
echo ============================================
echo  INSTALACION FALLIDA - Revisa los errores arriba
echo ============================================
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul

:fin
cmd /k