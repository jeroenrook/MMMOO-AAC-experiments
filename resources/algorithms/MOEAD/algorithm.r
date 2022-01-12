#!/usr/bin/env Rscript
library(optparse)
library(smoof)
library(MOEADr) #devtools::install_github("fcampelo/MOEADr")

source("utils.r")

# ARGUMENTS
option_list = list(
  make_option("--instance", type = "character", default = NULL, help = "instance"),
  make_option("--budget", type = "numeric", default = 10000L, help = "The maximum number of allowed function evaluations"),
  make_option("--seed", type = "numeric", default = 1, help = "The random seed"),
  make_option("--save_solution", type= "character", default = NULL, "save solution set to an Rdata object"),
  #Add parameters here
  make_option("--preset", type = "character", default = "original", help="[original, original2, moead.de, custom]"),
  make_option("--neighbors", type = "character", default = "lambda", help="[lambda, x]"),
  make_option("--neighbors_T", type = "numerical", default = 100L, help="Neighborhood size. Msut be smaller than the number of subproblems"),
  make_option("--neighbors_delta_p", type = "numerical", default = 0.5, help="Probability of sampling from the neighborhood when performing variation. Must be a scalar value between 0 and 1."),

  make_option("--decomp", type = "character", default = "sld", help="[msld, sld, uniform]"),
  make_option("--decomp_H", type = "numerical", default = 99L, help="decomposition constant. vectors generated (N) must be greater than the number declared in neighbors$T"),

  make_option("--aggfun", type = "character", default = "", help="[awt, ipbi, pbi, ws, wt]"),

  # make_option("--variation", type = "character", default = "", help="[diffmut, localsearch, none, polymut]"),
  # make_option("--variation_diffmut_phi", type = "numeric", default = 0.5, help="Mutation parameter. Either a scalar numeric constant, or NULL for randomly chosen between 0 and 1 (independently sampled for each operation)."),
  # make_option("--variation_diffmut_basis", type = "character", default = 0.5, help="[rand, mean]"),

  make_option("--update", type = "character", default = "standard", help="[best, restricted, standard]"),

  # make_option("--constraint", type = "character", default = "", help="[nmone, penalty, vbr]"),
  # make_option("--scaling", type = "character", default = "", help=""),

  make_option("--n_weights", type = "numeric", default = 50L)
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)
# print(opt)

#SET SEED
set.seed(opt$seed)

#INSTANCE LOADING
obj.fn = parse_instance_file(opt$instance) #utils.R
#print(paste(c(smoof::getRefPoint(obj.fn))))
writeLines(paste("c REFERENCE POINT", paste(c(smoof::getRefPoint(obj.fn)), collapse=" ")))

fn.lower = smoof::getLowerBoxConstraints(obj.fn)
fn.upper = smoof::getUpperBoxConstraints(obj.fn)

#ALGORITHM (MOGSA)
writeLines('c ALGORITHM MOGSA')

make_vectorized_smoof_fun = function (myfun, ...) {
  force(myfun)
  function(X, ...) {
    t(apply(X, MARGIN = 1, FUN = myfun))
  }
}

problem = make_vectorized_smoof_fun(obj.fn)
if(opt$preset != "custom"){
  optimizer = moead(
    problem = list(
      name = 'problem',
      xmin = fn.lower,
      xmax = fn.upper,
      m = 2L),
    preset   = preset_moead(opt$preset)
    showpars = list(show.iters = "none"),
    stopcrit = list(list(name = "maxeval", maxeval = opt$budget)),
    seed = opt$seed
  )
} else {
  neighbors <- list(name       = opt$neighbors,
                  T          = opt$neighbors_T,
                  delta.p    = opt$neighbors_delta_p)

  if (opt$decomp == "uniform"){
    decomp    <- list(name       = opt$decomp)
  }
  else if(opt$decomp == "sld"){
    decomp    <- list(name       = opt$decomp, H = opt$decomp_H)
  } else{
    decomp    <- list(name       = opt$decomp) #TODO H and tau
  }

  aggfun    <- list(name       = opt$aggfun)
  # variation <- list(list(name  = "sbx",
  #                      etax  = 20, pc = 1),
  #                 list(name  = "polymut",
  #                      etam  = 20, pm = 0.1),
  #                 list(name  = "truncate"))
  update    <- list(name       = opt$update, UseArchive = FALSE)
  # scaling   <- list(name       = "none")
  # constraint<- list(name       = "none")

  optimizer = moead(
  problem = list(
    name = 'problem',
    xmin = fn.lower,
    xmax = fn.upper,
    m = 2L),
  showpars = list(show.iters = "none"),
  stopcrit = list(list(name = "maxeval", maxeval = opt$budget)),
  seed = opt$seed,
  neighbors = neighbors,
  decomp = decomp,
  aggfun = aggfun,
  update = update
)
}

solution_set = as.data.frame(optimizer$Y)
#pareto_set = as.data.frame(res$X)

writeLines(paste("c EVALUATIONS", smoof::getNumberOfEvaluations(obj.fn)))

# Parse the solution set to a common interface
print_and_save_solution_set(solution_set)  #utils.R

measures <- compute_performance_metrics(solution_set, obj.fn, opt$instance) #utils
print_measures(measures) #utils
