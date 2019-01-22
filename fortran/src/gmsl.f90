!=================================================================================
!  Subroutines to run Rahmstorf (2007) GMSL emulator:
!
!  Note that sea levels and temperature should all be relative to 1850-1870
!  means (pre-industrial).
!=================================================================================
!
! Private parameters/variables 'globally' used within module
!
!   tstep     time step
!
!   alpha     sensitivity of sea level change to temperature change (mm/deg C)
!   Teq       equilibrium temperature at which no sea-level change (deg C)
!             Teq is relative to pre-industrial (1850-1870 mean)
!   SL0       initial sea level (mm)
!
!================================================================================

module gmsl

    USE global
    implicit none
    private

    ! parameters:
    real(DP) :: tstep
    real(DP) :: sl_temp_sens, Teq, SL0

    ! public subroutines
    public :: gmsl_step_forward, init_gmsl


contains

!------------------------------------------------------------------------------
subroutine init_gmsl(alphaSL_in, Teq_in, SL0_in, sealevel)

!  =========================================================================
! |  Initialize the GMSL parameters and initial variables.                  |
!  =========================================================================

    real(DP), intent(IN) :: alphaSL_in
    real(DP), intent(IN) :: Teq_in
    real(DP), intent(IN) :: SL0_in

    real(DP), intent(OUT) :: sealevel

! Assign values to model parameters
    sl_temp_sens = alphaSL_in
    Teq = Teq_in
    SL0 = SL0_in

! Initial values
    sealevel = SL0_in

end subroutine init_gmsl
!------------------------------------------------------------------------------


!------------------------------------------------------------------------------
subroutine gmsl_step_forward(tstep, Tg_old, sealevel_old, sealevel_new)
!  ==========================================================================
! | Calculate current state from previous state
! |
! | Input:
! |       tstep:        model time step (years)
! |       Tg_old:       global mean surface temperature (degC, rel to 1850-1869 mean)
! |       sealevel_old: global mean sea level (mm, also rel to 1850-1869 mean)
! |
! | Output:
! |       sealevel_new: sea level in new model timestep (mm, rel to 1850-1869 mean)
!  ==========================================================================

    implicit none

    real(DP), intent(IN)  :: tstep
    real(DP), intent(IN)  :: Tg_old
    real(DP), intent(IN)  :: sealevel_old
    real(DP), intent(OUT) :: sealevel_new

    ! Start model
    sealevel_new = sealevel_old + tstep * (sl_temp_sens*(Tg_old - Teq))

end subroutine gmsl_step_forward
!------------------------------------------------------------------------------

END MODULE gmsl
