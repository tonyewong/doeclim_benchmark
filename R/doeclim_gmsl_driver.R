##==============================================================================
##
##	Implementation of DOECLIM energy balance model, coupled to Rahmstorf 2007
##  emulator for global mean sea level (GMSL).
##
##	(Diffusion Ocean Energy CLIMate model, Kriegler, 2005; Tanaka et al, 2007)
##  standard model simulation for benchmarking.
##
##  This is standard model using the radiative forcing of Kriegler 2005, and
##  values for the parameters of:
##    climate sensitivity (S) = 3.1
##    ocean vertical diffusivity (kappa) = 3.5
##    aerosol scaling factor (alpha) = 1.1
##  And standard values for GMSL emulator of:
##    sea level sensitivity to temperature changes = 3.4 mm/deg C
##    equilibrium temperature = -0.5 deg C (rel to 1850-1869 mean; preindustrial)
##    initial (1850) sea level of 0 mm
##
##	Questions? -- Tony Wong <anthony.e.wong@colorado.edu>
##
##==============================================================================

rm(list=ls())	# Clear all previous variables

setwd('~/codes/doeclim_benchmark/R')

## Get the forcing data - this data set decomposes the radiative forcing into
## a number of different contributors. the `forcing_total()` routine (below)
## adds them up.
forcing <- read.csv( '../data/forcing_hindcast.csv', header=TRUE )

## Trim that down to only 1850-2009
ibeg <- which(forcing$year==1850)
iend <- which(forcing$year==2009)
forcing <- forcing[ibeg:iend,]
mod.time <- forcing$year

## Load the actual model
source('doeclim_gmslF.R')

## Set some default parameter values
climate_sensitivity <- 3.1
ocean_vertical_diffusivity <- 3.5
aerosol_scaling <- 1.1
sl_temp_sens <- 3.4
Teq <- -0.5
SL0 <- 0

## Calculate total forcing
source('forcing_total.R')  # Load a function that adds up the total radiative forcing
forcing.total <- forcing_total(forcing=forcing, alpha.doeclim=aerosol_scaling,
                               l.project=FALSE, begyear=mod.time[1], endyear=max(mod.time))

## Run a standard simulation
model_out <- doeclim_gmslF(S=climate_sensitivity, kappa=ocean_vertical_diffusivity,
                           alphaSL=sl_temp_sens, Teq=Teq, SL0=SL0,
                           forcing.total, mod.time)

## Write the output to a CSV file to read into Python/Jupyter/etc
write.csv(model_out, file='../output/doeclim_gmsl_output.csv', row.names=FALSE)

##==============================================================================
## End
##==============================================================================
