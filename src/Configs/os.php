<?php

return [

    /*
     * Ubuntu 24.04 (Noble Numbat) Configuration
     * * Този списък съдържа системните пакети, които инсталаторът 
     * ще провери и инсталира чрез APT.
     */
    'ubuntu' => [
        'pkg_manager' => 'apt-get',
        'web-user'    => 'www-data',
        'install_dir' => '/var/www/html',
        'nginx-sites-available_path' => '/etc/nginx/sites-available',

        'software' => [
            'build-essential' => 'Basic C/C++ Development Environment',
            'nginx'           => 'High-performance Web Server',
            'mysql-server'    => 'MySQL Database Server',
            'supervisor'      => 'Process Control System (for Queues)',
            'nodejs'          => 'JavaScript Run-time Environment (Includes npm)',
            'git'             => 'Version Control System',
            'tmux'            => 'Terminal Multiplexer',
            'vim'             => 'Advanced Text Editor',
            'wget'            => 'File Download Tool',
            'curl'            => 'Data Transfer Tool',
            'zip'             => 'File Compression Tool',
            'unzip'           => 'File Decompression Tool',
            'htop'            => 'Interactive Process Viewer',
            'cron'            => 'Job Scheduler Daemon',
            'ufw'             => 'Uncomplicated Firewall',
            'ca-certificates' => 'Common CA Certificates',
            'gnupg'           => 'GNU Privacy Guard (Encryption)',
        ],
    ]

];
