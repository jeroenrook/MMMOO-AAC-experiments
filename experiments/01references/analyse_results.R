#!/usr/bin/env Rscript

library(ecr)

tmp.path <- "/scratch/tmp/rookj/MMMOO/01references/"
results <- list.files(tmp.path)

solutions <- list()

for (res in results){
  meta.data <- unlist(strsplit(res,"_"))
  algorithm <- meta.data[1]
  instance <- meta.data[2]

  load(paste(tmp.path, res, sep=""))

  print(algorithm)
  print(names(solution_set))

  for (obj in 1:length(solution_set)){
    names(solution_set)[obj] <- paste("y", as.character(obj), sep="")
  }

  if(is.null(solutions[[instance]])){
    solutions[[instance]] <- solution_set
    # writeLines("init")
  }
  else{
    #merge
    # writeLines("add")
    solutions[[instance]] <- rbind(solutions[[instance]], solution_set, make.row.names=FALSE)
  }
}

references <- list()
for (instance in names(solutions)){
  print(instance)

  #Get pareto front
  solution.matrix <- t(data.matrix(solutions[[instance]]))

  plot(solution.matrix$y1, solution.matrix$y2, main=instance)

  pareto.idx <- ecr::nondominated(solution.matrix)
  pareto.front <- as.data.frame(t(solution.matrix[, pareto.idx, drop = FALSE]))
  pareto.refpoint <- as.vector(sapply(pareto.front, max))


  references[[instance]] <- list(approxfront=pareto.front, refpoint=pareto.refpoint)
}

save(references, "refdata.RData")