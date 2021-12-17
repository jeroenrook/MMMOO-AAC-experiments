# Install all relevant R packages

if (!("remotes" %in% installed.packages()))
  install.packages("remotes", dep = TRUE)

library(remotes)

# benchmark functions
install_github("jakobbossek/smoof")

# Multi-objective evolutionary algorithms: SMS-EMOA + NSGA-II + MOEA-D
install_github("jakobbossek/ecr2")
install.packages("MOEADr", dep = TRUE)

# OmniOptimizer
install_github("jakobbossek/omnioptr")

# Multi-objective performance assessment
install_github("jakobbossek/ecrvis")

# Multi-objective local search algorithms
install_github("kerschke/mogsa")
install_local("sources/moleopt")


