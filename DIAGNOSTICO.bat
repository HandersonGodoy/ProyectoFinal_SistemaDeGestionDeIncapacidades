@echo off
echo === DIAGNOSTICO ===
echo.
echo Paso 1: Verificar PHP
"C:\xampp\php\php.exe" -v
echo.
echo Paso 2: Verificar Composer
composer -V
echo.
echo Paso 3: Verificar carpeta ms-auth
dir "Backend_ms-auth\ms-auth"
echo.
echo Paso 4: Intentar entrar a ms-auth
cd "Backend_ms-auth\ms-auth"
echo Entre a carpeta: %cd%
echo.
echo Paso 5: Intentar composer install (solo verificar, no instalar)
composer install --dry-run --no-interaction
echo.
echo === FIN DIAGNOSTICO ===
pause
cmd /k