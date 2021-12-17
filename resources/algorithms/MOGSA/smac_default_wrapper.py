#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import os
import sys
import time
import re
import itertools
import numpy as np

def get_last_level_directory_name(filepath):
    if filepath[-1] == r'/':
        filepath = filepath[0:-1]
    right_index = filepath.rfind(r'/')
    if right_index < 0:
        pass
    else:
        filepath = filepath[right_index + 1:]
    return filepath

def build_param_string(params):
    def pairwise(lst):
        lst = iter(lst)
        return zip(lst, lst)

    paramstring = []
    for param, value in pairwise(params):
        paramstring.append(f"-{param} {value}")
    return " ".join(paramstring)

def parse_solution_set(output_list):
    do_match = False
    solution_set = []
    for line in output_list:
        line = line.strip()

        # JAKOB: needed to simplify from "[1] \"s SOLUTION SET\"": for whatever reason
        if line == "s SOLUTION SET":
            do_match = True
        if do_match and re.match(r"([-\+\d\.e]+\s*)+", line):
            objectives = re.split(r"\s+", line)
            assert(len(objectives) > 2)
            objectives = [float(obj) for obj in objectives[1:]]
            solution_set.append(objectives)
    solution_set = np.array(solution_set)
    return solution_set


# Exemplary manual call
# ./smac_default_wrapper.py ../../instances/DTLZ2 dummy 3 10 123 -mu 30

if __name__ == "__main__":
    assert (len(sys.argv) > 6)

    # Argument parsing
    instance = sys.argv[1]
    specifics = sys.argv[2] # not used
    cutoff_time = int(float(sys.argv[3]) + 1)
    run_length = int(sys.argv[4]) # not used
    seed = int(sys.argv[5])
    params = sys.argv[6:]
    print(params)

    # Constants
    solver_binary = r'./algorithm.r'

    # Build command
    assert(len(params) % 2 == 0) #require even number of parameters
    paramstring = build_param_string(params)

    command = f"{solver_binary} --instance {instance} --seed {seed} --budget 1000 {paramstring}"
    #print(command)

    # get output
    start_time = time.time()
    output_list = os.popen(command).readlines()
    end_time = time.time()
    run_time = end_time - start_time #Wallclock time

    # parse output
    solution_set = parse_solution_set(output_list)
    #print(solution_set)

    # Compute quality measurse
    # ONLY FOR THE BINARY CASE
    def HV(solution_set: np.array, ref_point=(0, 0)):
        # Sort first column
        order = np.argsort(solution_set[:, 0], axis=0)
        solution_set = solution_set[order]
        # Reverse order if ref point is lower than pareto front
        if ref_point[1] < solution_set[0, 1]:
            solution_set = np.flip(solution_set, axis=0)
            # Compute HV by computing the rectangular area between the point in the solution set
        start_point = (solution_set[0, 0], ref_point[1])
        hypervolume = 0
        for point in solution_set:
            dx = ref_point[0] - point[0]
            dy = start_point[1] - point[1]
            hypervolume += abs(dx * dy)  # abs in case one of the axis is in the negatives
            start_point = point

        return hypervolume

    def IGD(solution_set):
        return 1

    # based on SolPol94 and ecr3vis R implementation
    # Why can we neglect e in (e'F^(-1)e)^(-1)?
    def SP(solution_set, theta=1):
        npoints = len(solution_set)
        distances = np.zeros((npoints, npoints))
        for pair in itertools.combinations(range(npoints), r=2):
            dist = np.apply_along_axis(lambda r: (r[0] - r[1]) ** 2, 0, solution_set[pair, :])
            dist = np.sqrt(np.sum(dist))
            distances[pair[0], pair[1]] = dist
            distances[pair[1], pair[0]] = dist
        f = np.exp(-theta * distances)

        f = np.linalg.pinv(f)
        return np.sum(f)

    def ABSE(solution_set):
        return 1

    #print("HV:", HV(solution_set))
