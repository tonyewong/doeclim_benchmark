##==============================================================================
# doeclim_gmslF.R
#
# Nathan M. Urban (nurban@psu.edu)
# Department of Geosciences, Penn State
#
#	Modified for GMSL model by Tony Wong (twong@psu.edu)
#
# Implements DOECLIM, a simple climate model
#
# DOECLIM is a 0-dimensional energy balance model (EBM) for the
# atmosphere coupled to a 1-dimensional diffusive ocean.  The
# model outputs temperature and ocean heat content time series
# as well as ocean heat fluxes.  See:
#
#  Elmar Kriegler, "Imprecise probability analysis for integrated
#  assessment of climate change", Ph.D. thesis, Potsdam (2005).
#   http://opus.kobv.de/ubp/volltexte/2005/561/
#  (Fortran port by Marlos Goes and Nathan Urban.)
#
# The model is implemented in Fortran and called from R.  This
# file also contains functions to load and process forcing data
# and model output.  Any pre/post-processing of input/output
# should be done in R or otherwise separate from the main
# model subroutine, which for computational efficiency
# should not perform any file I/O itself.  The Fortran model
# must be implemented as a standalone subroutine.
#
# For further information on R/Fortran coupling, see:
#
#   http://www.stat.umn.edu/~charlie/rc/
#   http://math.acadiau.ca/ACMMaC/howtos/Fortran_R.html
#   http://cran.r-project.org/doc/manuals/R-exts.pdf (chapter 5)
#
##==============================================================================
#
# Input forcing:
#  forcing					CO2 (RCP8.5) and aerosol, non-CO2 radiative forcings
#										(co2,nonco2.land/ocean,aerosol.land/ocean,solar.land/ocean,
#                    volc.land/ocean,tot.land,tot.ocean)
#
# Input parameters:
#  S								climate sensitivity (inc temp from 2xCO2) [deg C]
#  kappa            ocean vertical heat diffusivity [cm2/s]
#
# Output:
#  time             years when model was run [year]
#  temp             surface temperature anomaly [deg C]
#  ocheat           ocean heat uptake [10^22 J]
#  ocheat.mixed     mixed layer ocean heat anomaly [10^22 J]
#  ocheat.interior  interior ocean heat anomaly [10^22 J]
#                   (Note: ocheat = ocheat.mixed + ocheat.interior)
#  ocheatflux.mixed     heat uptake of the ocean mixed layer [W/m2]
#  ocheatflux.interior  heat uptake of the ocean interior [W/m2]
#
##==============================================================================

# convert annual ocean heat flux (W/m^2) to cumulative ocean heat content anomaly (10^22 J)
flux.to.heat = function(heatflux.mixed, heatflux.interior)
{
	flnd = 0.29 # area land fraction
	fso = 0.95 # ocean area fraction of interior
	secs.per.year = 31556926
	earth.area = 510065600 * 10^6
	ocean.area = (1-flnd)*earth.area
	powtoheat = ocean.area*secs.per.year / 10^22 # in 10^22 J/yr

	heat.mixed = cumsum(heatflux.mixed) * powtoheat
	heat.interior = fso * cumsum(heatflux.interior) * powtoheat
	ocean.heat = heat.mixed + heat.interior

	return(list(ocean.heat=ocean.heat, heat.mixed=heat.mixed, heat.interior=heat.interior))
}

## load DOECLIM model shared library
dyn.load("../fortran/doeclim_gmsl.so")

# DOECLIM climate model (0D EBM atmosphere + 1D diffusive ocean)
# inputs: climate sensitivity (S), ocean vertical diffusivity (kappa), aerosol forcing scale factor (alpha)
# outputs: annual global temperature (temp, K) and total ocean heat (ocheat, 10^22 J), mixed-layer and interior ocean heat (ocheat.mixed and ocheat.interior, 10^22 J), atmosphere->mixed and mixed->interior heat fluxes (ocheatflux.mixed and ocheatflux.interior, W/m^2)
doeclim_gmslF = function(
							S     = 3.1,
							kappa = 3.5,
							alphaSL = 3.4,
							Teq = -0.5,
							SL0 = 0,
							forcing.total,
							mod.time
							)
{
	n = length(mod.time)

	# call Fortran DOECLIM-GMSL model
	# doeclim_gmsl.so must be already dynamically loaded (see above this function)
	fout = .Fortran( "run_doeclim_gmsl",
			ns = n,
			time_out = as.double(mod.time),
			forcing_in = as.double(forcing.total),
			t2co_in = as.double(S),
			kappa_in = as.double(kappa),
			alphaSL_in = as.double(alphaSL),
			Teq_in = as.double(Teq),
			SL0_in = as.double(SL0),
			temp_out = as.double(rep(0,n)),
			heatflux_mixed_out = as.double(rep(0,n)),
			heatflux_interior_out = as.double(rep(0,n)),
			gmsl_out = as.double(rep(0,n))
		)

	ocheat = flux.to.heat(fout$heatflux_mixed, fout$heatflux_interior)

  # make sure temperatures and sea levels are realtive to 1850-1869 mean (pre-industrial)
	fout$temp_out <- fout$temp_out - mean(fout$temp_out[1:20])
	fout$gmsl_out <- fout$gmsl_out - mean(fout$gmsl_out[1:20])

	model.output = list(time=mod.time, temp=fout$temp_out, ocheat=ocheat$ocean.heat,
											ocheat.mixed=ocheat$heat.mixed, ocheat.interior=ocheat$heat.interior,
											ocheatflux.mixed = fout$heatflux_mixed, ocheatflux.interior = fout$heatflux_interior,
											gmsl = fout$gmsl_out)

	return(model.output)
}
