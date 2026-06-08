@echo off
chcp 65001 >nul
echo ============================================
echo  INICIANDO SERVIDORES - Corporate Solutions
echo ============================================
echo.
echo Se abriran 5 ventanas de comandos:
echo   - 4 para los microservicios backend (puertos 8001-8004)
echo   - 1 para el frontend (puerto 8080)
echo.
echo Espera 3 segundos entre cada una para que no haya conflictos...
echo.
timeout /t 2 /nobreak >nul

:: Terminal 1: ms-auth (puerto 8001)
echo [1/5] Iniciando ms-auth en puerto 8001...
start "MS-AUTH :8001" cmd /k "cd Backend_ms-auth\ms-auth && php -S 127.0.0.1:8001 -t public"
timeout /t 3 /nobreak >nul

:: Terminal 2: ms-empleados (puerto 8002)
echo [2/5] Iniciando ms-empleados en puerto 8002...
start "MS-EMPLEADOS :8002" cmd /k "cd Backend_ms-empleados\ms-empleados && php -S 127.0.0.1:8002 -t public"
timeout /t 3 /nobreak >nul

:: Terminal 3: ms-incapacidades (puerto 8003)
echo [3/5] Iniciando ms-incapacidades en puerto 8003...
start "MS-INCAPACIDADES :8003" cmd /k "cd Backend_ms-incapacidades\ms-incapacidades && php -S 127.0.0.1:8003 -t public"
timeout /t 3 /nobreak >nul

:: Terminal 4: ms-seguimiento (puerto 8004)
echo [4/5] Iniciando ms-seguimiento en puerto 8004...
start "MS-SEGUIMIENTO :8004" cmd /k "cd Backend_ms-seguimiento\ms-seguimiento && php -S 127.0.0.1:8004 -t public"
timeout /t 3 /nobreak >nul

:: Terminal 5: frontend (puerto 8080)
echo [5/5] Iniciando frontend en puerto 8080...
start "FRONTEND :8080" cmd /k "cd frontend_incapacidades\frontend-incapacidades && php -S 127.0.0.1:8080"

timeout /t 2 /nobreak >nul
echo.
echo ============================================
echo  TODOS LOS SERVIDORES INICIADOS!
echo ============================================
echo.
echo Accede al sistema: http://127.0.0.1:8080
echo.
echo Credenciales de prueba:
echo   Admin:        admin / admin123
echo   Gestion Humana: gestionhumana / gh123
echo   Inactivo:     inactivo / inactivo123  (no puede entrar)
echo.
echo Para detener todos los servidores, cierra las 5 ventanas.
echo.
pause
