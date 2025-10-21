<?php

namespace AiReviewHook;

use AiReviewHook\Commands\InstallCommand;
use AiReviewHook\Commands\UninstallCommand;
use Illuminate\Support\ServiceProvider;

class AiReviewHookServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        if ($this->app->runningInConsole()) {
            $this->commands([
                InstallCommand::class,
                UninstallCommand::class,
            ]);
        }
    }

    public function register(): void
    {
        //
    }
}
