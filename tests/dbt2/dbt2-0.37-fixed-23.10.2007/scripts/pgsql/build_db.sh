#!/bin/sh

#
# This file is released under the terms of the Artistic License.
# Please see the file LICENSE, included in this package, for details.
#
# Copyright (C) 2005 Mark Wong & Open Source Development Lab, Inc.
#

DIR=`dirname $0`
. ${DIR}/pgsql_profile || exit 1

WAREHOUSES=1
GENERATE_DATAFILE=0
REBUILD_DB=0
while getopts "bd:gp:rtw:" OPT; do
	case ${OPT} in
	b)
		BACKGROUND_FLAG="-b"
		;;
	d)
		DBDATA=${OPTARG}
		;;
	g)
		GENERATE_DATAFILE=1
		;;
	p)
		PARAMETERS=$OPTARG
		;;
	r)
		REBUILD_DB=1
		;;
	t)
		TABLESPACES_FLAG="-t"
		;;
	w)
		WAREHOUSES=${OPTARG}
		;;
	esac
done

if [ ${GENERATE_DATAFILE} -eq 1 ]; then
	${TOP_DIR}/src/datagen -d ${DBDATA} -w ${WAREHOUSES} --pgsql || exit 1
fi

if [ ${REBUILD_DB} -eq 1 ]; then
	#
	# Stop the database so that new parameters will be set if sepcified.
	#
	${SHELL} ${DIR}/stop_db.sh
	${SHELL} ${DIR}/start_db.sh -p "${PARAMETERS}" || exit 1
	${SHELL} ${DIR}/drop_db.sh
fi

${SHELL} ${DIR}/create_db.sh || exit 1
${SHELL} ${DIR}/create_tables.sh ${TABLESPACES_FLAG} || exit 1
${SHELL} ${DIR}/load_db.sh -d ${DBDATA} ${BACKGROUND_FLAG} ${TABLESPACES_FLAG} || exit 1

exit 0
