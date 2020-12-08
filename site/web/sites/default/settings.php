<?php

$settings['hash_salt'] = 'd1zgPClTZwge8yO4TsU9TFKtS7q8Qv9kjOzGow-iNYj_G8bM5t8vGXBs7lE6Y9avQWXGXwF6jg';
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.yml';
$settings['file_scan_ignore_directories'] = [
  'node_modules',
  'bower_components',
];
$settings['entity_update_batch_size'] = 50;
$settings['entity_update_backup'] = TRUE;
$settings['migrate_node_migrate_type_classic'] = FALSE;
$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'drupal',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);
$settings['config_sync_directory'] = 'sites/default/files/config_0Ks9PnWaQ102Rck0sIptMbUmHiCgSMeOzKBUm4oqpozaZLG0ycNOMXlvsJP2_eZrlsqseN03nw/sync';

$colour = exec("hostname");
$config['environment_indicator.indicator']['bg_color'] = $colour;
$config['environment_indicator.indicator']['name'] = ucfirst($colour);
