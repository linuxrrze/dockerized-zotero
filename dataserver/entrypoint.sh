#!/bin/sh

# Env vars
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data
export APACHE_LOCK_DIR=/var/lock/apache2
export APACHE_PID_FILE=/var/run/apache2/apache2.pid
export APACHE_RUN_DIR=/var/run/apache2
export APACHE_LOG_DIR=/var/log/apache2

ROOT_DIR=/var/www/zotero

chmod 777 "$ROOT_DIR/tmp"
cd "$ROOT_DIR"
cp ./include/config/config.inc.php-template ./include/config/config.inc.php
cp ./include/config/dbconnect.inc.php-template ./include/config/dbconnect.inc.php

sed -i "s#\$BASE_URI = ''#\$BASE_URI = '$DATA_SERVER_URL'#g" ./include/config/config.inc.php
sed -i "s#\$API_BASE_URI = ''#\$API_BASE_URI = '$DATA_SERVER_URL'#g" ./include/config/config.inc.php
sed -i "s#\$WWW_BASE_URI = ''#\$WWW_BASE_URI = '$DATA_SERVER_URL'#g" ./include/config/config.inc.php
sed -i "s#\$S3_ENDPOINT = ''#\$S3_ENDPOINT = '$S3_ENDPOINT_URL'#g" ./include/config/config.inc.php

sed -i "s#\$AUTH_SALT = ''#\$AUTH_SALT = '$ZOTERO_AUTH_SALT'#g" ./include/config/config.inc.php
sed -i "s#\$API_SUPER_USERNAME = ''#\$API_SUPER_USERNAME = '$ZOTERO_API_SUPER_USERNAME'#g" ./include/config/config.inc.php
sed -i "s#\$API_SUPER_PASSWORD = ''#\$API_SUPER_PASSWORD = '$ZOTERO_API_SUPER_PASSWORD'#g" ./include/config/config.inc.php

sed -i "s#\$AWS_REGION = ''#\$AWS_REGION = '$AWS_DEFAULT_REGION'#g" ./include/config/config.inc.php
sed -i "s#\$AWS_ACCESS_KEY = ''#\$AWS_ACCESS_KEY = '$AWS_ACCESS_KEY_ID'#g" ./include/config/config.inc.php
sed -i "s#\$AWS_SECRET_KEY = ''#\$AWS_SECRET_KEY = '$AWS_SECRET_ACCESS_KEY'#g" ./include/config/config.inc.php

sed -i "s#\$pass = ''#\$pass = '$MYSQL_ROOT_PASSWORD'#g" ./include/config/dbconnect.inc.php

# Adapt zotero code to work on localhost
sed -i "s#'s3.amazonaws.com'#Z_CONFIG::\$S3_ENDPOINT#g" ./include/Zend/Service/Amazon/S3.php
sed -i "s#'http://'.self::S3_ENDPOINT#self::S3_ENDPOINT#g" ./include/Zend/Service/Amazon/S3.php
sed -i "s#parent::__construct(\$args)#\$args\['use_path_style_endpoint'\] = true;parent::__construct(\$args)#g" ./vendor/aws/aws-sdk-php/src/S3/S3Client.php
sed -i 's#"https://" . Z_CONFIG::\$S3_BUCKET . ".s3.amazonaws.com/"#Z_CONFIG::\$S3_ENDPOINT . "/" . Z_CONFIG::\$S3_BUCKET . "/"#g' ./model/Storage.inc.php
sed -i "s#\$awsConfig = \[#\$awsConfig = \['endpoint' => Z_CONFIG::\$S3_ENDPOINT,#g" ./include/header.inc.php

aws --endpoint-url "$AWS_ENDPOINT_URL" s3 mb s3://zotero
aws --endpoint-url "$AWS_ENDPOINT_URL" s3 mb s3://zotero-fulltext
aws --endpoint-url "$AWS_LOCALSTACK_ENDPOINT_URL" sns create-topic --name zotero

# Maybe disable rinetd forwarding?
if [ "x$ENABLE_S3_FORWARDING" != "no" ]; then
# Start rinetd
echo "0.0.0.0		$S3_SERVER_PORT		minio		$S3_SERVER_PORT" > /etc/rinetd.conf
/etc/init.d/rinetd start
fi

# Upgrade database
/init-mysql.sh

# Start Apache2
exec apache2 -DNO_DETACH -k start
