server {
    listen 80;

    server_name {{ server_name }};
    root        {{ doc_root }};

    access_log /var/log/nginx/{{ server_name }}.access.log;
    error_log /var/log/nginx/{{ server_name }}.error.log error;

    location = /js/index.php/x.js {
        rewrite ^(.*\.php)/ $1 last;
    }

    ## Main Magento @location
    location / {
        index index.php;
        try_files $uri $uri/ @rewrite;
        expires max;
    }

    location /. {
        return 404;
    }

    ## Images
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
        access_log off;
        add_header ETag "";
    }

    location @rewrite {
    rewrite / /index.php;
    }

    location ~ \.php$ {
        try_files $uri =404;
        expires off;
        fastcgi_intercept_errors off;
        fastcgi_pass  unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_script_name;
        fastcgi_read_timeout 180;

        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 16k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;

        include /etc/nginx/fastcgi_params;
    }

}
