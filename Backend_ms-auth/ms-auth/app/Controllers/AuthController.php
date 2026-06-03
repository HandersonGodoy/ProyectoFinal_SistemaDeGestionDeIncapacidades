<?php

namespace App\Controllers;

use App\Models\Usuario;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class AuthController
{
   
    public function login(Request $request, Response $response): Response
    {
        $data = $request->getParsedBody();
        
        $usuarioInput = $data['usuario'] ?? $data['correo'] ?? null;
        $contrasena = $data['contrasena'] ?? null;

        $usuario = Usuario::where('usuario', $usuarioInput)
            ->orWhere('correo', $usuarioInput)
            ->first();

        if (!$usuario || $usuario->contrasena !== $contrasena) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Credenciales incorrectas'
            ]));
            return $response->withStatus(401)
                ->withHeader('Content-Type', 'application/json');
        }

        $token = bin2hex(random_bytes(32));

        $usuario->token = $token;
        $usuario->sesion_activa = true;
        $usuario->save();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Login exitoso',
            'token' => $token,
            'usuario' => [
                'id' => $usuario->id,
                'nombre' => $usuario->nombre,
                'rol' => $usuario->rol
            ]
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function logout(Request $request, Response $response): Response
    {
        $authHeader = $request->getHeaderLine('Authorization');
        $token = str_replace('Bearer ', '', $authHeader);

        $usuario = Usuario::where('token', $token)->first();
        
        if ($usuario) {
            $usuario->token = null;
            $usuario->sesion_activa = false;
            $usuario->save();
        }

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Sesión cerrada correctamente'
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function validar(Request $request, Response $response): Response
    {
        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Token válido y sesión activa'
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }
}