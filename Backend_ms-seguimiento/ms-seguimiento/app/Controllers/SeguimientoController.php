<?php

namespace App\Controllers;

use App\Models\Seguimiento;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class SeguimientoController
{
    private function validarIncapacidad(int $incapacidadId, string $token): bool
    {
        $baseUrl = rtrim($_ENV['MS_INCAPACIDADES_URL'] ?? 'http://127.0.0.1:8003', '/');
        $url = $baseUrl . "/api/incapacidades/{$incapacidadId}";
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "Authorization: Bearer {$token}",
            "Accept: application/json"
        ]);
        
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); 
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true); 
        
        curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        return $httpCode >= 200 && $httpCode < 300;
    }

    public function index(Request $request, Response $response): Response
    {
        $queryParams = $request->getQueryParams();
        $query = Seguimiento::query();

        if (!empty($queryParams['incapacidad_id'])) {
            $query->where('incapacidad_id', $queryParams['incapacidad_id']);
        }

        if (!empty($queryParams['estado'])) {
            $query->where('estado', $queryParams['estado']);
        }

        if (!empty($queryParams['fecha'])) {
            $query->where('fecha', 'LIKE', $queryParams['fecha'] . '%');
        }

        if (!empty($queryParams['usuario_responsable'])) {
            $query->where('usuario_responsable', 'like', '%' . $queryParams['usuario_responsable'] . '%');
        }

        $seguimientos = $query->orderBy('created_at', 'desc')->get();

        $response->getBody()->write(json_encode([
            'success' => true,
            'data' => $seguimientos
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function show(Request $request, Response $response, array $args): Response
    {
        $seguimiento = Seguimiento::find($args['id']);

        if (!$seguimiento) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Seguimiento no encontrado, verificalo por favor'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $response->getBody()->write(json_encode([
            'success' => true,
            'data' => $seguimiento
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function store(Request $request, Response $response): Response
    {
        $data = $request->getParsedBody();
        $token = str_replace('Bearer ', '', $request->getHeaderLine('Authorization'));

        $camposObligatorios = ['incapacidad_id', 'fecha', 'comentario', 'estado', 'usuario_responsable'];
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

        $fecha = \DateTime::createFromFormat('Y-m-d', $data['fecha']);
        if (!$fecha) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Formato de fecha invalido, por favor usa YYYY-MM-DD'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $estadosPermitidos = ['registrada', 'en_revision', 'aprobada', 'rechazada', 'finalizada'];
        if (!in_array($data['estado'], $estadosPermitidos)) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Estado inválido. Use: ' . implode(', ', $estadosPermitidos)
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        if (!$this->validarIncapacidad((int)$data['incapacidad_id'], $token)) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'La incapacidad no existe, verficala por favor'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $seguimiento = Seguimiento::create([
            'incapacidad_id' => (int)$data['incapacidad_id'],
            'fecha' => $data['fecha'],
            'comentario' => $data['comentario'],
            'estado' => $data['estado'],
            'usuario_responsable' => $data['usuario_responsable']
        ]);

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Seguimiento registrado exitosamente, cargado al sistema',
            'data' => $seguimiento
        ]));

        return $response->withStatus(201)
            ->withHeader('Content-Type', 'application/json');
    }

    public function update(Request $request, Response $response, array $args): Response
    {
        $seguimiento = Seguimiento::find($args['id']);

        if (!$seguimiento) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Seguimiento no encontrado, verificalo por favor'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $data = $request->getParsedBody();

        if (isset($data['fecha'])) {
            $fecha = \DateTime::createFromFormat('Y-m-d', $data['fecha']);
            if (!$fecha) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'Formato de fecha invalido, por favor usa YYYY-MM-DD'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }
            $seguimiento->fecha = $data['fecha'];
        }

        if (isset($data['comentario'])) {
            $seguimiento->comentario = $data['comentario'];
        }

        if (isset($data['usuario_responsable'])) {
            $seguimiento->usuario_responsable = $data['usuario_responsable'];
        }

        if (!empty($data['estado'])) {
            $estadosPermitidos = ['registrada', 'en_revision', 'aprobada', 'rechazada', 'finalizada'];
            if (!in_array($data['estado'], $estadosPermitidos)) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'Estado invalido, verificalo por favor'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }
            $seguimiento->estado = $data['estado'];
        }

        $seguimiento->save();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Seguimiento actualizado exitosamente, cargado al sistema',
            'data' => $seguimiento
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function updateEstado(Request $request, Response $response, array $args): Response
    {
        $seguimiento = Seguimiento::find($args['id']);

        if (!$seguimiento) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Seguimiento no encontrado, verificalo por favor'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $data = $request->getParsedBody();
        $estadosPermitidos = ['registrada', 'en_revision', 'aprobada', 'rechazada', 'finalizada'];

        if (empty($data['estado']) || !in_array($data['estado'], $estadosPermitidos)) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Estado inválido, verifica por favor'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $seguimiento->estado = $data['estado'];
        $seguimiento->save();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Estado actualizado correctamente, cargado al sistema',
            'data' => $seguimiento
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function destroy(Request $request, Response $response, array $args): Response
    {
        $seguimiento = Seguimiento::find($args['id']);

        if (!$seguimiento) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Seguimiento no encontrado, verificalo por favor'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $seguimiento->delete();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Seguimiento eliminado correctamente, cargado al sistema'
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }
}