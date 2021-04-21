#!/usr/bin/env bash
while true
do
  DATA=$(jps)
  rm java_threads.txt 2> /dev/null
  var=''
  while read -r program
  do
    PID=$(echo $program | awk '{print $1}')
    name=$(echo $program | awk '{print $2}')
    threads=$( jstack $PID  | grep 'java.lang.Thread.State' | wc -l )
    printf "java_threads{process=\""$name"\", pid=\""$PID"\"} $threads" >> java_threads.txt
    echo >> java_threads.txt
  done <<< "$DATA"
  server=$(hostname -s)
  curl --data-binary @java_threads.txt http://10.50.166.92:9091/metrics/job/java/monitor/threads/server/$(hostname -s)
  sleep 30
done

