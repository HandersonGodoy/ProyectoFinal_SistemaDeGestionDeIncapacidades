# Sistema de Gestion de Incapacidades Medicas - Corporate Solutions

## Descripcion
Sistema web distribuido basado en microservicios para la gestion de incapacidades medicas empresariales. Desarrollado con PHP 8+, Slim Framework, Eloquent ORM y JavaScript Vanilla.

## Arquitectura
- **Frontend**: HTML5, CSS3, JavaScript Vanilla (sin frameworks)
- **Backend**: 4 microservicios independientes con APIs REST
- **Base de datos**: MySQL (4 bases de datos independientes)

## Repositorios
Este proyecto se compone de 2 repositorios:
1. `frontend-incapacidades` - Aplicacion frontend
2. `backend-incapacidades` - 4 microservicios backend

## Requisitos Previos
- PHP 8.0 o superior
- Composer (https://getcomposer.org/)
- MySQL / XAMPP / WAMP
- Git

## Instalacion Rapida (Windows)

### Paso 1: Clonar repositorios
```bash
git clone https://github.com/tu-usuario/frontend-incapacidades.git
git clone https://github.com/tu-usuario/backend-incapacidades.git
```

### Paso 2: Ejecutar instalador
Doble clic en **`Instalar.bat`**

Este script automaticamente:
- Instala dependencias de Composer en los 4 microservicios
- Crea los archivos `.env` con configuracion correcta
- Crea las 4 bases de datos en MySQL

### Paso 3: Iniciar servidores
Doble clic en **`INICIAR_SERVIDORES.bat`**

Este script abre 5 ventanas:
- 4 microservicios backend (puertos 8001-8004)
- 1 servidor frontend (puerto 8080)

### Paso 4: Acceder al sistema
Abrir navegador en: **http://127.0.0.1:8080**

## Instalacion Manual (si el .bat falla)

### 1. Bases de datos
```bash
cd C:\xampp\mysql\bin
mysql.exe -u root < setup.sql
```

### 2. Dependencias backend
```bash
cd Backend_ms-auth\ms-auth
composer install

cd Backend_ms-empleados\ms-empleados
composer install

cd Backend_ms-incapacidades\ms-incapacidades
composer install

cd Backend_ms-seguimiento\ms-seguimiento
composer install
```

### 3. Archivos .env
Crear `.env` en cada microservicio con:

**ms-auth/.env**
```
DB_HOST=localhost
DB_NAME=db_auth
DB_USER=root
DB_PASS=
```

**ms-empleados/.env**
```
DB_HOST=localhost
DB_NAME=db_empleados
DB_USER=root
DB_PASS=
MS_AUTH_URL=http://127.0.0.1:8001
```

**ms-incapacidades/.env**
```
DB_HOST=localhost
DB_NAME=db_incapacidades
DB_USER=root
DB_PASS=
MS_AUTH_URL=http://127.0.0.1:8001
MS_EMPLEADOS_URL=http://127.0.0.1:8002
```

**ms-seguimiento/.env**
```
DB_HOST=localhost
DB_NAME=db_seguimiento
DB_USER=root
DB_PASS=
MS_AUTH_URL=http://127.0.0.1:8001
MS_INCAPACIDADES_URL=http://127.0.0.1:8003
APP_PORT=8004
```

### 4. Levantar servidores
```bash
# Terminal 1
cd Backend_ms-auth\ms-auth
php -S 127.0.0.1:8001 -t public

# Terminal 2
cd Backend_ms-empleados\ms-empleados
php -S 127.0.0.1:8002 -t public

# Terminal 3
cd Backend_ms-incapacidades\ms-incapacidades
php -S 127.0.0.1:8003 -t public

# Terminal 4
cd Backend_ms-seguimiento\ms-seguimiento
php -S 127.0.0.1:8004 -t public

# Terminal 5
cd frontend_incapacidades\frontend-incapacidades
php -S 127.0.0.1:8080
```

## Credenciales de Prueba

| Usuario | Contrasena | Rol | Estado |
|---------|-----------|-----|--------|
| admin | admin123 | administrador | activo |
| gestionhumana | gh123 | gestion_humana | activo |
| inactivo | inactivo123 | empleado | inactivo |

## Microservicios y Endpoints

### ms-auth (http://127.0.0.1:8001)
| Metodo | Endpoint | Descripcion |
|--------|----------|-------------|
| POST | /api/auth/login | Iniciar sesion |
| POST | /api/auth/logout | Cerrar sesion (requiere token) |
| GET | /api/auth/validar | Validar token (requiere token) |

### ms-empleados (http://127.0.0.1:8002)
| Metodo | Endpoint | Descripcion |
|--------|----------|-------------|
| GET | /api/empleados | Listar empleados (filtros: documento, area, cargo) |
| GET | /api/empleados/{id} | Ver empleado |
| POST | /api/empleados | Crear empleado |
| PUT | /api/empleados/{id} | Editar empleado |
| PATCH | /api/empleados/{id}/estado | Cambiar estado |
| DELETE | /api/empleados/{id} | Eliminar empleado |

### ms-incapacidades (http://127.0.0.1:8003)
| Metodo | Endpoint | Descripcion |
|--------|----------|-------------|
| GET | /api/incapacidades | Listar (filtros: empleado_id, estado, tipo, fechas) |
| GET | /api/incapacidades/{id} | Ver incapacidad |
| POST | /api/incapacidades | Registrar |
| PUT | /api/incapacidades/{id} | Editar |
| PATCH | /api/incapacidades/{id}/estado | Cambiar estado |
| PATCH | /api/incapacidades/{id}/finalizar | Finalizar |
| DELETE | /api/incapacidades/{id} | Eliminar |

### ms-seguimiento (http://127.0.0.1:8004)
| Metodo | Endpoint | Descripcion |
|--------|----------|-------------|
| GET | /api/seguimientos | Listar (filtros: incapacidad_id, estado, fecha, responsable) |
| GET | /api/seguimientos/{id} | Ver seguimiento |
| POST | /api/seguimientos | Registrar |
| PUT | /api/seguimientos/{id} | Editar |
| PATCH | /api/seguimientos/{id}/estado | Cambiar estado |
| DELETE | /api/seguimientos/{id} | Eliminar |

## Solucion de Problemas

### Error "Failed to fetch" / CORS
Verificar que:
1. Los 4 microservicios estan corriendo
2. CORS esta configurado en cada `index.php`
3. Se usa `http://127.0.0.1:8080` (no `file:///`)

### Error 404
Verificar que:
1. Se ejecuto `composer install`
2. El archivo `.env` existe con contenido correcto
3. Se levanto el servidor desde la carpeta `public/`

### Error de conexion a MySQL
Verificar que:
1. XAMPP/MySQL esta corriendo
2. El usuario/contrasena en `.env` es correcto
3. Se ejecuto `setup.sql` para crear las bases de datos

## Estructura de Proyecto
```
ProyectoFinal/
├── Backend_ms-auth/
│   └── ms-auth/
│       ├── app/
│       │   ├── Controllers/
│       │   ├── Models/
│       │   ├── Middleware/
│       │   ├── Config/
│       │   └── Routes/
│       ├── public/
│       │   └── index.php
│       ├── vendor/
│       └── .env
├── Backend_ms-empleados/
│   └── ms-empleados/
│       └── (misma estructura)
├── Backend_ms-incapacidades/
│   └── ms-incapacidades/
│       └── (misma estructura)
├── Backend_ms-seguimiento/
│   └── ms-seguimiento/
│       └── (misma estructura)
├── frontend_incapacidades/
│   └── frontend-incapacidades/
│       ├── index.html
│       ├── dashboard.html
│       ├── css/
│       ├── js/
│       └── pages/
├── setup.sql
├── Instalar.bat
├── INICIAR_SERVIDORES.bat
└── README.md
```

## Autor
[Nombre del estudiante]
[Correo institucional]
[Universidad/Escuela]

## Fecha
Junio 2026
