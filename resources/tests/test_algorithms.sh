#!/usr/bin/env bash

CWD=$(pwd)

cd ../algorithms
./distribute_shared_files.sh

for folder in $(echo */)
do
  if [[ $folder != _* ]]; then
    cd $folder
    echo $(basename $folder)
    ./algorithm.r --budget 1000 --seed 1 --instance ../../instances/BiObjBBOB1 --visualise "${CWD}/algout/$(basename $folder).pdf" &> "${CWD}/algout/$(basename $folder).txt"
    cat "${CWD}/algout/$(basename $folder).txt" | tail -n9
    cd ..
  fi
done