#!/usr/bin/env Rscript

library("ecr")
library("smoof")
library("ecr3vis")

#Get all instances
instances.path <- "../../resources/instances/"
instances <- list.files(instances.path)

parse_instance_file = function(filename){
  content = readChar(filename, nchars=file.info(filename)$size)
  fn <- eval(parse(text=content))
  fn <- smoof::addCountingWrapper(fn)
  return(fn)
}

load("./refdata.RData")

nsga2m = function(
  fitness.fun,
  n.objectives = NULL,
  n.dim = NULL,
  minimize = NULL,
  lower = NULL,
  upper = NULL,
  mu = 100L,
  lambda = mu,
  mutator = setup(mutPolynomial, eta = 25, p = 0.2, lower = lower, upper = upper),
  recombinator = setup(recSBX, eta = 15, p = 0.7, lower = lower, upper = upper),
  terminators = list(stopOnIters(100L)),
  ...) {

  res = ecr(fitness.fun = fitness.fun, n.objectives = n.objectives,
    n.dim = n.dim, minimize = minimize, lower = lower, upper = upper,
    mu = mu, lambda = lambda, representation = "float", survival.strategy = "plus",
    parent.selector = selSimple,
    mutator = mutator,
    recombinator = recombinator,
    survival.selector = selNondom,
    terminators = terminators,
    log.pop = TRUE)
  return(res)
}

smsemoam = function(
  fitness.fun,
  n.objectives = NULL,
  n.dim = NULL,
  minimize = NULL,
  lower = NULL,
  upper = NULL,
  mu = 100L,
  ref.point = NULL,
  mutator = setup(mutPolynomial, eta = 25, p = 0.2, lower = lower, upper = upper),
  recombinator = setup(recSBX, eta = 15, p = 0.7, lower = lower, upper = upper),
  terminators = list(stopOnIters(100L)),
  ...) {
  
  if (is.null(ref.point)) {
    if (is.null(n.objectives)) {
      stopf("[smsemoa] Reference point default can only be generated if n.objectives is passed.")
    }
    ref.point = rep(11, n.objectives)
  }
  assertNumeric(ref.point, len = n.objectives)
  
  res = ecr(fitness.fun = fitness.fun, n.objectives = n.objectives,
            n.dim = n.dim, minimize = minimize, lower = lower, upper = upper,
            mu = mu, lambda = 1L, representation = "float", survival.strategy = "plus",
            parent.selector = selSimple,
            mutator = mutator,
            recombinator = recombinator,
            survival.selector = setup(selDomHV, ref.point = ref.point),
            terminators = terminators,
            log.pop = TRUE)
  
  return(res)
}

load("./refdata.RData")

for (instance in instances){
  writeLines(paste("c FN:", instance))
  instance.path <- paste(instances.path, instance, sep="")

  fn <- parse_instance_file(instance.path)
  
  lower = smoof::getLowerBoxConstraints(fn)
  upper = smoof::getUpperBoxConstraints(fn)

  optimizer = nsga2m(
    fn,
    smoof::getNumberOfObjectives(fn),
    lower=lower,
    upper=upper,
    terminators = list(stopOnEvals(max.evals = 20000)),
    log.pop = TRUE,
    mu = 100,
    ref.point = references[[instance]]$refpoint
  );
  writeLines(paste("c EVALUATIONS", smoof::getNumberOfEvaluations(fn)))

  compute_performance_metrics <- function (solution_set, fn, instance_path){
    #Get reference data
    pareto.matrix <- data.matrix(solution_set)
    instance_name <- tail(unlist(strsplit(instance_path,"/")), n=1)

    reference.front <- references[[instance_name]]$approxfront
    reference.front <- t(data.matrix(reference.front))

    reference.point <- smoof::getRefPoint(fn)
    if (is.null(reference.point)){
      reference.point <- references[[instance]]$refpoint
    }

    #Compute measures
    measures = list()
    #HV
    measures$HV <- ecr3vis::hv(pareto.matrix, reference.point)
    #IDG+
    measures$IDGP <- ecr3vis::igdp(pareto.matrix, reference.front)
    #SP
    measures$SP <- ecr3vis::solow_polasky(pareto.matrix)
    #TODO: implement Approach for Basin Separated Evaluation
    measures$ABSE <- NULL
    return(measures)
  }

  writeLines("c Compute MO metrics")
  poplog <- getPopulations(optimizer$log)
  metrics <- lapply(poplog, function(pop) { compute_performance_metrics(pop$fitness, fn, instance.path)})
  metrics <- as.data.frame(do.call(rbind, metrics))

  writeLines("c Plot metrics")
  for (col in names(metrics)){
    plot(1:nrow(metrics), metrics[[col]], ylab=col, xlab="evaluations", main=instance, type = "S")
  }

}
