@echo off
echo ============================================
echo Instalando dependencias de Composer...
echo ============================================

echo [1/4] Instalando ms-auth...
cd Backend_ms-auth
composer install
copy .env.example .env
cd ..

echo [2/4] Instalando ms-empleados...
cd Backend_ms-empleados
composer install
copy .env.example .env
cd ..

echo [3/4] Instalando ms-incapacidades...
cd Backend_ms-incapacidades
composer install
copy .env.example .env
cd ..

echo [4/4] Instalando ms-seguimiento...
cd Backend_ms-seguimiento
composer install
copy .env.example .env
cd ..

echo ============================================
echo LISTO! Todas las dependencias instaladas.
echo ============================================
pause