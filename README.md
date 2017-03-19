# Time-location Sampling: A potential sampling approach for Border Monitoring

## Definition of TLS
Time-location sampling is used to sample a population for which a sampling frame cannot be constructed but locations are known at which the population of interest can be found, or for which it is more efficient to sample at these locations. The objective is to reach individuals in places and at times where they gather. Locations are selected at random from the sampling frame of candidate locations, and persons are enrolled by sampling at these locations. 


Arbitrary convenience samples compromise validity of comparisons between survey rounds since change in the composition of the successive sample may stem from the difference in methods. TLS 
significantly reduces arbitrary selection of venues and individuals and provides a replicable method of sample selection. TLS is recommended when all population members can be reached at 2 certain sites at different times and where no comprehensive list (census) of the target population exists

Because the probability of being sampled varies among enrolled persons and persons enrolled at the same location may have similar characteristics, TLS data should be analyzed using sample-survey methods in order to make inference to the population of persons attending these locations. In TLS, the persons are not sampled as an independent, identically distributed sample chosen with equal probability from an infinite population.

The script presented here was adapted from [Design-based inference in time-location sampling](https://academic.oup.com/biostatistics/article/16/3/565/269802/Design-based-inference-in-time-location-sampling#26958236) by Caterina Schiavoni.

## Implementation
As explained in this [paper](http://iussp2009.princeton.edu/papers/93359), Time-Location Sampling (also known as venue sampling) is a probabilistic method used to recruit members of a target population at specific times in set venues. The sampling framework consists of venue-day-time units (VDT) – also known as time-location units - which represent the potential universe of venues, days and times. For example, a VDT unit could be a defined period of four hours on a Monday in a specific venue. 

The fieldwork team identifies a range of time-location units to locate the members of the target population through interviews and key informants, service providers, and members of the target population. Then, the team visits the venues and prepares a list of VDT units which are considered potentially eligible on the basis of checking the number of people present. In addition, interviews are conducted with those in charge of the venue to ascertain affluence on certain days and at certain times. With this information, population size for each VDT unit, and the number eligible for each sample are estimated. 

The sample is selected in stages. In the first stage of the sampling strategy, a simple or stratified sample of all the time-location units which appear in the sampling frame list (preferably with probability proportional to the total number of members of the population eligible for each time-location unit) is selected. In the second stage, the participants are systematically selected for each time-location unit selected randomly. 



