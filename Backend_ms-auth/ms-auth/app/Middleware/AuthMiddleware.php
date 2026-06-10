<?php

namespace App\Middleware;

use App\Models\Usuario;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as Handler;
use Slim\Psr7\Response;

class AuthMiddleware
{
    
    public function __invoke(Request $request, Handler $handler): \Psr\Http\Message\ResponseInterface
    {
        $authHeader = $request->getHeaderLine('Authorization');
        $token = str_replace('Bearer ', '', $authHeader);

        if (empty($token)) {
            $response = new Response();
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Token no proporcionado, incorrecto'
            ]));
            return $response->withStatus(401)
                ->withHeader('Content-Type', 'application/json');
        }

        $usuario = Usuario::where('token', $token)
            ->where('sesion_activa', true)
            ->first();

        if (!$usuario) {
            $response = new Response();
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Token invalido o sesión expirada, intentalo de nuevo'
            ]));
            return $response->withStatus(401)
                ->withHeader('Content-Type', 'application/json');
        }

        return $handler->handle($request);
    }
}