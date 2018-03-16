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

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get install -y curl \
    && apt-get -y autoclean

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 4.4.7

# Install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# Install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install bzip2
RUN apt-get install -y bzip2

# Install Grunt
RUN npm install -g grunt-cli

# Make everything available to all users
RUN n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin/*; cp -r $n/{bin,lib,share} /usr/local