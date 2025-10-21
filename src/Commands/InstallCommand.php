<?php

namespace AiReviewHook\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class InstallCommand extends Command
{
    protected $signature = 'ai-review:install {--force : Overwrite existing files}';

    protected $description = 'Install AI code review scripts and setup composer commands';

    public function handle(): int
    {
        $this->info('🤖 Installing AI Code Review Scripts...');
        $this->newLine();

        // Check if in a git repository
        if (! File::exists(base_path('.git'))) {
            $this->error('✗ Not a git repository');
            $this->info('  This command must be run from a git repository');

            return self::FAILURE;
        }

        // Create .ai/scripts directory
        $scriptsDir = base_path('.ai/scripts');
        if (! File::exists($scriptsDir)) {
            File::makeDirectory($scriptsDir, 0755, true);
            $this->info('✓ Created .ai/scripts/ directory');
        }

        // Create ignore.yml file
        $ignoreSource = __DIR__.'/../../stubs/ignore.yml';
        $ignoreDest = base_path('.ai/ignore.yml');
        if (! File::exists($ignoreDest)) {
            File::copy($ignoreSource, $ignoreDest);
            $this->info('✓ Created .ai/ignore.yml file');
        }

        // Install ai-reviewer.sh script
        $reviewerSource = __DIR__.'/../../stubs/ai-reviewer.sh';
        $reviewerDest = $scriptsDir.'/ai-reviewer.sh';

        if (File::exists($reviewerDest) && ! $this->option('force')) {
            $this->warn('⚠ ai-reviewer.sh already exists');
            if (! $this->confirm('Overwrite existing script?', false)) {
                $this->info('Installation cancelled');

                return self::FAILURE;
            }
        }

        File::copy($reviewerSource, $reviewerDest);
        chmod($reviewerDest, 0755);
        $this->info('✓ Installed ai-reviewer.sh script');

        // Create code-reviews directory
        $reviewsDir = base_path('.ai/code-reviews');
        if (! File::exists($reviewsDir)) {
            File::makeDirectory($reviewsDir, 0755, true);
            $this->info('✓ Created .ai/code-reviews/ directory');
        }

        // Update .gitignore
        $gitignorePath = base_path('.gitignore');
        if (File::exists($gitignorePath)) {
            $gitignoreContent = File::get($gitignorePath);

            $entriesToAdd = [
                '.ai/code-reviews/' => '# AI Code Review files',
                '.ai/ignore.yml' => '# AI Review ignore list'
            ];

            foreach ($entriesToAdd as $entry => $comment) {
                if (! str_contains($gitignoreContent, $entry)) {
                    $gitignoreEntry = "\n$comment\n$entry\n";
                    File::append($gitignorePath, $gitignoreEntry);
                    $this->info("✓ Added $entry to .gitignore");
                }
            }
            
            if (str_contains($gitignoreContent, '.ai/code-reviews') && str_contains($gitignoreContent, '.ai/ignore.yml')) {
                $this->info('✓ .gitignore already configured');
            }
        }

        // Check and update composer.json
        $this->updateComposerJson();

        $this->newLine();
        $this->info('═══════════════════════════════════════════');
        $this->info('  ✨ AI Code Review installed successfully!');
        $this->info('═══════════════════════════════════════════');
        $this->newLine();

        $this->info('Usage:');
        $this->info('  <fg=cyan>composer ai-review</> - Comprehensive review of all uncommitted changes');
        $this->info('  <fg=cyan>composer ai-review-staged</> - Comprehensive review of staged changes only');
        $this->newLine();

        $this->info('Integration examples:');
        $this->info('  <fg=yellow>composer ai-review</>');
        $this->info('  <fg=yellow>composer pint && composer ai-review && git commit</>');
        $this->newLine();

        // Check if Claude CLI is available
        exec('which claude', $output, $returnCode);
        if ($returnCode !== 0) {
            $this->warn('⚠ Claude CLI not found in PATH');
            $this->info('  Install Claude Code from: https://claude.ai/code');
            $this->info('  The hook will skip gracefully until Claude is installed');
            $this->newLine();
        } else {
            $this->info('<fg=green>✓</> Claude CLI detected at: '.$output[0]);
            $this->newLine();
        }

        return self::SUCCESS;
    }

    private function updateComposerJson(): void
    {
        $composerPath = base_path('composer.json');
        
        if (! File::exists($composerPath)) {
            $this->warn('⚠ composer.json not found');
            return;
        }

        $composerContent = json_decode(File::get($composerPath), true);
        
        if (! $composerContent) {
            $this->warn('⚠ Could not parse composer.json');
            return;
        }

        $scriptsToAdd = [
            'ai-review' => ['./.ai/scripts/ai-reviewer.sh'],
            'ai-review-staged' => ['./.ai/scripts/ai-reviewer.sh staged'],
        ];

        $updated = false;
        
        foreach ($scriptsToAdd as $scriptName => $scriptCommand) {
            if (! isset($composerContent['scripts'][$scriptName])) {
                $composerContent['scripts'][$scriptName] = $scriptCommand;
                $updated = true;
                $this->info("✓ Added '{$scriptName}' script to composer.json");
            } else {
                $this->info("✓ '{$scriptName}' script already exists in composer.json");
            }
        }

        if ($updated) {
            $updatedJson = json_encode($composerContent, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
            File::put($composerPath, $updatedJson);
            $this->info('✓ Updated composer.json');
        }
    }
}
