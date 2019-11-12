<?php

namespace System\Controllers;

use App\Library\ControllerBase;

class ErrorController extends ControllerBase
{

    public function notFoundAction()
    {
        return $this->response
                    ->setStatusCode(404)
                    ->send();
    }

    public function serverErrorAction()
    {
        return $this->response
                    ->setStatusCode(500)
                    ->send();
    }
}
