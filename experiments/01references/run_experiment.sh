#!/usr/bin/env bash

./compute_references.R
chmod 755 script.sh
sbatch script.sh