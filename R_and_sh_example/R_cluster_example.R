################################
#Another simple cluster example
#This is an example of simulations
#Can easily be changed
################################

#######
#Grab information on job ID
#######

touse<-as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))


#######
#Create table of simulation scenarios
#######
TabTabTabby<-expand.grid(c(0,0.5,1), #effect estimates
                          seq(200,1000,by=200))# sample size

#######
#Grab what parameters using for this run
#######
BetaUse<-TabTabTabby[touse,1]
N<-TabTabTabby[touse,2]
set.seed(touse+1975)
#######
#Number of replications
#######

Niter<-200
ResultsSave<-matrix(nrow=Niter,ncol=4)

#######
#Run Simulations
#######
set.seed(touse+1975)
for(i in 1:Niter){
  X<-rnorm(N)
  Y<-X*BetaUse+rnorm(N)
  Resu<-summary(lm(Y~X))
  ResultsSave[i,]<-coef(Resu)[2,]
}

#######
#Save Output
#Need to have a file called Output in your directory for this to work
#######
FileSave<-paste0("Output/data_results_simp_sim_",touse,".RDS")

saveRDS(ResultsSave,file=FileSave)

q("no")



