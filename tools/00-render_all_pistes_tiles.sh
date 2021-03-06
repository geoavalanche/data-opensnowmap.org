osmosis=/home/admin/src/osmosis/bin/osmosis
WORK_DIR=/home/admin/Planet/
cd ${WORK_DIR}
# This script log
LOGFILE=${WORK_DIR}log/planet_update.log
# Directory where the planet file is stored
PLANET_DIR=${WORK_DIR}data/
TMP_DIR=${WORK_DIR}tmp/
TOOLS_DIR=${WORK_DIR}tools/

today=$(date --date="today" +%Y-%m-%d)

echo $(date)' Render tiles '>> $LOGFILE
echo $(date)' Render tiles '
pwd
#~ ${TOOLS_DIR}./tile-list-from-db.py  -o all_tiles-$today.tilelist -z 0 -Z 15
#~ cat all_tiles-$today.tilelist | sort | uniq > uniq.lst
cat all_tiles-2014-01-08.lst | sort | uniq > uniq.lst
cat uniq.lst | render_list --num-threads=6 -s /var/run/renderd/renderd.sock -m pistes -f
if [ $? -ne 0 ]
then
    echo $(date)' FAILED Render tiles'>> $LOGFILE
    exit 4
else echo $(date)' Render tiles succeed '>> $LOGFILE
fi

#~ cat uniq.lst | render_list -s /var/run/renderd/renderd.sock -m single
#~ if [ $? -ne 0 ]
#~ then
    #~ echo $(date)' FAILED Render tiles'>> $LOGFILE
    #~ exit 4
#~ else echo $(date)' Render tiles succeed '>> $LOGFILE
#~ fi
