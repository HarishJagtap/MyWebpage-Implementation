#!/bin/bash
# Run this script as SU

for pid in $(ps aux | grep '[g]unicorn' | awk '{print $2}')
do
  echo "Killing gunicorn at $pid"
  kill $pid
done

for pid in $(ps aux | grep '[n]ginx' | awk '{print $2}')
do
  echo "Killing nginx at $pid"
  kill $pid
done
