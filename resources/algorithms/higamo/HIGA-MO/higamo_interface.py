from moo_gradient import MOO_HyperVolumeGradient
import argparse
import copy
import numpy as np
import rpy2.robjects as robjects
import rpy2.robjects.packages as rpackages
from rpy2.robjects.packages import importr
from rpy2.robjects.vectors import StrVector
import rpy2.robjects.numpy2ri
import csv, time, datetime
rpy2.robjects.numpy2ri.activate()

# import R's utility package
utils = rpackages.importr('utils')

# select a mirror for R packages
utils.chooseCRANmirror(ind=1) # select the first mirror in the list

# R package names
packnames = ['remotes','smoof']

# set libPath paths for palma to skip below install steps
# use steps below instead on local machine
lib_path = robjects.r['.libPaths']
lib_path("~/R/library/")

# Uncomment this to remove old versions of packages, if needed
# utils.remove_packages("remotes")
# utils.remove_packages("smoof")

# Selectively install what needs to be installed.
# names_to_install = [x for x in packnames if not rpackages.isinstalled(x)]
# if len(names_to_install) > 0:
#     if("smoof" in names_to_install): 
#         utils.install_packages("remotes")
#         remotes = importr('remotes')
#         install_github = robjects.r['install_github']
#         install_github("jakobbossek/smoof")

base = importr('base')
smoof = importr('smoof')
getUpperBounds = robjects.r["getUpperBoxConstraints"]
getLowerBounds = robjects.r["getLowerBoxConstraints"]
getRefPoint = robjects.r["getRefPoint"]
addCountingWrapper = robjects.r["addCountingWrapper"]
getNumberOfEvaluations = robjects.r["getNumberOfEvaluations"]
getName = robjects.r["getName"]
start = time.time()

def getFunctionByName(name, dims=2, bbob_fid = 1, bbob_iid = 1):
    name = name.split()
    if(name[0]=="ZDT1"):
        fn = robjects.r['makeZDT1Function']
        return fn(dimensions = dims)
    if(name[0]=="ZDT2"):
        fn = robjects.r['makeZDT2Function']
        return fn(dimensions = dims)
    if(name[0]=="ZDT3"):
        fn = robjects.r['makeZDT3Function']
        return fn(dimensions = dims)
    if(name[0]=="ZDT4"):
        fn = robjects.r['makeZDT4Function']
        return fn(dimensions = dims)
    if(name[0]=="ZDT6"):
        fn = robjects.r['makeZDT6Function']
        return fn(dimensions = dims)
    if(name[0]=="DTLZ1"):
        fn = robjects.r['makeDTLZ1Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="DTLZ2"):
        fn = robjects.r['makeDTLZ2Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="DTLZ3"):
        fn = robjects.r['makeDTLZ3Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="DTLZ4"):
        fn = robjects.r['makeDTLZ4Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="DTLZ5"):
        fn = robjects.r['makeDTLZ5Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="DTLZ6"):
        fn = robjects.r['makeDTLZ6Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="DTLZ7"):
        fn = robjects.r['makeDTLZ7Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="MMF1"):
        fn = robjects.r['makeMMF1Function']
        return fn()
    if(name[0]=="MMF1e"):
        fn = robjects.r['makeMMF1eFunction']
        return fn()
    if(name[0]=="MMF1z"):
        fn = robjects.r['makeMMF1zFunction']
        return fn()
    if(name[0]=="MMF2"):
        fn = robjects.r['makeMMF2Function']
        return fn()
    if(name[0]=="MMF3"):
        fn = robjects.r['makeMMF3Function']
        return fn()
    if(name[0]=="MMF4"):
        fn = robjects.r['makeMMF4Function']
        return fn()
    if(name[0]=="MMF5"):
        fn = robjects.r['makeMMF5Function']
        return fn()
    if(name[0]=="MMF6"):
        fn = robjects.r['makeMMF6Function']
        return fn()
    if(name[0]=="MMF7"):
        fn = robjects.r['makeMMF7Function']
        return fn()
    if(name[0]=="MMF8"):
        fn = robjects.r['makeMMF8Function']
        return fn()
    if(name[0]=="MMF9"):
        fn = robjects.r['makeMMF9Function']
        return fn()
    if(name[0]=="MMF10"):
        fn = robjects.r['makeMMF10Function']
        return fn()
    if(name[0]=="MMF11"):
        fn = robjects.r['makeMMF11Function']
        return fn()
    if(name[0]=="MMF12"):
        fn = robjects.r['makeMMF12Function']
        return fn()
    if(name[0]=="MMF13"):
        fn = robjects.r['makeMMF13Function']
        return fn()
    if(name[0]=="MMF14"):
        fn = robjects.r['makeMMF14Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="MMF14a"):
        fn = robjects.r['makeMMF14aFunction']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="MMF15"):
        fn = robjects.r['makeMMF15Function']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="MMF15a"):
        fn = robjects.r['makeMMF15aFunction']
        return fn(dimensions = dims, n_objectives=2)
    if(name[0]=="Bi-Objective"):
        params = name[1].split('_')
        fn = robjects.r['makeBiObjBBOBFunction']
        if(len(params)>=4):
            return fn(dimensions = int(params[1]), fid=int(params[2]), iid=int(params[3]))    
        return fn(dimensions = dims, fid=bbob_fid, iid=bbob_iid)

def positive_int(x):
    x = int(x)
    if x <= 0:
        raise argparse.ArgumentTypeError("%s is an invalid. Choose a value >= 1" % x)
    return x

def getEstimateGradientFn(fn, precission=1e-4):
    # return function
    def estimateGradient(x):
        x_val = fn(x)
        grad = [[]]*len(x)
        for indx, element in enumerate(x):
            temp = copy.deepcopy(x)
            temp[indx] = element + precission
            grad[indx] = (fn(temp) - x_val) / precission
        
        grad = np.matrix(grad).transpose().tolist()

        return grad

    return estimateGradient

# test functions TODO: replace with smoof functions
def f1(x):
    x1, x2 = x
    return x1 ** 2.0 + (x2 - 0.5) ** 2.0


def f2(x):
    x1, x2 = x
    return (x1 - 1) ** 2.0 + (x2 - 0.5) ** 2.0


def f1_grad(x):
    x1, x2 = x
    return [2.0 * x1, 2.0 * (x2 - 0.5)]


def f2_grad(x):
    x1, x2 = x
    return [2.0 * (x1 - 1), 2.0 * (x2 - 0.5)]

def f_test(x):
    return np.array([f1(x), f2(x)])

def f_test_grad(x):
    return np.array([f1_grad(x), f2_grad(x)])

# get parameters from command line or use default
parser = argparse.ArgumentParser(description='HIGA-MO Algorithm')
# callable or list of callables (functions) (vector-evaluated) objective function                 
parser.add_argument('--fitness_func', default="ZDT1 Function",
                   help='callable or list of callables (functions) (vector-evaluated) objective function')
# callable or list of callables (functions) the gradient (Jacobian) of the objective function
# parser.add_argument('--fitness_grad', default=[f1_grad, f2_grad], 
#                    help='callable or list of callables (functions) the gradient (Jacobian) of the objective function')
# decision space dimension
parser.add_argument('--dim_d', default=2, 
                   help='decision space dimension')
# objective space dimension                   
parser.add_argument('--dim_o', default=2,
                   help='objective space dimension')
# the size of the Pareto approxiamtion set                   
parser.add_argument('--mu', default=100, 
                   help='the size of the Pareto approxiamtion set')
# max number of iterations                   
parser.add_argument('--maxiter', default=1000, 
                   help='max number of iterations')
# array or list the reference point (Hypervolume)
parser.add_argument('--ref', default=[1, 1], 
                   help='array or list the reference point')
# the inital step size, it could be a string subject to evaluation
parser.add_argument('--step_size', default=0.001, 
                   help='the inital step size, it could be a string subject to evaluation')
# the method used in the initial sampling of the approximation set (uniform, LHS, Grid)
parser.add_argument('--sampling', default='uniform', 
                   help='the method used in the initial sampling of the approximation set (uniform, LHS, Grid)')
# # lower bound of the search domain
# parser.add_argument('--lb', default=[0, 0], 
#                    help='lower bound of the search domain')
# # upper bound of the search domain
# parser.add_argument('--ub', default=[1, 1], 
#                    help='upper bound of the search domain')
# if using BiObjBBOB, specify function id with this parameter
parser.add_argument('--bbob_fid', default=1, type=positive_int,
                   help='if using BiObjBBOB, specify function id with this parameter')
# if using BiObjBBOB, specify instance id with this parameter
parser.add_argument('--bbob_iid', default=1, type=positive_int,
                   help='if using BiObjBBOB, specify instance id with this parameter')
# passes the current replication number used to write the logs later on
parser.add_argument('--replication', default=0, type=positive_int,
                   help='The number of replication that should be written to the log in the end')                   
# Is the objective functions subject to maximization. 
# If it is a list, it specifys the maximization option per objective dimension
maximize = False

args = parser.parse_args()
fitness_fn = getFunctionByName(args.fitness_func, int(args.dim_d), int(args.bbob_fid), int(args.bbob_iid))
test = getEstimateGradientFn(fitness_fn, precission=1e-8)
gradient_fn = getEstimateGradientFn(fitness_fn, precission=1e-8)
gradient_f_test = getEstimateGradientFn(f_test, precission=1e-8)
upper_bounds = getUpperBounds(fitness_fn)
lower_bounds = getLowerBounds(fitness_fn)
ref_point = getRefPoint(fitness_fn)
fitness_fn = addCountingWrapper(fitness_fn)

if(ref_point is rpy2.robjects.rinterface.NULL):
    ref_point = [10e6,10e6]
print("---------------------------------")
print(fitness_fn)
print("---------------------------------")
optimizer = MOO_HyperVolumeGradient(dim_d = int(args.dim_d), dim_o = int(args.dim_o), lb = lower_bounds, ub =  upper_bounds, mu = args.mu,
                                    fitness = fitness_fn,
                                    gradient = gradient_fn,
                                    ref =  ref_point, initial_step_size = args.step_size,
                                    sampling = args.sampling, maximize = maximize,
                                    maxiter = args.maxiter)

# optimizer.optimize runs the algorithm until first termination criterion is true
# it then returns the pareto front and the number of iterations     

fn_name = getName(fitness_fn)
timestamp = str(datetime.datetime.now().strftime("%d-%m-%Y_%H:%M:%S"))
filename = "higamo__"+fn_name[0].replace(" ", "_")+"__"+str(args.replication)+"__"+timestamp+".csv"
with open('/scratch/tmp/j_hein37/csv_log/HIGAMO/'+filename, 'w') as file:
    writer = csv.writer(file, delimiter=',')
    writer.writerow(["iter","x1","x2","y1","y2","fun_calls"]) #,"algorithm","prob","repl","rep_time"
    for iter in range(0, args.maxiter):
        optimizer.step()
        function_calls = getNumberOfEvaluations(fitness_fn)
        end = time.time()
        if iter % 5 == 0 or iter == (args.maxiter - 1):
            for i in range(0,len(optimizer.pop[0])):
                    fn_eval = fitness_fn([optimizer.pop[0,i], optimizer.pop[1,i]])
                    writer.writerow([iter, optimizer.pop[0,i], optimizer.pop[1,i], fn_eval[0], fn_eval[1], function_calls[0]]) #, end - start, "HIGAMO", fn_name[0], args.replication
