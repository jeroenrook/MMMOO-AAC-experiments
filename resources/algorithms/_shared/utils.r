library("smoof")
library("ecr3vis")

parse_instance_file = function(filename){
    content = readChar(filename, nchars=file.info(filename)$size)
    obj.fn <- eval(parse(text=content))
    obj.fn = smoof::addCountingWrapper(obj.fn)
    return(obj.fn)
}

print_and_save_solution_set <- function (solution_set){
    writeLines("s SOLUTION SET")
    print(solution_set)
    if (!is.null(opt$save_solution)){
        writeLines("Save to file")
        save(solution_set, file=opt$save_solution)
    }
}

compute_performance_metrics <- function (solution_set, fn, instance_path){
    #Get reference data
    pareto.matrix <- t(data.matrix(solution_set))
    instance_name <- tail(unlist(strsplit(instance_path,"/")), n=1)

    load("refdata.RData")

    reference.front <- references[[instance_name]]$approxfront
    reference.front <- t(data.matrix(reference.front))

    reference.point <- smoof::getRefPoint(fn)
    if (is.null(reference.point)){
        reference.point <- references[[instance_name]]$refpoint
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

print_measures <- function (measures){
    writeLines("s MEASURES")
    writeLines(paste("s HV",as.character(measures$HV)))
    writeLines(paste("s IDGP",as.character(measures$IDGP)))
    writeLines(paste("s SP",as.character(measures$SP)))
}