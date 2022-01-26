#!/usr/bin/env bash

CWD=$(pwd)

cd ../algorithms
./distribute_shared_files.sh

for folder in $(echo */)
do
  if [[ $folder != _* ]]; then
    cd $folder
    echo $(basename $folder)
    ./algorithm.r --budget 10000 --seed 1 --instance ../../instances/BiObjBBOB1 --visualise "${CWD}/algout/$(basename $folder).pdf" 2>&1 | tee "${CWD}/algout/$(basename $folder).txt"
    cd ..
  fi
done