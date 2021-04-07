#!/usr/bin/env bash
DATA=$(jps)
rm heap_memory.txt 2> /dev/null
var=''
while read -r program
do
  PID=$(echo $program | awk '{print $1}')
  name=$(echo $program | awk '{print $2}')
  heap_memory=$( (jstat -gc $PID 2>/dev/null || echo "0 0 0 0 0 0 0 0 0") | tail -n 1 | awk '{split($0,a," "); sum=a[3]+a[4]+a[6]+a[8]; print sum/1024}' )
  printf "heap_memory{process=\""$name"\", pid=\""$PID"\"} $heap_memory" >> heap_memory.txt
  echo >> heap_memory.txt
done <<< "$DATA"
server=$(hostname -s)
curl --data-binary @heap_memory.txt http://10.50.166.92:9091/metrics/job/java/server/$(hostname -s)
