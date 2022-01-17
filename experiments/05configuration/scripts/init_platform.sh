#!/usr/bin/env bash

./Commands/initialise.py

#Add all solvers


python create_instance_partitions.py ../../../resources/instances/
#Created by create_instance_partitions.py
./instances.sh
./configurations.sh


#./Commands/add_instances.py --run-extractor-later --run-solver-later ../../../resources/instances/
#
#./Commands/configure_solver.py --solver Solvers/SMS-EMOA/ --instance-set-train Instances/instances/

