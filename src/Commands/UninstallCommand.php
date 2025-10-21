<?php

namespace AiReviewHook\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class UninstallCommand extends Command
{
    protected $signature = 'ai-review:uninstall';

    protected $description = 'Uninstall AI code review scripts and remove composer commands';

    public function handle(): int
    {
        $this->info('🗑️  Uninstalling AI Code Review...');
        $this->newLine();

        // Remove ai-reviewer.sh script
        $scriptsDir = base_path('.ai/scripts');
        $reviewerPath = $scriptsDir.'/ai-reviewer.sh';
        
        if (File::exists($reviewerPath)) {
            File::delete($reviewerPath);
            $this->info('✓ Removed ai-reviewer.sh script');
            
            // Remove .ai/scripts directory if empty
            if (File::exists($scriptsDir) && count(File::files($scriptsDir)) === 0) {
                File::deleteDirectory($scriptsDir);
                $this->info('✓ Removed .ai/scripts directory');
                
                // Remove .ai directory if empty
                $aiDir = base_path('.ai');
                if (File::exists($aiDir) && count(File::allFiles($aiDir)) === 0) {
                    File::deleteDirectory($aiDir);
                    $this->info('✓ Removed .ai directory');
                }
            }
        }

        // Remove composer scripts
        $this->removeComposerScripts();

        // Optionally remove code-reviews directory
        $reviewsDir = base_path('.ai/code-reviews');
        if (File::exists($reviewsDir)) {
            if ($this->confirm('Remove code-reviews directory and all reviews?', false)) {
                File::deleteDirectory($reviewsDir);
                $this->info('✓ Removed .ai/code-reviews directory');
            } else {
                $this->info('✓ Kept .ai/code-reviews directory');
            }
        }

        $this->newLine();
        $this->info('✨ AI Code Review uninstalled successfully');

        return self::SUCCESS;
    }

    private function removeComposerScripts(): void
    {
        $composerPath = base_path('composer.json');
        
        if (! File::exists($composerPath)) {
            return;
        }

        $composerContent = json_decode(File::get($composerPath), true);
        
        if (! $composerContent) {
            return;
        }

        $scriptsToRemove = ['ai-review', 'ai-review-staged'];
        $updated = false;

        foreach ($scriptsToRemove as $scriptName) {
            if (isset($composerContent['scripts'][$scriptName])) {
                unset($composerContent['scripts'][$scriptName]);
                $updated = true;
                $this->info("✓ Removed '{$scriptName}' script from composer.json");
            }
        }

        if ($updated) {
            $updatedJson = json_encode($composerContent, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
            File::put($composerPath, $updatedJson);
            $this->info('✓ Updated composer.json');
        }
    }
}
