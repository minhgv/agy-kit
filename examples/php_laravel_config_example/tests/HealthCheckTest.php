<?php

namespace Tests;

use App\HealthCheck;
use PHPUnit\Framework\TestCase;

class HealthCheckTest extends TestCase
{
    public function testStatusReturnsOk(): void
    {
        $healthCheck = new HealthCheck();
        $this->assertEquals('OK', $healthCheck->status());
    }
}
