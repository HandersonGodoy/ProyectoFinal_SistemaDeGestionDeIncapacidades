<?php

namespace App\Config;

use Illuminate\Database\Capsule\Manager as Capsule;

class Database
{
    private static ?Capsule $capsule = null;

    public static function init(): void
    {
        if (self::$capsule !== null) {
            return;
        }

        self::$capsule = new Capsule();

        self::$capsule->addConnection([
            'driver'    => 'mysql',
            'host'      => $_ENV['DB_HOST']      ?? 'localhost',
            'database'  => $_ENV['DB_NAME']      ?? 'db_auth',
            'username'  => $_ENV['DB_USER']     ?? 'root',
            'password'  => $_ENV['DB_PASS']     ?? '',
            'charset'   => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
            'prefix'    => '',
        ]);

        self::$capsule->setAsGlobal();
        
        self::$capsule->bootEloquent();
    }
    
    public static function getCapsule(): Capsule
    {
        if (self::$capsule === null) {
            self::init();
        }
        return self::$capsule;
    }
}