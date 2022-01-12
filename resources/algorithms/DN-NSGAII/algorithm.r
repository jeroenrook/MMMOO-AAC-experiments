#!/usr/bin/env Rscript

#R LIBRARIES
library(optparse)
library(smoof)
library(ecr)
library(tidyverse)

source("utils.r")

#ARGUMENTS
option_list = list(
  make_option("--instance", type = "character", default = NULL, help = "instance"),
  make_option("--budget", type = "numeric", default = 10000L, help = "The maximum number of allowed function evaluations"),
  make_option("--seed", type = "numeric", default = 0, help = "The random seed"),
  make_option("--save_solution", type= "character", default = NULL, "save solution set to an Rdata object"),
  #Add parameters here
  make_option("--mu", type = "numeric", default=100L),
  make_option("--cf", type = "numeric", default=10L),
  make_option("--rec_eta", type = "numeric", default=15L),
  make_option("--p", type = "numeric", default=0.7),
  make_option("--mut_eta", type = "numeric", default=25L)
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

writeLines('c ALGORITHM DN-NGSA-II')
# We currently do nothing with the intermediate results, so we do not need the for-loop and can just run with the budget

dn_nsga2 = function(
  fitness.fun,
  opt,
  cf = 10,
  mu = 100L,
  MAX.ITER = 100L,
  tournamentsize  = 3,
  rec_eta = 15,
  p = 0.7,
  mut_eta =25,
  ...) {

  # set necessary parameters
  n.select  = mu
  lower = smoof::getLowerBoxConstraints(fitness.fun)
  upper = smoof::getUpperBoxConstraints(fitness.fun)
  n.objectives = smoof::getNumberOfObjectives(fitness.fun)
  n.dim = smoof::getNumberOfParameters(fitness.fun)
  lambda = mu

  # initialize control object to use for the fitness function and mutator
  # control = initECRControl(fun)
  # control = registerECROperator(control, "dplyr::mutate", mutPolynomial, eta = 25, p = 0.2, lower = lower, upper = upper)
  # control = registerECROperator(control, "recombine", recSBX, eta = 15, p = 0.7, lower = lower, upper = upper)


  # initialize the population and define fitness function
  population = genReal(mu, getNumberOfParameters(fitness.fun), lower, upper)
  fitness = as.matrix(as.data.frame(lapply(population, fitness.fun))) # design fitness function

  #recombinator = setup(recSBX, eta = 15, p = 0.7, lower = lower, upper = upper)
  #mutator = setup(mutPolynomial, eta = 25, p = 0.2, lower = lower, upper = upper)


  # it is necessary to create the selection function on our own since it is necessary
  # to take decision space values into account (not considered in control object)
  # @param population:  representation of the population in decision space
  # @param fitness:     representation of population in objective space
  # @param n.select:    number of desired parent population
  # @param cf:          crowding factor

  nichingSelector = function (population, fitness, n.select, cf) {

    existing_indizes = c(1:length(population))
    non_dom_sorted = doNondominatedSorting(fitness)

    res = c()

    for (i in 1:n.select) {
      ## 1. choose random individual from population

      indi = sample(existing_indizes, 1)
      existing_indizes = setdiff(existing_indizes, indi)


      ## 2. CF additional individuals are randomly chosen
      ##    assuming that no individual can be selected twice
      ##    random_individual is not allowed to be part of the random_pool

      if(length(existing_indizes) < cf){cf = length(existing_indizes)}
      random_individuals = sample(existing_indizes,cf)
      crowding = computeCrowdingDistance(fitness)



      ## 3. calculate euclidean distance between random_individual and each
      ##    individual from random_pool IN DECISION SPACE
      ##    choose individual from random_pool that is closest to random_individual (closest_individual)

      init_information = population[[indi]]

      distances = data.frame( indi = random_individuals[1], dist =
                                TSdist::EuclideanDistance(init_information,
                                                          population[[random_individuals[1]]])
      )

      for (j in 2:cf){
        new_dist = data.frame( indi = random_individuals[j], dist =
                                 TSdist::EuclideanDistance(init_information,
                                                           population[[random_individuals[j]]])
        )
        distances = rbind(distances, new_dist)
      }

      distances = dplyr::arrange(distances, dist)

      random_indi = distances[1,1]

      ## 4. select superior individual between random_individual and closest_individual (according to fitness value)

      #indi better than random
      if (non_dom_sorted$ranks[indi] <non_dom_sorted$ranks[random_indi] ){
        res[i] = indi
      }
      #random better than indi
      if (non_dom_sorted$ranks[indi] > non_dom_sorted$ranks[random_indi] ){
        res[i] = random_indi
        existing_indizes = setdiff(existing_indizes, random_indi)
        existing_indizes = append(existing_indizes, indi)

      }

      #indi better than random
      if (non_dom_sorted$ranks[indi] == non_dom_sorted$ranks[random_indi] ){
        if (crowding[indi] > crowding[random_indi]){
          res[i] = indi
        }else{
          res[i] = random_indi
          existing_indizes = setdiff(existing_indizes, random_indi)
          existing_indizes = append(existing_indizes, indi)
        }
      }



      ## 5. repeat procedure until n.select individuals are chosen
      ##    ATTENTION: already selected individuals can not be selected again

      ## needs to return the indices from the individuals that were selected

    }


    return(res)

  }


  generalOutput = t(as.data.frame(population)) %>%
    cbind(t(fitness)) %>%
    as.data.frame() %>%
    dplyr::mutate(iter = 1) %>%
    dplyr::mutate(nfe = (mu * 1))

  colnames(generalOutput) = c("x1", "x2", "y1", "y2", "iter", "nfe")
  rownames(generalOutput) = NULL


  #
  # # loop to generate evolve population
  # # here stopping criteria can be determined
  # for (i in seq_len(MAX.ITER)) {
  i = 0
  while (smoof::getNumberOfEvaluations(fitness.fun) < opt$budget) {
    ## 1. get parent population
    ## HOW LARGE HAS THE PARENT POPULATION TO BE?
    #idx = nichingSelector(population, fitness, n.select, cf)
    print(i)
    i = i + 1
    ## 2. generate offspring by mutation  AND RECOMBINATION and evaluate their fitness
    ## IS P.MUT A NECESSARY PARAMETER?

    parents = sample(1:mu, mu)
    #colnames(fitness)  = NULL
    #parents = selTournament(fitness, mu, tournamentsize)

    offspring = recSBX(population[c(parents[1],parents[2])], lower = lower, upper = upper, eta = rec_eta, p =p)


    for (j in 2: (mu/2)){
      p1 = as.numeric(parents[(j*2) -1])
      p2 = as.numeric(parents[(j*2) ])
      offspring = append(offspring,
                         recSBX(
                           population[c(p1,
                                        p2)],
                           lower = lower, upper = upper, eta = rec_eta, p = p))
    }

    offspring = lapply(offspring, mutPolynomial, lower = lower, upper = upper, eta = mut_eta)

    fitness.o = as.matrix(as.data.frame(lapply(offspring, fitness.fun)))

    population = append(population, offspring)
    fitness = cbind(fitness, fitness.o)
    colnames(fitness) = NULL

    #fitness.o = as.data.frame(evaluateFitness(control, offspring))
    ## 3. now select the best out of the union of population and offspring
    ##    while considering diversity in decision space
    ## 4. add population to archive

    ## USE MU ALS N.SELECT VALUE?
    idx = nichingSelector(population, fitness, mu, cf)
    ## 5. set the population and fitness function for the next iteration
    population = population[idx]
    fitness = fitness[,idx]

    newOutput = t(as.data.frame(population)) %>%
      cbind(t(fitness)) %>%
      as.data.frame() %>%
      dplyr::mutate(iter = i) %>%
      dplyr::mutate(nfe = (mu * i))

    colnames(newOutput) = c("x1", "x2", "y1", "y2", "iter", "nfe")
    rownames(newOutput) = NULL
    rownames(newOutput) = NULL

    generalOutput = rbind( generalOutput, newOutput)


  }

  return(list(x = population, y =fitness, totalOutput = generalOutput))

}

res = dn_nsga2(fitness.fun = obj.fn,
               opt,
               mu = opt$mu,
               cf = opt$cf,
               rec_eta = opt$rec_eta,
               p = opt$p,
               mut_eta = opt$mut_eta)


front = as.data.frame(t(res$y))
colnames(front) <- c("y1", "y2")

writeLines(paste("c EVALUATIONS", smoof::getNumberOfEvaluations(obj.fn)))

# Parse the solution set to a common interface
solution_set <- front
print_and_save_solution_set(solution_set)  #utils.R

measures <- compute_performance_metrics(solution_set, obj.fn, opt$instance) #utils
print_measures(measures) #utils




