<?php

namespace App;

class HealthCheck
{
    public function status(): string
    {
        return 'OK';
    }
}
