
#~ createdb pistes-pgsnapshot
#~ psql -d pistes-pgsnapshot -f /usr/share/postgresql/9.1/contrib/postgis-2.0/postgis.sql
#~ psql -d pistes-pgsnapshot -f /usr/share/postgresql/9.1/contrib/postgis-2.0/spatial_ref_sys.sql
#~ echo "CREATE EXTENSION hstore;"  | psql -d pistes-pgsnapshot
#~ echo "CREATE EXTENSION pg_trgm;"  | psql -d pistes-pgsnapshot
#~ psql -d pistes-pgsnapshot -f /home/website/src/osmosis-0.43.1/script/pgsnapshot_schema_0.6.sql
#~ psql -d pistes-pgsnapshot -f /home/website/src/osmosis-0.43.1/script/pgsnapshot_schema_0.6_bbox.sql
#~ psql -d pistes-pgsnapshot -f /home/website/src/osmosis-0.43.1/script/pgsnapshot_schema_0.6_linestring.sql
#~ psql -d pistes-pgsnapshot -f /home/website/src/osmosis-0.43.1/script/pgsnapshot_schema_0.6_action.sql
#~ psql -d pistes-pgsnapshot -f /home/website/Planet/config/pgsnapshot_schema_0.6_relations_geometry.sql
#~ psql -d pistes-pgsnapshot -f /home/website/Planet/config/pgsnapshot_schema_0.6_names.sql
#~ psql -d pistes-pgsnapshot -f /home/website/Planet/config/pgsnapshot_schema_0.6_relations_types.sql
#~ 
#~ dropdb pistes-pgsnapshot-tmp
#~ createdb pistes-pgsnapshot-tmp
#~ psql -d pistes-pgsnapshot-tmp -f /usr/share/postgresql/9.1/contrib/postgis-2.0/postgis.sql
#~ psql -d pistes-pgsnapshot-tmp -f /usr/share/postgresql/9.1/contrib/postgis-2.0/spatial_ref_sys.sql
#~ echo "CREATE EXTENSION hstore;"  | psql -d pistes-pgsnapshot-tmp
#~ echo "CREATE EXTENSION pg_trgm;"  | psql -d pistes-pgsnapshot-tmp
#~ psql -d pistes-pgsnapshot-tmp -f /home/admin/src/osmosis/script/pgsnapshot_schema_0.6.sql
#~ psql -d pistes-pgsnapshot-tmp -f /home/admin/src/osmosis/script/pgsnapshot_schema_0.6_bbox.sql
#~ psql -d pistes-pgsnapshot-tmp -f /home/admin/src/osmosis/script/pgsnapshot_schema_0.6_linestring.sql
#~ psql -d pistes-pgsnapshot-tmp -f /home/admin/src/osmosis/script/pgsnapshot_schema_0.6_action.sql
## 94 s import
##$osmosis --rxc "test.osc" --wpc database="pistes-pgsnapshot-tmp";
##2 s
#~ psql -d pistes-pgsnapshot-tmp -f /home/admin/Planet/config/pgsnapshot_schema_0.6_relations_geometry.sql
#~ psql -d pistes-pgsnapshot-tmp -f /home/admin/Planet/config/pgsnapshot_schema_0.6_names.sql
#~ psql -d pistes-pgsnapshot-tmp -f /home/admin/Planet/config/pgsnapshot_schema_0.6_relations_types.sql
#~ ## 200s import

osmosis="/home/admin/src/osmosis/bin/osmosis"
WORK_DIR=/home/admin/Planet/
cd ${WORK_DIR}
# This script log
LOGFILE=${WORK_DIR}log/planet_update.log
# Directory where the planet file is stored
PLANET_DIR=${WORK_DIR}data/
TMP_DIR=${WORK_DIR}tmp/
TOOLS_DIR=${WORK_DIR}tools/
CONFIG_DIR=${WORK_DIR}config/

DBTMP=pistes-pgsnapshot-tmp
DB=pistes-pgsnapshot

TESTSIZE=$(stat -c%s ${PLANET_DIR}planet_pistes.osm)
if [ $TESTSIZE -gt 1000 ]
then echo $(date)' planet_pistes.osm ok, updating pgsnapshot DB'
    #Updating DB for osmosis:
    $osmosis --truncate-pgsql host="localhost" user="xapi" password="xapi" \
    database=$DBTMP
    if [ $? -ne 0 ]
    then
        echo $(date)' truncate DB failed'
        exit 5
    fi
    $osmosis --read-xml-change ${PLANET_DIR}landuse.osc \
    --sort-change --simplify-change \
    --read-xml ${PLANET_DIR}planet_pistes.osm \
    --apply-change \
    --write-pgsql host="localhost" database=$DBTMP user="xapi" password="xapi"
    if [ $? -ne 0 ]
    then
        echo $(date)' Osmosis failed to update pgsnapshot DB'
        exit 5
    fi
    echo $(date)' Drop pgsnapshot DB'
    dropdb $DB
    echo $(date)' Create pgsnapshot DB'
	createdb -T $DBTMP $DB
    
    #~ # Copy the total way length and last update.txt infos to the website
#~ 
else 
    echo $(date)' planet_pistes.osm empty'
    exit 5
fi

${TOOLS_DIR}./resort_list.py > ${PLANET_DIR}resorts.json
TESTSIZE=$(stat -c%s ${PLANET_DIR}resorts.json)
if [ $TESTSIZE -gt 10 ]
then 
	echo $(date)' resorts.json ok'
	cp ${PLANET_DIR}resorts.json /var/www/data

else 
    echo $(date)' resorts.json empty'
    exit 6
fi

