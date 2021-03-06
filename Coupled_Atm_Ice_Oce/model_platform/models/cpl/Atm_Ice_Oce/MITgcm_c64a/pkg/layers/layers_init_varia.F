C $Header: /u/gcmpack/MITgcm/pkg/layers/layers_init_varia.F,v 1.6 2012/10/18 19:51:14 jmc Exp $
C $Name: checkpoint64a $

#include "LAYERS_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      SUBROUTINE LAYERS_INIT_VARIA( myThid )

C ===================================================================
C     Initialize LAYERS variables.
C ===================================================================

      IMPLICIT NONE
#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "LAYERS_SIZE.h"
#include "LAYERS.h"

C  INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid

#ifdef ALLOW_LAYERS

C     === Local variables ===
      INTEGER i,j,kg,bi,bj
c     INTEGER iLa

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)

C     Loop through 3D variables:
        DO kg=1,Nlayers
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx

#ifdef LAYERS_UFLUX
           layers_UH (i,j,kg,bi,bj) = 0. _d 0
#ifdef LAYERS_THICKNESS
           layers_Hw (i,j,kg,bi,bj) = 0. _d 0
           layers_PIw(i,j,kg,bi,bj) = 0. _d 0
           layers_U  (i,j,kg,bi,bj) = 0. _d 0
#endif /* LAYERS_THICKNESS */
#endif /* LAYERS_UFLUX */

#ifdef LAYERS_VFLUX
           layers_VH (i,j,kg,bi,bj) = 0. _d 0
#ifdef LAYERS_THICKNESS
           layers_Hs (i,j,kg,bi,bj) = 0. _d 0
           layers_PIs(i,j,kg,bi,bj) = 0. _d 0
           layers_V  (i,j,kg,bi,bj) = 0. _d 0
#endif /* LAYERS_THICKNESS */
#endif /* LAYERS_VFLUX */

          ENDDO
         ENDDO
        ENDDO
#ifdef LAYERS_PRHO_REF
        DO kg=1,Nr
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           prho(i,j,kg,bi,bj) = 0. _d 0
          ENDDO
         ENDDO
        ENDDO
#endif /* LAYERS_PRHO_REF */

C- end bi,bj loops
       ENDDO
      ENDDO

#endif /* ALLOW_LAYERS */

      RETURN
      END
