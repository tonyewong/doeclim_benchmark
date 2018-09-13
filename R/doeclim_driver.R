##==============================================================================
##
##	Implementation of DOECLIM energy balance model
##	(Diffusion Ocean Energy CLIMate model, Kriegler, 2005; Tanaka et al, 2007)
##  standard model simulation for benchmarking.
##
##  This is standard model using the radiative forcing of Kriegler 2005, and
##  values for the parameters of:
##    climate sensitivity (S) = 3.1
##    ocean vertical diffusivity (kappa) = 3.5
##    aerosol scaling factor (alpha) = 1.1
##
##	Questions? -- Tony Wong <twong@psu.edu>
##
##==============================================================================

rm(list=ls())	# Clear all previous variables

## Get the forcing data - this data set decomposes the radiative forcing into
## a number of different contributors. the `forcing_total()` routine (below)
## adds them up.
forcing <- read.csv( '../data/forcing_hindcast.csv', header=TRUE )
mod.time <- forcing$year

## Load the actual model
source('doeclimF.R')

## Set some default parameter values
climate_sensitivity <- 3.1
ocean_vertical_diffusivity <- 3.5
aerosol_scaling <- 1.1

## Calculate total forcing
source('forcing_total.R')  # Load a function that adds up the total radiative forcing
forcing.total <- forcing_total(forcing=forcing, alpha.doeclim=aerosol_scaling,
                               l.project=FALSE, begyear=mod.time[1], endyear=max(mod.time))

## Run a standard simulation
doeclim_out <- doeclimF(S=climate_sensitivity, kappa=ocean_vertical_diffusivity, forcing.total, mod.time)

## Write the output to a CSV file to read into Python/Jupyter/etc
write.csv(doeclim_out, file='../output/doeclim_output.csv', row.names=FALSE)

##==============================================================================
## End
##==============================================================================
