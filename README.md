# Sistema de Gestion de Incapacidades Medicas - Corporate Solutions

## Descripcion
Sistema web distribuido basado en microservicios para la gestion de incapacidades medicas empresariales. Desarrollado con PHP 8+, Slim Framework, Eloquent ORM y JavaScript Vanilla.

## Requisitos Previos

- PHP 8.0 o superior (incluido en XAMPP)
- Composer (https://getcomposer.org/)
- MySQL / XAMPP (https://www.apachefriends.org/)
- Navegador web

## Instalacion en CUALQUIER PC (Windows)

### Paso 1: Descargar los dos repositorios de GitHub

```bash
git clone https://github.com/tu-usuario/backend-incapacidades.git
git clone https://github.com/tu-usuario/frontend-incapacidades.git
```

### Paso 2: Colocar los archivos .bat

Copia estos archivos en la carpeta raiz del **backend**:
- `Instalar.bat`
- `INICIAR_SERVIDORES.bat`

### Paso 3: Ejecutar Instalar.bat

1. Doble clic en **`Instalar.bat`**
2. El sistema detectara automaticamente las rutas
3. Si no encuentra el frontend, te pedira que arrastres la carpeta
4. Espera a que termine (instala Composer y crea bases de datos)

### Paso 4: Ejecutar INICIAR_SERVIDORES.bat

1. Doble clic en **`INICIAR_SERVIDORES.bat`**
2. Se abriran 5 ventanas de comandos automaticamente
3. Espera 15 segundos a que todos inicien

### Paso 5: Abrir el sistema

En tu navegador, ve a:
```
http://127.0.0.1:8080
```

## Credenciales de Prueba

| Usuario | Contrasena | Rol | Estado |
|---------|-----------|-----|--------|
| admin | admin123 | administrador | activo |
| gestionhumana | gh123 | gestion_humana | activo |
| inactivo | inactivo123 | empleado | inactivo (no entra) |

## Como funciona la deteccion automatica

Los archivos `.bat` detectan automaticamente:
1. **Backend**: La carpeta donde esta el propio `.bat`
2. **Frontend**: Busca en varias ubicaciones comunes:
   - Dentro de la misma carpeta del backend
   - Al lado del backend (mismo nivel)
   - En todo el perfil de usuario (`C:\Users\[usuario]\`)

Si no lo encuentra, te pide que arrastres la carpeta manualmente.

## Si algo falla

### "No se encontro el frontend"
- Arrastra la carpeta `frontend-incapacidades` cuando te lo pida
- O mueve el frontend dentro de la carpeta del backend

### "PHP no encontrado"
- Instala XAMPP desde https://www.apachefriends.org/
- Reinicia la PC despues de instalar

### "Composer no encontrado"
- Descarga desde https://getcomposer.org/download/
- Instala y reinicia la PC

### MySQL no conecta
- Abre XAMPP Control Panel
- Dale "Start" a MySQL
- Verifica que el puerto 3306 no este ocupado

## Estructura esperada

```
Cualquier carpeta\
├── Instalar.bat              <- Aqui
├── INICIAR_SERVIDORES.bat    <- Aqui
├── README.md
├── setup.sql
├── Backend_ms-auth\
├── Backend_ms-empleados\
├── Backend_ms-incapacidades\
├── Backend_ms-seguimiento\
└── frontend_incapacidades\    <- Puede estar aqui o al lado
    └── frontend-incapacidades\
        ├── index.html
        └── ...
```

## Instalacion Manual (si el .bat falla)

Ver la seccion "Instalacion Manual" del README anterior.

## Autor
[Nombre del estudiante]
[Correo institucional]

## Fecha
Junio 2026
