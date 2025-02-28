appliance_url '${appliance_url}'
app_dir '/opt/morpheus'

elasticsearch['host'] = '${opensearch_host}'
elasticsearch['port'] = ${opensearch_port}
elasticsearch['use_tls'] = true

rabbitmq['host'] = '${rabbitmq_host}'
rabbitmq['port'] = ${rabbitmq_port}
rabbitmq['vhost'] = '${rabbitmq_vhost}'
rabbitmq['username'] = '${rabbitmq_user}'
rabbitmq['password'] = '${rabbitmq_password}'
rabbitmq['use_tls'] = true

mysql['host'] = '${db_host}'
mysql['port'] = ${db_port}
mysql['database'] = '${db_name}'
mysql['username'] = '${db_user}'
mysql['password'] = '${db_password}'

nginx['ssl']['enabled'] = true
nginx['ssl']['protocols'] = "TLSv1.2 TLSv1.3"
nginx['workers'] = 4

# High availability settings
high_availability['enabled'] = true
high_availability['zone'] = '${availability_zone}'

# Shared storage configuration
shared_storage['enabled'] = true
shared_storage['mount_path'] = '/morpheus/lib'

# Session management using Redis
sessions['store'] = 'redis'
sessions['redis']['host'] = '${redis_host}'
sessions['redis']['port'] = ${redis_port}
sessions['redis']['password'] = '${redis_auth_token}'
sessions['redis']['ssl'] = true

# Performance settings
web_workers = 4
job_workers = 4

# JVM configuration
java_args = '-Xms4g -Xmx8g -XX:+UseG1GC -XX:+UseStringDeduplication'