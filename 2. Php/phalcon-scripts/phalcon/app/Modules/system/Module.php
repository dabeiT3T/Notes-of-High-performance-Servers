<?php

namespace App\Modules\system;

use Phalcon\Loader;
use Phalcon\Di\Injectable;
use Phalcon\DiInterface;

class Module extends Injectable
{
    public function registerAutoloaders(DiInterface $di)
    {
        $loader = new Loader;
        $loader->registerNamespaces([
            'System'    => __DIR__
        ])->register();
    }

    /**
     * Register the services here to make them general or register in the ModuleDefinition to make them module-specific
     */
    public function registerServices(DiInterface $di)
    {
        $di->get('dispatcher')->setDefaultNamespace('System\Controllers');
    }
}
