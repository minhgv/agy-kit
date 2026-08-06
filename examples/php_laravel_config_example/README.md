# agy-kit Configuration for PHP / Laravel Projects

This directory provides complete configuration templates and starter files for PHP / Laravel applications using `agy-kit`.

## Configuration Structure

```text
php_laravel_config_example/
├── .antigravity/
│   ├── agents/
│   │   ├── planner.json      # Architect agent survey & SPEC creation
│   │   ├── coder.json        # TDD implementation agent (phpunit / pest)
│   │   ├── reviewer.json     # Code review, phpstan, php-cs-fixer audit
│   │   └── qa.json           # Laravel E2E test runner
│   └── mcp.json              # MCP server mappings for PHP tooling
├── composer.json             # PHP Composer manifest
├── phpstan.neon              # PHPStan static analysis configuration
├── app/
│   └── HealthCheck.php       # Sample PHP application class
└── tests/
    └── HealthCheckTest.php   # Sample PHPUnit test suite
```

## Required Tools & Linters

- **Static Analysis:** `phpstan/phpstan` (Level 8 or higher).
- **Code Style Formatter:** `friendsofphp/php-cs-fixer` or `laravel/pint`.
- **Test Runner:** `phpunit/phpunit` or `pestphp/pest`.
- **Security Audit:** `gitleaks` (Scans hardcoded API keys and secrets).

## Setup & Execution Commands

```bash
# 1. Install dependencies
composer install

# 2. Run TDD pipeline using agy-kit
agy run --agent coder "Implement Laravel HealthCheck controller with PHPUnit tests"

# 3. Run Quality Gate audit
agy run --agent reviewer "Audit git diff with PHPStan level 8 and PHPUnit"
```
