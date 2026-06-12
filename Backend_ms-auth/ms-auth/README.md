##  Estructura

├── app/
│   ├── Config/
│   │   └── Database.php      # Inicialización y Singleton de Eloquent Capsule
│   ├── Controllers/
│   │   └── AuthController.php # Lógica de Login, Logout y Validación
│   ├── Middleware/
│   │   └── AuthMiddleware.php  # Verificación de Token Bearer y Sesión Activa
│   ├── Models/
│   │   └── Usuario.php        # Modelo Eloquent mapeado a la tabla 'usuarios'
│   └── Routes/
│       └── web.php            # Definición de grupos de rutas y asignación de middlewares
├── public/
│   └── index.php              # Punto de entrada de la aplicación, CORS y Bootstrap
├── .env.example                       # Variables de entorno 
├── database.sql               # Script de creación de base de datos y semillas
└── docs/                  # Archivo de pruebas HTTP completas
└──.gitignore/               # Ignora archivos prohibidos de subir 