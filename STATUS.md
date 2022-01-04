#Algorithms

###NSGA-II ✅
###omnioptimizer ✅
###SMS-EMOA ✅

###DN-NSGA-II
* wrapper
* pcs

###higamo
* wrapper
* pcs 

###MOAED
* pcs

###MOGSA
* Takes a long time sometimes (investigate)

###MOLE
`Runtime error: Error in run_mole_cpp Expecting a single value: [extent=0]`.

#Quality measures
* Hypervolume ✅ 
* IDG+ ✅ 
* Solow Polasky ✅ 
* ❌

#Experimental setup
###Done
* Reference points (combined results of all (working) algorithms in 30 independent runs)
* Budget determination (5000 evaluations)
* Sparkle leave-one-out configuration launch

###TODO
* Gather configuration results and visualise.
* Configuration is done with fixed seeds. Do we need to do multiple runs for validation?