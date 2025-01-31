# Disable login / automatic login
SERVER_MODE = False
MASTER_PASSWORD_REQUIRED = False

# Allow connections from outside the container
DEFAULT_SERVER = '0.0.0.0'

# The `config_distro.py` when installing through Pip does not contain these
# paths. We must specify them so pgAdmin4 can backup, restore, ...
# (any external process that require invoking `/usr/bin/pg_*`)
DEFAULT_BINARY_PATHS = {
    "pg": "/usr/bin",
    "pg-13": "",
    "pg-14": "",
    "pg-15": "",
    "pg-16": "",
    "pg-17": "",
    "ppas": "/usr/bin",
    "ppas-13": "",
    "ppas-14": "",
    "ppas-15": "",
    "ppas-16": "",
    "ppas-17": ""
}

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
