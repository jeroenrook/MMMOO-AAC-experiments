#!/usr/bin/env bash

CWD=$(pwd)
cd ../algorithms/NSGA-II

for instance in $(echo ../../instances/*)
do
  echo ${instance}
  ./algorithm.r --budget 10000 --seed 1 --instance ${instance} --visualise "${CWD}/instout/$(basename ${instance}).pdf" &> "${CWD}/instout/$(basename ${instance}).txt"
done