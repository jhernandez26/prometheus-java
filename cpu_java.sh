#!/usr/bin/env bash
while true
do
  DATA=$(jps)
  rm java_cpu.txt 2> /dev/null
  var=''
  while read -r program
  do
    PID=$(echo $program | awk '{print $1}')
    name=$(echo $program | awk '{print $2}')
    if [[ $(ps -p $PID | grep -v "TIME" | wc -l ) == 0 ]];then
      threads='0'
    else
      threads=$(  ps aux | grep $PID | grep -vEi "grep" | awk '{print $3}'  )
    fi
    printf "java_cpu{process=\""$name"\", pid=\""$PID"\"} $threads" >> java_cpu.txt
    echo >> java_cpu.txt
  done <<< "$DATA"
  server=$(hostname -s)
  curl --data-binary @java_cpu.txt http://10.50.166.92:9091/metrics/job/java/monitor/cpu/server/$(hostname -s)
  sleep 30
done
