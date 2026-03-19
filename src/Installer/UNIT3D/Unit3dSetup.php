<?php

namespace App\Installer\UNIT3D;

use App\Installer\BaseInstaller;

class Unit3dSetup extends BaseInstaller
{
    public function handle()
    {
        $this->clone();

        $this->env();

        $this->perms();

        $this->crons();

        $this->setup();
    }

    protected function clone()
    {
        $this->io->writeln('<fg=blue>Cloning Source Files from your Repository</>');
        $this->seperator();

        $install_dir = $this->config->os('install_dir');
        $url = $this->config->app('repository');

        if (is_dir($install_dir)) {
            $this->process(["rm -rf $install_dir"]);
        }

        // Клонираме директно в инсталационната папка
        $this->process(["git clone $url $install_dir"]);

        if (!is_dir($install_dir)) {
            $this->throwError('Something went wrong with the cloning process. Check your repository URL!');
        }
    }

    protected function env()
    {
        $this->io->writeln("\n\n<fg=blue>Preparing the '.env' File for v9.2.0</>");
        $this->seperator();

        $install_dir = $this->config->os('install_dir');

        if (file_exists("$install_dir/.env")) {
            $this->process(["rm $install_dir/.env"]);
        }

        $this->createFromStub(
            [
                '{{PROTOCOL}}'      => $this->config->app('ssl') == 'yes' ? 'https' : 'http',
                '{{FQDN}}'          => $this->config->app('hostname'),
                '{{DBDRIVER}}'      => strtolower($this->config->app('database_driver')),
                '{{DB}}'            => $this->config->app('db'),
                '{{DBUSER}}'        => $this->config->app('dbuser'),
                '{{DBPASS}}'        => $this->config->app('dbpass'),
                '{{OWNER}}'         => $this->config->app('owner'),
                '{{OWNEREMAIL}}'    => $this->config->app('owner_email'),
                '{{OWNERPASSWORD}}' => $this->config->app('password'),
                '{{TMDBAPIKEY}}'    => $this->config->app('tmdb-key'),
                '{{MAILDRIVER}}'    => $this->config->app('mail_driver'),
                '{{MAILHOST}}'      => $this->config->app('mail_host'),
                '{{MAILPORT}}'      => $this->config->app('mail_port'),
                '{{MAILUSERNAME}}'  => $this->config->app('mail_username'),
                '{{MAILPASSWORD}}'  => $this->config->app('mail_password'),
                '{{MAILFROMNAME}}'  => $this->config->app('mail_from_name'),
                // ДОБАВЯМЕ MEILISEARCH ТУК
                '{{MEILI_HOST}}'    => $this->config->app('meilisearch_host'),
                '{{MEILI_KEY}}'     => $this->config->app('meilisearch_key'),
            ],
            '../.env.stub',
            "$install_dir/.env"
        );

        $this->io->writeln('<fg=green>OK: .env file created with Meilisearch support.</>');
    }

    protected function perms()
    {
        $this->io->writeln("\n<fg=blue>Setting Proper Permissions</>");
        $this->seperator();

        $install_dir = $this->config->os('install_dir');
        $web_user = $this->config->os('web-user');

        $this->process([
            "chown -R $web_user:$web_user " . $install_dir,
            "find $install_dir -type d -exec chmod 0775 '{}' +",
            "find $install_dir -type f -exec chmod 0664 '{}' +",
            "chmod 750 $install_dir/artisan",
            "chmod 640 $install_dir/.env"
        ]);
        
        // Важно за Laravel: storage и cache трябва да са writable
        $this->process([
            "chmod -R 775 $install_dir/storage",
            "chmod -R 775 $install_dir/bootstrap/cache"
        ]);
    }

    protected function setup()
    {
        $this->io->writeln("\n\n<fg=blue>Running Core Installation Commands (This may take a while)</>");
        $this->seperator();

        $install_dir = $this->config->os('install_dir');
        $web_user = $this->config->os('web-user');

        // Списък с команди за изпълнение
        $www_cmds = [
            'composer install --no-interaction --optimize-autoloader',
            'bun install',
            'bun run build',
            'php artisan key:generate --force',
            'php artisan migrate --seed --force',
            'php artisan scout:sync', // Синхронизиране на Meilisearch
            'php artisan storage:link'
        ];

        foreach ($www_cmds as $cmd) {
            $this->io->writeln("<fg=yellow>Executing: $cmd</>");
            $this->process([
                "su $web_user -s /bin/bash --command=\"cd $install_dir && $cmd\""
            ], true);
        }

        $this->io->writeln('<fg=green>Web Site Setup Completed!</>');
    }

    protected function crons()
    {
        $this->io->writeln("\n\n<fg=blue>Setting Up Laravel Scheduler</>");
        $this->seperator();

        $install_dir = $this->config->os('install_dir');
        $web_user = $this->config->os('web-user');

        // Добавяме крона директно към www-data потребителя
        $this->process([
            "echo \"* * * * * php $install_dir/artisan schedule:run >> /dev/null 2>&1\" | crontab -u $web_user -"
        ]);
    }
}
