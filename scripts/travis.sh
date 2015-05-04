cd drupal
php -d sendmail_path=`which true` ~/.composer/vendor/bin/drush.php si --db-url="mysql://$DB_USERNAME@127.0.0.1/$DATABASE" --keep-config -y
drush cset system.site uuid b1a21ab8-84c4-4028-bb09-9f3f9935cb51 -y
drush pm-uninstall contact -y
drush delete-shortcuts
echo "\$config_directories['staging'] = 'config/staging';" | sudo tee -a sites/default/settings.php
drush cim staging -y
# enable php-fpm
sudo cp ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf.default ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf
sudo a2enmod rewrite actions fastcgi alias
echo "cgi.fix_pathinfo = 1" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini
~/.phpenv/versions/$(phpenv version-name)/sbin/php-fpm
# configure apache virtual hosts
sudo cp -f build/travis-ci-apache /etc/apache2/sites-available/default
sudo sed -e "s?%TRAVIS_BUILD_DIR%?$(pwd)?g" --in-place /etc/apache2/sites-available/default
sudo service apache2 restart
