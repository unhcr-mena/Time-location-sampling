### Script by C. Sch

## Adapted from https://academic.oup.com/biostatistics/article/16/3/565/269802/Design-based-inference-in-time-location-sampling#26958236.



#############################################################
## STEP 1: Install & load Required Library
#############################################################


#############################################################
## STEP 2: Insert your configuration for the sample
#############################################################

# Confirm the the population size called here N
## This is the total number of people in the group you are trying to reach with the survey. 
N <- 10000
#id variable
id <- seq(1:N)

# Decide on the confidence level
# It represents the probability of the same result if you re-sampled, all other things equal.
# A measure of how certain you are that your sample accurately reflects the population, within its margin of error.
## Common standards used by researchers are 90%, 95%, and 99%.
cl <- 0.95
z <- abs(qt((1-cl)/2, (N-1)))

# Decide on the margin of error - Precision  
# This percentage describes the variability of the estimate: how closely the answer your sample gave is
# to the "true value" is in your population. 
# The smaller the margin of error is, the closer you are to having the exact answer at a given confidence level.
# A smaller margin of error means that you must have a larger sample size given the same population.
## Common standards used by researchers are: ? 5%, ? 3% , ? 1%)
e <- 0.10

## Expected final sample size
n0 <- N/(1+N*(e^2))
n0 <- round(n0, digits = 0)

#############################################################
## STEP 3: Generate the variables and the dataset
#############################################################
# PS: note that you can skip that step if you have already your dataset

## This is the vector of the number of days when the survey takes place - suppose they are 30
days <- c(1:30)
## This is the vector of the time slots (periods) when the survey can be done in each day (suppose it can only be done 4 hours per day)
period <- sample(x=c("8-12", "10-14", "12-16", "14-18", "16-20"), size=30, replace=TRUE)
time <- data.frame(days, period)
time <- time[sample(nrow(time),size=N,replace=TRUE),]

## Generate randome variables for the test dataset
sex <- sample(x=c(0,1), size=N, replace=TRUE, prob=c(.4,.6))
age <- sample(x=c("15-24", "25-64", "65+"), size=N, replace=TRUE, prob=c(.3,.5,.2))
## This is the vector of the locations where the survey can take place
location <- floor(runif(N, min=1, max=101)) 
# The locations are expressed in numbers for sake of simplicity of the simulation, but a vector of strings should work as well

## Bind all variable to get our test dataset
data <- data.frame(id, sex, age, location, time)


#############################################################
## STEP 4: Three-stages sampling design
#############################################################

# First stage

## Compute the sample size to sample the locations
n <- length(unique(location))/(1+(length(unique(location))*(e^2)))
n <- round(n, digits = 0)

## Randomly sample the locations without replacement 
location_sampled <- sample(unique(location), size=n, replace = FALSE, prob = NULL)
sample <- subset(data, location %in% location_sampled)

## Calculate the inclusion probabilities in the first-stage sample
prob_locations <- rep(n/length(unique(location)), length(sample$location))

## Add the inclusion probabilities in the sampled dataset
sample <- data.frame(sample, prob_locations)

## Split the obtained sample according to the location
subsetTab <- split(sample, sample$location)

# Second stage

## Compute the sample size for each subset to sample the days
listn <- list()
for (i in 1:length(subsetTab)){
  listn[i] <- length(unique(subsetTab[[i]]$days))/(1+(length(unique(subsetTab[[i]]$days))*(e^2)))
  listn[i] <- round(listn[[i]], digits = 0)
}

## Compute the inclusion probabilities in the second-stage samples
prob_days <- vector()
for (i in 1:length(subsetTab)){
  prob_days[i] <- listn[[i]]/length(unique(subsetTab[[i]]$days))
}

## Randomly sample the days without replacement from each subset
days_sampled <- list()
for (i in 1:length(subsetTab)){
  days_sampled[[i]] <- sample(unique(subsetTab[[i]]$days), size=listn[[i]], replace = FALSE, prob = NULL)
  subsetTab[[i]] <- subset(subsetTab[[i]], days %in% days_sampled[[i]])
}

## Add the inclusion probabilites in the sampled dataset
for (i in 1:length(subsetTab)){
  subsetTab[[i]] <- data.frame(subsetTab[[i]], prob_days[i])
}

## Split the obtained samples according to the day
for (i in 1:length(subsetTab)){
  subsetTab[[i]] <- split(subsetTab[[i]], subsetTab[[i]]$days)
}

# Third sage

## Compute the sample size for each subset to sample the individuals
listn2 <- list()
listn3 <- list()
for (i in 1:length(subsetTab)){
  for (j in 1:length(subsetTab[[i]])) {
    listn2[j] <- length(subsetTab[[i]][[j]]$id)/(1+(length(subsetTab[[i]][[j]]$id))*(e^2))
    listn2[j] <- round(listn2[[j]], digits = 0)
  }
  listn3[i] <- list(listn2)
}

## Compute the inclusion probabilities in the third-stage samples
prob_id <- vector()
all_prob_id <- list()
for (i in 1:length(subsetTab)){
  for (j in 1:length(subsetTab[[i]])) {
    prob_id[[j]] <- listn3[[i]][[j]]/length(unique(subsetTab[[i]][[j]]$id))
  }
  all_prob_id[i] <- list(prob_id)
}

## Randomly sample the individuals without replacement from each subset
id_sampled <- list()
all_id_sampled <- list()
for (i in 1:length(subsetTab)){
  for (j in 1:length(subsetTab[[i]])) {
    id_sampled[[j]] <- sample(subsetTab[[i]][[j]]$id, size=listn3[[i]][[j]], replace = FALSE, prob = NULL)
    } 
  all_id_sampled[i] <- list(id_sampled)
}

## Get the final sample with the sampled individuals
for (i in 1:length(subsetTab)){
  for (j in 1:length(subsetTab[[i]])) {
    subsetTab[[i]][[j]] <- subset(subsetTab[[i]][[j]], id %in% all_id_sampled[[i]][[j]])
  }
}

## Add the inclusion probabilites in the sampled dataset
for (i in 1:length(subsetTab)){
  for (j in 1:length(subsetTab[[i]])) {
    subsetTab[[i]][[j]] <- data.frame(subsetTab[[i]][[j]], rep(all_prob_id[[i]][[j]], length(subsetTab[[i]][[j]]$id)))
  }
}

## Get the final sample in a data.frame format
subsetTab <- unlist(subsetTab, recursive = FALSE)
sample_final <- do.call("rbind", subsetTab)
## Order the final dataset according to the id
sample_final <- sample_final[order(sample_final$id),]
## change the name of the last 2 columns (inclusion probabilites of the second and third stages)
colnames(sample_final)[8] <- "prob_days"
colnames(sample_final)[9] <- "all_prob_id"

## Check if the final sample contains the sampled locations and days
length(unique(sample_final$location))
length(location_sampled)
all(unique(sample_final$location) %in% location_sampled)
days_sampled_unlisted <- unlist(days_sampled)
length(unique(days_sampled_unlisted))
length(unique(sample_final$days))
all(unique(sample_final$days) %in% unique(days_sampled_unlisted))


#############################################################
## STEP 5: Conduct Inference
#############################################################

## compute the final inclusion probabilities
prob_final <- sample_final$prob_locations*sample_final$prob_days*sample_final$all_prob_id
## Compute the final sampling weight
weight_final <- (1/sample_final$prob_locations)*(1/sample_final$prob_days)*(1/sample_final$all_prob_id)
sample_final <- data.frame(sample_final, prob_final, weight_final)

# Horovitz-Thompson estimator
## Use the final weights to estimate parameters of interest (proportions, totals, means etc.)
## For instance, let's estimate the parameters for sex:
### Total:
tot <- sum(sample_final$weight_final*sample_final$sex, na.rm = TRUE)
print(tot)
### compare with
table(data$sex)
### Proportion of females:
prop <- tot/sum(sample_final$weight_final)
print(prop)
### Compare with 
summary(data$sex)
