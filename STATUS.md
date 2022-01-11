#Algorithms

###NSGA-II ✅
###omnioptimizer ✅
###SMS-EMOA ✅

###MOGSA ✅
* Takes a long time sometimes (investigate)
* Number of evaluations cannot be a stopping criterion?

###DN-NSGA-II
* wrapper
* pcs

###higamo
* wrapper
* pcs 

###MOAED
* pcs

###MOLE
`Runtime error: Error in run_mole_cpp Expecting a single value: [extent=0]`.

#Quality measures
* Hypervolume ✅ 
* IDG+ ✅ 
* Solow Polasky ✅ 
* Approach for Basin Separated Evaluation ❌

#Experimental setup
###Done
* Reference points (combined results of all (working) algorithms in 30 independent runs)
* Budget determination (5000 evaluations)
* Sparkle leave-one-out configuration launch
* Gather configuration results and visualise

###TODO
* Configuration is done with fixed seeds. Do we need to do multiple runs for validation?