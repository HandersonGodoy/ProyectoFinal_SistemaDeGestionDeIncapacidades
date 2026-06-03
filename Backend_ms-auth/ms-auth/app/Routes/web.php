<?php

use Slim\Routing\RouteCollectorProxy;
use App\Controllers\AuthController;
use App\Middleware\AuthMiddleware;

return function ($app) {
    
    $app->group('/api/auth', function (RouteCollectorProxy $group) {
        
        $group->post('/login', [AuthController::class, 'login']);
        
        $group->post('/logout', [AuthController::class, 'logout'])
            ->add(AuthMiddleware::class);
        
        $group->get('/validar', [AuthController::class, 'validar'])
            ->add(AuthMiddleware::class);
            
    });
    
};