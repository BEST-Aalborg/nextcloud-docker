./cockroach sql --url="$(cat server.url)" \
    --execute 'SET CLUSTER SETTING sql.defaults.serial_normalization = "virtual_sequence";'

#./cockroach sql --url="$(cat server.url)" \
#    --execute 'ALTER ROLE ALL SET sql.defaults.serial_normalization = "virtual_sequence";'

./cockroach sql --url="$(cat server.url)" \
    --execute "DROP DATABASE IF EXISTS ${COCKROACH_DATABASE}; CREATE DATABASE ${COCKROACH_DATABASE};"

