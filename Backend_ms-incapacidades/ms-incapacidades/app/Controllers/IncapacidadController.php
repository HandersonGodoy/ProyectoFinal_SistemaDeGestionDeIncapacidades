<?php

namespace App\Controllers;

use App\Models\Incapacidad;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class IncapacidadController
{
    private function validarEmpleado(int $empleadoId, string $token): bool
    {
        $url = ($_ENV['MS_EMPLEADOS_URL'] ?? 'http://localhost:8082') . "/api/empleados/{$empleadoId}";
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ["Authorization: Bearer {$token}"]);
        curl_setopt($ch, CURLOPT_TIMEOUT, 5);
        curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        return $httpCode === 200;
    }

    public function index(Request $request, Response $response): Response
    {
        $queryParams = $request->getQueryParams();
        $query = Incapacidad::query();

        if (!empty($queryParams['empleado_id'])) {
            $query->where('empleado_id', $queryParams['empleado_id']);
        }

        if (!empty($queryParams['fecha'])) {
            $query->where(function ($q) use ($queryParams) {
                $q->where('fecha_inicio', '<=', $queryParams['fecha'])
                  ->where('fecha_fin', '>=', $queryParams['fecha']);
            });
        }

        if (!empty($queryParams['fecha_inicio']) && !empty($queryParams['fecha_fin'])) {
            $query->where(function ($q) use ($queryParams) {
                $q->whereBetween('fecha_inicio', [$queryParams['fecha_inicio'], $queryParams['fecha_fin']])
                  ->orWhereBetween('fecha_fin', [$queryParams['fecha_inicio'], $queryParams['fecha_fin']])
                  ->orWhere(function ($sq) use ($queryParams) {
                      $sq->where('fecha_inicio', '<=', $queryParams['fecha_inicio'])
                         ->where('fecha_fin', '>=', $queryParams['fecha_fin']);
                  });
            });
        }

        if (!empty($queryParams['estado'])) {
            $query->where('estado', $queryParams['estado']);
        }

        if (!empty($queryParams['tipo'])) {
            $query->where('tipo', $queryParams['tipo']);
        }

        $incapacidades = $query->orderBy('created_at', 'desc')->get();

        $response->getBody()->write(json_encode([
            'success' => true,
            'data' => $incapacidades
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function show(Request $request, Response $response, array $args): Response
    {
        $incapacidad = Incapacidad::find($args['id']);

        if (!$incapacidad) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Incapacidad no encontrada, intenta nuevamente'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $response->getBody()->write(json_encode([
            'success' => true,
            'data' => $incapacidad
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function store(Request $request, Response $response): Response
    {
        $data = $request->getParsedBody();
        $token = str_replace('Bearer ', '', $request->getHeaderLine('Authorization'));

        $camposObligatorios = ['empleado_id', 'fecha_inicio', 'fecha_fin', 'tipo', 'diagnostico_general', 'entidad_medica'];
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

        $tiposPermitidos = ['enfermedad_general', 'accidente_laboral', 'licencia_medica', 'incapacidad_temporal'];
        if (!in_array($data['tipo'], $tiposPermitidos)) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Tipo de incapacidad invalido, intenta nuevamente'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $fechaInicio = \DateTime::createFromFormat('Y-m-d', $data['fecha_inicio']);
        $fechaFin = \DateTime::createFromFormat('Y-m-d', $data['fecha_fin']);

        if (!$fechaInicio || !$fechaFin) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Formato de fecha invalido, Use el formato YYYY-MM-DD'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        if ($fechaFin < $fechaInicio) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'La fecha fin no puede ser menor a la fecha inicio, intenta nuevamente'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        if (!$this->validarEmpleado((int)$data['empleado_id'], $token)) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'El empleado no existe, rectificalo en el sistema'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $existe = Incapacidad::where('empleado_id', $data['empleado_id'])
            ->where(function ($query) use ($data) {
                $query->whereBetween('fecha_inicio', [$data['fecha_inicio'], $data['fecha_fin']])
                      ->orWhereBetween('fecha_fin', [$data['fecha_inicio'], $data['fecha_fin']])
                      ->orWhere(function ($q) use ($data) {
                          $q->where('fecha_inicio', '<=', $data['fecha_inicio'])
                            ->where('fecha_fin', '>=', $data['fecha_fin']);
                      });
            })
            ->exists();

        if ($existe) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Ya existe una incapacidad para este empleado en el rango de fechas indicado, no se permite duplicado'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $diasIncapacidad = $fechaInicio->diff($fechaFin)->days + 1;

        $incapacidad = Incapacidad::create([
            'empleado_id' => $data['empleado_id'],
            'fecha_inicio' => $data['fecha_inicio'],
            'fecha_fin' => $data['fecha_fin'],
            'tipo' => $data['tipo'],
            'diagnostico_general' => $data['diagnostico_general'],
            'entidad_medica' => $data['entidad_medica'],
            'observaciones' => $data['observaciones'] ?? null,
            'dias_incapacidad' => $diasIncapacidad,
            'estado' => 'registrada'
        ]);

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Incapacidad registrada exitosamente, cargada al sistema',
            'data' => $incapacidad
        ]));

        return $response->withStatus(201)
            ->withHeader('Content-Type', 'application/json');
    }

    public function update(Request $request, Response $response, array $args): Response
    {
        $incapacidad = Incapacidad::find($args['id']);

        if (!$incapacidad) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Incapacidad no encontrada, por favor verificala'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        if ($incapacidad->estado === 'finalizada') {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'No se puede editar una incapacidad finalizada, el sistema ya se cargo'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $data = $request->getParsedBody();

        if (!empty($data['fecha_inicio']) && !empty($data['fecha_fin'])) {
            $fechaInicio = \DateTime::createFromFormat('Y-m-d', $data['fecha_inicio']);
            $fechaFin = \DateTime::createFromFormat('Y-m-d', $data['fecha_fin']);

            if (!$fechaInicio || !$fechaFin) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'Formato de fecha invalido, por favor usa YYYY-MM-DD'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }

            if ($fechaFin < $fechaInicio) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'La fecha fin no puede ser menor a la fecha inicio, por favor prueba en otro rango'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }

            $existe = Incapacidad::where('empleado_id', $incapacidad->empleado_id)
                ->where('id', '!=', $incapacidad->id)
                ->where(function ($query) use ($data) {
                    $query->whereBetween('fecha_inicio', [$data['fecha_inicio'], $data['fecha_fin']])
                          ->orWhereBetween('fecha_fin', [$data['fecha_inicio'], $data['fecha_fin']])
                          ->orWhere(function ($q) use ($data) {
                              $q->where('fecha_inicio', '<=', $data['fecha_inicio'])
                                ->where('fecha_fin', '>=', $data['fecha_fin']);
                          });
                })
                ->exists();

            if ($existe) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'Ya existe una incapacidad para este empleado en el rango de fechas indicado, no se permite duplicados'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }

            $incapacidad->fecha_inicio = $data['fecha_inicio'];
            $incapacidad->fecha_fin = $data['fecha_fin'];
            $incapacidad->dias_incapacidad = $fechaInicio->diff($fechaFin)->days + 1;
        }

        if (array_key_exists('observaciones', $data)) {
            $incapacidad->observaciones = $data['observaciones'];
        }

        if (!empty($data['estado'])) {
            $estadosPermitidos = ['registrada', 'en_revision', 'aprobada', 'rechazada', 'finalizada'];
            if (!in_array($data['estado'], $estadosPermitidos)) {
                $response->getBody()->write(json_encode([
                    'success' => false,
                    'message' => 'Estado inválido'
                ]));
                return $response->withStatus(400)
                    ->withHeader('Content-Type', 'application/json');
            }
            $incapacidad->estado = $data['estado'];
        }

        $incapacidad->save();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Incapacidad actualizada exitosamente, por favor corrobora en el sistema',
            'data' => $incapacidad
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function updateEstado(Request $request, Response $response, array $args): Response
    {
        $incapacidad = Incapacidad::find($args['id']);

        if (!$incapacidad) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Incapacidad no encontrada, por favor verifica bien'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $data = $request->getParsedBody();
        $estadosPermitidos = ['registrada', 'en_revision', 'aprobada', 'rechazada', 'finalizada'];

        if (empty($data['estado']) || !in_array($data['estado'], $estadosPermitidos)) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Estado inválido'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $incapacidad->estado = $data['estado'];
        $incapacidad->save();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Estado actualizado correctamente, felicitaciones',
            'data' => $incapacidad
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function finalizar(Request $request, Response $response, array $args): Response
    {
        $incapacidad = Incapacidad::find($args['id']);

        if (!$incapacidad) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Incapacidad no encontrada, verificala por favor'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        if ($incapacidad->estado === 'finalizada') {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'La incapacidad ya está finalizada, ya esta cargada en el sistema'
            ]));
            return $response->withStatus(400)
                ->withHeader('Content-Type', 'application/json');
        }

        $incapacidad->estado = 'finalizada';
        $incapacidad->save();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Incapacidad finalizada exitosamente, ya quedo cargada al sistema',
            'data' => $incapacidad
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }

    public function destroy(Request $request, Response $response, array $args): Response
    {
        $incapacidad = Incapacidad::find($args['id']);

        if (!$incapacidad) {
            $response->getBody()->write(json_encode([
                'success' => false,
                'message' => 'Incapacidad no encontrada, verificala por favor'
            ]));
            return $response->withStatus(404)
                ->withHeader('Content-Type', 'application/json');
        }

        $incapacidad->delete();

        $response->getBody()->write(json_encode([
            'success' => true,
            'message' => 'Incapacidad eliminada correctamente, ya quedo cargada al sistema'
        ]));

        return $response->withHeader('Content-Type', 'application/json');
    }
}