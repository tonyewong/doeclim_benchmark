# doeclim_benchmark

Questions?  Tony Wong (<anthony.e.wong@colorado.edu>)
---

This establishes a baseline result against which other implementations of **DOECLIM** (Diffusion-Ocean-Energy Balance Climate Model; Krieglar 2005) can be tested.

### Workflow

**1)** Clone the repository
```
git clone https://github.com/tonyewong/doeclim_benchmark.git
```

**2)** Change directories into the `fortran` directory. Edit the `Makefile` to point to wherever your preferred fortran compiler is. If you are not sure, try running `which gfortran` or `which g95`, then pointing the `F90` variable in the `Makefile` to wherever your fortran compiler is located.

You may also need to `mkdir obj` if this is a fresh clone of the repository, and there is no `obj` directory within the `fortran` directory.

Then, run `make` to compile the model. Be sure you do this in the `fortran` directory.
```
cd doeclim_benchmark/fortran
make
```

**3)** Change directories into the `R` directory. Open an R terminal.
```
cd ../R
R
```

**4)** Now in the R terminal, run the `doeclim_driver.R` script. This will run an instance of the DOECLIM model using the standard parameter values of 3.1 for climate sensitivity (S), 3.5 for ocean vertical diffusivity ($\kappa$) and 1.1 for aerosol scaling factor ($\alpha$).
```
source('doeclim_driver.R')
```

**5)** The `doeclim_driver.R` routine will yield a file in the `output` directory called `doeclim_output.csv`. The model will be run for the years 1750 through 2009, which corresponds to the first column of the `doeclim_output.csv` array. The other columns, in order, correspond to:
* temp: the global mean surface temperature anomaly (degrees Celsius). by default, this is relative to the first year of the simulation (1750), but when comparing against other model implementations and/or observational data, should be normalized relative to some time period (e.g., 1750-1850 mean).
* ocheat: the ocean heat uptake ($10^{22}$ J). by default, this is also relative to the first year of the simulation. When comparing against other model implementations and/or observational data, this should be normalized consistently with the other time series. This output is what should be compared against observational data sets like Gouretski and Koltermann.
* ocheat.mixed/ocheat.interior: ocean heat anomaly in the mixed layer (near surface) and in the interior (deeper) ($10^{22}$ J)
* ocheatflux.mixed/ocheatflux.interior: ocean heat uptake by the mixed layer and by the interior (W m$^{-2}$)

**6)** Read the `dooeclim_output.csv` results into whatever IDE you want to make the model implementation comparisons in. The main time series of interest are global mean surface temperature anomaly (temp) and ocean heat uptake (ocheat). Be sure that the model output from both versions of the model (the R/fortran one here and the one you want to compare against) are normalized relative to the same time period. Or, just leave `temp` and `ocheat` as relative to the first year of the simulations.
