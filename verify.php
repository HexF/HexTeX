<?php

/**
 * We do this because there is no libsodium wrapper for bash :(
 * PHP natively supports it so we just use this...
 */

$PUBLIC_KEY = hex2bin($argv[1]);
$SIGNATURE = hex2bin($argv[2]);
$MESSAGE = utf8_encode(fgets(STDIN));

$result = sodium_crypto_sign_verify_detached($SIGNATURE, $MESSAGE, $PUBLIC_KEY);

if($result) exit(0); else exit(1);
