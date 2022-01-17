#!/usr/bin/env bash

CWD=$(pwd)
BASE_DIR="/home/r/rookj/projects/MMMOO/remote/MMMOO"
EXP_NAME=$(basename $(pwd))
#Make scratch directory

EXP_DIR="${TMP}/MMMOO/${EXP_NAME}"
echo $EXP_DIR
mkdir -p -- $EXP_DIR
cd $EXP_DIR

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

./Commands/initialise.py
cp -r "${CWD}/Settings" .

#Add solvers
./Commands/add_solver.py --deterministic 0 --run-solver-later  "${BASE_DIR}/resources/algorithms/SMS-EMOA/"
./Commands/add_solver.py --deterministic 0 --run-solver-later  "${BASE_DIR}/resources/algorithms/NSGA-II/"
./Commands/add_solver.py --deterministic 0 --run-solver-later  "${BASE_DIR}/resources/algorithms/MOLE/"
./Commands/add_solver.py --deterministic 0 --run-solver-later  "${BASE_DIR}/resources/algorithms/MOGSA/"
./Commands/add_solver.py --deterministic 0 --run-solver-later  "${BASE_DIR}/resources/algorithms/omnioptimizer/"
./Commands/add_solver.py --deterministic 0 --run-solver-later  "${BASE_DIR}/resources/algorithms/higamo/"
./Commands/add_solver.py --deterministic 0 --run-solver-later  "${BASE_DIR}/resources/algorithms/MOEAD/"
./Commands/add_solver.py --deterministic 0 --run-solver-later  "${BASE_DIR}/resources/algorithms/DN-NSGAII/"

#Add instances
./Commands/add_instances.py --run-extractor-later --run-solver-later "${BASE_DIR}/resources/instances"

#Run configurations
solvers=("Solvers/SMS-EMOA" "Solvers/NSGA-II" "Solver/MOLE" "Solvers/MOGSA" \
"Solvers/MOEAD" "Solvers/higamo" "Solvers/omnioptimizer" "Solvers/DN-NSGAII")
for solver in "${solvers[@]}"; do
  echo "${solver}"
  ./Commands/configure_solver.py --solver "${solver}" --instance-set-train Instances/instances
done