CREATE DATABASE IF NOT EXISTS db_auth CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_auth;
CREATE TABLE usuarios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    rol ENUM('administrador','gestion_humana','empleado') NOT NULL,
    token VARCHAR(255) NULL,
    sesion_activa BOOLEAN DEFAULT FALSE,
    estado ENUM('activo','inactivo') DEFAULT 'activo',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);
INSERT INTO usuarios (nombre, correo, usuario, contrasena, rol, token, sesion_activa, estado, created_at, updated_at) VALUES
('Administrador General', 'admin@empresa.com', 'admin', 'admin123', 'administrador', NULL, FALSE, 'activo', NOW(), NOW()),
('Analista Gestion Humana', 'gh@empresa.com', 'gestionhumana', 'gh123', 'gestion_humana', NULL, FALSE, 'activo', NOW(), NOW()),
('Usuario Inactivo', 'inactivo@empresa.com', 'inactivo', 'inactivo123', 'empleado', NULL, FALSE, 'inactivo', NOW(), NOW());

CREATE DATABASE IF NOT EXISTS db_empleados CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_empleados;
CREATE TABLE empleados (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    documento VARCHAR(30) NOT NULL UNIQUE,
    correo VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(30) NOT NULL,
    cargo VARCHAR(100) NOT NULL,
    area VARCHAR(100) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado ENUM('activo','inactivo') DEFAULT 'activo',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);
INSERT INTO empleados (nombres, apellidos, documento, correo, telefono, cargo, area, fecha_ingreso, estado, created_at, updated_at) VALUES
('Carlos', 'Ramirez', '1000123456', 'carlos@empresa.com', '3001234567', 'Analista', 'Tecnologia', '2024-01-15', 'activo', NOW(), NOW()),
('Laura', 'Martinez', '1000456789', 'laura@empresa.com', '3019876543', 'Auxiliar', 'Gestion Humana', '2023-07-10', 'activo', NOW(), NOW());

CREATE DATABASE IF NOT EXISTS db_incapacidades CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_incapacidades;
CREATE TABLE incapacidades (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    empleado_id BIGINT UNSIGNED NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    tipo ENUM('enfermedad_general','accidente_laboral','licencia_medica','incapacidad_temporal') NOT NULL,
    diagnostico_general TEXT NOT NULL,
    entidad_medica VARCHAR(150) NOT NULL,
    observaciones TEXT NULL,
    dias_incapacidad INT NOT NULL,
    estado ENUM('registrada','en_revision','aprobada','rechazada','finalizada') DEFAULT 'registrada',
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);
INSERT INTO incapacidades (empleado_id, fecha_inicio, fecha_fin, tipo, diagnostico_general, entidad_medica, observaciones, dias_incapacidad, estado, created_at, updated_at) VALUES
(1, '2026-06-01', '2026-06-05', 'enfermedad_general', 'Infeccion respiratoria', 'Clinica Central', 'Reposo medico durante cinco dias', 5, 'aprobada', NOW(), NOW()),
(2, '2026-06-08', '2026-06-10', 'licencia_medica', 'Control medico general', 'Hospital Regional', 'Seguimiento medico preventivo', 3, 'en_revision', NOW(), NOW());

CREATE DATABASE IF NOT EXISTS db_seguimiento CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_seguimiento;
CREATE TABLE seguimientos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    incapacidad_id BIGINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    comentario TEXT NOT NULL,
    estado ENUM('registrada','en_revision','aprobada','rechazada','finalizada') NOT NULL,
    usuario_responsable VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);
INSERT INTO seguimientos (incapacidad_id, fecha, comentario, estado, usuario_responsable, created_at, updated_at) VALUES
(1, '2026-06-01', 'Incapacidad registrada correctamente', 'registrada', 'gestionhumana', NOW(), NOW()),
(1, '2026-06-02', 'Incapacidad aprobada por gestion humana', 'aprobada', 'admin', NOW(), NOW()),
(2, '2026-06-08', 'Pendiente validacion de soportes medicos', 'en_revision', 'gestionhumana', NOW(), NOW());