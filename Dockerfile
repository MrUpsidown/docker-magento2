FROM alexcheng/magento2:integrator

MAINTAINER A. Marquis <mrupsidown@gmail.com>

# Add magento CLI to system path
ENV PATH "$PATH:/var/www/html/bin"

# Install wget which is required to download xdebug
RUN apt-get update && apt-get install -y wget

# Install xdebug 2.6.0
RUN cd /tmp/ && wget http://xdebug.org/files/xdebug-2.6.0.tgz && tar -xvzf xdebug-2.6.0.tgz && cd xdebug-2.6.0/ && phpize && ./configure --enable-xdebug --with-php-config=/usr/local/bin/php-config && make && make install
RUN mkdir /usr/local/lib/php/extensions/no-debug-non-zts-20180129 && cd /tmp/xdebug-2.6.0 && cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20180129/

# Add xdebug configurations
RUN { \
        echo '[xdebug]'; \
        echo 'zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20180129/xdebug.so'; \
        echo 'xdebug.remote_enable=1'; \
        echo 'xdebug.remote_autostart=0'; \
        echo 'xdebug.remote_connect_back=0'; \
        echo 'xdebug.remote_handler=dbgp'; \
        echo 'xdebug.profiler_enable=0'; \
        echo 'xdebug.remote_port=9001'; \
        echo 'xdebug.remote_host=docker.for.mac.localhost'; \
    } > /usr/local/etc/php/conf.d/xdebug.ini