<?php

use Phalcon\Http\Response;
use Phalcon\Di\FactoryDefault;

define('BASE_PATH', dirname(__DIR__));
define('APP_PATH', BASE_PATH . '/app');
define('DEBUG', false);

try {

    if (DEBUG)
        error_reporting(E_ALL);
    else
        error_reporting(0);

    /**
     * The FactoryDefault Dependency Injector automatically registers
     * the services that provide a full stack framework.
     */
    $di = new FactoryDefault();

    /**
     * Read services
     */
    include APP_PATH . '/Config/Services.php';

    /**
     * Get config service for use in inline setup below
     */
    $config = $di->getConfig();

    /**
     * Include Autoloader
     */
    include APP_PATH . '/Config/Loader.php';

    /**
     * Handle the request
     */
    $application = new \Phalcon\Mvc\Application($di);
    $application->registerModules($config->modules->toArray());

    echo $application->handle($_SERVER['REQUEST_URI'])->getContent();
} catch (\Exception $e) {
    if (DEBUG) {
        echo $e->getMessage() . '<br>';
        echo '<pre>' . $e->getTraceAsString() . '</pre>';
    } else {
        $response = new Response();
        $response->setStatusCode(500);
        $response->send();
    }
}
