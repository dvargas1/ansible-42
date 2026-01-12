#!/bin/sh

if [ ! -d "/database/$DB_NAME" ]
then
	mysqld_safe --datadir=/database & #start server
	i=30
	while [ $i -gt 0 ]; do
	    if mysqladmin ping >/dev/null 2>&1; then
	        break
	    fi
	    echo "Waiting for MariaDB... ($i)"
	    sleep 1
	    i=$((i-1))
	done

#secure installaiton
mariadb-secure-installation << END

y
y
$MARIADB_ROOT_PASSWD
$MARIADB_ROOT_PASSWD
y
n
y
y
END

	#Create user
	mysql -e "CREATE DATABASE $DB_NAME;CREATE USER $MARIADB_USR@'%'\
		IDENTIFIED BY '$MARIADB_PASSWD';GRANT ALL PRIVILEGES ON $DB_NAME.* TO \
		$MARIADB_USR@'%';FLUSH PRIVILEGES;"

	mysqladmin -u root shutdown #shutdown server
fi

exec mysqld_safe --datadir=/database
