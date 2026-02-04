<?php
$cfg['blowfish_secret'] = 'k8F2jL9mR3xQ7wN1vT6yP0sA4dG5hB8c';
$cfg['Servers'][1]['host'] = getenv('PMA_HOST') ?: 'mariadb';
$cfg['Servers'][1]['port'] = getenv('PMA_PORT') ?: '3306';
$cfg['Servers'][1]['auth_type'] = 'cookie';
$cfg['PmaAbsoluteUri'] = '/phpmyadmin/';
$cfg['TempDir'] = '/tmp/phpmyadmin';
