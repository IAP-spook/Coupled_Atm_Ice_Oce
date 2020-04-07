#!/bin/bash
RUN_START_DATE=$1
RUN_START_SECOND=$2
RUN_STOP_DATE=$3
RUN_STOP_SECOND=$4
time_step=$5
wrf_input="$CODEROOT/../../WRF_MITgcm/run/atm/wrf/data/namelist.input"
mitgcm_input1="$CODEROOT/../../WRF_MITgcm/run/cpl/mitgcm/data/data"
mitgcm_input2="$CODEROOT/../../WRF_MITgcm/run/cpl/mitgcm/data/data.cal"


set_namelist()
{
	sed -i -e "s/\(\<$1\>\s*\)=.*/\1= $2,/g" $wrf_input
}

if [ ! -e "${SCRIPTSROOT}" ]; then
     echo 
#    echo "[ERROR]: Cannot find the SCRIPTSROOT: \"${SCRIPTSROOT}\""
#    echo "Please set the SCRIPTSROOT through source register_platform.sh or register_platform.csh under the directory scripts of the C-Coupler model platform"
#   exit 1
fi

if [ ! -f "$wrf_input" -o ! -f "$mitgcm_input1" -o ! -f "$mitgcm_input2" ]; then
	echo "[ERROR]: Cannot find the input file, please confirm"
	exit 1
fi

start_year=`echo $RUN_START_DATE | awk -F '-' '{print $1}'`
start_month=`echo $RUN_START_DATE | awk -F '-' '{print $2}'`
start_day=`echo $RUN_START_DATE | awk -F '-' '{print $3}'`
stop_year=`echo $RUN_STOP_DATE | awk -F '-' '{print $1}'`
stop_month=`echo $RUN_STOP_DATE | awk -F '-' '{print $2}'`
stop_day=`echo $RUN_STOP_DATE | awk -F '-' '{print $3}'`
hour_second=3600
minute_second=60
temp1=0
start_hour=`expr $RUN_START_SECOND / $hour_second`
temp1=`expr $RUN_START_SECOND / $minute_second`
start_minute=`expr $temp1 % $minute_second`
start_second=`expr $RUN_START_SECOND % $minute_second`
stop_hour=`expr $RUN_STOP_SECOND / $hour_second`
temp1=`expr $RUN_STOP_SECOND / $minute_second`
stop_minute=`expr $temp1 % $minute_second`
stop_second=`expr $RUN_STOP_SECOND % $minute_second`


set_namelist start_year "$start_year,$start_year"
set_namelist start_month "$start_month,$start_month"
set_namelist start_day "$start_day,$start_day"
set_namelist start_hour "$start_hour,$start_hour"
set_namelist start_minute "$start_minute,$start_minute"
set_namelist start_second "$start_second,$start_second"
set_namelist end_year "$stop_year,$stop_year"
set_namelist end_month "$stop_month,$stop_month"
set_namelist end_day "$stop_day,$stop_day"
set_namelist end_hour "$stop_hour,$stop_hour"
set_namelist end_minute "$stop_minute,$stop_minute"
set_namelist end_second "$stop_second,$stop_second"
set_namelist time_step "$time_step"

sed -i "s/deltaT=.*/deltaT=$time_step,/g" $mitgcm_input1
sed -i "s/startDate_1=.*/startDate_1=$start_year$start_month$start_day,/g" $mitgcm_input2 
sed -i "s/startDate_2=.*/startDate_2=$RUN_START_SECOND,/g" $mitgcm_input2
sed -i "s/start_date=\".*\"/start_date=\"$start_year$start_month$start_day\"/g" CCPL_dir/config/all/env_run.xml
sed -i "s/start_second=\".*\"/start_second=\"$RUN_START_SECOND\"/g" CCPL_dir/config/all/env_run.xml
sed -i "s/stop_date=\".*\"/stop_date=\"$stop_year$stop_month$stop_day\"/g" CCPL_dir/config/all/env_run.xml
sed -i "s/stop_second=\".*\"/stop_second=\"$RUN_STOP_SECOND\"/g" CCPL_dir/config/all/env_run.xml
sed -i "s/rest_freq_count=\".*\"/rest_freq_count=\"$time_step\"/g" CCPL_dir/config/all/env_run.xml
