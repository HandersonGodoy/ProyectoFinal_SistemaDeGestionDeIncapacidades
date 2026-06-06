<?php

use Slim\Routing\RouteCollectorProxy;
use App\Controllers\SeguimientoController;
use App\Middleware\TokenMiddleware;

return function ($app) {
    $app->group('/api/seguimientos', function (RouteCollectorProxy $group) {
        $group->get('', [SeguimientoController::class, 'index']);
        $group->get('/{id}', [SeguimientoController::class, 'show']);
        $group->post('', [SeguimientoController::class, 'store']);
        $group->put('/{id}', [SeguimientoController::class, 'update']);
        $group->patch('/{id}/estado', [SeguimientoController::class, 'updateEstado']);
        $group->delete('/{id}', [SeguimientoController::class, 'destroy']);
    })->add(TokenMiddleware::class);
};