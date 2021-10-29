external_url 'https://git.geektr.co'

nginx['listen_port'] = 80
nginx['listen_https'] = false

gitlab_rails['internal_api_url'] = 'https://git.geektr.co'

nginx['custom_error_pages'] = {
  '404' => {
    'title' => '404 Not Found',
    'header' => 'Ooooops!',
    'message' => '根据相关法律法规和政策，部分结果未予显示'
  }
}

gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'yumemi@ch-postal.com'
gitlab_rails['gitlab_email_display_name'] = 'Yumemi'
gitlab_rails['gitlab_email_reply_to'] = 'noreply@ch-postal.com'
gitlab_rails['gitlab_email_subject_suffix'] = '[GeekTR/Git]'

gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = 'smtp.exmail.qq.com'
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_authentication'] = 'login'
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['smtp_user_name'] = 'yumemi@ch-postal.com'
gitlab_rails['smtp_password'] = '${SMTP_PASSWORD}'
gitlab_rails['smtp_domain'] = 'exmail.qq.com'

user['git_user_email'] = 'yumemi@ch-postal.com'

minio_configuration = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_signature_version' => 4,
  'path_style' => true,
  'enable_signature_v4_streaming' => true,
  'host' => 'minio.geektr.co',
  'endpoint' => 'https://minio.geektr.co:9091',
  'aws_access_key_id' => '${AWS_ACCESS_KEY_ID}',
  'aws_secret_access_key' => '${AWS_SECRET_ACCESS_KEY}'
}

gitlab_rails['lfs_enabled'] = true

gitlab_rails['lfs_object_store_enabled'] = true
gitlab_rails['lfs_object_store_direct_upload'] = false
gitlab_rails['lfs_object_store_remote_directory'] = "gitlab-lfs"
gitlab_rails['lfs_object_store_connection'] = minio_configuration

gitlab_rails['uploads_object_store_enabled'] = true
gitlab_rails['uploads_object_store_direct_upload'] = false
gitlab_rails['uploads_object_store_remote_directory'] = "gitlab-uploads"
gitlab_rails['uploads_object_store_connection'] = minio_configuration

gitlab_rails['external_diffs_enabled'] = true
gitlab_rails['external_diffs_object_store_enabled'] = true
gitlab_rails['external_diffs_object_store_remote_directory'] = "gitlab-extdiffs"
gitlab_rails['external_diffs_object_store_connection'] = minio_configuration

gitlab_rails['gitlab_default_projects_features_container_registry'] = false

registry_external_url 'https://registry.geektr.co'

registry_nginx['listen_port'] = 5001
registry_nginx['listen_https'] = false
registry_nginx['proxy_set_headers'] = {
  "Host" => "$http_host",
  "X-Real-IP" => "$remote_addr",
  "X-Forwarded-For" => "$proxy_add_x_forwarded_for",
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
}
registry['enable'] = true
registry['host'] = 'registry.geektr.co'
registry['storage'] = {
  's3' => {
    'accesskey' => minio_configuration['aws_access_key_id'],
    'secretkey' => minio_configuration['aws_secret_access_key'],
    'bucket' => 'gitlab-registry',
    'region' => minio_configuration['region'],
    'regionendpoint' => minio_configuration['endpoint'],
    'v4auth' => true,
    'chunksize' => 10485760
  }
}
registry['env'] = {
  "REGISTRY_HTTP_RELATIVEURLS" => true
}
