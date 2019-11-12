<?php

return new \Phalcon\Config([
    'database'  => [
        'adapter'     => 'Mysql',
        'host'        => 'localhost',
        'username'    => 'root',
        'password'    => '',
        'dbname'      => 'test',
        'charset'     => 'utf8',
    ],
    'application'   => [

    ],
    'modules'   => [
        'system'   => [
            'className' => 'App\Modules\system\Module',
            'path'  => APP_PATH . '/Modules/system/Module.php',
        ]
    ],
]);
