<?php

use Phalcon\Mvc\View;
use Phalcon\Mvc\Model;
use Phalcon\Session\Adapter\Files as SessionAdapter;
use Phalcon\Dispatcher;
use Phalcon\Mvc\Dispatcher as MvcDispatcher;
use Phalcon\Events\Event;
use Phalcon\Events\Manager as EventsManager;
use Phalcon\Mvc\Dispatcher\Exception as DispatchException;

/**
 * Shared configuration service
 */
$di->setShared('config', function () {
    return include APP_PATH . '/Config/Config.php';
});

/**
 * The URL component is used to generate all kind of urls in the application
 */
$di->setShared('router', function () {
    return include APP_PATH . '/Config/Router.php';
});

/**
 * Setting up the view component
 */
$di->setShared('view', function () {
    $config = $this->getConfig();

    $view = new View();
    $view->setDI($this);
    $view->setViewsDir(APP_PATH . '/Views/');

    return $view;
});

/**
 * Database connection is created based in the parameters defined in the configuration file
 */
$di->setShared('db', function () {
    $config = $this->getConfig();

    $class = 'Phalcon\Db\Adapter\Pdo\\' . $config->database->adapter;
    $params = [
        'host'     => $config->database->host,
        'username' => $config->database->username,
        'password' => $config->database->password,
        'dbname'   => $config->database->dbname,
        'charset'  => $config->database->charset,
        'options'  => [
            PDO::MYSQL_ATTR_INIT_COMMAND    => 'SET NAMES utf8mb4',
            PDO::ATTR_PERSISTENT            => true,
            PDO::ATTR_DEFAULT_FETCH_MODE    => PDO::FETCH_ASSOC,
        ],
    ];

    $connection = new $class($params);

    return $connection;
});

/**
 * Model::create() skip null columns
 */
Model::setup([
    'notNullValidations'    => false,
]);

/**
 * Start the session the first time some component request the session service
 */
$di->setShared('session', function () {
    $session = new SessionAdapter();
    $session->start();

    return $session;
});

$di->setShared(
    'dispatcher',
    function () {
        // Create an EventsManager
        $eventsManager = new EventsManager();

        // Attach a listener
        $eventsManager->attach(
            'dispatch:beforeException',
            function (Event $event, $dispatcher, \Exception $exception) {
                // Default error action
                $action = 'serverError';
                // Handle 404 exceptions
                if ($exception instanceof DispatchException)
                    $action = 'notFound';

                
                $dispatcher->forward(
                    [
                        'module'    => 'system',
                        'controller'=> 'error',
                        'action'    => $action,
                    ]
                );

                return false;
            }
        );

        $dispatcher = new MvcDispatcher();

        // Bind the EventsManager to the dispatcher
        $dispatcher->setEventsManager($eventsManager);

        return $dispatcher;
    }
);
