export DEV_DB="limespot_dev"
export DEV_USER="rails"
export DEV_PASS="rails"
export DEV_HOST="localhost"

export TEST_DB="limespot_test"
export TEST_USER="rails"
export TEST_PASS="rails"
export TEST_HOST="localhost"

export MYSQL_SOCK="/opt/local/var/run/mysql5/mysqld.sock"

# alias e=/Applications/Emacs.app/Contents/MacOS/Emacs
