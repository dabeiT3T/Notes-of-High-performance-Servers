<?php

use Phalcon\Mvc\Router;

$router = new Router(false);
$router->setUriSource(Router::URI_SOURCE_SERVER_REQUEST_URI);
$router->setDefaultModule('system');
$router->setDefaultController('index');
$router->setDefaultAction('index');
$router->add('/', []);
$router->add('/:controller', [
    'module'    => 'system',
    'controller'=> 1,
]);
$router->add('/:controller/:action', [
    'module'    => 'system',
    'controller'=> 1,
    'action'    => 2,
]);
$router->add('/:module/:controller/:action', [
    'module'    => 1,
    'controller'=> 2,
    'action'    => 3,
]);
$router->notFound([
    'module'    => 'system',
    'controller'=> 'error',
    'action'    => 'notFound',
]);

return $router;
