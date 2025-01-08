# Disable login / automatic login
SERVER_MODE = False
MASTER_PASSWORD_REQUIRED = False

# Change some paths for data and logs
# (because we have forced desktop-mode)
DATA_DIR = '/var/lib/pgadmin4'
LOG_FILE = '/var/log/pgadmin4/pgadmin4.log'
SQLITE_PATH = '/var/lib/pgadmin4/pgadmin4.db'
SESSION_DB_PATH = '/var/lib/pgadmin4/sessions'
STORAGE_DIR = '/home/pgadmin'

# Logs
FILE_LOG_LEVEL = 20 # Info

# Enable PSQL just in case
# (it introduces critical security flaws because we can run arbitrary code, but it's a Docker container so it's okay)
ENABLE_PSQL = True
