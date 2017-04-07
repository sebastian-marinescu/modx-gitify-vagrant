/*=====================================
=            Configuration            =
=====================================*/

$database_name = "dbname"
$database_user = "username"
$database_password = "dbpassword"

/*-----  End of Configuration  ------*/



/*==========  Do not change below  ==========*/


/*===================================================
=            Generic Webserver and MySQL            =
===================================================*/
$packages = ["build-essential", "bison", "rake", "zlib1g-dev", "libyaml-dev", "libssl-dev", "libreadline-dev", "libncurses5-dev", "llvm", "llvm-dev", "libeditline-dev", "libedit-dev", "clang-3.5", "git", "php5-curl", "php5-gd"]

exec { "update":
    command => "apt-get update",
    path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}
->
package { $packages: ensure => "installed" }
->
class { 'apache':
	default_vhost => false,
	mpm_module => "prefork"
}

# Install PHP, Mod_Rewrite, etc
class {'::apache::mod::php':}
class {'::apache::mod::rewrite':}
class {'::apache::mod::proxy':}
class {'::apache::mod::proxy_http':}


# Ensure the /var/www folder is available
file { '/var/www/':
    ensure  => directory,
    force   => true,
    purge   => false
}->
file { '/var/www/project':
    ensure  => directory,
    force   => true,
    purge   => false
}->
apache::vhost { "project.local":
    port          => '80',
    docroot       => "/var/www/project",
    directories  => [
            { 
                path => "/var/www/project",
                allow_override => ['All']
            }
          ],
}

# Override the default timezone
file {'/etc/php5/apache2/conf.d/50-override-default-settings.ini':
  ensure => present,
  owner => root, group => root, mode => 444,
  content => "date.timezone = Europe/Amsterdam\nerror_reporting = E_ALL\ndisplay_errors = On",
  require => Class[::apache::mod::php]
}

# Change user
file_line { 'ApacheUser':
  path  => '/etc/apache2/apache2.conf',
  line  => 'User vagrant',
  match => 'User www-data',
  require => Package["apache2"],
  notify  => Service["apache2"],
}

# Change Group
file_line { 'ApacheGroup':
  path  => '/etc/apache2/apache2.conf',
  line  => 'Group vagrant',
  match => 'Group www-data',
  require => Package["apache2"],
  notify  => Service["apache2"],
}


class { '::mysql::server':
  root_password           => 'modx',
  require => Exec["update"]
}->
class { 'mysql::bindings': 
    php_enable => true
}->
mysql::db { $database_name:
  user     => $database_user,
  password => $database_password,
  host     => 'localhost',
  grant    => ['ALL'],
}


/* Install Adminer */
apache::vhost { "adminer.local":
    port          => '8080',
    docroot       => "/var/www/adminer",
    directories  => [
            { 
                path => "/var/www/adminer",
                allow_override => ['All']
            }
          ],
}->
file { "/var/www/adminer":
    ensure => 'directory',
    mode => '775'
}->
exec { "adminer":
    command => "wget -O ./index.php http://www.adminer.org/latest-mysql-en.php",
    path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    cwd => "/var/www/adminer/",
    creates => "/var/www/adminer/index.php",
}->
exec { "less_ugly_adminer_css":
    command => "wget -O ./adminer.css https://raw.github.com/vrana/adminer/master/designs/nette/adminer.css",
    path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    cwd => "/var/www/adminer/",
    creates => "/var/www/adminer/adminer.css",
}

/*-----  End of Generic Webserver and MySQL  ------*/
