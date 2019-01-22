# Define "all"
all: doeclim.so doeclim_gmsl.so

# Fortran compiler:
F90 = /usr/local/bin/gfortran # g95

# Directories: objpath, srcpath
OP = ./obj
SP = ./src

# Compiler flags:
Optimization = -O3
SOFlags = -fPIC
#Modpath = -module $(OP)
#Flags = ${SOFlags} ${Optimization} -fno-range-check #$(Modpath)
Flags = ${SOFlags} -fno-range-check #$(Modpath)

# Preprocessor options:
#CPP = cpp
#CPPFLAGS = -DMOC_NOISE

# ==============================================================
## The main programs/subroutines ##
# ==============================================================

doeclim.so: $(OP)/global.o $(OP)/doeclim.o $(OP)/run_doeclim.o
	$(F90) -o $@ $(Flags) -shared $(Incl) $^

doeclim_gmsl.so: $(OP)/global.o $(OP)/doeclim.o $(OP)/gmsl.o $(OP)/run_doeclim_gmsl.o
	$(F90) -o $@ $(Flags) -shared $(Incl) $^

# ==============================================================
## Main Object files ##
# ==============================================================

## DOECLIM ##
$(OP)/run_doeclim.o: $(OP)/global.o $(SP)/run_doeclim.f90
	$(F90) -c $(Flags) $(Incl) $(SP)/run_doeclim.f90 -o $@

$(OP)/doeclim.o: $(OP)/global.o $(SP)/doeclim.f90
	$(F90) -c $(Flags) $(Incl) $(SP)/doeclim.f90 -o $@

## GMSL ##
$(OP)/run_doeclim_gmsl.o: $(OP)/global.o $(SP)/run_doeclim_gmsl.f90
	$(F90) -c $(Flags) $(Incl) $(SP)/run_doeclim_gmsl.f90 -o $@

$(OP)/gmsl.o: $(OP)/global.o $(SP)/gmsl.f90
	$(F90) -c $(Flags) $(Incl) $(SP)/gmsl.f90 -o $@

## Some global variables used in all/most modules ##
$(OP)/global.o: $(SP)/global.f90
	$(F90) -c $(Flags) $(Incl) $(SP)/global.f90 -o $@

.PHONY: clean

#Cleaning up
clean:
	rm -f $(OP)/*.o $(OP)/*.mod $(OP)/*.F90
