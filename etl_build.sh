#!/bin/bash
set -o errexit

#usage: XXX <OLTP_DB_NAME> <DW_DB_NAME> <PDI_HOME> <MYSQL_ARGS>
OLTP_DB_NAME=$1
DW_DB_NAME=$2
PDI_HOME=$3
MYSQL_ARGS=$4

PRG="$0"

while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

PRGDIR=`dirname "$PRG"`

echo "Initializing OLTP database ($OLTP_DB_NAME)..."
echo "drop database $OLTP_DB_NAME" | mysql $MYSQL_ARGS
echo "create database $OLTP_DB_NAME" | mysql $MYSQL_ARGS
mysql $MYSQL_ARGS $OLTP_DB_NAME < $PRGDIR/ETL/MifosDataWarehouseETLTest/mifos_testetl_db.sql

echo "Initializing data warehouse ($DW_DB_NAME)..."
echo "drop database $DW_DB_NAME" | mysql $MYSQL_ARGS
echo "create database $DW_DB_NAME" | mysql $MYSQL_ARGS
mysql $MYSQL_ARGS $DW_DB_NAME < $PRGDIR/ETL/MifosDataWarehouseETL/load_mifos_datawarehouse.sql
mysql $MYSQL_ARGS $DW_DB_NAME < $PRGDIR/ETL/MifosDataWarehouseETL/load_mifos_datawarehouse_stored_procedures.sql
mysql $MYSQL_ARGS $DW_DB_NAME < $PRGDIR/ETL/MifosDataWarehouseETL/load_ppi_poverty_lines.sql
mysql $MYSQL_ARGS $DW_DB_NAME --default_character_set utf8 < $PRGDIR/ETL/MifosDataWarehouseETL/load_dw_ppi_survey.sql

echo "Running ETL..."
log=`mktemp`
$PDI_HOME/kitchen.sh /file:`readlink -f $PRGDIR/ETL/MifosDataWarehouseETL/DataWarehouseInitialLoad.kjb` | tee $log

exitcode=0
if grep -q '^ERROR ' $log
then
    echo ETL Has Errors
    exitcode=1
    rm $log
    exit $exitcode
fi

echo "Running tests..."
$PDI_HOME/kitchen.sh /file:`readlink -f $PRGDIR/ETL/MifosDataWarehouseETLTest/TestDataWarehouseETL.kjb` | tee -a $log

mkdir -p target
groovy generate_junit_output.groovy < $log > target/junit_output.xml

if grep -q '^ERROR ' $log
then
    exitcode=1
fi

rm $log
exit $exitcode
