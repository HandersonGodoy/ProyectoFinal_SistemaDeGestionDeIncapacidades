<?php

use Slim\Routing\RouteCollectorProxy;
use App\Controllers\IncapacidadController;
use App\Middleware\TokenMiddleware;

return function ($app) {
    $app->group('/api/incapacidades', function (RouteCollectorProxy $group) {
        $group->get('', [IncapacidadController::class, 'index']);
        $group->get('/{id}', [IncapacidadController::class, 'show']);
        $group->post('', [IncapacidadController::class, 'store']);
        $group->put('/{id}', [IncapacidadController::class, 'update']);
        $group->patch('/{id}/estado', [IncapacidadController::class, 'updateEstado']);
        $group->patch('/{id}/finalizar', [IncapacidadController::class, 'finalizar']);
        $group->delete('/{id}', [IncapacidadController::class, 'destroy']);
    })->add(TokenMiddleware::class);
};