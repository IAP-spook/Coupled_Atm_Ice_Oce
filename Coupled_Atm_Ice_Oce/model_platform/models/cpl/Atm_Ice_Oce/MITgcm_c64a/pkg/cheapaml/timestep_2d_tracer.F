C $Header: /u/gcmpack/MITgcm/pkg/cheapaml/timestep_2d_tracer.F,v 1.5 2012/08/11 19:50:47 jmc Exp $
C $Name: checkpoint64a $

#include "CHEAPAML_OPTIONS.h"

CBOP
C     !ROUTINE: TIMESTEP_2d_TRACER
C     !INTERFACE:
      SUBROUTINE TIMESTEP_2d_TRACER(
     I                     bi, bj, iMin, iMax, jMin, jMax,
     I                     deltaTTracer,
     I                     tracer, gTracer,
     I                     myIter, myThid )
C     !DESCRIPTION: \bv
C     *==========================================================*
C     | S/R TIMESTEP_2d_TRACER
C     | o Step model tracer field forward in time
C     *==========================================================*
C     \ev

C     !USES:
      IMPLICIT NONE
C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine Arguments ==
      INTEGER bi,bj,iMin,iMax,jMin,jMax
      _RL  tracer (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  gTracer(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL  deltaTTracer
      INTEGER myIter, myThid

C     !LOCAL VARIABLES:
C     == Local variables ==
      INTEGER i,j
CEOP

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C     -    Extrapolate tendancies to mid-time level (n+1/2)
      DO j=jMin,jMax
        DO i=iMin,iMax
          gTracer(i,j,bi,bj)=tracer(i,j,bi,bj)
     $       +deltaTtracer*gTracer(i,j,bi,bj)
        ENDDO
      ENDDO

      RETURN
      END
