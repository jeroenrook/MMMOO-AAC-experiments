#!/usr/bin/env bash

cd ../algorithms/SMS-EMOA

for instance in $(echo ../../instances/*)
do
  ./algorithm.r --budget 1000 --seed 1 --instance ${instance}
done