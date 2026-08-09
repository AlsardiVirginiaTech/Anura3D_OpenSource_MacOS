    !*****************************************************************************
    !
    !   Anura3D - storage module for the TempParticles scratch array
    !
    !   TempParticles was originally a local variable of the particle
    !   rediscretisation routine (AdjustParticleDiscretisation). gfortran
    !   (through at least 14.x) hits internal compiler errors deallocating
    !   arrays of parameterized derived types in every context except one:
    !   a module-level array, deallocated by a minimal contained subroutine
    !   with no stat=, no local variables and no dummy arguments, as the
    !   only such pattern in its module.
    !
    !   This module replicates exactly that shape. Do not add stat=, locals,
    !   arguments, or further PDT deallocations here.
    !
    !*****************************************************************************

      module ModTempParticleStorage

      use ModParticle

      implicit none

        ! Scratch copy of the particle array used by AdjustParticleDiscretisation
        type(ParticleType(:, :, :)), dimension(:), allocatable, public :: TempParticles

      contains

        subroutine DestroyTempParticles()
        !**********************************************************************
        !
        !    Function:  Deallocates the TempParticles scratch array.
        !
        !**********************************************************************

        implicit none

          if (allocated(TempParticles)) deallocate(TempParticles)

        end subroutine DestroyTempParticles

      end module ModTempParticleStorage
