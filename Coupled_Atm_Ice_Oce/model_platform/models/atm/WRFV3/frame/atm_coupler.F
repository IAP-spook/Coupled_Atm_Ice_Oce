    module atm_coupler
        USE ccpl_interface_mod
        INTEGER my_comm,my_comp_id,proc_id,export_interface_id,import_interface_id,dm_is,dm_ie,dm_js,dm_je
		REAL,DIMENSION(:,:),ALLOCATABLE :: test_array,ccpl_t2,ccpl_q2,ccpl_u10,ccpl_v10
        
        contains 
        
     SUBROUTINE register_component(comm)
        IMPLICIT NONE
        integer, intent(inout) :: comm
        comm = CCPL_NULL_COMM
        my_comp_id = CCPL_register_component(-1, "wrf","atm", comm, change_dir=.true., annotation = "register atm model wrf")
        my_comm = comm
        print *,"Register component complete, comm is ",comm
     END SUBROUTINE

     
    SUBROUTINE register_grids_decomps(time_step,grid)
        USE module_domain
        IMPLICIT NONE
INCLUDE "mpif.h"
        ! Input data 
        TYPE(domain) , POINTER             :: grid
        INTEGER, INTENT(IN)                :: time_step
        ! Local data
        INTEGER                            :: timer1_id,grid_H2D_id,decomp_id,num_local_cells,field_id_t2,field_id_q2,field_id_u10,field_id_v10,field_id_test_array
        INTEGER                            :: myrank,nprocs,MyError
        LOGICAL                            :: interface_status
        INTEGER, ALLOCATABLE               :: local_cells_global_index(:)
        REAL                               :: min_lat,max_lat,min_lon,max_lon
        INTEGER                            :: i,j,k,Isize,Jsize,ii,jj
        REAL, ALLOCATABLE                  :: ylong(:),ylat(:)
        INTEGER                            :: fields_id(10)
        INTEGER,ALLOCATABLE                :: mask(:)
        INTEGER                            :: num_array(16)
        INTEGER                            :: num_sum,mpi_rank,ierr
        INTEGER                            :: num_comps, individual_or_family(100)
        CHARACTER*1024                     :: comps_full_names(12)
        INTEGER,ALLOCATABLE                :: start(:), length(:)
        INTEGER                            :: gsmsize,jc,par_grid_ratio,full_Jsize,full_Isize,parent_id

        proc_id = CCPL_get_current_process_id_in_component(my_comp_id)
        CALL mpi_comm_rank (my_comm, myrank, MyError)
        CALL mpi_comm_size (my_comm, nprocs, MyError)
        print *,"the proc_id is ",proc_id
        print *,"the time_step is ", time_step  
!Find the real part of grid data                
        dm_is = grid%sp31
        dm_ie = grid%ep31
        dm_js = grid%sp33
        dm_je = grid%ep33

        IF (grid%ed31.eq.dm_ie) THEN
            dm_ie=dm_ie-1
        END IF
        IF (grid%ed33.eq.dm_je) THEN
            dm_je=dm_je-1
        END IF
        Isize=dm_ie-dm_is+1
        Jsize=dm_je-dm_js+1
!--------------------------
!copy from COWA...
        allocate(start(Jsize),length(Jsize))
        jc=0
        DO j=dm_js,dm_je
           jc=jc+1
           start(jc)=(j-1)*(grid%ed31-1)+dm_is
           length(jc)=Isize
        END DO
        gsmsize=Isize*Jsize

!------------------------------

        num_local_cells = Isize*Jsize
        allocate(local_cells_global_index(0:num_local_cells-1))
        allocate(test_array(Isize,Jsize),ccpl_t2(Isize,Jsize),ccpl_q2(Isize,Jsize),ccpl_u10(Isize,Jsize),ccpl_v10(Isize,Jsize))
!The array for testing data send and recv
        allocate(ylong(Isize*Jsize),ylat(Isize*Jsize),mask(Isize*Jsize))
!These code get some needed array data
        num_sum = 0
        CALL MPI_ALLGATHER(num_local_cells,1,MPI_INTEGER,num_array,1,MPI_INTEGER,my_comm,ierr)
        k=0
        j=1
        do i=0,num_local_cells-1
            local_cells_global_index(i)= start(j)+k
            k=k+1
            if(k.eq.length(j)) then
                k=0
                j=j+1
            endif
        enddo
!Choose the exact part of xlong and xlat,change these to ylong and ylat
        k=1
        do j=dm_js,dm_je
            do i=dm_is,dm_ie
                ylong(k) = grid%xlong(i,j)
                if(ylong(k)<0.0) then
                    ylong(k)=360.0+ylong(k)
                endif
                ylat(k) = grid%xlat(i,j)
                mask(k) = 1
                k = k + 1
            enddo
        enddo
        ccpl_t2 = grid%T2(dm_is:dm_ie,dm_js:dm_je)
        ccpl_q2 = grid%Q2(dm_is:dm_ie,dm_js:dm_je)
        ccpl_u10 = grid%U10(dm_is:dm_ie,dm_js:dm_je)
        ccpl_v10 = grid%V10(dm_is:dm_ie,dm_js:dm_je)
!Try to find the exact min and max value of long and lat
        min_lon = minval(ylong)
        max_lon = maxval(ylong)
        min_lat = minval(ylat)
        max_lat = maxval(ylat)
        CALL MPI_AllREDUCE(MPI_IN_PLACE,min_lat,1,MPI_REAL,MPI_MIN,my_comm)
        CALL MPI_AllREDUCE(MPI_IN_PLACE,min_lon,1,MPI_REAL,MPI_MIN,my_comm)
        CALL MPI_AllREDUCE(MPI_IN_PLACE,max_lat,1,MPI_REAL,MPI_MAX,my_comm)
        CALL MPI_AllREDUCE(MPI_IN_PLACE,max_lon,1,MPI_REAL,MPI_MAX,my_comm)
 !------give it a constant min and max,the lon is cyclic
        min_lat=0.0
        max_lat=90.0
!Register every thing
        print *,"yuhao_log begin call CCPL_register_H2D_grid_via_local_data"
        grid_H2D_id = CCPL_register_H2D_grid_via_local_data(my_comp_id,"wrf_H2D_grid", "LON_LAT", "degrees","cyclic",sum(num_array),num_local_cells,local_cells_global_index,min_lon,max_lon, min_lat, max_lat, ylong, ylat,mask,annotation="register H2D grid for wrf")
        print *,"yuhao_log begin call CCPL_register_normal_parallel_decomp"
        decomp_id = CCPL_register_normal_parallel_decomp("wrf_decomp",grid_H2D_id,num_local_cells,local_cells_global_index,annotation = "register parallel decomp for wrf")
        call CCPL_set_normal_time_step(my_comp_id, time_step,annotation="setting the time step for wrf")
        timer1_id = CCPL_define_single_timer(my_comp_id, "seconds", time_step, 0, 0, annotation="define a single timer for wrf")
        field_id_test_array = CCPL_register_field_instance(test_array,"test_array",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST, field_unit="K",annotation="register field test_array for MITgcm")

        fields_id(1)=field_id_test_array
        import_interface_id = CCPL_register_import_interface("recv_data_from_MIT", 1, fields_id, timer1_id, 0,annotation="register interface for receiving data from MIT")

        field_id_t2=CCPL_register_field_instance(ccpl_t2,"t2",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,field_unit="K",annotation="register field t2 for WRF")
        field_id_q2=CCPL_register_field_instance(ccpl_q2,"q2",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,field_unit="kg kg-1",annotation="register field q2 for WRF")
        field_id_u10=CCPL_register_field_instance(ccpl_u10,"u10",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,field_unit="m s-1",annotation="register field u10 for WRF")
        field_id_v10=CCPL_register_field_instance(ccpl_v10,"v10",decomp_id,grid_H2D_id,0,CCPL_TAG_CPL_REST,field_unit="m s-1",annotation="register field v10 for WRF")
        fields_id(1)=field_id_t2
        fields_id(2)=field_id_q2
        fields_id(3)=field_id_u10
        fields_id(4)=field_id_v10
        export_interface_id = CCPL_register_export_interface("send_data_to_MIT", 4, fields_id, timer1_id, annotation="register interface for sending data to CPL")
        print *,"yuhao_log begin call CCPL_do_individual_coupling_generation"
        call CCPL_do_individual_coupling_generation(my_comp_id,"component WRF begin individual coupling generation.")
        print *,"yuhao_log end call CCPL_do_individual_coupling_generation"
        call CCPL_get_configurable_comps_full_names(my_comp_id,"external_comps_for_coupling_generation", num_comps,comps_full_names, annotation="test CCPL_get_configurable_comps_full_names")
        call CCPL_do_external_coupling_generation(num_comps,comps_full_names, annotation="external coupling generation for fixed interface")
        print *,"yuhao_log begin call CCPL_end_coupling_configuration"
        call CCPL_end_coupling_configuration(my_comp_id, annotation = "component WRF end registration")
        print *,"Finish CCPL configuration"
        interface_status = CCPL_execute_interface_using_name(my_comp_id,"recv_data_from_MIT",.true.)
        interface_status = CCPL_execute_interface_using_name(my_comp_id,"send_data_to_MIT",.true.)

        interface_status = CCPL_execute_interface_using_name(my_comp_id,"recv_data_from_MIT",.false.)
        interface_status = CCPL_execute_interface_using_name(my_comp_id,"send_data_to_MIT",.false.)
        CALL CCPL_advance_time(my_comp_id,annotation="WRF advance time ")
        call CCPL_do_restart_write_IO(my_comp_id, .false.,annotation="WRF do restart write")

    END SUBROUTINE

    end module
