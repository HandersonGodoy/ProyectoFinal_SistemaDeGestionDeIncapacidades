<?php

namespace App\Controllers;

use App\Models\Empleado;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class EmpleadoController
{
    public function index(Request $request, Response $response): Response
    {
        $queryParams = $request->getQueryParams();
        
        $query = Empleado::query();
        
        if (!empty($queryParams['documento'])) {
            $query->where('documento', 'like', '%' . $queryParams['documento'] . '%');
        }
        
        if (!empty($queryParams['area'])) {
            $query->where('area', 'like', '%' . $queryParams['area'] . '%');
        }
        
        if (!empty($queryParams['cargo'])) {
            $query->where('cargo', 'like', '%' . $queryParams['cargo'] . '%');
        }
        
        $empleados = $query->get();
        
        $response->getBody()->write(json_encode([
            'success' => true,
            'data' => $empleados
        ]));
        
        return $response->withHeader('Content-Type', 'application/json');
    }

    public function show(Request $request, Response $response, array $args): Response
    {
        $empleado = Empleado::find($args['id']);

        if (!$empleado) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Empleado no encontrado'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $response->getBody()->write(json_encode([
            'success' => true,
            'data' => $empleado
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function store(Request $request, Response $response): Response
    {
        $data = $request->getParsedBody();

        $camposObligatorios = ['nombres', 'apellidos', 'documento', 'correo', 'telefono', 'cargo', 'area', 'fecha_ingreso'];
        foreach ($camposObligatorios as $campo) {
            if (empty($data[$campo])) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => "El campo {$campo} es obligatorio"
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }
        }

        $fechaIngreso = new \DateTime($data['fecha_ingreso']);
        $hoy = new \DateTime();
        if ($fechaIngreso > $hoy) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'La fecha de ingreso no puede ser futura'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        if (Empleado::where('documento', $data['documento'])->exists()) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'El documento ya está registrado'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        if (Empleado::where('correo', $data['correo'])->exists()) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'El correo ya está registrado'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $empleado = Empleado::create($data);

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Empleado creado exitosamente',
            'data' => $empleado
        ]));

        return $response->withStatus(201)
            ->withHeader('Content-Type', 'application/json');
    }

    public function update(Request $request, Response $response, array $args): Response
    {
        $empleado = Empleado::find($args['id']);

        if (!$empleado) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Empleado no encontrado'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $data = $request->getParsedBody();

        if (!empty($data['fecha_ingreso'])) {
            $fechaIngreso = new \DateTime($data['fecha_ingreso']);
            $hoy = new \DateTime();
            if ($fechaIngreso > $hoy) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'La fecha de ingreso no puede ser futura'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }
        }

        if (isset($data['documento']) && $data['documento'] !== $empleado->documento) {
            if (Empleado::where('documento', $data['documento'])->exists()) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'El documento ya está registrado en otro empleado'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }
        }

        if (isset($data['correo']) && $data['correo'] !== $empleado->correo) {
            if (Empleado::where('correo', $data['correo'])->exists()) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'El correo ya está registrado en otro empleado'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }
        }

        $empleado->update($data);

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Empleado actualizado exitosamente',
            'data' => $empleado
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function cambiarEstado(Request $request, Response $response, array $args): Response
    {
        $empleado = Empleado::find($args['id']);

        if (!$empleado) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Empleado no encontrado'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $data = $request->getParsedBody();
        $nuevoEstado = $data['estado'] ?? null;

        if (!in_array($nuevoEstado, ['activo', 'inactivo'])) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Estado inválido. Use: activo o inactivo'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $empleado->estado = $nuevoEstado;
        $empleado->save();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => "Estado actualizado a '{$nuevoEstado}'",
            'data' => $empleado
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }
}