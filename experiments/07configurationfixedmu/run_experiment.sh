#!/usr/bin/env bash

CWD=$(pwd)
BASE_DIR="/home/r/rookj/projects/MMMOO/remote/MMMOO"
EXP_NAME=$(basename $(pwd))
#Make scratch directory

EXP_DIR="${TMP}/MMMOO/${EXP_NAME}"
echo $EXP_DIR
mkdir -p -- $EXP_DIR

#Prepare wrappers
cd "${BASE_DIR}/intermediates/algorithmsAllFixed"
./generate_algorithms.py

targets=("SP" "HV")
for target in "${targets[@]}"; do
  echo $target

  cd $EXP_DIR
  mkdir $target
  cd $target

  #Clone sparkle
  if [[ -d "sparkle" ]]
  then
      echo "sparkle/ exists."
      cd sparkle
  else
    git clone git@bitbucket.org:sparkle-ai/sparkle.git
    cd sparkle
    git checkout 9336661208ee3b857b420ae3dd5460d9d1c21f16
  fi

  #Copy settings and scripts
  cp -r "${CWD}/Settings" .
  cp -r "${CWD}/scripts/"* .

  cd "$EXP_DIR/$target/sparkle"

  ./Commands/initialise.py
  #Add all solvers

  python generate_sparkle_commands.py "${BASE_DIR}/resources/instances/" "${BASE_DIR}/intermediates/algorithmsAllFixed/" -t $target
  #Created by create_instance_partitions.py

  ./solvers.sh

  ./instances.sh

done




