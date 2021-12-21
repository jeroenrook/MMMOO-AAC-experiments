#!/usr/bin/env bash

cd ../algorithms
./distribute_shared_files.sh

for folder in $(echo */)
do
  if [[ $folder != _* ]]; then
    cd $folder
    ./algorithm.r --budget 1000 --seed 1 --instance ../../instances/DTLZ2
    cd ..
  fi
done