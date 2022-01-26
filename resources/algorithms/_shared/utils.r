library("smoof")
library("ecr3vis")

parse_instance_file = function(filename){
    content = readChar(filename, nchars=file.info(filename)$size)
    obj.fn <- eval(parse(text=content))
    obj.fn = smoof::addCountingWrapper(obj.fn)
    return(obj.fn)
}

print_and_save_solution_set <- function (solution_set){
    writeLines("s SOLUTION SET (not showed)")
    #print(solution_set)
    # if (!is.null(opt$save_solution)){
    #     writeLines("Save to file")
    #     #save(solution_set, file=opt$save_solution)
    #     write.table(solution_set, file=opt$save_solution)
    # }
}

compute_performance_metrics <- function (population, solution_set, fn, instance_path){
    #Get reference data
    population <- t(data.matrix(population))
    solution_set <- t(data.matrix(solution_set)) #No guarantee of non-domination
    instance_name <- tail(unlist(strsplit(instance_path,"/")), n=1)

    load("refdata.RData")

    reference.front <- references[[instance_name]]$approxfront
    reference.front <- t(data.matrix(reference.front))

    reference.point <- smoof::getRefPoint(fn)
    if (is.null(reference.point)){
        reference.point <- references[[instance_name]]$refpoint
    }

    #print(population)
    #print(solution_set)

    #Compute measures
    measures <- list()
    #HV MAXIMISE, hence minimise
    #Only use non-dominated set:
    pareto.matrix <- solution_set[, ecr::nondominated(solution_set)]
    measures$HV <- -ecr3vis::hv(pareto.matrix, reference.point)
    #IDG+ MINIMAISE
    measures$IGDP <- NULL #ecr3vis::igdp(pareto.matrix, reference.front) #JEROEN: Not used so do not waste resources
    #SP MAXIMISE, hence minimise
    measures$SP <- -ecr3vis::solow_polasky(solution_set)
    #SP MAXIMISE, hence minimise
    measures$SPD <- -ecr3vis::solow_polasky(population)
    #TODO: implement Approach for Basin Separated Evaluation
    measures$ABSE <- NULL

    if (!is.null(opt$save_solution)){
        writeLines("Save to file")
        #save(solution_set, file=opt$save_solution)
        measuresdf <- data.frame(Reduce(rbind, measures))

        HV = measures$HV
        IGDP = measures$IGDP
        SP = measures$SP
        SPD = measures$SPD

        save(solution_set, measuresdf , HV, SP, SPD , IGDP, reference.point, file=opt$save_solution)
    }

    if(!is.null(opt$visualise)){
        output <- opt$visualise
        pdf(output)
        # print(dim(as.data.frame(t(population))))
        # print(dim(as.data.frame(t(solution_set))))
        # print(dim(as.data.frame(t(pareto.matrix))))
        plot(t(population), main="Decision space")
        plot(t(solution_set), main="Objective space")
        plot(t(pareto.matrix), main="Non-dominated set in objective space")
        dev.off()
    }
    return(measures)
}

print_measures <- function (measures){
    writeLines("s MEASURES")
    writeLines(paste("s HV",as.character(measures$HV)))
    writeLines(paste("s IGDP",as.character(measures$IGDP)))
    writeLines(paste("s SP",as.character(measures$SP)))
    writeLines(paste("s SPD",as.character(measures$SPD)))
}

plot_solutions <- function(solution_set, fn, instance_path){
    measures = compute_performance_metrics(solution_set, fn, instance_path)

    load("refdata.RData")

    reference.front <- references[[instance_name]]$approxfront
    reference.front <- t(data.matrix(reference.front))

    reference.point <- smoof::getRefPoint(fn)
}