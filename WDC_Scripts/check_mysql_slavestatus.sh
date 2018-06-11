#!/bin/bash
# SQL Binary Replication Failure Detection      #
# Dave Byrne @ VooServers Ltd                   #
#################################################
#Is the Slave IO Running?
#EMAIL=Shrikant.Patil@Thinkbiganalytics.com
EMAIL=HM230067@Teradata.com
slaveio=`ssh svc-awor-bdppmon@abo-lp-mstr04.wdc.com mysql -u root -p***** -e "'show slave status\G;'" | grep Slave_IO_Running | awk '{ print $2 }'`
#Is the Slave SQL Running?
slavesql=`ssh svc-awor-bdppmon@abo-lp-mstr04.wdc.com mysql -u root -p***** -e "'show slave status\G;'" | grep Slave_SQL_Running | awk '{ print $2 }'`

#Pull the Last SQL Error just in case
lasterror=`ssh svc-awor-bdppmon@abo-lp-mstr04.wdc.com mysql -u root -p***** -e "'show slave status\G;'" | grep Last_Error | awk -F : '{ print $2 }'`
#Work out if its failed or not..
if [ "$slavesql" = "No" ] || [ "$slaveio" = "No" ];
then
  #Its failed, go CRITICAL
  echo " Slave IO Running? ... "$slaveio > /home/svc-awor-bdppmon/replication_fail.out
  echo "Slave SQL Running? ... "$slavesql  >> /home/svc-awor-bdppmon/replication_fail.out 
  echo "Last SQL Error:  "$lasterror  >> /home/svc-awor-bdppmon/replication_fail.out 
  echo "CRITICAL - MySQL Replication Failure is detected" >> /home/svc-awor-bdppmon/replication_fail.out 
#  exit 2
echo -e "\n\nRecommended Action: Please check if the slave MYSQL server on abo-lp-mstr04.wdc.com is in sync with master MYSQL server on abo-lp-mstr03.wdc.com
Please debug the error and try to resolve it.\n\n">> /home/svc-awor-bdppmon/replication_fail.out 

mailx -S smtp="10.86.1.25:25" -r svc-awor-bdppmon@hgst.com -s "MYSQL Replication Failure on abo-lp-mstr04.wdc.com" $EMAIL < /home/svc-awor-bdppmon/replication_fail.out 
#  exit 2
else
  #Its good, go OK
  echo "OK - MySQL Replication Running"
  echo $slavesql
  exit 0
fi