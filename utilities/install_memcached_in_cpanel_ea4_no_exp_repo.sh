#!/bin/bash

# /**
#  * @version    1.9.0
#  * @package    Engintron for cPanel/WHM
#  * @author     Fotis Evangelou
#  * @url        https://engintron.com
#  * @copyright  Copyright (c) 2010 - 2018 Nuevvo Webware P.C. All rights reserved.
#  * @license    GNU/GPL license: https://www.gnu.org/copyleft/gpl.html
#  */

CACHE_SIZE="256M"
MEMCACHED_FOR_PHP5="https://pecl.php.net/get/memcached-2.2.0.tgz"
MEMCACHED_FOR_PHP7="https://pecl.php.net/get/memcached-3.0.4.tgz"

if [[ $1 ]]; then
    CACHE_SIZE=$1
fi

clear

echo " ****************************************************"
echo " *               Installing Memcached               *"
echo " ****************************************************"

# Let's update the system first
yum clean all
yum -y update
yum -y upgrade

# Install memcached & start it
yum -y install memcached memcached-devel libmemcached libmemcached-devel
service memcached start
chkconfig memcached on

# Adjust its cache size to 512M & restart
if [ -e "/etc/sysconfig/memcached" ]; then
    sed -i 's/CACHESIZE=.*/CACHESIZE="'${CACHE_SIZE}'"/' /etc/sysconfig/memcached
fi
service memcached restart

# Install related PHP modules for PHP versions 5.6 to 7.2
# Setup Memcached 2.x for PHP 5.6
if [ -f /opt/cpanel/ea-php56/root/usr/bin/pecl ]; then
    echo "*************************************"
    echo "*    Installing Memcached for PHP 5.6    *"
    echo "*************************************"
    echo ""

    echo | /opt/cpanel/ea-php56/root/usr/bin/pecl install -f $MEMCACHED_FOR_PHP5
    touch /opt/cpanel/ea-php56/root/etc/php.d/memcached.ini
    cat > "/opt/cpanel/ea-php56/root/etc/php.d/memcached.ini" <<EOF
[memcached]
extension=/opt/cpanel/ea-php56/root/usr/lib64/php/modules/memcached.so

EOF

    echo ""
    echo "************************************************"
    echo "* Memcached for PHP 5.6 is now installed"
    echo "************************************************"
    echo ""
    echo ""

fi

# Setup Memcached 3.x for PHP 7.0
if [ -f /opt/cpanel/ea-php70/root/usr/bin/pecl ]; then
    echo "*************************************"
    echo "*    Installing Memcached for PHP 7.0    *"
    echo "*************************************"
    echo ""

    echo | /opt/cpanel/ea-php70/root/usr/bin/pecl install -f $MEMCACHED_FOR_PHP7
    touch /opt/cpanel/ea-php70/root/etc/php.d/memcached.ini
    cat > "/opt/cpanel/ea-php70/root/etc/php.d/memcached.ini" <<EOF
[memcached]
extension=/opt/cpanel/ea-php70/root/usr/lib64/php/modules/memcached.so

EOF

    echo ""
    echo "************************************************"
    echo "* Memcached for PHP 7.0 is now installed"
    echo "************************************************"
    echo ""
    echo ""

fi

# Setup Memcached 3.x for PHP 7.1
if [ -f /opt/cpanel/ea-php71/root/usr/bin/pecl ]; then
    echo "*************************************"
    echo "*    Installing Memcached for PHP 7.1    *"
    echo "*************************************"
    echo ""

    echo | /opt/cpanel/ea-php71/root/usr/bin/pecl install -f $MEMCACHED_FOR_PHP7
    touch /opt/cpanel/ea-php71/root/etc/php.d/memcached.ini
    cat > "/opt/cpanel/ea-php71/root/etc/php.d/memcached.ini" <<EOF
[memcached]
extension=/opt/cpanel/ea-php71/root/usr/lib64/php/modules/memcached.so

EOF

    echo ""
    echo "************************************************"
    echo "* Memcached for PHP 7.1 is now installed"
    echo "************************************************"
    echo ""
    echo ""

fi

# Setup Memcached 3.x for PHP 7.2
if [ -f /opt/cpanel/ea-php72/root/usr/bin/pecl ]; then
    echo "*************************************"
    echo "*    Installing Memcached for PHP 7.2    *"
    echo "*************************************"
    echo ""

    echo | /opt/cpanel/ea-php72/root/usr/bin/pecl install -f $MEMCACHED_FOR_PHP7
    touch /opt/cpanel/ea-php72/root/etc/php.d/memcached.ini
    cat > "/opt/cpanel/ea-php72/root/etc/php.d/memcached.ini" <<EOF
[memcached]
extension=/opt/cpanel/ea-php72/root/usr/lib64/php/modules/memcached.so

EOF

    echo ""
    echo "************************************************"
    echo "* Memcached for PHP 7.2 is now installed"
    echo "************************************************"
    echo ""
    echo ""

fi

# Cleanup apsu.so entries in cPanel's PHP config files
find /opt/cpanel/ -name "local.ini" | xargs grep -l "memcached.so" | xargs sed -i "s/(\;)extension.*memcached\.so//"
find /opt/cpanel/ -name "*pecl.ini" | xargs grep -l "memcached.so" | xargs sed -i "s/.*\"memcached\.so\"//"

# Finish things up by restarting web services
service memcached restart

# Restart Apache & PHP-FPM
if [ "$(pstree | grep 'httpd')" ]; then
    echo "Restarting Apache..."
    /scripts/restartsrv apache_php_fpm
    /scripts/restartsrv_httpd
    echo ""
fi

# Restart Nginx (if it's installed via Engintron)
if [ "$(pstree | grep 'nginx')" ]; then
    echo "Restarting Nginx..."
    service nginx restart
    echo ""
fi

# Print out useful info
memcached -h
php -i | grep -i memcached

echo " ****************************************************"
echo " *         Memcached installation complete          *"
echo " ****************************************************"