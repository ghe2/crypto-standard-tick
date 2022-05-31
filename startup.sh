#!/bin/bash
# Sourcing Environment to get the ON_DISK_HDB directory
#source environment.sh
BASE_DIRECTORY=$(cd $(dirname $0) && pwd)
ON_DISK_HDB=${BASE_DIRECTORY}/OnDiskDB
echo "Operating out of directory: ${BASE_DIRECTORY}"
echo "On Disk DB set to: ${ON_DISK_HDB}"
# Checking if directories exist

if [ ! -d $ON_DISK_HDB ]
then
    echo "Creating On Disk DB $ON_DISK_HDB"
    mkdir -p $ON_DISK_HDB
fi

if [ ! -d ${ON_DISK_HDB}/sym ]
then
    echo "Creating On Disk DB ${ON_DISK_HDB}/sym"
    mkdir -p ${ON_DISK_HDB}/sym
fi

if [ ! -d ${BASE_DIRECTORY}/logs ]
then
    echo "Creating logs directory ${BASE_DIRECTORY}/logs"
    mkdir -p ${BASE_DIRECTORY}/logs
fi
HDB_STARTUP_DIR=${ON_DISK_HDB}/sym
TICK_DIRECTORY=${BASE_DIRECTORY}/tick
LOG_DIRECTORY=${BASE_DIRECTORY}/logs

echo "Starting Dashboards"
cd $BASE_DIRECTORY
cd dash
q sample/demo.q -u 1 &
q dash.q -p 10001 -u 1 &

cd $BASE_DIRECTORY
q tick.q sym $ON_DISK_HDB -p 5000 -t 200 > ${LOG_DIRECTORY}/tp.log 2>&1 &
q hdb.q $HDB_STARTUP_DIR -p 5002 > ${LOG_DIRECTORY}/hdb.log 2>&1 &

cd $TICK_DIRECTORY
q r.q localhost:5000 localhost:5002 -p 5008 > ${LOG_DIRECTORY}/rdb.log 2>&1 &
q chainedr.q localhost:5000 -p 5112 > ${LOG_DIRECTORY}/chainedr.log 2>&1 &
q wschaintick_0.2.2.q localhost:5000 -p 5110 -t 1000 > ${LOG_DIRECTORY}/wschaintick.log 2>&1 & 
q gw.q localhost:5002 localhost:5008 -p 5005 > ${LOG_DIRECTORY}/gw.log 2>&1 &

cd $BASE_DIRECTORY
q feedhandler_bitmexBitfinex.q -p 5111 > ${LOG_DIRECTORY}/feedhandler.log 2>&1 &
