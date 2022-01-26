#!/usr/bin/env Rscript

library(ecr)

tmp.path <- "/scratch/tmp/rookj/MMMOO/01references/"
results <- list.files(tmp.path)

solutions <- list()

for (res in results){
  meta.data <- unlist(strsplit(res,"_"))
  print(meta.data)
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
  #print(t(solution.matrix))

  #plot(t(solution.matrix)[1], t(solution.matrix)[2], main=instance)

  pareto.idx <- ecr::nondominated(solution.matrix)
  pareto.front <- as.data.frame(t(solution.matrix[, pareto.idx, drop = FALSE]))
  pareto.front <- pareto.front[sample(nrow(pareto.front), 100), ]
  pareto.refpoint <- as.vector(sapply(pareto.front, max))

  #png(paste("plots/", instance, ".png", sep=""), width=600, height=600)
  plot(pareto.front$y1, pareto.front$y2, main=instance)
  dev.off()


  references[[instance]] <- list(approxfront=pareto.front, refpoint=pareto.refpoint)
}

save(references, file="refdata.RData")