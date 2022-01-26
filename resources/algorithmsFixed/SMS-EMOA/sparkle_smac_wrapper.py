#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os
import sys
import time
import re

from utils import *


if __name__ == "__main__":
    assert (len(sys.argv) >= 6)

    #Argument parsing
    instance = sys.argv[1]
    specifics = sys.argv[2]
    cutoff_time = int(float(sys.argv[3]) + 1)
    run_length = int(sys.argv[4])
    seed = int(sys.argv[5])
    params = sys.argv[6:]
    print(params)

    #Constants
    solver_binary = r'./algorithm.r'

    # Build command
    assert (len(params) % 2 == 0)  # require even number of parameters
    paramstring = build_param_string(params)

    command = f"{solver_binary} --instance {instance} --seed {seed} --budget 20000 {paramstring}"

    print(command)

    start_time = time.time()
    output_list = os.popen(command).readlines()
    end_time = time.time()
    run_time = end_time - start_time #Wallclock time

    #Parse output
    # parse output
    measures = parse_solution_set(output_list)
    status = "SUCCESS"
    if measures["HV"] is None:
        status = "CRASHED"
        measures["HV"] = 0
        measures["IGDP"] = 2 ** 32 - 1
        measures["SP"] = 0
    target = "HV"
    ##TARGET-REPLACE
    result_line = "Result for SMAC: {}, {}, 0, {}, {}".format(status, run_time, measures[target], seed)
    print(result_line)