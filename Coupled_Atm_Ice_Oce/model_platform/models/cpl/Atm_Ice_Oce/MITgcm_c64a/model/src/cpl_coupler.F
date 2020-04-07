C $Header: /u/gcmpack/MITgcm/model/src/cpl_coupler.F,v 1.140
C 2012/11/15 15:55:42 dimitri Exp $
C $Name: checkpoint64a $


#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"
#ifdef ALLOW_OBCS
# include "OBCS_OPTIONS.h"
#endif
#ifdef ALLOW_SEAICE
# include "SEAICE_OPTIONS.h"
#endif
#ifdef ALLOW_GENERIC_ADVDIFF
# include "GAD_OPTIONS.h"
#endif
#ifdef ALLOW_GMREDI
# include "GMREDI_OPTIONS.h"
#endif
#ifdef ALLOW_STREAMICE
# include "STREAMICE_OPTIONS.h"
#endif
#ifdef ALLOW_GGL90
# include "GGL90_OPTIONS.h"
#endif
#ifdef ALLOW_EXF
# include "EXF_OPTIONS.h"
#endif


CBOP
C     !ROUTINE: register_component_coupling_configuration
      
      
        SUBROUTINE register_coupling_configuration(time_step)
        USE ccpl_interface_mod         
        IMPLICIT NONE

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "FFIELDS.h"
#include "GRID.h"

        INTEGER               :: i,j,k,t,ierr
        INTEGER               :: proc_id
        INTEGER, INTENT(IN)   :: time_step

        INTEGER               :: grid_H2D_id,decomp_id
        INTEGER               :: export_interface_id,import_interface_id
        INTEGER               :: timer1_id
        INTEGER               :: field_id_t2,field_id_q2,field_id_u10,
     &                            field_id_v10
        INTEGER               :: field_id_test_array
        INTEGER               :: local_cells_global_index(0:sNx*sNy-1)
C       INTEGER               :: local_cells_global_index(sNx*sNy)
        _RS                   :: min_lon,min_lat,max_lon,max_lat
        _RS, ALLOCATABLE      :: xcc(:),ycc(:)
        INTEGER               :: fields_id(10)
        INTEGER,ALLOCATABLE   :: mask(:)
        LOGICAL               :: interface_status
        INTEGER               :: num_comps, individual_or_family(100)
        CHARACTER*1024        :: comps_full_names(12)
        INTEGER               :: iBase,jBase
     
 
        proc_id = CCPL_get_current_process_id_in_component(comp_id,
     &  annotation="MITgcm get current process id" )

        local_cells_global_index=0
        k=0
        iBase = mpi_myXGlobalLo(proc_id+1)-1
        jBase = mpi_myYGlobalLo(proc_id+1)-1
        DO j=1,sNy
            DO i=1,sNx
               local_cells_global_index(k)=iBase+i+(jBase+j-1)*(sNx*nPx)
               k = k + 1
            enddo
        enddo


C-------Choose the exact part of the xC,yC
        k=1
        allocate(xcc(sNx*sNy))
        allocate(ycc(sNx*sNy))
        allocate(mask(sNx*sNy))
        do i=1,sNx
            do j=1,sNy
                xcc(k) = xC(i,j,1,1)
                ycc(k) = yC(i,j,1,1)
                mask(k) = 1
                k = k + 1
            enddo
        enddo
        print *,"thexc is,",xC(1:sNx,1:sNy,1,1)
C------make test array data--------       
       do i=1,sNx
            do j=1,sNy
                test_array(i,j) = 1
            enddo
       enddo
C-------Find the Max and the Min of the lon and lat of global grid

        min_lat = 0.0
        max_lat = 90.0
        min_lon = 0.0
        max_lon = 360.0

!        CALL MPI_AllREDUCE(MPI_IN_PLACE,min_lat,1,MPI_REAL8,MPI_MIN,
!     &  comm,ierr)
!        CALL MPI_AllREDUCE(MPI_IN_PLACE,max_lat,1,MPI_REAL8,MPI_MAX,
!     &  comm,ierr)
!        CALL MPI_AllREDUCE(MPI_IN_PLACE,min_lon,1,MPI_REAL8,MPI_MIN,
!     &  comm,ierr)
!        CALL MPI_AllREDUCE(MPI_IN_PLACE,max_lon,1,MPI_REAL8,MPI_MAX,
!     &  comm,ierr)

C-------give it a constant min and max,the lon is cyclic,
!       
        grid_H2D_id = CCPL_register_H2D_grid_via_local_data(comp_id,
     &  "MITgcm_H2D_grid","LON_LAT","degrees","cyclic",
     &  sNx*sNy*nPx*nPy,sNx*sNy,
     &  local_cells_global_index,min_lon,max_lon,min_lat,max_lat,
     &  xcc,ycc,mask,annotation="register a H2D grid for MITgcm")
        decomp_id = CCPL_register_normal_parallel_decomp(
     &  "MITgcm_decomp",
     &  grid_H2D_id,sNx*sNy,local_cells_global_index,"register decomp
     &  for MITgcm")
       
        CALL CCPL_set_normal_time_step(comp_id, time_step, 
     &  annotation="setting the time step for MITgcm")

        timer1_id = CCPL_define_single_timer(comp_id, "seconds",
     &  time_step, 0, 0, annotation="define a single timer for MITgcm")

        field_id_test_array = CCPL_register_field_instance(test_array,
     &  "test_array",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,
     &  field_unit="K",
     &  annotation="register field test_array for MITgcm")
        
        fields_id(1)=field_id_test_array

        export_interface_id = CCPL_register_export_interface(
     &  "send_data_to_WRF", 1, fields_id, timer1_id, 
     &  annotation="register interface for sending data to CPL")

        field_id_t2 = CCPL_register_field_instance(ccpl_t2,
     &  "t2",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,
     &  field_unit="K", annotation="register field t2 for MITgcm")
        field_id_q2=CCPL_register_field_instance(ccpl_q2,
     &  "q2",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,
     &  field_unit="kg kg-1",annotation="register field q2 for MITgcm")
        field_id_u10=CCPL_register_field_instance(ccpl_u10,
     &  "u10",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,
     &  field_unit="m s-1",annotation="register field u10 for MITgcm")
        field_id_v10=CCPL_register_field_instance(ccpl_v10,
     &  "v10",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,
     &  field_unit="m s-1",annotation="register field v10 for MITgcm")

        fields_id(1)=field_id_t2
        fields_id(2)=field_id_q2
        fields_id(3)=field_id_u10
        fields_id(4)=field_id_v10
        import_interface_id = CCPL_register_import_interface(
     &  "recv_data_from_WRF", 4, fields_id,timer1_id,0,
     &  annotation="register interface for receiving data from MIT")
        call CCPL_do_individual_coupling_generation(comp_id,
     &  "component WRF begin individual coupling generation.")
        call CCPL_get_configurable_comps_full_names(comp_id,
     &  "external_comps_for_coupling_generation", num_comps, 
     &  comps_full_names,
     &  annotation="test CCPL_get_configurable_comps_full_names")
     
        call CCPL_do_external_coupling_generation(num_comps,
     &  comps_full_names, annotation="external coupling generation
     &  for fixed interface")
        call CCPL_end_coupling_configuration(comp_id, annotation=
     &  "component MITgcm  end registration")
        print *,"Finish CCPL configuration"
        interface_status = CCPL_execute_interface_using_name(comp_id,
     &  "send_data_to_WRF", .true.)
        interface_status = CCPL_execute_interface_using_name(comp_id,
     &  "recv_data_from_WRF", .true.)

        interface_status = CCPL_execute_interface_using_name(comp_id,
     &  "send_data_to_WRF", .false.)
        interface_status = CCPL_execute_interface_using_name(comp_id,
     &  "recv_data_from_WRF", .false.)
       
        CALL CCPL_advance_time(comp_id,
     &  annotation="MITgcm advance time ")
        CALL CCPL_do_restart_write_IO(comp_id,.false.,
     &  annotation = "MITgcm do restart write")
C        deallocate(xcc,ycc)

        END SUBROUTINE
