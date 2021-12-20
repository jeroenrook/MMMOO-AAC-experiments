#!/usr/bin/env Rscript

library(smoof)
library(ecr)

set.seed(2021)
seeds <- sample(1:100000, 10, replace=FALSE)
print(seeds)
seeds.bash <- paste("SEEDS=(", paste(c(seeds), collapse=" "),")", sep="")

#Get all instances
instances.path <- "../../resources/instances/"
instances <- list.files(instances.path)

parse_instance_file = function(filename){
    content = readChar(filename, nchars=file.info(filename)$size)
    return(eval(parse(text=content)))
}


#Get all algorithms
algorithms.path <- "../../resources/algorithms/"
algorithms <- list.files(algorithms.path)



commands.list <- c()
for (algorithm in algorithms){
  algorithm.path <- paste(algorithms.path,algorithm,"/algorithm.r", sep="")
  writeLines(paste(">>>> \t", algorithm.path))

  #try algorithm
  command <- paste(algorithm.path,
                   "--instance",
                   "../../resources/instances/BiObjBBOB1",
                   "--budget 100")
  writeLines(command)
  out <- system(command, ignore.stdout = TRUE, ignore.stderr = TRUE)
  if (out != 0){
    next
  }


  for (instance in instances){
    instance.path <- paste(instances.path,instance, sep="")
    #writeLines(instance.path)

    # temp.path <- paste("tmp/", instance, "_", algorithm, "_", as.character(seed), ".RData", sep="")
    # command <- paste(algorithm.path,
    #                  "--instance",
    #                  instance.path,
    #                  "--budget 1000",
    #                  "--save_solution",
    #                  temp.path)

    #writeLines(paste(algorithm.path, instance.path))
    commands.list[[(length(commands.list) + 1)]] <- paste("\"",
                                                          algorithm, " ",
                                                          instance, " ",
                                                          algorithm.path, " ",
                                                          instance.path, "\"",
                                                          sep="")

    #writeLines(command)
  }
}

sink("script.sh")
writeLines(readLines("sbatch_headers.txt"))
writeLines(paste("#SBATCH --array=0-",as.character(length(commands.list)),sep=""))
writeLines(seeds.bash)
cat("ARGUMENTS=(")
cat(paste(commands.list, collapse=" \\\n"))
cat(")\n\n")
writeLines(readLines("sbatch_body.txt"))
sink()
