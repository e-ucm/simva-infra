To test the migration script to debug it run : 
./simva uninstall 07-simva/ && rm -rf data/simva/sqlite_init && docker volume rm simva_sqlite_data && ./simva start 07-simva/