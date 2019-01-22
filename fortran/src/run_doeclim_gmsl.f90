SUBROUTINE run_doeclim_gmsl(ns, time_out, forcing_in, t2co_in, kappa_in, alphaSL_in, Teq_in, SL0_in, &
                           temp_out, heatflux_mixed_out, heatflux_interior_out, gmsl_out)

    USE global
    USE doeclim
    USE gmsl

    implicit none

    integer(i4b), intent(IN) :: ns
    real(DP), intent(IN) :: t2co_in
    real(DP), intent(IN) :: kappa_in
    real(DP), intent(IN) :: alphaSL_in
    real(DP), intent(IN) :: Teq_in
    real(DP), intent(IN) :: SL0_in
    real(DP), dimension(ns), intent(IN) :: forcing_in
    real(DP), dimension(ns), intent(OUT) :: time_out
    real(DP), dimension(ns), intent(OUT) :: temp_out
    real(DP), dimension(ns), intent(OUT) :: heatflux_mixed_out
    real(DP), dimension(ns), intent(OUT) :: heatflux_interior_out
    real(DP), dimension(ns), intent(OUT) :: gmsl_out

    integer(i4b) :: i
    integer(i4b) :: start_year = 1850

! Assign global variables.
    nsteps = ns
    deltat = 1.0d0

    call init_doeclim_arrays()

    call init_doeclim_parameters(t2co_in, kappa_in)

    call init_gmsl(alphaSL_in, Teq_in, SL0_in, gmsl_out(1))

    ! Run DOECLIM
    do i = 1,nsteps
        call doeclimtimestep_simple(i, forcing_in(i), temp_out(i))
        time_out(i) = start_year + (i-1)*deltat
    end do
    heatflux_mixed_out = heatflux_mixed
    heatflux_interior_out = heatflux_interior

    ! Normalize temperatures relative to pre-industrial
    ! (this includes the year 1870 in pre-industrial)
    temp_out(:) = temp_out(:) - (SUM(temp_out(1:21))/21.0)

    ! Run GMSL model
    do i = 1,(nsteps-1)
        call gmsl_step_forward(deltat, temp_out(i), gmsl_out(i), gmsl_out(i+1))
    end do

    call dealloc_doeclim()

    RETURN

END SUBROUTINE run_doeclim_gmsl
