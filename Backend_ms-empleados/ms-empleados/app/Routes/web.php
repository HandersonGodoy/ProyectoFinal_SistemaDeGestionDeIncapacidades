<?php

use Slim\Routing\RouteCollectorProxy;
use App\Controllers\EmpleadoController;
use App\Middleware\TokenMiddleware;

return function ($app) {
    
    $app->group('/api/empleados', function (RouteCollectorProxy $group) {
        
        $group->get('', [EmpleadoController::class, 'index']);
        
        $group->get('/{id}', [EmpleadoController::class, 'show']);
        
        $group->post('', [EmpleadoController::class, 'store']);
        
        $group->put('/{id}', [EmpleadoController::class, 'update']);
        
        $group->patch('/{id}/estado', [EmpleadoController::class, 'cambiarEstado']);
        
        $group->delete('/{id}', [EmpleadoController::class, 'destroy']);
        
    })->add(TokenMiddleware::class);
    
};