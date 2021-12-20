#!/usr/bin/env Rscript
library(optparse)
library(smoof)
library(MOEADr)

# ARGUMENTS
option_list = list(
  make_option("--instance", type = "character", default = NULL, help = "instance"),
  make_option("--budget", type = "numeric", default = 10000L, help = "The maximum number of allowed function evaluations"),
  make_option("--seed", type = "numeric", default = 0, help = "The random seed"),
  make_option("--save_solution", type= "character", default = NULL, "save solution set to an Rdata object"),
  #Add parameters here
  make_option("--n_weights", type = "numeric", default = 50L)
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)
# print(opt)

#SET SEED
set.seed(opt$seed)

#INSTANCE LOADING
parse_instance_file = function(filename){
  content = readChar(filename, nchars=file.info(filename)$size)
  return(eval(parse(text=content)))
}

obj.fn = parse_instance_file(opt$instance)
obj.fn = smoof::addCountingWrapper(obj.fn)
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

optimizer = moead(
  problem = list(
    name = 'problem',
    xmin = fn.lower,
    xmax = fn.upper,
    m = 2L),
  preset = preset_moead("original"),
  showpars = list(show.iters = "none"),
  stopcrit = list(list(name = "maxeval", maxeval = opt$budget)),
  seed = opt$seed
)

solution_set = as.data.frame(optimizer$Y)
#pareto_set = as.data.frame(res$X)

writeLines(paste("c EVALUATIONS", smoof::getNumberOfEvaluations(obj.fn)))

# Parse the solution set to a common interface
writeLines("s SOLUTION SET")
print(solution_set)
if (!is.null(opt$save_solution)){
    writeLines("Save to file")
    save(pareto_front, file=solution_set)
}