FROM alexcheng/magento2

MAINTAINER A. Marquis <mrupsidown@gmail.com>

# Add magento CLI to system path
ENV PATH "$PATH:/var/www/html/bin"