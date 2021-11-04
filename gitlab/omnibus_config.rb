external_url 'https://git.geektr.co'

nginx['listen_port'] = 80
nginx['listen_https'] = false

gitlab_rails['internal_api_url'] = 'https://git.geektr.co'

nginx['custom_error_pages'] = {
  '404' => {
    'title' => '404 Not Found',
    'header' => 'Ooooooooops!',
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
gitlab_rails['smtp_password'] = ENV['EXT_SMTP_PASSWORD']
gitlab_rails['smtp_domain'] = 'exmail.qq.com'

user['git_user_name'] = "gitlab"
user['git_user_email'] = 'yumemi@ch-postal.com'

minio_configuration = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_signature_version' => 4,
  'enable_signature_v4_streaming' => true,
  'host' => 'anita.minio.geektr.co',
  'endpoint' => 'https://anita.minio.geektr.co:9002',
  'aws_access_key_id' => ENV['EXT_AWS_ACCESS_KEY_ID'],
  'aws_secret_access_key' => ENV['EXT_AWS_SECRET_ACCESS_KEY']
}

gitlab_rails['artifacts_enabled'] = true
gitlab_rails['lfs_enabled'] = true
gitlab_rails['external_diffs_enabled'] = true
gitlab_rails['packages_enabled'] = true
gitlab_rails['terraform_state_enabled'] = true

gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['proxy_download'] = false
gitlab_rails['object_store']['connection'] = minio_configuration
gitlab_rails['object_store']['objects']['artifacts']['bucket'] = 'gitlab-artifacts'
gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = 'gitlab-extdiffs'
gitlab_rails['object_store']['objects']['lfs']['bucket'] = 'gitlab-lfs'
gitlab_rails['object_store']['objects']['uploads']['bucket'] = 'gitlab-uploads'
gitlab_rails['object_store']['objects']['packages']['bucket'] = 'gitlab-packages'
gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = 'gitlab-depproxy'
gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = 'gitlab-tfstate'
gitlab_rails['object_store']['objects']['pages']['bucket'] = 'gitlab-pages'

gitlab_rails['gitlab_default_projects_features_container_registry'] = true

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
