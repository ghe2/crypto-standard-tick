#!/bin/bash

set -o errexit

stdout() { echo -e "$(hostname | cut -c -12) $(date "+%Y.%m.%d %H:%M:%S.%3N:") $1" ; }

finish() {
    res=$?
    if [[ 0 -ne $res ]]; then
        stdout "ERROR: script did not exit succesfully. Exit code $res"
    fi
}
trap finish EXIT

if [[ ! $2 || ! -d $2 ]]
        then
                echo "Expecting number of days and directory as arguments"
                exit 1
fi

stdout "Running $(basename $0) on directory $2. Deleting ALL files older than $1 days"

cd $2

#FILESFOUND = $(find . -maxdepth 1 -type f -mtime +$1)
#echo "$FILESFOUND"
find . -maxdepth 1 -type f -mmin +$1 -exec rm -f {} \;
stdout "Deleted files in $2 older than $1 days. Exiting"