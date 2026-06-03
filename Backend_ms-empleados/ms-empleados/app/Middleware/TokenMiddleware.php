<?php

namespace App\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as Handler;
use Slim\Psr7\Response;

class TokenMiddleware
{
    public function __invoke(Request $request, Handler $handler): \Psr\Http\Message\ResponseInterface
    {
        $authHeader = $request->getHeaderLine('Authorization');
        $token = str_replace('Bearer ', '', $authHeader);

        if (empty($token)) {
            $response = new Response();
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Token no proporcionado. Inicie sesión.'
            ]));
            return $response->withStatus(401)
                ->withHeader('Content-Type', 'application/json');
        }
        return $handler->handle($request);
    }
}