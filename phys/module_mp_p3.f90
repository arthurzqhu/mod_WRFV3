

























 MODULE MODULE_MP_P3   


 implicit none

 public  :: mp_p3_wrapper_wrf,mp_p3_wrapper_gem,p3_main,polysvp1

 private :: gamma,derf,find_lookupTable_indices_1a,find_lookupTable_indices_1b,          &
            find_lookupTable_indices_2,find_lookupTable_indices_3,get_cloud_dsd,         &
            get_rain_dsd,calc_bulkRhoRime,impose_max_total_Ni,check_values,qv_sat


 integer, private, parameter :: isize        = 50
 integer, private, parameter :: iisize       = 25
 integer, private, parameter :: zsize        = 20  
 integer, private, parameter :: densize      =  5
 integer, private, parameter :: rimsize      =  4
 integer, private, parameter :: rcollsize    = 30
 integer, private, parameter :: tabsize      = 12  
 integer, private, parameter :: colltabsize  =  2  
 integer, private, parameter :: collitabsize =  2  

 real, private, parameter    :: real_rcollsize = real(rcollsize)

 real, private, dimension(densize,rimsize,isize,tabsize) :: itab   


 double precision, private, dimension(densize,rimsize,isize,rcollsize,colltabsize)    :: itabcoll

 double precision, private, dimension(iisize,rimsize,densize,iisize,rimsize,densize) :: itabcolli1
 double precision, private, dimension(iisize,rimsize,densize,iisize,rimsize,densize) :: itabcolli2


 integer, private :: iparam



 real, private, dimension(16) :: dnu


 real, private, dimension(150) :: mu_r_table


 real, private, dimension(300,10) :: vn_table,vm_table,revap_table

 
 real, private  :: rhosur,rhosui,ar,br,f1r,f2r,ecr,rhow,kr,kc,bimm,aimm,rin,mi0,nccnst,  &
                   eci,eri,bcn,cpw,e0,cons1,cons2,cons3,cons4,cons5,cons6,cons7,         &
                   inv_rhow,qsmall,nsmall,bsmall,zsmall,cp,g,rd,rv,ep_2,inv_cp,mw,osm,   &
                   vi,epsm,rhoa,map,ma,rr,bact,inv_rm1,inv_rm2,sig1,nanew1,f11,f21,sig2, &
                   nanew2,f12,f22,pi,thrd,sxth,piov3,piov6,diff_nucthrs,rho_rimeMin,     &
                   rho_rimeMax,inv_rho_rimeMax,max_total_Ni,dbrk,nmltratio,clbfact_sub,  &
                   clbfact_dep

 contains








 SUBROUTINE p3_init(lookup_file_1,lookup_file_2,nCat)







 implicit none


 character*(*), intent(in) :: lookup_file_1    
 character*(*), intent(in) :: lookup_file_2    
 integer, intent(in)       :: nCat             


 integer :: i,j,k,ii,jj,kk,jjj,jjj2,jjjj,jjjj2
 real    :: lamr,mu_r,lamold,dum,initlamr
 real    :: dm,dum1,dum2,dum3,dum4,dum5,dum6
 real    :: dd,amg,vt,dia,vn,vm







































 


 pi    = 3.14159265
 thrd  = 1./3.
 sxth  = 1./6.
 piov3 = pi*thrd
 piov6 = pi*sxth


 max_total_Ni = 500.e+3  





 iparam = 3


 nccnst = 400.e+6


 kc     = 9.44e+9
 kr     = 5.78e+3


 cp     = 1005.
 inv_cp = 1./cp
 g      = 9.816
 rd     = 287.15
 rv     = 461.51
 ep_2   = 0.622
 rhosur = 100000./(rd*273.15)
 rhosui = 60000./(rd*253.15)
 ar     = 841.99667
 br     = 0.8
 f1r    = 0.78
 f2r    = 0.32
 ecr    = 1.
 rhow   = 997.
 cpw    = 4218.
 inv_rhow = 1.e-3  


 rho_rimeMin     =  50.
 rho_rimeMax     = 900.
 inv_rho_rimeMax = 1./rho_rimeMax


 qsmall = 1.e-14
 nsmall = 1.e-16
 bsmall = qsmall*inv_rho_rimeMax






 bimm   = 2.
 aimm   = 0.65
 rin    = 0.1e-6
 mi0    = 4.*piov3*900.*1.e-18

 eci    = 0.5
 eri    = 1.
 bcn    = 2.


 dbrk   = 600.e-6

 nmltratio = 0.2


 e0    = polysvp1(273.15,0)

 cons1 = piov6*rhow
 cons2 = 4.*piov3*rhow
 cons3 = 1./(cons2*(25.e-6)**3)
 cons4 = 1./(dbrk**3*pi*rhow)
 cons5 = piov6*bimm
 cons6 = piov6**2*rhow*bimm
 cons7 = 4.*piov3*rhow*(1.e-6)**3


 mw     = 0.018
 osm    = 1.
 vi     = 3.
 epsm   = 0.9
 rhoa   = 1777.
 map    = 0.132
 ma     = 0.0284
 rr     = 8.3187
 bact   = vi*osm*epsm*mw*rhoa/(map*rhow)



 inv_rm1 = 2.e+7           
 sig1    = 2.0             
 nanew1  = 300.e6          
 f11     = 0.5*exp(2.5*(log(sig1))**2)
 f21     = 1. + 0.25*log(sig1)




 inv_rm2 = 7.6923076e+5    
 sig2    = 2.5             
 nanew2  = 0.              
 f12     = 0.5*exp(2.5*(log(sig2))**2)
 f22     = 1. + 0.25*log(sig2)



 dnu(1)  =  0.
 dnu(2)  = -0.557
 dnu(3)  = -0.430
 dnu(4)  = -0.307
 dnu(5)  = -0.186
 dnu(6)  = -0.067
 dnu(7)  =  0.050
 dnu(8)  =  0.167
 dnu(9)  =  0.282
 dnu(10) =  0.397
 dnu(11) =  0.512
 dnu(12) =  0.626
 dnu(13) =  0.739
 dnu(14) =  0.853
 dnu(15) =  0.966
 dnu(16) =  0.966





 clbfact_dep = 1.
 clbfact_sub = 1.




 print*
 print*, ' P3 microphysics, version: 2.4.7'
 print*, '   P3_INIT (READING/CREATING LOOK-UP TABLES) ...'


 open(unit=10,file=lookup_file_1, status='old')

 do jj = 1,densize
    do ii = 1,rimsize
       do i = 1,isize
          read(10,*) dum,dum,dum,dum,itab(jj,ii,i,1),itab(jj,ii,i,2),           &
               itab(jj,ii,i,3),itab(jj,ii,i,4),itab(jj,ii,i,5),                 &
               itab(jj,ii,i,6),itab(jj,ii,i,7),itab(jj,ii,i,8),dum,             &
               itab(jj,ii,i,9),itab(jj,ii,i,10),itab(jj,ii,i,11),               &
               itab(jj,ii,i,12)
        enddo

       do i = 1,isize
          do j = 1,rcollsize
             read(10,*) dum,dum,dum,dum,dum,itabcoll(jj,ii,i,j,1),              &
              itabcoll(jj,ii,i,j,2),dum
              itabcoll(jj,ii,i,j,1) = dlog10(itabcoll(jj,ii,i,j,1))
              itabcoll(jj,ii,i,j,2) = dlog10(itabcoll(jj,ii,i,j,2))
          enddo
       enddo
    enddo
 enddo


 close(10)







 if (nCat>1) then



    open(unit=10,file=lookup_file_2,status='old')

    do i = 1,iisize
       do jjj = 1,rimsize
          do jjjj = 1,densize
             do ii = 1,iisize
                do jjj2 = 1,rimsize
                   do jjjj2 = 1,densize
                      read(10,*) dum,dum,dum,dum,dum,dum,dum,                      &
                      itabcolli1(i,jjj,jjjj,ii,jjj2,jjjj2),                        &
                      itabcolli2(i,jjj,jjjj,ii,jjj2,jjjj2)
                   enddo
                enddo
             enddo
          enddo
       enddo
    enddo

    close(unit=10)

 else 

    itabcolli1 = 0.
    itabcolli2 = 0.

 endif










 do i = 1,150              
    initlamr = 1./((real(i)*2.)*1.e-6 + 250.e-6)






    mu_r = 0.

    do ii=1,50
       lamr = initlamr*((mu_r+3.)*(mu_r+2.)*(mu_r+1.)/6.)**thrd




       dum  = min(20.,lamr*1.e-3)
       mu_r = max(0.,-0.0201*dum**2+0.902*dum-1.718)


       if (ii.ge.2) then
          if (abs((lamold-lamr)/lamr).lt.0.001) goto 111
       end if

       lamold = lamr

    enddo

111 continue


    mu_r_table(i) = mu_r

 enddo






 mu_r_loop: do ii = 1,10   


    mu_r = real(ii-1)  


    meansize_loop: do jj = 1,300

       if (jj.le.20) then
          dm = (real(jj)*10.-5.)*1.e-6      
       elseif (jj.gt.20) then
          dm = (real(jj-20)*30.+195.)*1.e-6 
       endif

       lamr = (mu_r+1)/dm



       dum1 = 0. 
       dum2 = 0. 
       dum3 = 0. 
       dum4 = 0. 
       dum5 = 0. 
       dd   = 2.


       do kk = 1,10000

          dia = (real(kk)*dd-dd*0.5)*1.e-6  
          amg = piov6*997.*dia**3           
          amg = amg*1000.                   

         
          if (dia*1.e+6.le.134.43)      then
            vt = 4.5795e+3*amg**(2.*thrd)
          elseif (dia*1.e+6.lt.1511.64) then
            vt = 4.962e+1*amg**thrd
          elseif (dia*1.e+6.lt.3477.84) then
            vt = 1.732e+1*amg**sxth
          else
            vt = 9.17
          endif

         
         
          dum1 = dum1 + vt*10.**(mu_r*alog10(dia)+4.*mu_r)*exp(-lamr*dia)*dd*1.e-6
          dum2 = dum2 + 10.**(mu_r*alog10(dia)+4.*mu_r)*exp(-lamr*dia)*dd*1.e-6
          dum3 = dum3 + vt*10.**((mu_r+3.)*alog10(dia)+4.*mu_r)*exp(-lamr*dia)*dd*1.e-6
          dum4 = dum4 + 10.**((mu_r+3.)*alog10(dia)+4.*mu_r)*exp(-lamr*dia)*dd*1.e-6
          dum5 = dum5 + (vt*dia)**0.5*10.**((mu_r+1.)*alog10(dia)+3.*mu_r)*exp(-lamr*dia)*dd*1.e-6

       enddo 

       dum2 = max(dum2, 1.e-30)  
       dum4 = max(dum4, 1.e-30)  
       dum5 = max(dum5, 1.e-30)  

       vn_table(jj,ii)    = dum1/dum2
       vm_table(jj,ii)    = dum3/dum4
       revap_table(jj,ii) = 10.**(alog10(dum5)+(mu_r+1.)*alog10(lamr)-(3.*mu_r))

    enddo meansize_loop

 enddo mu_r_loop



 print*, '   P3_INIT DONE.'
 print*

END SUBROUTINE P3_INIT













 SUBROUTINE mp_p3_wrapper_wrf(th_3d,qv_3d,qc_3d,qr_3d,qnr_3d,                            &
                              th_old_3d,qv_old_3d,                                       &
                              pii,p,dz,w,dt,itimestep,                                   &
                              rainnc,rainncv,sr,snownc,snowncv,n_iceCat,                 &
                              ids, ide, jds, jde, kds, kde ,                             &
                              ims, ime, jms, jme, kms, kme ,                             &
                              its, ite, jts, jte, kts, kte ,                             &
                              diag_zdbz_3d,diag_effc_3d,diag_effi_3d,                    &
                              diag_vmi_3d,diag_di_3d,diag_rhopo_3d,                      &
                              qi1_3d,qni1_3d,qir1_3d,qib1_3d,                            &
                              qi2_3d,qni2_3d,qir2_3d,qib2_3d,nc_3d)

  
  
  

  
  
  
  
  
  

  

  
  
  
  
  
  
  


  

  
  
  
  
  
  
  
  
  

  

  
  
  
  
  
  
  
  
  
  
  
  

  implicit none

  

   integer, intent(in)            ::  ids, ide, jds, jde, kds, kde ,                      &
                                      ims, ime, jms, jme, kms, kme ,                      &
                                      its, ite, jts, jte, kts, kte
   real, dimension(ims:ime, kms:kme, jms:jme), intent(inout):: th_3d,qv_3d,qc_3d,qr_3d,   &
                   qnr_3d,diag_zdbz_3d,diag_effc_3d,diag_effi_3d,diag_vmi_3d,diag_di_3d,  &
                   diag_rhopo_3d,th_old_3d,qv_old_3d
   real, dimension(ims:ime, kms:kme, jms:jme), intent(inout):: qi1_3d,qni1_3d,qir1_3d,    &
                                                               qib1_3d
   real, dimension(ims:ime, kms:kme, jms:jme), intent(inout), optional :: qi2_3d,qni2_3d, &
                                                                          qir2_3d,qib2_3d
   real, dimension(ims:ime, kms:kme, jms:jme), intent(inout), optional :: nc_3d

   real, dimension(ims:ime, kms:kme, jms:jme), intent(in) :: pii,p,dz,w
   real, dimension(ims:ime, jms:jme), intent(inout) :: RAINNC,RAINNCV,SR,SNOWNC,SNOWNCV
   real, intent(in)    :: dt
   integer, intent(in) :: itimestep
   integer, intent(in) :: n_iceCat
   logical :: log_predictNc

   

   real, dimension(ims:ime, kms:kme) ::nc,ssat

   
   real, dimension(ims:ime, kms:kme, 1) :: qitot,qirim,nitot,birim,diag_di,diag_vmi,       &
                                          diag_rhopo,diag_effi

   real, dimension(its:ite) :: pcprt_liq,pcprt_sol
   real                     :: dum1,dum2
   integer                  :: i,k,j
   integer, parameter       :: n_diag_ss = 3        
   logical, parameter       :: nk_bottom = .false.  

   real, dimension(ims:ime, kms:kme, n_diag_ss) :: diag_ss











   

   log_predictNc=.false.
   if (present(nc_3d)) log_predictNc = .true.

   do j = jts,jte      

      if (log_predictNc) then
         nc(its:ite,kts:kte)=nc_3d(its:ite,kts:kte,j)
     
      else
         nc=0.
      endif

     
      ssat=0.

    





  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

      call P3_MAIN(qc_3d(its:ite,kts:kte,j),nc(its:ite,kts:kte),                                       &
              qr_3d(its:ite,kts:kte,j),qnr_3d(its:ite,kts:kte,j),                                      &
              th_old_3d(its:ite,kts:kte,j),th_3d(its:ite,kts:kte,j),qv_old_3d(its:ite,kts:kte,j),      &
              qv_3d(its:ite,kts:kte,j),dt,qi1_3d(its:ite,kts:kte,j),                                   &
              qir1_3d(its:ite,kts:kte,j),qni1_3d(its:ite,kts:kte,j),                                   &
              qib1_3d(its:ite,kts:kte,j),ssat(its:ite,kts:kte),                                        &
              W(its:ite,kts:kte,j),P(its:ite,kts:kte,j),                                               &
              DZ(its:ite,kts:kte,j),itimestep,pcprt_liq,pcprt_sol,its,ite,kts,kte,nk_bottom,n_iceCat,  &
              diag_zdbz_3d(its:ite,kts:kte,j),diag_effc_3d(its:ite,kts:kte,j),                         &
              diag_effi_3d(its:ite,kts:kte,j),n_diag_ss,diag_ss(its:ite,kts:kte,1:n_diag_ss),          &
              log_predictNc)

     
      dum1 = 1000.*dt
      RAINNC(its:ite,j)  = RAINNC(its:ite,j) + pcprt_liq(:)*dum1  
      RAINNCV(its:ite,j) = pcprt_liq(:)*dum1                      
      SNOWNC(its:ite,j)  = SNOWNC(its:ite,j) + pcprt_sol(:)*dum1  
      SNOWNCV(its:ite,j) = pcprt_sol(:)*dum1                      
      SR(its:ite,j)      = pcprt_sol(:)/(pcprt_liq(:)+1.E-12)     

    
      if (log_predictNc) then
         nc_3d(its:ite,kts:kte,j)=nc(its:ite,kts:kte)
      endif

    
    
    

    





    

         diag_vmi_3d(its:ite,kts:kte,j)   = diag_ss(its:ite,kts:kte,1)
         diag_di_3d(its:ite,kts:kte,j)    = diag_ss(its:ite,kts:kte,2)
         diag_rhopo_3d(its:ite,kts:kte,j) = diag_ss(its:ite,kts:kte,3)


    












 

 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 

   enddo 

 

   END SUBROUTINE mp_p3_wrapper_wrf






  SUBROUTINE mp_p3_wrapper_gem
  END SUBROUTINE mp_p3_wrapper_gem















































































































































































































 SUBROUTINE P3_MAIN(qc,nc,qr,nr,th_old,th,qv_old,qv,dt,qitot,qirim,nitot,birim,ssat,uzpl,   &
                    pres,dzq,it,pcprt_liq,pcprt_sol,its,ite,kts,kte,nk_bottom,nCat,diag_ze, &
                    diag_effc,diag_effi,n_diag_ss,diag_ss,log_predictNc)















 implicit none



 real, intent(inout), dimension(its:ite,kts:kte)      :: qc         

 real, intent(inout), dimension(its:ite,kts:kte)      :: nc         
 real, intent(inout), dimension(its:ite,kts:kte)      :: qr         
 real, intent(inout), dimension(its:ite,kts:kte)      :: nr         
 real, intent(inout), dimension(its:ite,kts:kte,nCat) :: qitot      
 real, intent(inout), dimension(its:ite,kts:kte,nCat) :: qirim      
 real, intent(inout), dimension(its:ite,kts:kte,nCat) :: nitot      
 real, intent(inout), dimension(its:ite,kts:kte,nCat) :: birim      
 real, intent(inout), dimension(its:ite,kts:kte)      :: ssat       

 real, intent(inout), dimension(its:ite,kts:kte)      :: qv         
 real, intent(inout), dimension(its:ite,kts:kte)      :: th         

 real, intent(inout), dimension(its:ite,kts:kte)      :: th_old     
 real, intent(inout), dimension(its:ite,kts:kte)      :: qv_old     




 real, intent(in),    dimension(its:ite,kts:kte)      :: uzpl       
 real, intent(in),    dimension(its:ite,kts:kte)      :: pres       
 real, intent(in),    dimension(its:ite,kts:kte)      :: dzq        
 real, intent(in)                                     :: dt         

 real, intent(out),   dimension(its:ite)              :: pcprt_liq  
 real, intent(out),   dimension(its:ite)              :: pcprt_sol  
 real, intent(out),   dimension(its:ite,kts:kte)      :: diag_ze    
 real, intent(out),   dimension(its:ite,kts:kte)      :: diag_effc  
 real, intent(out),   dimension(its:ite,kts:kte,nCat) :: diag_effi  
 real, intent(out),   dimension(its:ite,kts:kte,n_diag_ss)  :: diag_ss 

 integer, intent(in)                                  :: its,ite    
 integer, intent(in)                                  :: kts,kte    
 integer, intent(in)                                  :: it         
 integer, intent(in)                                  :: nCat       
 integer, intent(in)                                  :: n_diag_ss  

 logical, intent(in)                                  :: nk_bottom     
 logical, intent(in)                                  :: log_predictNc 



 real, dimension(its:ite,kts:kte) :: mu_r  
 real, dimension(its:ite,kts:kte) :: t     
 real, dimension(its:ite,kts:kte) :: t_old 



 real, dimension(its:ite,kts:kte) :: lamc
 real, dimension(its:ite,kts:kte) :: lamr
 real, dimension(its:ite,kts:kte) :: n0c
 real, dimension(its:ite,kts:kte) :: logn0r
 real, dimension(its:ite,kts:kte) :: mu_c

 real, dimension(its:ite,kts:kte) :: nu
 real, dimension(its:ite,kts:kte) :: cdist
 real, dimension(its:ite,kts:kte) :: cdist1
 real, dimension(its:ite,kts:kte) :: cdistr
 real, dimension(its:ite,kts:kte) :: Vt_nc
 real, dimension(its:ite,kts:kte) :: Vt_qc
 real, dimension(its:ite,kts:kte) :: Vt_nr
 real, dimension(its:ite,kts:kte) :: Vt_qr
 real, dimension(its:ite,kts:kte) :: Vt_qit
 real, dimension(its:ite,kts:kte) :: Vt_nit






 real :: qrcon   
 real :: qcacc   
 real :: qcaut   
 real :: ncacc   
 real :: ncautc  
 real :: ncslf   
 real :: nrslf   
 real :: ncnuc   
 real :: qccon   
 real :: qcnuc   
 real :: qrevp   
 real :: qcevp   
 real :: nrevp   
 real :: ncautr  





 real, dimension(nCat) :: qccol     
 real, dimension(nCat) :: qwgrth    
 real, dimension(nCat) :: qidep     
 real, dimension(nCat) :: qrcol     
 real, dimension(nCat) :: qinuc     
 real, dimension(nCat) :: nccol     
 real, dimension(nCat) :: nrcol     
 real, dimension(nCat) :: ninuc     
 real, dimension(nCat) :: qisub     
 real, dimension(nCat) :: qimlt     
 real, dimension(nCat) :: nimlt     
 real, dimension(nCat) :: nisub     
 real, dimension(nCat) :: nislf     
 real, dimension(nCat) :: qchetc    
 real, dimension(nCat) :: qcheti    
 real, dimension(nCat) :: qrhetc    
 real, dimension(nCat) :: qrheti    
 real, dimension(nCat) :: nchetc    
 real, dimension(nCat) :: ncheti    
 real, dimension(nCat) :: nrhetc    
 real, dimension(nCat) :: nrheti    
 real, dimension(nCat) :: nrshdr    
 real, dimension(nCat) :: qcshd     
 real, dimension(nCat) :: qcmul     
 real, dimension(nCat) :: qrmul     
 real, dimension(nCat) :: nimul     
 real, dimension(nCat) :: ncshdc    
 real, dimension(nCat) :: rhorime_c 
 real, dimension(nCat) :: rhorime_r 

 real, dimension(nCat,nCat) :: nicol 
 real, dimension(nCat,nCat) :: qicol 

 real, dimension(its:ite,kts:kte,nCat) :: diag_vmi,diag_di,diag_rhopo 

 logical, dimension(nCat)   :: log_wetgrowth

 real, dimension(nCat) :: Eii_fact,epsi
 real :: eii 

 real, dimension(its:ite,kts:kte,nCat) :: diam_ice

 real, dimension(its:ite,kts:kte)      :: inv_dzq,inv_rho,ze_ice,ze_rain,prec,rho,       &
            rhofacr,rhofaci,acn,xxls,xxlv,xlf,qvs,qvi,sup,supi,ss,vtrmi1,vtrnitot,       &
            tmparr1

 real, dimension(kts:kte) :: dum_qit,dum_qr,dum_nit,dum_qir,dum_bir,dum_zit,dum_nr,      &
            dum_qc,dum_nc,V_qr,V_qit,V_nit,V_nr,V_qc,V_nc,V_zit,flux_qr,flux_qit,        &
            flux_nit,flux_nr,flux_qir,flux_bir,flux_zit,flux_qc,flux_nc,tend_qc,tend_qr, &
            tend_nr,tend_qit,tend_qir,tend_bir,tend_nit,tend_nc 

 real    :: lammax,lammin,mu,dv,sc,dqsdt,ab,kap,epsr,epsc,xx,aaa,epsilon,sigvl,epsi_tot, &
            aact,alpha,gamm,gg,psi,eta1,eta2,sm1,sm2,smax,uu1,uu2,dum,dum0,dum1,dum2,    &
            dumqv,dumqvs,dums,dumqc,ratio,qsat0,udiff,dum3,dum4,dum5,dum6,lamold,rdumii, &
            rdumjj,dqsidt,abi,dumqvi,dap,nacnt,rhop,v_impact,ri,iTc,D_c,D_r,dumlr,tmp1,  &
            tmp2,tmp3,inv_nstep,inv_dum,inv_dum3,odt,oxx,oabi,zero,test,test2,test3,     &
            onstep,fluxdiv_qr,fluxdiv_qit,fluxdiv_nit,fluxdiv_qir,fluxdiv_bir,           &
            fluxdiv_zit,fluxdiv_qc,fluxdiv_nc,fluxdiv_nr,rgvm,D_new,Q_nuc,N_nuc,         &
            deltaD_init,dum1c,dum4c,dum5c,dumt,qcon_satadj,qdep_satadj,sources,sinks,    &
            drhop,timeScaleFactor

 integer :: dumi,i,k,kk,ii,jj,iice,iice_dest,j,dumk,dumj,dumii,dumjj,dumzz,n,nstep,      &
            tmpint1,tmpint2,ktop,kbot,kdir,qcindex,qrindex,qiindex,dumic,dumiic,dumjjc,  &
            catcoll
 logical :: log_nucleationPossible,log_hydrometeorsPresent,log_predictSsat,log_tmp1,     &
            log_exitlevel,log_hmossopOn,log_qcpresent,log_qrpresent,log_qipresent,       &
            log_ni_add



 real    :: f1pr01   
 real    :: f1pr02   
 real    :: f1pr03   
 real    :: f1pr04   
 real    :: f1pr05   
 real    :: f1pr06   
 real    :: f1pr07   
 real    :: f1pr08   
 real    :: f1pr09   
 real    :: f1pr10   
 real    :: f1pr11   
 real    :: f1pr12   
 real    :: f1pr13   
 real    :: f1pr14   
 real    :: f1pr15   
 real    :: f1pr16   
 real    :: f1pr17   
 real    :: f1pr18   

 
 logical, parameter :: debug_ON     = .false.  
 logical, parameter :: debug_ABORT  = .false.  
 




















 
 if (nk_bottom) then
   
    ktop = kts        
    kbot = kte        
    kdir = -1         
 else
   
    ktop = kte        
    kbot = kts        
    kdir = 1          
 endif





 select case (nCat)
    case (1)
       deltaD_init = 999.    
    case (2)
       deltaD_init = 500.e-6
    case (3)
       deltaD_init = 400.e-6
    case (4)
       deltaD_init = 235.e-6
    case (5)
       deltaD_init = 175.e-6
    case (6:)
       deltaD_init = 150.e-6
 end select






 log_predictSsat = .false.

 log_hmossopOn   = (nCat.gt.1)      



 inv_dzq    = 1./dzq  
 odt        = 1./dt   



 timeScaleFactor = min(1./120., odt)

 pcprt_liq  = 0.
 pcprt_sol  = 0.
 prec       = 0.
 mu_r       = 0.
 diag_ze    = -99.
 diam_ice   = 0.
 ze_ice     = 1.e-22
 ze_rain    = 1.e-22
 diag_effc  = 10.e-6 

 diag_effi  = 25.e-6 
 diag_vmi   = 0.
 diag_di    = 0.
 diag_rhopo = 0.
 diag_ss    = 0.
 rhorime_c  = 400.


 tmparr1 = (pres*1.e-5)**(rd*inv_cp)
 t       = th    *tmparr1    
 t_old   = th_old*tmparr1    
 qv      = max(qv,0.)        


 i_loop_main: do i = its,ite  

    if (debug_ON) call check_values(qv,T,qc,qr,nr,qitot,qirim,nitot,birim,i,it,.false.,debug_ABORT,100)

    log_hydrometeorsPresent = .false.
    log_nucleationPossible  = .false.

    k_loop_1: do k = kbot,ktop,kdir








     
       rho(i,k)     = pres(i,k)/(rd*t(i,k))
       inv_rho(i,k) = 1./rho(i,k)
       xxlv(i,k)    = 3.1484e6-2370.*t(i,k)
       xxls(i,k)    = xxlv(i,k)+0.3337e6
       xlf(i,k)     = xxls(i,k)-xxlv(i,k)
       qvs(i,k)     = qv_sat(t_old(i,k),pres(i,k),0)
       qvi(i,k)     = qv_sat(t_old(i,k),pres(i,k),1)

      
       if (.not.(log_predictSsat).or.it.eq.1) then
          ssat(i,k)    = qv_old(i,k)-qvs(i,k)
          sup(i,k)     = qv_old(i,k)/qvs(i,k)-1.
          supi(i,k)    = qv_old(i,k)/qvi(i,k)-1.
      
       else if ((log_predictSsat).and.it.gt.1) then
          sup(i,k)     = ssat(i,k)/qvs(i,k)
          supi(i,k)    = (ssat(i,k)+qvs(i,k)-qvi(i,k))/qvi(i,k)
       endif

       rhofacr(i,k) = (rhosur*inv_rho(i,k))**0.54
       rhofaci(i,k) = (rhosui*inv_rho(i,k))**0.54
       dum          = 1.496e-6*t(i,k)**1.5/(t(i,k)+120.)  
       acn(i,k)     = g*rhow/(18.*dum)  

      
       if (.not.(log_predictNc)) then
          nc(i,k) = nccnst*inv_rho(i,k)
       endif

       if ((t(i,k).lt.273.15 .and. supi(i,k).ge.-0.05) .or.                              &
           (t(i,k).ge.273.15 .and. sup(i,k).ge.-0.05 )) log_nucleationPossible = .true.

    
    

       if (qc(i,k).lt.qsmall .or. (qc(i,k).lt.1.e-8 .and. sup(i,k).lt.-0.1)) then
          qv(i,k) = qv(i,k) + qc(i,k)
          th(i,k) = th(i,k) - th(i,k)/t(i,k)*qc(i,k)*xxlv(i,k)*inv_cp
          qc(i,k) = 0.
          nc(i,k) = 0.
       else
          log_hydrometeorsPresent = .true.    
       endif

       if (qr(i,k).lt.qsmall .or. (qr(i,k).lt.1.e-8 .and. sup(i,k).lt.-0.1)) then
          qv(i,k) = qv(i,k) + qr(i,k)
          th(i,k) = th(i,k) - th(i,k)/t(i,k)*qr(i,k)*xxlv(i,k)*inv_cp
          qr(i,k) = 0.
          nr(i,k) = 0.
       else
          log_hydrometeorsPresent = .true.    
       endif

       do iice = 1,nCat
          if (qitot(i,k,iice).lt.qsmall .or. (qitot(i,k,iice).lt.1.e-8 .and.             &
           supi(i,k).lt.-0.1)) then
             qv(i,k) = qv(i,k) + qitot(i,k,iice)
             th(i,k) = th(i,k) - th(i,k)/t(i,k)*qitot(i,k,iice)*xxls(i,k)*inv_cp
             qitot(i,k,iice) = 0.
             nitot(i,k,iice) = 0.
             qirim(i,k,iice) = 0.
             birim(i,k,iice) = 0.
          else
             log_hydrometeorsPresent = .true.    
          endif

          if (qitot(i,k,iice).ge.qsmall .and. qitot(i,k,iice).lt.1.e-8 .and.             &
           t(i,k).ge.273.15) then
             qr(i,k) = qr(i,k) + qitot(i,k,iice)
             th(i,k) = th(i,k) - th(i,k)/t(i,k)*qitot(i,k,iice)*xlf(i,k)*inv_cp
             qitot(i,k,iice) = 0.
             nitot(i,k,iice) = 0.
             qirim(i,k,iice) = 0.
             birim(i,k,iice) = 0.
          endif

       enddo  

    

    enddo k_loop_1

    if (debug_ON) then
       tmparr1(i,:) = th(i,:)*(pres(i,:)*1.e-5)**(rd*inv_cp)
       call check_values(qv,tmparr1,qc,qr,nr,qitot,qirim,nitot,birim,i,it,.true.,debug_ABORT,200)
    endif

   
    if (.not. (log_nucleationPossible .or. log_hydrometeorsPresent)) goto 333

    log_hydrometeorsPresent = .false.   



    k_loop_main: do k = kbot,ktop,kdir

     
       log_exitlevel = .true.
       if (qc(i,k).ge.qsmall .or. qr(i,k).ge.qsmall) log_exitlevel = .false.
       do iice = 1,nCat
          if (qitot(i,k,iice).ge.qsmall) log_exitlevel = .false.
       enddo
       if (log_exitlevel .and.                                                           &
          ((t(i,k).lt.273.15 .and. supi(i,k).lt.-0.05) .or.                              &
           (t(i,k).ge.273.15 .and. sup(i,k) .lt.-0.05))) goto 555   

    
       qcacc   = 0.;     qrevp   = 0.;     qccon   = 0.
       qcaut   = 0.;     qcevp   = 0.;     qrcon   = 0.
       ncacc   = 0.;     ncnuc   = 0.;     ncslf   = 0.
       ncautc  = 0.;     qcnuc   = 0.;     nrslf   = 0.
       nrevp   = 0.;     ncautr  = 0.

    
       qchetc  = 0.;     qisub   = 0.;     nrshdr  = 0.
       qcheti  = 0.;     qrcol   = 0.;     qcshd   = 0.
       qrhetc  = 0.;     qimlt   = 0.;     qccol   = 0.
       qrheti  = 0.;     qinuc   = 0.;     nimlt   = 0.
       nchetc  = 0.;     nccol   = 0.;     ncshdc  = 0.
       ncheti  = 0.;     nrcol   = 0.;     nislf   = 0.
       nrhetc  = 0.;     ninuc   = 0.;     qidep   = 0.
       nrheti  = 0.;     nisub   = 0.;     qwgrth  = 0.
       qcmul   = 0.;     qrmul   = 0.;     nimul   = 0.
       qicol   = 0.;     nicol   = 0.

       log_wetgrowth = .false.


       predict_supersaturation: if (log_predictSsat) then

      
      
      
      
      

          dqsdt   = xxlv(i,k)*qvs(i,k)/(rv*t(i,k)*t(i,k))
          ab      = 1. + dqsdt*xxlv(i,k)*inv_cp
          epsilon = (qv(i,k)-qvs(i,k)-ssat(i,k))/ab
          epsilon = max(epsilon,-qc(i,k))   

        
        
          if (ssat(i,k).lt.0.) epsilon = min(0.,epsilon)

        
          if (abs(epsilon).ge.1.e-15) then
             qc(i,k)   = qc(i,k)+epsilon
             qv(i,k)   = qv(i,k)-epsilon
             th(i,k)   = th(i,k)+epsilon*th(i,k)/t(i,k)*xxlv(i,k)*inv_cp
            
             t(i,k)    = th(i,k)*(1.e-5*pres(i,k))**(rd*inv_cp)
             qvs(i,k)  = qv_sat(t(i,k),pres(i,k),0)
             qvi(i,k)  = qv_sat(t(i,k),pres(i,k),1)
             sup(i,k)  = qv(i,k)/qvs(i,k)-1.
             supi(i,k) = qv(i,k)/qvi(i,k)-1.
             ssat(i,k) = qv(i,k)-qvs(i,k)
          endif

       endif predict_supersaturation



       log_exitlevel = .true.
       if (qc(i,k).ge.qsmall .or. qr(i,k).ge.qsmall) log_exitlevel = .false.
       do iice = 1,nCat
          if (qitot(i,k,iice).ge.qsmall) log_exitlevel=.false.
       enddo
       if (log_exitlevel) goto 444   

        
       mu     = 1.496e-6*t(i,k)**1.5/(t(i,k)+120.)
       dv     = 8.794e-5*t(i,k)**1.81/pres(i,k)
       sc     = mu/(rho(i,k)*dv)
       dum    = 1./(rv*t(i,k)**2)
       dqsdt  = xxlv(i,k)*qvs(i,k)*dum
       dqsidt = xxls(i,k)*qvi(i,k)*dum
       ab     = 1.+dqsdt*xxlv(i,k)*inv_cp
       abi    = 1.+dqsidt*xxls(i,k)*inv_cp
       kap    = 1.414e+3*mu
      
       if (t(i,k).lt.253.15) then
          eii=0.1
       else if (t(i,k).ge.253.15.and.t(i,k).lt.268.15) then
          eii=0.1+(t(i,k)-253.15)/15.*0.9  
       else if (t(i,k).ge.268.15) then
          eii=1.
       end if

       call get_cloud_dsd(qc(i,k),nc(i,k),mu_c(i,k),rho(i,k),nu(i,k),dnu,lamc(i,k),      &
                          lammin,lammax,k,cdist(i,k),cdist1(i,k),tmpint1,log_tmp1)

       call get_rain_dsd(qr(i,k),nr(i,k),mu_r(i,k),rdumii,dumii,lamr(i,k),mu_r_table,    &
                         cdistr(i,k),logn0r(i,k),log_tmp1,tmpint1,tmpint2)
       

     
       epsi_tot = 0.

       call impose_max_total_Ni(nitot(i,k,:),max_total_Ni,inv_rho(i,k))

       iice_loop1: do iice = 1,nCat

          if (qitot(i,k,iice).ge.qsmall) then

            
             nitot(i,k,iice) = max(nitot(i,k,iice),nsmall)
             nr(i,k)         = max(nr(i,k),nsmall)

            
             dum2 = 500. 
             diam_ice(i,k,iice) = ((qitot(i,k,iice)*6.)/(nitot(i,k,iice)*dum2*pi))**thrd

             call calc_bulkRhoRime(qitot(i,k,iice),qirim(i,k,iice),birim(i,k,iice),rhop)

           
             call find_lookupTable_indices_1a(dumi,dumjj,dumii,dumzz,dum1,dum4,          &
                                   dum5,dum6,isize,rimsize,densize,zsize,                &
                                   qitot(i,k,iice),nitot(i,k,iice),qirim(i,k,iice),      &
                                   999.,rhop)
                                  
             call find_lookupTable_indices_1b(dumj,dum3,rcollsize,qr(i,k),nr(i,k))

          
             call access_lookup_table(dumjj,dumii,dumi, 2,dum1,dum4,dum5,f1pr02)
             call access_lookup_table(dumjj,dumii,dumi, 3,dum1,dum4,dum5,f1pr03)
             call access_lookup_table(dumjj,dumii,dumi, 4,dum1,dum4,dum5,f1pr04)
             call access_lookup_table(dumjj,dumii,dumi, 5,dum1,dum4,dum5,f1pr05)
             call access_lookup_table(dumjj,dumii,dumi, 7,dum1,dum4,dum5,f1pr09)
             call access_lookup_table(dumjj,dumii,dumi, 8,dum1,dum4,dum5,f1pr10)
             call access_lookup_table(dumjj,dumii,dumi,10,dum1,dum4,dum5,f1pr14)

          
             if (qr(i,k).ge.qsmall) then
                call access_lookup_table_coll(dumjj,dumii,dumj,dumi,1,dum1,    &
                                              dum3,dum4,dum5,f1pr07)
                call access_lookup_table_coll(dumjj,dumii,dumj,dumi,2,dum1,    &
                                              dum3,dum4,dum5,f1pr08)
             else
                f1pr07 = 0.
                f1pr08 = 0.
             endif

          
          
             nitot(i,k,iice) = min(nitot(i,k,iice),f1pr09*nitot(i,k,iice))
             nitot(i,k,iice) = max(nitot(i,k,iice),f1pr10*nitot(i,k,iice))


          
          
          
             if (qirim(i,k,iice)>0.) then
                tmp1 = qirim(i,k,iice)/qitot(i,k,iice)   
                if (tmp1.lt.0.6) then
                   Eii_fact(iice)=1.
                else if (tmp1.ge.0.6.and.tmp1.lt.0.9) then
          
                   Eii_fact(iice) = 1.-(tmp1-0.6)/0.3
                else if (tmp1.ge.0.9) then
                   Eii_fact(iice) = 0.
                endif
             else
                Eii_fact(iice) = 1.
             endif

          endif   

















          if (qitot(i,k,iice).ge.qsmall .and. qc(i,k).ge.qsmall .and. t(i,k).le.273.15) then
             qccol(iice) = rhofaci(i,k)*f1pr04*qc(i,k)*eci*rho(i,k)*nitot(i,k,iice)
             nccol(iice) = rhofaci(i,k)*f1pr04*nc(i,k)*eci*rho(i,k)*nitot(i,k,iice)
          endif



          if (qitot(i,k,iice).ge.qsmall .and. qc(i,k).ge.qsmall .and. t(i,k).gt.273.15) then
          
             qcshd(iice) = rhofaci(i,k)*f1pr04*qc(i,k)*eci*rho(i,k)*nitot(i,k,iice)
             nccol(iice) = rhofaci(i,k)*f1pr04*nc(i,k)*eci*rho(i,k)*nitot(i,k,iice)
          
             ncshdc(iice) = qcshd(iice)*1.923e+6
          endif




     
     
     

     
     
     



          if (qitot(i,k,iice).ge.qsmall .and. qr(i,k).ge.qsmall .and. t(i,k).le.273.15) then
           
           
           
             qrcol(iice) = 10.**(f1pr08+logn0r(i,k))*rho(i,k)*rhofaci(i,k)*eri*nitot(i,k,iice)
             nrcol(iice) = 10.**(f1pr07+logn0r(i,k))*rho(i,k)*rhofaci(i,k)*eri*nitot(i,k,iice)
       endif

     
     
     
     
     

          if (qitot(i,k,iice).ge.qsmall .and. qr(i,k).ge.qsmall .and. t(i,k).gt.273.15) then
           
             nrcol(iice)  = 10.**(f1pr07 + logn0r(i,k))*rho(i,k)*rhofaci(i,k)*eri*nitot(i,k,iice)
           
             dum    = 10.**(f1pr08 + logn0r(i,k))*rho(i,k)*rhofaci(i,k)*eri*nitot(i,k,iice)
     
     
     
     
          endif





          iceice_interaction1:  if (iice.ge.2) then


             qitot_notsmall: if (qitot(i,k,iice).ge.qsmall) then
                catcoll_loop: do catcoll = 1,iice-1
                   qitotcatcoll_notsmall: if (qitot(i,k,catcoll).ge.qsmall) then

                  

                    

                      call find_lookupTable_indices_2(dumi,dumii,dumjj,dumic,dumiic,   &
                                 dumjjc,dum1,dum4,dum5,dum1c,dum4c,dum5c,              &
                                 iisize,rimsize,densize,                               &
                                 qitot(i,k,iice),qitot(i,k,catcoll),nitot(i,k,iice),        &
                                 nitot(i,k,catcoll),qirim(i,k,iice),qirim(i,k,catcoll),     &
                                 birim(i,k,iice),birim(i,k,catcoll))

                      call access_lookup_table_colli(dumjjc,dumiic,dumic,dumjj,dumii,dumj,  &
                                 dumi,1,dum1c,dum4c,dum5c,dum1,dum4,dum5,f1pr17)
                      call access_lookup_table_colli(dumjjc,dumiic,dumic,dumjj,dumii,dumj,  &
                                 dumi,2,dum1c,dum4c,dum5c,dum1,dum4,dum5,f1pr18)

                    
                    
                    
                      nicol(catcoll,iice) = f1pr17*rhofaci(i,k)*rhofaci(i,k)*rho(i,k)*     &
                                            nitot(i,k,catcoll)*nitot(i,k,iice)
                      qicol(catcoll,iice) = f1pr18*rhofaci(i,k)*rhofaci(i,k)*rho(i,k)*     &
                                            nitot(i,k,catcoll)*nitot(i,k,iice)

                      nicol(catcoll,iice) = eii*Eii_fact(iice)*nicol(catcoll,iice)
                      qicol(catcoll,iice) = eii*Eii_fact(iice)*qicol(catcoll,iice)
                      nicol(catcoll,iice) = min(nicol(catcoll,iice), nitot(i,k,catcoll)*odt)
                      qicol(catcoll,iice) = min(qicol(catcoll,iice), qitot(i,k,catcoll)*odt)
                  

                    

                    
                      call calc_bulkRhoRime(qitot(i,k,catcoll),qirim(i,k,catcoll),birim(i,k,catcoll),rhop)

                      call find_lookupTable_indices_2(dumi,dumii,dumjj,dumic,dumiic,  &
                                 dumjjc,dum1,dum4,dum5,dum1c,dum4c,dum5c,             &
                                 iisize,rimsize,densize,                              &
                                 qitot(i,k,catcoll),qitot(i,k,iice),nitot(i,k,catcoll),    &
                                 nitot(i,k,iice),qirim(i,k,catcoll),qirim(i,k,iice),       &
                                 birim(i,k,catcoll),birim(i,k,iice))

                      call access_lookup_table_colli(dumjjc,dumiic,dumic,dumjj,dumii,dumj, &
                                 dumi,1,dum1c,dum4c,dum5c,dum1,dum4,dum5,f1pr17)

                      call access_lookup_table_colli(dumjjc,dumiic,dumic,dumjj,dumii,dumj, &
                                 dumi,2,dum1c,dum4c,dum5c,dum1,dum4,dum5,f1pr18)

                      nicol(iice,catcoll) = f1pr17*rhofaci(i,k)*rhofaci(i,k)*rho(i,k)*     &
                                            nitot(i,k,iice)*nitot(i,k,catcoll)
                      qicol(iice,catcoll) = f1pr18*rhofaci(i,k)*rhofaci(i,k)*rho(i,k)*     &
                                            nitot(i,k,iice)*nitot(i,k,catcoll)
                     
                      nicol(iice,catcoll) = eii*Eii_fact(catcoll)*nicol(iice,catcoll)
                      qicol(iice,catcoll) = eii*Eii_fact(catcoll)*qicol(iice,catcoll)
                      nicol(iice,catcoll) = min(nicol(iice,catcoll),nitot(i,k,iice)*odt)
                      qicol(iice,catcoll) = min(qicol(iice,catcoll),qitot(i,k,iice)*odt)

                   endif qitotcatcoll_notsmall
                enddo catcoll_loop
             endif qitot_notsmall

          endif iceice_interaction1





    
    
    


          if (qitot(i,k,iice).ge.qsmall) then
             nislf(iice) = f1pr03*rho(i,k)*eii*Eii_fact(iice)*rhofaci(i,k)*nitot(i,k,iice)
          endif





    


          if (qitot(i,k,iice).ge.qsmall .and. t(i,k).gt.273.15) then
             qsat0 = 0.622*e0/(pres(i,k)-e0)
          
          
          
             dum = 0.
          
          
          
             qimlt(iice) = ((f1pr05+f1pr14*sc**thrd*(rhofaci(i,k)*rho(i,k)/mu)**0.5)*((t(i,k)-   &
                          273.15)*kap-rho(i,k)*xxlv(i,k)*dv*(qsat0-qv(i,k)))*2.*pi/xlf(i,k)+     &
                          dum)*nitot(i,k,iice)
             qimlt(iice) = max(qimlt(iice),0.)

             nimlt(iice) = qimlt(iice)*(nitot(i,k,iice)/qitot(i,k,iice))
          endif




    


          if (qitot(i,k,iice).ge.qsmall .and. qc(i,k)+qr(i,k).ge.1.e-6 .and. t(i,k).lt.273.15) then

             qsat0  = 0.622*e0/(pres(i,k)-e0)
             qwgrth(iice) = ((f1pr05 + f1pr14*sc**thrd*(rhofaci(i,k)*rho(i,k)/mu)**0.5)*       &
                       2.*pi*(rho(i,k)*xxlv(i,k)*dv*(qsat0-qv(i,k))-(t(i,k)-273.15)*           &
                       kap)/(xlf(i,k)+cpw*(t(i,k)-273.15)))*nitot(i,k,iice)
             qwgrth(iice) = max(qwgrth(iice),0.)
         
             dum    = max(0.,(qccol(iice)+qrcol(iice))-qwgrth(iice))
             if (dum.ge.1.e-10) then
                nrshdr(iice) = nrshdr(iice) + dum*1.923e+6   
                if ((qccol(iice)+qrcol(iice)).ge.1.e-10) then
                   dum1  = 1./(qccol(iice)+qrcol(iice))
                   qcshd(iice) = qcshd(iice) + dum*qccol(iice)*dum1
                   qccol(iice) = qccol(iice) - dum*qccol(iice)*dum1
                   qrcol(iice) = qrcol(iice) - dum*qrcol(iice)*dum1
               endif
             
               log_wetgrowth(iice) = .true.
             endif

          endif





          if (qitot(i,k,iice).ge.qsmall .and. t(i,k).lt.273.15) then
             epsi(iice) = ((f1pr05+f1pr14*sc**thrd*(rhofaci(i,k)*rho(i,k)/mu)**0.5)*2.*pi* &
                          rho(i,k)*dv)*nitot(i,k,iice)
             epsi_tot   = epsi_tot + epsi(iice)
          else
             epsi(iice) = 0.
          endif








     
     
     
     

      
      

        
        
          if (qccol(iice).ge.qsmall .and. t(i,k).lt.273.15) then

           
             vtrmi1(i,k) = f1pr02*rhofaci(i,k)
             iTc   = 1./min(-0.001,t(i,k)-273.15)

          
             if (qc(i,k).ge.qsmall) then
              

                Vt_qc(i,k) = acn(i,k)*gamma(4.+bcn+mu_c(i,k))/(lamc(i,k)**bcn*gamma(mu_c(i,k)+4.))
              
                D_c = (mu_c(i,k)+4.)/lamc(i,k)
                V_impact  = abs(vtrmi1(i,k)-Vt_qc(i,k))
                Ri        = -(0.5e+6*D_c)*V_impact*iTc

                Ri        = max(1.,min(Ri,12.))
                if (Ri.le.8.) then
                   rhorime_c(iice)  = (0.051 + 0.114*Ri - 0.0055*Ri**2)*1000.
                else
                
                
                
                
                   rhorime_c(iice)  = 611.+72.25*(Ri-8.)
                endif

             endif    

          
            










          else
             rhorime_c(iice) = 400.

          endif 

    
       enddo iice_loop1
    










       if (qc(i,k).ge.qsmall .and. t(i,k).le.269.15) then



          dum    = (1./lamc(i,k))**3


          Q_nuc = cons6*cdist1(i,k)*gamma(7.+mu_c(i,k))*exp(aimm*(273.15-t(i,k)))*dum**2
          N_nuc = cons5*cdist1(i,k)*gamma(mu_c(i,k)+4.)*exp(aimm*(273.15-t(i,k)))*dum
         
          dum1      = 900.     
          D_new     = ((Q_nuc*6.)/(pi*dum1*N_nuc))**thrd
          call icecat_destination(qitot(i,k,:),diam_ice(i,k,:),D_new,deltaD_init,      &
                                  log_ni_add,iice_dest)
         
          qcheti(iice_dest) = Q_nuc
          if (log_ni_add) ncheti(iice_dest) = N_nuc
       endif






       if (qr(i,k).ge.qsmall.and.t(i,k).le.269.15) then
          Q_nuc = cons6*exp(log(cdistr(i,k))+log(gamma(7.+mu_r(i,k)))-6.*log(lamr(i,k)))* &
                  exp(aimm*(273.15-T(i,k)))
          N_nuc = cons5*exp(log(cdistr(i,k))+log(gamma(mu_r(i,k)+4.))-3.*log(lamr(i,k)))* &
                  exp(aimm*(273.15-T(i,k)))
         
          dum1      = 900.     
          D_new     = ((Q_nuc*6.)/(pi*dum1*N_nuc))**thrd
          call icecat_destination(qitot(i,k,:),diam_ice(i,k,:),D_new,deltaD_init,        &
                               log_ni_add,iice_dest)
         
          qrheti(iice_dest) = Q_nuc
          if (log_ni_add) nrheti(iice_dest) = N_nuc
       endif





       rimesplintering_on:  if (log_hmossopOn) then

        
          D_new = 10.e-6 
          call icecat_destination(qitot(i,k,:),diam_ice(i,k,:),D_new,deltaD_init,        &
                                  log_ni_add,iice_dest)

          iice_loop_HM:  do iice = 1,nCat

             if (qitot(i,k,iice).ge.qsmall.and. (qccol(iice).gt.0. .or.                  &
              qrcol(iice).gt.0.)) then

                if (t(i,k).gt.270.15) then
                   dum = 0.
                elseif (t(i,k).le.270.15 .and. t(i,k).gt.268.15) then
                   dum = (270.15-t(i,k))*0.5
                elseif (t(i,k).le.268.15 .and. t(i,k).ge.265.15) then
                   dum = (t(i,k)-265.15)*thrd
                elseif (t(i,k).lt.265.15) then
                   dum = 0.
                endif

                












               
                dum1 = 35.e+4*qrcol(iice)*dum*1000. 
                dum2 = dum1*piov6*900.*(10.e-6)**3  
                qrcol(iice) = qrcol(iice)-dum2      
                if (qrcol(iice) .lt. 0.) then
                   dum2 = qrcol(iice)
                   qrcol(iice) = 0.
                endif

                qrmul(iice_dest) = qrmul(iice_dest) + dum2
                if (log_ni_add) nimul(iice_dest) = nimul(iice_dest) + dum2/(piov6*900.*(10.e-6)**3)

             endif

          enddo iice_loop_HM

       endif rimesplintering_on






     
       if (qr(i,k).ge.qsmall) then
          call find_lookupTable_indices_3(dumii,dumjj,dum1,rdumii,rdumjj,inv_dum3,mu_r(i,k),lamr(i,k))
         
          dum1 = revap_table(dumii,dumjj)+(rdumii-real(dumii))*inv_dum3*                   &
                 (revap_table(dumii+1,dumjj)-revap_table(dumii,dumjj))
         
          dum2 = revap_table(dumii,dumjj+1)+(rdumii-real(dumii))*inv_dum3*                 &
                 (revap_table(dumii+1,dumjj+1)-revap_table(dumii,dumjj+1))
         
          dum  = dum1+(rdumjj-real(dumjj))*(dum2-dum1)

          epsr = 2.*pi*cdistr(i,k)*rho(i,k)*dv*(f1r*gamma(mu_r(i,k)+2.)/(lamr(i,k))+f2r*   &
                 (rho(i,k)/mu)**0.5*sc**thrd*dum)
       else
          epsr = 0.
       endif

       if (qc(i,k).ge.qsmall) then
          epsc = 2.*pi*rho(i,k)*dv*cdist(i,k)
       else
          epsc = 0.
       endif
   

       if (t(i,k).lt.273.15) then
          oabi = 1./abi
          xx   = epsc + epsr + epsi_tot*(1.+xxls(i,k)*inv_cp*dqsdt)*oabi
       else
          xx   = epsc + epsr
       endif

       dumqvi = qvi(i,k)   


























       dum = -cp/g*(t(i,k)-t_old(i,k))/dt



       if (t(i,k).lt.273.15) then
          aaa = (qv(i,k)-qv_old(i,k))/dt - dqsdt*(-dum*g*inv_cp)-(qvs(i,k)-dumqvi)*(1.+xxls(i,k)*      &
                inv_cp*dqsdt)*oabi*epsi_tot
       else
          aaa = (qv(i,k)-qv_old(i,k))/dt - dqsdt*(-dum*g*inv_cp)
       endif

       xx  = max(1.e-20,xx)   
       oxx = 1./xx

       if (qc(i,k).ge.qsmall) &
          qccon = (aaa*epsc*oxx+(ssat(i,k)-aaa*oxx)*odt*epsc*oxx*(1.-dexp(-dble(xx*dt))))/ab
       if (qr(i,k).ge.qsmall) &
          qrcon = (aaa*epsr*oxx+(ssat(i,k)-aaa*oxx)*odt*epsr*oxx*(1.-dexp(-dble(xx*dt))))/ab

     
       if (sup(i,k).lt.-0.001 .and. qc(i,k).lt.1.e-12)  qccon = -qc(i,k)*odt
       if (sup(i,k).lt.-0.001 .and. qr(i,k).lt.1.e-12)  qrcon = -qr(i,k)*odt

       if (qccon.lt.0.) then
          qcevp = -qccon

          qccon = 0.
       endif

       if (qrcon.lt.0.) then
          qrevp = -qrcon

          nrevp = qrevp*(nr(i,k)/qr(i,k))
         
          qrcon = 0.
       endif

      

       dumqvs = qv_sat(t(i,k),pres(i,k),0)
       qcon_satadj  = (qv(i,k)-dumqvs)/(1.+xxlv(i,k)**2*dumqvs/(cp*rv*t(i,k)**2))*odt
       if (qccon+qrcon.gt.0.) then
          ratio = max(0.,qcon_satadj)/(qccon+qrcon)
          ratio = min(1.,ratio)
          qccon = qccon*ratio
          qrcon = qrcon*ratio
       elseif (qcevp+qrevp.gt.0.) then
          ratio = max(0.,-qcon_satadj)/(qcevp+qrevp)
          ratio = min(1.,ratio)
          qcevp = qcevp*ratio
          qrevp = qrevp*ratio
       endif

       iice_loop_depsub:  do iice = 1,nCat

          if (qitot(i,k,iice).ge.qsmall.and.t(i,k).lt.273.15) then
             qidep(iice) = (aaa*epsi(iice)*oxx+(ssat(i,k)-aaa*oxx)*odt*epsi(iice)*oxx*   &
                           (1.-dexp(-dble(xx*dt))))*oabi+(qvs(i,k)-dumqvi)*epsi(iice)*oabi
          endif

         
          if (supi(i,k).lt.-0.001 .and. qitot(i,k,iice).lt.1.e-12) &
             qidep(iice) = -qitot(i,k,iice)*odt

          if (qidep(iice).lt.0.) then
           
             qisub(iice) = -qidep(iice)
             qisub(iice) = qisub(iice)*clbfact_sub
             qisub(iice) = min(qisub(iice), qitot(i,k,iice)*dt)
             nisub(iice) = qisub(iice)*(nitot(i,k,iice)/qitot(i,k,iice))
             qidep(iice) = 0.
          else
             qidep(iice) = qidep(iice)*clbfact_dep
          endif

       enddo iice_loop_depsub

444   continue






      if (t(i,k).lt.258.15 .and. supi(i,k).ge.0.05) then


         dum = 0.005*exp(0.304*(273.15-t(i,k)))*1000.*inv_rho(i,k)   
         dum = min(dum,100.e3*inv_rho(i,k))
         N_nuc = max(0.,(dum-sum(nitot(i,k,:)))*odt)

         if (N_nuc.ge.1.e-20) then
            Q_nuc = max(0.,(dum-sum(nitot(i,k,:)))*mi0*odt)
            
            dum1      = 900.     
            D_new     = ((Q_nuc*6.)/(pi*dum1*N_nuc))**thrd
            call icecat_destination(qitot(i,k,:),diam_ice(i,k,:),D_new,deltaD_init,    &
                                    log_ni_add,iice_dest)
            
            qinuc(iice_dest) = Q_nuc
            if (log_ni_add) ninuc(iice_dest) = N_nuc
         endif

      endif









          if (.not.(log_predictNc).and.sup(i,k).gt.1.e-6.and.it.gt.1) then
             dum   = nccnst*inv_rho(i,k)*cons7-qc(i,k)
             dum   = max(0.,dum)
             dumqvs = qv_sat(t(i,k),pres(i,k),0)
             dqsdt = xxlv(i,k)*dumqvs/(rv*t(i,k)*t(i,k))
             ab    = 1. + dqsdt*xxlv(i,k)*inv_cp
             dum   = min(dum,(qv(i,k)-dumqvs)/ab)  
             qcnuc = dum*odt
          endif

          if (log_predictNc) then





             if (sup(i,k).gt.1.e-6) then
                dum1  = 1./bact**0.5
                sigvl = 0.0761 - 1.55e-4*(t(i,k)-273.15)
                aact  = 2.*mw/(rhow*rr*t(i,k))*sigvl
                sm1   = 2.*dum1*(aact*thrd*inv_rm1)**1.5
                sm2   = 2.*dum1*(aact*thrd*inv_rm2)**1.5
                uu1   = 2.*log(sm1/sup(i,k))/(4.242*log(sig1))
                uu2   = 2.*log(sm2/sup(i,k))/(4.242*log(sig2))
                dum1  = nanew1*0.5*(1.-derf(uu1)) 
                dum2  = nanew2*0.5*(1.-derf(uu2)) 
              
                dum2  = min((nanew1+nanew2),dum1+dum2)
                dum2  = (dum2-nc(i,k))*odt
                dum2  = max(0.,dum2)
                ncnuc = dum2

              
                if (it.eq.1) then
                   qcnuc = 0.
                else
                   qcnuc = ncnuc*cons7
                endif
             endif

          endif







       if (it.eq.1) then
          dumt   = th(i,k)*(pres(i,k)*1.e-5)**(rd*inv_cp)
          dumqv  = qv(i,k)
          dumqvs = qv_sat(dumt,pres(i,k),0)
          dums   = dumqv-dumqvs
          qccon  = dums/(1.+xxlv(i,k)**2*dumqvs/(cp*rv*dumt**2))*odt
          qccon  = max(0.,qccon)
          if (qccon.le.1.e-7) qccon = 0.
       endif




       qc_not_small: if (qc(i,k).ge.1.e-8) then

          if (iparam.eq.1) then

            
             dum   = 1.-qc(i,k)/(qc(i,k)+qr(i,k))
             dum1  = 600.*dum**0.68*(1.-dum**0.68)**3
           
           
           
           
             qcaut =  kc*1.9230769e-5*(nu(i,k)+2.)*(nu(i,k)+4.)/(nu(i,k)+1.)**2*        &
                      (rho(i,k)*qc(i,k)*1.e-3)**4/(rho(i,k)*nc(i,k)*1.e-6)**2*(1.+      &
                      dum1/(1.-dum)**2)*1000.*inv_rho(i,k)
             ncautc = qcaut*7.6923076e+9

          elseif (iparam.eq.2) then

            
             if (nc(i,k)*rho(i,k)*1.e-6 .lt. 100.) then
                qcaut = 6.e+28*inv_rho(i,k)*mu_c(i,k)**(-1.7)*(1.e-6*rho(i,k)*          &
                        nc(i,k))**(-3.3)*(1.e-3*rho(i,k)*qc(i,k))**4.7
             else
               
                dum   = 41.46 + (nc(i,k)*1.e-6*rho(i,k)-100.)*(37.53-41.46)*5.e-3
                dum1  = 39.36 + (nc(i,k)*1.e-6*rho(i,k)-100.)*(30.72-39.36)*5.e-3
                qcaut = dum+(mu_c(i,k)-5.)*(dum1-dum)*0.1
              
                qcaut = exp(qcaut)*(1.e-3*rho(i,k)*qc(i,k))**4.7*1000.*inv_rho(i,k)
             endif
             ncautc = 7.7e+9*qcaut

          elseif (iparam.eq.3) then

           
             dum   = qc(i,k)
             qcaut = 1350.*dum**2.47*(nc(i,k)*1.e-6*rho(i,k))**(-1.79)
            
             ncautr = qcaut*cons3
             ncautc = qcaut*nc(i,k)/qc(i,k)

          endif

          if (qcaut .eq.0.) ncautc = 0.
          if (ncautc.eq.0.) qcaut  = 0.


       endif qc_not_small




       if (qc(i,k).ge.qsmall) then

          if (iparam.eq.1) then
           
             ncslf = -kc*(1.e-3*rho(i,k)*qc(i,k))**2*(nu(i,k)+2.)/(nu(i,k)+1.)*         &
                     1.e+6*inv_rho(i,k)+ncautc
          elseif (iparam.eq.2) then
           
             ncslf = -5.5e+16*inv_rho(i,k)*mu_c(i,k)**(-0.63)*(1.e-3*rho(i,k)*qc(i,k))**2
          elseif (iparam.eq.3) then
            
             ncslf = 0.
          endif

       endif




       if (qr(i,k).ge.qsmall .and. qc(i,k).ge.qsmall) then

          if (iparam.eq.1) then
           
             dum   = 1.-qc(i,k)/(qc(i,k)+qr(i,k))
             dum1  = (dum/(dum+5.e-4))**4
             qcacc = kr*rho(i,k)*0.001*qc(i,k)*qr(i,k)*dum1
             ncacc = qcacc*rho(i,k)*0.001*(nc(i,k)*rho(i,k)*1.e-6)/(qc(i,k)*rho(i,k)*   &
                     0.001)*1.e+6*inv_rho(i,k)
          elseif (iparam.eq.2) then
           
             qcacc = 6.*rho(i,k)*(qc(i,k)*qr(i,k))
             ncacc = qcacc*rho(i,k)*1.e-3*(nc(i,k)*rho(i,k)*1.e-6)/(qc(i,k)*rho(i,k)*1.e-3)* &
                     1.e+6*inv_rho(i,k)
          elseif (iparam.eq.3) then
            
             qcacc = 67.*(qc(i,k)*qr(i,k))**1.15
             ncacc = qcacc*nc(i,k)/qc(i,k)
          endif

          if (qcacc.eq.0.) ncacc = 0.
          if (ncacc.eq.0.) qcacc = 0.


       endif





       if (qr(i,k).ge.qsmall) then

        
          dum1 = 280.e-6

        
        
        

        

          dum2 = (qr(i,k)/(pi*rhow*nr(i,k)))**thrd
          if (dum2.lt.dum1) then
             dum = 1.
          else if (dum2.ge.dum1) then
             dum = 2.-exp(2300.*(dum2-dum1))
          endif

          if (iparam.eq.1.) then
             nrslf = dum*kr*1.e-3*qr(i,k)*nr(i,k)*rho(i,k)
          elseif (iparam.eq.2 .or. iparam.eq.3) then
             nrslf = dum*5.78*nr(i,k)*qr(i,k)*rho(i,k)
          endif

       endif










   
   
   
   
   
   

       dumqvi = qv_sat(t(i,k),pres(i,k),1)
       qdep_satadj = (qv(i,k)-dumqvi)/(1.+xxls(i,k)**2*dumqvi/(cp*rv*t(i,k)**2))*odt
       qidep  = qidep*min(1.,max(0., qdep_satadj)/max(sum(qidep), 1.e-20))
       qisub  = qisub*min(1.,max(0.,-qdep_satadj)/max(sum(qisub), 1.e-20))
      
      
   





       sinks   = (qcaut+qcacc+sum(qccol)+qcevp+sum(qchetc)+sum(qcheti)+sum(qcshd))*dt
       sources = qc(i,k) + (qccon+qcnuc)*dt
       if (sinks.gt.sources .and. sinks.ge.1.e-20) then
          ratio  = sources/sinks
          qcaut  = qcaut*ratio
          qcacc  = qcacc*ratio
          qcevp  = qcevp*ratio
          qccol  = qccol*ratio
          qcheti = qcheti*ratio
          qcshd  = qcshd*ratio
         
       endif


       sinks   = (qrevp+sum(qrcol)+sum(qrhetc)+sum(qrheti)+sum(qrmul))*dt
       sources = qr(i,k) + (qrcon+qcaut+qcacc+sum(qimlt)+sum(qcshd))*dt
       if (sinks.gt.sources .and. sinks.ge.1.e-20) then
          ratio  = sources/sinks
          qrevp  = qrevp*ratio
          qrcol  = qrcol*ratio
          qrheti = qrheti*ratio
          qrmul  = qrmul*ratio
         
       endif


       do iice = 1,nCat
          sinks   = (qisub(iice)+qimlt(iice))*dt
          sources = qitot(i,k,iice) + (qidep(iice)+qinuc(iice)+qrcol(iice)+qccol(iice)+  &
                    qrhetc(iice)+qrheti(iice)+qchetc(iice)+qcheti(iice)+qrmul(iice))*dt
          do catcoll = 1,nCat
            
             sources = sources + qicol(catcoll,iice)*dt
            
             sinks = sinks + qicol(iice,catcoll)*dt
          enddo
          if (sinks.gt.sources .and. sinks.ge.1.e-20) then
             ratio = sources/sinks
             qisub(iice) = qisub(iice)*ratio
             qimlt(iice) = qimlt(iice)*ratio
             do catcoll = 1,nCat
                qicol(iice,catcoll) = qicol(iice,catcoll)*ratio
             enddo
          endif
      enddo  






   
       iice_loop2: do iice = 1,nCat

          qc(i,k) = qc(i,k) + (-qchetc(iice)-qcheti(iice)-qccol(iice)-qcshd(iice))*dt
          if (log_predictNc) then
             nc(i,k) = nc(i,k) + (-nccol(iice)-nchetc(iice)-ncheti(iice))*dt
          endif

          qr(i,k) = qr(i,k) + (-qrcol(iice)+qimlt(iice)-qrhetc(iice)-qrheti(iice)+            &
                    qcshd(iice)-qrmul(iice))*dt
        
        
          nr(i,k) = nr(i,k) + (-nrcol(iice)-nrhetc(iice)-nrheti(iice)+nmltratio*nimlt(iice)+  &
                    nrshdr(iice)+ncshdc(iice))*dt

          if (qitot(i,k,iice).ge.qsmall) then
         
             birim(i,k,iice) = birim(i,k,iice) - ((qisub(iice)+qimlt(iice))/qitot(i,k,iice))* &
                               dt*birim(i,k,iice)
             qirim(i,k,iice) = qirim(i,k,iice) - ((qisub(iice)+qimlt(iice))*qirim(i,k,iice)/  &
                               qitot(i,k,iice))*dt
             qitot(i,k,iice) = qitot(i,k,iice) - (qisub(iice)+qimlt(iice))*dt
          endif

          dum             = (qrcol(iice)+qccol(iice)+qrhetc(iice)+qrheti(iice)+          &
                            qchetc(iice)+qcheti(iice)+qrmul(iice))*dt
          qitot(i,k,iice) = qitot(i,k,iice) + (qidep(iice)+qinuc(iice))*dt + dum
          qirim(i,k,iice) = qirim(i,k,iice) + dum
          birim(i,k,iice) = birim(i,k,iice) + (qrcol(iice)*inv_rho_rimeMax+qccol(iice)/  &
                            rhorime_c(iice)+(qrhetc(iice)+qrheti(iice)+qchetc(iice)+     &
                            qcheti(iice)+qrmul(iice))*inv_rho_rimeMax)*dt
          nitot(i,k,iice) = nitot(i,k,iice) + (ninuc(iice)-nimlt(iice)-nisub(iice)-      &
                            nislf(iice)+nrhetc(iice)+nrheti(iice)+nchetc(iice)+          &
                            ncheti(iice)+nimul(iice))*dt

          interactions_loop: do catcoll = 1,nCat
        
        

             qitot(i,k,catcoll) = qitot(i,k,catcoll) - qicol(catcoll,iice)*dt
             nitot(i,k,catcoll) = nitot(i,k,catcoll) - nicol(catcoll,iice)*dt
             qitot(i,k,iice)    = qitot(i,k,iice)    + qicol(catcoll,iice)*dt
             
             
             
             if (qitot(i,k,catcoll).ge.qsmall) then
              
                qirim(i,k,iice) = qirim(i,k,iice)+qicol(catcoll,iice)*dt*                &
                                  qirim(i,k,catcoll)/qitot(i,k,catcoll)
                birim(i,k,iice) = birim(i,k,iice)+qicol(catcoll,iice)*dt*                &
                                  birim(i,k,catcoll)/qitot(i,k,catcoll)
              
                qirim(i,k,catcoll) = qirim(i,k,catcoll)-qicol(catcoll,iice)*dt*          &
                                     qirim(i,k,catcoll)/qitot(i,k,catcoll)
                birim(i,k,catcoll) = birim(i,k,catcoll)-qicol(catcoll,iice)*dt*          &
                                     birim(i,k,catcoll)/qitot(i,k,catcoll)
             endif

          enddo interactions_loop 


          if (qirim(i,k,iice).lt.0.) then
             qirim(i,k,iice) = 0.
             birim(i,k,iice) = 0.
          endif

        
        
        
          if (log_wetgrowth(iice)) then
             qirim(i,k,iice) = qitot(i,k,iice)
             birim(i,k,iice) = qirim(i,k,iice)*inv_rho_rimeMax
          endif

        
        
        
        
        
        

          qv(i,k) = qv(i,k) + (-qidep(iice)+qisub(iice)-qinuc(iice))*dt

          th(i,k) = th(i,k) + th(i,k)/t(i,k)*((qidep(iice)-qisub(iice)+qinuc(iice))*     &
                              xxls(i,k)*inv_cp +(qrcol(iice)+qccol(iice)+qchetc(iice)+   &
                              qcheti(iice)+qrhetc(iice)+qrheti(iice)-qimlt(iice))*       &
                              xlf(i,k)*inv_cp)*dt

       enddo iice_loop2
   

   
       qc(i,k) = qc(i,k) + (-qcacc-qcaut+qcnuc+qccon-qcevp)*dt
       qr(i,k) = qr(i,k) + (qcacc+qcaut+qrcon-qrevp)*dt

       if (log_predictNc) then
          nc(i,k) = nc(i,k) + (-ncacc-ncautc+ncslf+ncnuc)*dt
       else
          nc(i,k) = nccnst*inv_rho(i,k)
       endif
       if (iparam.eq.1 .or. iparam.eq.2) then
          nr(i,k) = nr(i,k) + (0.5*ncautc-nrslf-nrevp)*dt
       else
          nr(i,k) = nr(i,k) + (ncautr-nrslf-nrevp)*dt
       endif

       qv(i,k) = qv(i,k) + (-qcnuc-qccon-qrcon+qcevp+qrevp)*dt
       th(i,k) = th(i,k) + th(i,k)/t(i,k)*((qcnuc+qccon+qrcon-qcevp-qrevp)*xxlv(i,k)*    &
                 inv_cp)*dt
   

     
       if (qc(i,k).lt.qsmall) then
          qv(i,k) = qv(i,k) + qc(i,k)
          th(i,k) = th(i,k) - th(i,k)/t(i,k)*qc(i,k)*xxlv(i,k)*inv_cp
          qc(i,k) = 0.
          nc(i,k) = 0.
       else
          log_hydrometeorsPresent = .true.
       endif

       if (qr(i,k).lt.qsmall) then
          qv(i,k) = qv(i,k) + qr(i,k)
          th(i,k) = th(i,k) - th(i,k)/t(i,k)*qr(i,k)*xxlv(i,k)*inv_cp
          qr(i,k) = 0.
          nr(i,k) = 0.
       else
          log_hydrometeorsPresent = .true.
       endif

       do iice = 1,nCat
          if (qitot(i,k,iice).lt.qsmall) then
             qv(i,k) = qv(i,k) + qitot(i,k,iice)
             th(i,k) = th(i,k) - th(i,k)/t(i,k)*qitot(i,k,iice)*xxls(i,k)*inv_cp
             qitot(i,k,iice) = 0.
             nitot(i,k,iice) = 0.
             qirim(i,k,iice) = 0.
             birim(i,k,iice) = 0.
          else
             log_hydrometeorsPresent = .true.
          endif
       enddo 

       call impose_max_total_Ni(nitot(i,k,:),max_total_Ni,inv_rho(i,k))



555    continue

    enddo k_loop_main

    if (debug_ON) then
       tmparr1(i,:) = th(i,:)*(pres(i,:)*1.e-5)**(rd*inv_cp)
       call check_values(qv,tmparr1,qc,qr,nr,qitot,qirim,nitot,birim,i,it,.true.,debug_ABORT,300)
    endif

    if (.not. log_hydrometeorsPresent) goto 333













    log_qcpresent = .false.

    do k = ktop,kbot,-kdir

       inv_dzq(i,k) = 1./dzq(i,k)



       call get_cloud_dsd(qc(i,k),nc(i,k),mu_c(i,k),rho(i,k),nu(i,k),dnu,lamc(i,k), &
                          lammin,lammax,k,tmp1,tmp2,qcindex,log_qcpresent)




       if (qc(i,k).ge.qsmall) then
          dum = 1./lamc(i,k)**bcn
          if (log_predictNc) then
             Vt_nc(i,k) =  acn(i,k)*gamma(1.+bcn+mu_c(i,k))*dum/(gamma(mu_c(i,k)+1.))
          endif
          Vt_qc(i,k) = acn(i,k)*gamma(4.+bcn+mu_c(i,k))*dum/(gamma(mu_c(i,k)+4.))
       else
          if (log_predictNc) then
             Vt_nc(i,k) = 0.
          endif
          Vt_qc(i,k) = 0.
       endif

    enddo 

    if (log_qcpresent) then



       nstep = 1
       do k = qcindex+kdir,kbot,-kdir

         
         
          V_qc(K)  = Vt_qc(i,k)

          if (kdir.eq.1) then
             if (k.le.qcindex-kdir) then
                if (V_qc(k).lt.1.E-10) then
                   V_qc(k) = V_qc(k+kdir)
                endif
             endif
          elseif (kdir.eq.-1) then
             if (k.ge.qcindex-kdir) then
                if (V_qc(k).lt.1.e-10) then
                   V_qc(k) = V_qc(k+kdir)
                endif
             endif
          endif


          rgvm       = V_qc(k)
          nstep      = max(int(rgvm*dt*inv_dzq(i,k)+1.),nstep)
          dum_qc(k)  = qc(i,k)*rho(i,k)
          tend_qc(K) = 0.

       enddo 

       inv_nstep = 1./real(nstep)

       if (nstep.ge.100) then
          print*,'CLOUD nstep LARGE:',i,nstep
          stop
       endif


       tmp1 = 0.
       do n = 1,nstep

          do k = kbot,qcindex,kdir
             flux_qc(k) = V_qc(k)*dum_qc(k)
          enddo
          tmp1 = tmp1 + flux_qc(kbot)  


          k = qcindex
          fluxdiv_qc = flux_qc(k)*inv_dzq(i,k)
          tend_qc(k) = tend_qc(k)-fluxdiv_qc*inv_nstep*inv_rho(i,k)
          dum_qc(k)  = dum_qc(k)-fluxdiv_qc*dt*inv_nstep


          do k = qcindex-kdir,kbot,-kdir
             fluxdiv_qc = (flux_qc(k+kdir)-flux_qc(K))*inv_dzq(i,k)
             tend_qc(k) = tend_qc(k)+fluxdiv_qc*inv_nstep*inv_rho(i,k)
             dum_qc(k)  = dum_qc(k)+fluxdiv_qc*dt*inv_nstep
          enddo 

       enddo 

       do k = kbot,qcindex,kdir
          qc(i,k) = qc(i,k)+tend_qc(k)*dt
       enddo


       tmp1 = tmp1*inv_nstep           
       pcprt_liq(i) = tmp1*inv_rhow    




       if (log_predictNc) then

       nstep = 1
       do k = qcindex+kdir,kbot,-kdir

         
         
          V_nc(K) = Vt_nc(i,k)

          if (kdir.eq.1) then
             if (k.le.qcindex-kdir) then
                if (V_nc(k).lt.1.E-10) then
                   V_nc(k) = V_nc(k+kdir)
                endif
             endif
          elseif (kdir.eq.-1) then
             if (k.ge.qcindex-kdir) then
                if (V_nc(k).lt.1.e-10) then
                   V_nc(k) = V_nc(k+kdir)
                endif
             endif
          endif


          rgvm       = V_nc(k)
          nstep      = max(int(rgvm*dt*inv_dzq(i,k)+1.),nstep)
          dum_nc(k)  = nc(i,k)*rho(i,k)
          tend_nc(K) = 0.

       enddo 

       inv_nstep = 1./real(nstep)

       if (nstep.ge.100) then
          print*,'CLOUD nstep LARGE:',i,nstep
          stop
       endif


       do n = 1,nstep

          do k = kbot,qcindex,kdir
             flux_nc(k) = V_nc(k)*dum_nc(k)
          enddo


          k = qcindex
          fluxdiv_nc = flux_nc(k)*inv_dzq(i,k)
          tend_nc(k) = tend_nc(k)-fluxdiv_nc*inv_nstep*inv_rho(i,k)
          dum_nc(k)  = dum_nc(k)-fluxdiv_nc*dt*inv_nstep


          do k = qcindex-kdir,kbot,-kdir

             fluxdiv_nc = (flux_nc(k+kdir)-flux_nc(K))*inv_dzq(i,k)
             tend_nc(k) = tend_nc(k)+fluxdiv_nc*inv_nstep*inv_rho(i,k)
             dum_nc(k)  = dum_nc(k)+fluxdiv_nc*dt*inv_nstep

          enddo 

       enddo 

       do k = kbot,qcindex,kdir
          nc(i,k) = nc(i,k)+tend_nc(k)*dt
       enddo

    endif 

    endif 





    log_qrpresent = .false.

    do k = ktop,kbot,-kdir

       call get_rain_dsd(qr(i,k),nr(i,k),mu_r(i,k),rdumii,dumii,lamr(i,k),mu_r_table,    &
                         tmp1,tmp2,log_qrpresent,qrindex,k)
       

       if (qr(i,k).ge.qsmall) then

       
          call find_lookupTable_indices_3(dumii,dumjj,dum1,rdumii,rdumjj,inv_dum3,       &
                                          mu_r(i,k),lamr(i,k))

     
       
          dum1 = vn_table(dumii,dumjj)+(rdumii-real(dumii))*inv_dum3*                    &
                 (vn_table(dumii+1,dumjj)-vn_table(dumii,dumjj))
       
          dum2 = vn_table(dumii,dumjj+1)+(rdumii-real(dumii))*                           &
                 inv_dum3*(vn_table(dumii+1,dumjj+1)-vn_table(dumii,dumjj+1))
       
          Vt_nr(i,k) = dum1+(rdumjj-real(dumjj))*(dum2-dum1)
          Vt_nr(i,k) = Vt_nr(i,k)*rhofacr(i,k)

      
       
          dum1 = vm_table(dumii,dumjj)+(rdumii-real(dumii))*inv_dum3*                    &
                 (vm_table(dumii+1,dumjj)-vm_table(dumii,dumjj))
       
          dum2 = vm_table(dumii,dumjj+1)+(rdumii-real(dumii))*inv_dum3*                  &
                 (vm_table(dumii+1,dumjj+1)-vm_table(dumii,dumjj+1))

       
          Vt_qr(i,k) = dum1 + (rdumjj-real(dumjj))*(dum2-dum1)
          Vt_qr(i,k) = Vt_qr(i,k)*rhofacr(i,k)

       else

          Vt_nr(i,k) = 0.
          Vt_qr(i,k) = 0.

       endif

    enddo 

    if (log_qrpresent) then

       nstep = 1

       do k = qrindex+kdir,kbot,-kdir

         
         
          V_qr(k) = Vt_qr(i,k)
          V_nr(k) = Vt_nr(i,k)

          if (kdir.eq.1) then
             if (k.le.qrindex-kdir) then
                if (V_qr(k).lt.1.e-10) then
                   V_qr(k) = V_qr(k+kdir)
                endif
                if (V_nr(k).lt.1.e-10) then
                   V_nr(k) = V_nr(k+kdir)
                endif
             endif
          elseif (kdir.eq.-1) then
             if (k.ge.qrindex-kdir) then
                if (V_qr(k).lt.1.e-10) then
                   V_qr(k) = V_qr(k+kdir)
                endif
                if (V_nr(k).lt.1.e-10) then
                   V_nr(k) = V_nr(k+kdir)
                endif
             endif
          endif

       
          rgvm       = max(V_qr(k),V_nr(k))
          nstep      = max(int(rgvm*dt*inv_dzq(i,k)+1.),nstep)
          dum_qr(k)  = qr(i,k)*rho(i,k)
          dum_nr(k)  = nr(i,k)*rho(i,k)
          tend_qr(k) = 0.
          tend_nr(k) = 0.

       enddo 

       inv_nstep = 1./real(nstep)

       if (nstep .ge. 100) then
          print*,'RAIN nstep LARGE:',i,nstep
          stop
       endif






       tmp1 = 0.
       do n = 1,nstep

          do k = kbot,qrindex,kdir
             flux_qr(k) = V_qr(k)*dum_qr(k)
             flux_nr(k) = V_nr(k)*dum_nr(k)
          enddo
          tmp1 = tmp1 + flux_qr(kbot)  


          k          = qrindex
          fluxdiv_qr = flux_qr(k)*inv_dzq(i,k)
          fluxdiv_nr = flux_nr(k)*inv_dzq(i,k)
          tend_qr(k) = tend_qr(k) - fluxdiv_qr*inv_nstep*inv_rho(i,k)
          tend_nr(k) = tend_nr(k) - fluxdiv_nr*inv_nstep*inv_rho(i,k)
          dum_qr(k)  = dum_qr(k)  - fluxdiv_qr*dt*inv_nstep
          dum_nr(k)  = dum_nr(k)  - fluxdiv_nr*dt*inv_nstep


          do k = qrindex-kdir,kbot,-kdir
             fluxdiv_qr = (flux_qr(k+kdir) - flux_qr(K))*inv_dzq(i,k)
             fluxdiv_nr = (flux_nr(k+kdir) - flux_nr(K))*inv_dzq(i,k)
             tend_qr(k) = tend_qr(k) + fluxdiv_qr*inv_nstep*inv_rho(i,k)
             tend_nr(k) = tend_nr(k) + fluxdiv_nr*inv_nstep*inv_rho(i,k)
             dum_qr(k)  = dum_qr(k)  + fluxdiv_qr*dt*inv_nstep
             dum_nr(k)  = dum_nr(k)  + fluxdiv_nr*dt*inv_nstep
          enddo 

       enddo 


       do k = kbot,qrindex,kdir
          qr(i,k) = qr(i,k) + tend_qr(k)*dt
          nr(i,k) = nr(i,k) + tend_nr(k)*dt
       enddo


       tmp1 = tmp1*inv_nstep               
       tmp1 = tmp1*inv_rhow                

       pcprt_liq(i) = pcprt_liq(i) + tmp1  

    endif 





    iice_loop_sedi_ice:  do iice = 1,nCat

       log_qipresent = .false.  

       do k = ktop,kbot,-kdir


          qitot_not_small: if (qitot(i,k,iice).ge.qsmall) then

            
             nitot(i,k,iice) = max(nitot(i,k,iice),nsmall)

             call calc_bulkRhoRime(qitot(i,k,iice),qirim(i,k,iice),birim(i,k,iice),rhop)

           
             call find_lookupTable_indices_1a(dumi,dumjj,dumii,dumzz,dum1,dum4,dum5,     &
                                       dum6,isize,rimsize,densize,zsize,qitot(i,k,iice), &
                                       nitot(i,k,iice),qirim(i,k,iice),999.,rhop)
                                      

             call access_lookup_table(dumjj,dumii,dumi, 1,dum1,dum4,dum5,f1pr01)
             call access_lookup_table(dumjj,dumii,dumi, 2,dum1,dum4,dum5,f1pr02)
             call access_lookup_table(dumjj,dumii,dumi, 7,dum1,dum4,dum5,f1pr09)
             call access_lookup_table(dumjj,dumii,dumi, 8,dum1,dum4,dum5,f1pr10)










          
          
             nitot(i,k,iice) = min(nitot(i,k,iice),f1pr09*nitot(i,k,iice))
             nitot(i,k,iice) = max(nitot(i,k,iice),f1pr10*nitot(i,k,iice))





             if (.not. log_qipresent) then
                qiindex = k
             endif
             log_qipresent = .true.

             Vt_nit(i,k) = f1pr01*rhofaci(i,k)     
             Vt_qit(i,k) = f1pr02*rhofaci(i,k)     
          
             diag_vmi(i,k,iice) = f1pr02           

          else

             Vt_nit(i,k) = 0.
             Vt_qit(i,k) = 0.
           

          endif qitot_not_small

       enddo 

       qipresent: if (log_qipresent) then

          nstep = 1

          do k = qiindex+kdir,kbot,-kdir

            
            
             V_qit(k) = Vt_qit(i,k)
             V_nit(k) = Vt_nit(i,k)
          

            
             if (kdir.eq.1) then
                if (k.le.qiindex-kdir) then
                   if (V_qit(k).lt.1.e-10)  V_qit(k) = V_qit(k+kdir)
                   if (V_nit(k).lt.1.e-10)  V_nit(k) = V_nit(k+kdir)
                 
                endif
             elseif (kdir.eq.-1) then
                if (k.ge.qiindex-kdir) then
                   if (V_qit(k).lt.1.e-10)  V_qit(k) = V_qit(k+kdir)
                   if (V_nit(k).lt.1.e-10)  V_nit(k) = V_nit(k+kdir)
                 
                endif
             endif 
            


             rgvm        = max(V_qit(k),V_nit(k))

             nstep       = max(int(rgvm*dt*inv_dzq(i,k)+1.),nstep)
             dum_qit(k)  = qitot(i,k,iice)*rho(i,k)
             dum_qir(k)  = qirim(i,k,iice)*rho(i,k)
             dum_bir(k)  = birim(i,k,iice)*rho(i,k)
             dum_nit(k)  = nitot(i,k,iice)*rho(i,k)

             tend_qit(k) = 0.
             tend_qir(k) = 0.
             tend_bir(k) = 0.
             tend_nit(k) = 0.


          enddo 

          inv_nstep = 1./real(nstep)

          if (nstep.ge.200) then
             print*,'ICE nstep LARGE:',i,nstep
             if (nstep.ge.500) stop
          endif


          tmp1 = 0.
          do n = 1,nstep

             do k = kbot,qiindex,kdir
                flux_qit(k) = V_qit(k)*dum_qit(k)
                flux_nit(k) = V_nit(k)*dum_nit(k)
                flux_qir(k) = V_qit(k)*dum_qir(k)
                flux_bir(k) = V_qit(k)*dum_bir(k)

             enddo
            tmp1 = tmp1 + flux_qit(kbot)  


             k = qiindex
             fluxdiv_qit = flux_qit(k)*inv_dzq(i,k)
             fluxdiv_qir = flux_qir(k)*inv_dzq(i,k)
             fluxdiv_bir = flux_bir(k)*inv_dzq(i,k)
             fluxdiv_nit = flux_nit(k)*inv_dzq(i,k)


             tend_qit(k) = tend_qit(k) - fluxdiv_qit*inv_nstep*inv_rho(i,k)
             tend_qir(k) = tend_qir(k) - fluxdiv_qir*inv_nstep*inv_rho(i,k)
             tend_bir(k) = tend_bir(k) - fluxdiv_bir*inv_nstep*inv_rho(i,k)
             tend_nit(k) = tend_nit(k) - fluxdiv_nit*inv_nstep*inv_rho(i,k)


             dum_qit(k) = dum_qit(k) - fluxdiv_qit*dt*inv_nstep
             dum_qir(k) = dum_qir(k) - fluxdiv_qir*dt*inv_nstep
             dum_bir(k) = dum_bir(k) - fluxdiv_bir*dt*inv_nstep
             dum_nit(k) = dum_nit(k) - fluxdiv_nit*dt*inv_nstep



             do k = qiindex-kdir,kbot,-kdir
                fluxdiv_qit = (flux_qit(k+kdir) - flux_qit(k))*inv_dzq(i,k)
                fluxdiv_qir = (flux_qir(k+kdir) - flux_qir(k))*inv_dzq(i,k)
                fluxdiv_bir = (flux_bir(k+kdir) - flux_bir(k))*inv_dzq(i,k)
                fluxdiv_nit = (flux_nit(k+kdir) - flux_nit(k))*inv_dzq(i,k)


                tend_qit(k) = tend_qit(k) + fluxdiv_qit*inv_nstep*inv_rho(i,k)
                tend_qir(k) = tend_qir(k) + fluxdiv_qir*inv_nstep*inv_rho(i,k)
                tend_bir(k) = tend_bir(k) + fluxdiv_bir*inv_nstep*inv_rho(i,k)
                tend_nit(k) = tend_nit(k) + fluxdiv_nit*inv_nstep*inv_rho(i,k)


                dum_qit(k) = dum_qit(k) + fluxdiv_qit*dt*inv_nstep
                dum_qir(k) = dum_qir(k) + fluxdiv_qir*dt*inv_nstep
                dum_bir(k) = dum_bir(k) + fluxdiv_bir*dt*inv_nstep
                dum_nit(k) = dum_nit(k) + fluxdiv_nit*dt*inv_nstep
 
             enddo 

          enddo 


          do k = kbot,qiindex,kdir
             qitot(i,k,iice) = qitot(i,k,iice) + tend_qit(k)*dt
             qirim(i,k,iice) = qirim(i,k,iice) + tend_qir(k)*dt
             birim(i,k,iice) = birim(i,k,iice) + tend_bir(k)*dt
             nitot(i,k,iice) = nitot(i,k,iice) + tend_nit(k)*dt

          enddo


          tmp1 = tmp1*inv_nstep   
          tmp1 = tmp1*inv_rhow    
          pcprt_sol(i) = pcprt_sol(i) + tmp1  

       endif qipresent

    enddo iice_loop_sedi_ice  










    k_loop_fz:  do k = kbot,ktop,kdir

    
       diam_ice(i,k,:) = 0.
       do iice = 1,nCat
          if (qitot(i,k,iice).ge.qsmall) then
             dum1 = max(nitot(i,k,iice),nsmall)
             dum2 = 500. 
             diam_ice(i,k,iice) = ((qitot(i,k,iice)*6.)/(dum1*dum2*pi))**thrd
          endif
       enddo  

       if (qc(i,k).ge.qsmall .and. t(i,k).lt.233.15) then
          Q_nuc = qc(i,k)
          N_nuc = max(nc(i,k),nsmall)
         
          dum1   = 900.     
          D_new  = ((Q_nuc*6.)/(pi*dum1*N_nuc))**thrd
          call icecat_destination(qitot(i,k,:),diam_ice(i,k,:),D_new,deltaD_init,       &
                                  log_ni_add,iice_dest)
         
          qirim(i,k,iice_dest) = qirim(i,k,iice_dest) + Q_nuc
          qitot(i,k,iice_dest) = qitot(i,k,iice_dest) + Q_nuc
          birim(i,k,iice_dest) = birim(i,k,iice_dest) + Q_nuc*inv_rho_rimeMax
          nitot(i,k,iice_dest) = nitot(i,k,iice_dest) + N_nuc
          th(i,k) = th(i,k) + th(i,k)/t(i,k)*Q_nuc*xlf(i,k)*inv_cp
          qc(i,k) = 0.  
          nc(i,k) = 0.  
       endif

       if (qr(i,k).ge.qsmall .and. t(i,k).lt.233.15) then
          Q_nuc = qr(i,k)
          N_nuc = max(nr(i,k),nsmall)
         
          dum1  = 900.     
          D_new = ((Q_nuc*6.)/(pi*dum1*N_nuc))**thrd
          call icecat_destination(qitot(i,k,:),diam_ice(i,k,:),D_new,deltaD_init,       &
                                  log_ni_add,iice_dest)
         
          qirim(i,k,iice_dest) = qirim(i,k,iice_dest) + Q_nuc
          qitot(i,k,iice_dest) = qitot(i,k,iice_dest) + Q_nuc
          birim(i,k,iice_dest) = birim(i,k,iice_dest) + Q_nuc*inv_rho_rimeMax
          nitot(i,k,iice_dest) = nitot(i,k,iice_dest) + N_nuc
          th(i,k) = th(i,k) + th(i,k)/t(i,k)*Q_nuc*xlf(i,k)*inv_cp
          qr(i,k) = 0.  
          nr(i,k) = 0.  
       endif

    enddo k_loop_fz







    k_loop_final_diagnostics:  do k = kbot,ktop,kdir

    
       if (qc(i,k).ge.qsmall) then
          call get_cloud_dsd(qc(i,k),nc(i,k),mu_c(i,k),rho(i,k),nu(i,k),dnu,lamc(i,k),   &
                             lammin,lammax,k,tmp1,tmp2,tmpint1,log_tmp1)
          diag_effc(i,k) = 0.5*(mu_c(i,k)+3.)/lamc(i,k)
       else
          qv(i,k) = qv(i,k)+qc(i,k)
          th(i,k) = th(i,k)-th(i,k)/t(i,k)*qc(i,k)*xxlv(i,k)*inv_cp
          qc(i,k) = 0.
          nc(i,k) = 0.
       endif

    
       if (qr(i,k).ge.qsmall) then
          call get_rain_dsd(qr(i,k),nr(i,k),mu_r(i,k),rdumii,dumii,lamr(i,k),mu_r_table, &
                            tmp1,tmp2,log_tmp1,tmpint1,tmpint2)
         

         
         
         
         
         
         
         
         

         
        
          
          ze_rain(i,k) = nr(i,k)*(mu_r(i,k)+6.)*(mu_r(i,k)+5.)*(mu_r(i,k)+4.)*           &
                        (mu_r(i,k)+3.)*(mu_r(i,k)+2.)*(mu_r(i,k)+1.)/lamr(i,k)**6
          ze_rain(i,k) = max(ze_rain(i,k),1.e-22)
       else
          qv(i,k) = qv(i,k)+qr(i,k)
          th(i,k) = th(i,k)-th(i,k)/t(i,k)*qr(i,k)*xxlv(i,k)*inv_cp
          qr(i,k) = 0.
          nr(i,k) = 0.
       endif

    

       call impose_max_total_Ni(nitot(i,k,:),max_total_Ni,inv_rho(i,k))

       iice_loop_final_diagnostics:  do iice = 1,nCat

          qi_not_small:  if (qitot(i,k,iice).ge.qsmall) then

            
             nitot(i,k,iice) = max(nitot(i,k,iice),nsmall)
             nr(i,k)         = max(nr(i,k),nsmall)

             call calc_bulkRhoRime(qitot(i,k,iice),qirim(i,k,iice),birim(i,k,iice),rhop)

           
             call find_lookupTable_indices_1a(dumi,dumjj,dumii,dumzz,dum1,dum4,          &
                                              dum5,dum6,isize,rimsize,densize,zsize,     &
                                              qitot(i,k,iice),nitot(i,k,iice),           &
                                              qirim(i,k,iice),999.,rhop)
                                             

             call access_lookup_table(dumjj,dumii,dumi, 6,dum1,dum4,dum5,f1pr06)
             call access_lookup_table(dumjj,dumii,dumi, 7,dum1,dum4,dum5,f1pr09)
             call access_lookup_table(dumjj,dumii,dumi, 8,dum1,dum4,dum5,f1pr10)
             call access_lookup_table(dumjj,dumii,dumi, 9,dum1,dum4,dum5,f1pr13)
             call access_lookup_table(dumjj,dumii,dumi,11,dum1,dum4,dum5,f1pr15)
             call access_lookup_table(dumjj,dumii,dumi,12,dum1,dum4,dum5,f1pr16)

          
          
             nitot(i,k,iice) = min(nitot(i,k,iice),f1pr09*nitot(i,k,iice))
             nitot(i,k,iice) = max(nitot(i,k,iice),f1pr10*nitot(i,k,iice))


             if (qirim(i,k,iice).lt.qsmall) then
                qirim(i,k,iice) = 0.
                birim(i,k,iice) = 0.
             endif
  

  
             diag_effi(i,k,iice)  = f1pr06 
             diag_di(i,k,iice)    = f1pr15
             diag_rhopo(i,k,iice) = f1pr16
          
             ze_ice(i,k) = ze_ice(i,k) + 0.1892*f1pr13*nitot(i,k,iice)*rho(i,k)   
             ze_ice(i,k) = max(ze_ice(i,k),1.e-22)

          else

             qv(i,k) = qv(i,k) + qitot(i,k,iice)
             th(i,k) = th(i,k) - th(i,k)/t(i,k)*qitot(i,k,iice)*xxls(i,k)*inv_cp
             qitot(i,k,iice) = 0.
             nitot(i,k,iice) = 0.
             qirim(i,k,iice) = 0.
             birim(i,k,iice) = 0.
             diag_di(i,k,iice) = 0.

          endif qi_not_small

       enddo iice_loop_final_diagnostics

     
       diag_ze(i,k) = 10.*log10((ze_rain(i,k) + ze_ice(i,k))*1.d+18)

     
     
       if (qr(i,k).lt.qsmall) then
          nr(i,k) = 0.
       endif

    enddo k_loop_final_diagnostics









    multicat:  if (nCat.gt.1) then


       do k = kbot,ktop,kdir
          do iice = nCat,2,-1

           
             if (abs(diag_di(i,k,iice)-diag_di(i,k,iice-1)).le.150.e-6   .and.           &
                 abs(diag_rhopo(i,k,iice)-diag_rhopo(i,k,iice-1)).le.100.) then

                qitot(i,k,iice-1) = qitot(i,k,iice-1) + qitot(i,k,iice)
                nitot(i,k,iice-1) = nitot(i,k,iice-1) + nitot(i,k,iice)
                qirim(i,k,iice-1) = qirim(i,k,iice-1) + qirim(i,k,iice)
                birim(i,k,iice-1) = birim(i,k,iice-1) + birim(i,k,iice)
             

                qitot(i,k,iice) = 0.
                nitot(i,k,iice) = 0.
                qirim(i,k,iice) = 0.
                birim(i,k,iice) = 0.
             

             endif

          enddo 
       enddo 

    endif multicat



333 continue

    if (log_predictSsat) then
   
       do k = kbot,ktop,kdir
          t(i,k) = th(i,k)*(1.e-5*pres(i,k))**(rd*inv_cp)
          dum    = qv_sat(t(i,k),pres(i,k),0)
          ssat(i,k) = qv(i,k)-dum
       enddo
    endif

    if (debug_ON) then
       tmparr1(i,:) = th(i,:)*(pres(i,:)*1.e-5)**(rd*inv_cp)
       call check_values(qv,tmparr1,qc,qr,nr,qitot,qirim,nitot,birim,i,it,.true.,debug_ABORT,900)
    endif



 enddo i_loop_main




  diag_ss(:,:,1) = diag_vmi(:,:,1)     
  diag_ss(:,:,2) = diag_di(:,:,1)      
  diag_ss(:,:,3) = diag_rhopo(:,:,1)   





  th_old = th
  qv_old = qv































 return

 END SUBROUTINE p3_main



 SUBROUTINE access_lookup_table(dumjj,dumii,dumi,index,dum1,dum4,dum5,proc)

 implicit none

 real    :: dum1,dum4,dum5,proc,dproc1,dproc2,iproc1,gproc1,tmp1,tmp2
 integer :: dumjj,dumii,dumi,index





   iproc1 = itab(dumjj,dumii,dumi,index)+(dum1-real(dumi))*(itab(dumjj,dumii,       &
            dumi+1,index)-itab(dumjj,dumii,dumi,index))



   gproc1 = itab(dumjj,dumii+1,dumi,index)+(dum1-real(dumi))*(itab(dumjj,dumii+1,   &
          dumi+1,index)-itab(dumjj,dumii+1,dumi,index))

   tmp1   = iproc1+(dum4-real(dumii))*(gproc1-iproc1)





   iproc1 = itab(dumjj+1,dumii,dumi,index)+(dum1-real(dumi))*(itab(dumjj+1,dumii,   &
            dumi+1,index)-itab(dumjj+1,dumii,dumi,index))



   gproc1 = itab(dumjj+1,dumii+1,dumi,index)+(dum1-real(dumi))*(itab(dumjj+1,       &
            dumii+1,dumi+1,index)-itab(dumjj+1,dumii+1,dumi,index))

   tmp2   = iproc1+(dum4-real(dumii))*(gproc1-iproc1)


   proc   = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)

END SUBROUTINE access_lookup_table


SUBROUTINE access_lookup_table_coll(dumjj,dumii,dumj,dumi,index,dum1,dum3,          &
                                    dum4,dum5,proc)

 implicit none

 real    :: dum1,dum3,dum4,dum5,proc,dproc1,dproc2,iproc1,gproc1,tmp1,tmp2,dproc11, &
            dproc12,dproc21,dproc22
 integer :: dumjj,dumii,dumj,dumi,index







  dproc1  = itabcoll(dumjj,dumii,dumi,dumj,index)+(dum1-real(dumi))*                &
             (itabcoll(dumjj,dumii,dumi+1,dumj,index)-itabcoll(dumjj,dumii,dumi,    &
             dumj,index))

   dproc2  = itabcoll(dumjj,dumii,dumi,dumj+1,index)+(dum1-real(dumi))*             &
             (itabcoll(dumjj,dumii,dumi+1,dumj+1,index)-itabcoll(dumjj,dumii,dumi,  &
             dumj+1,index))

   iproc1  = dproc1+(dum3-real(dumj))*(dproc2-dproc1)



   dproc1  = itabcoll(dumjj,dumii+1,dumi,dumj,index)+(dum1-real(dumi))*             &
             (itabcoll(dumjj,dumii+1,dumi+1,dumj,index)-itabcoll(dumjj,dumii+1,     &
                 dumi,dumj,index))

   dproc2  = itabcoll(dumjj,dumii+1,dumi,dumj+1,index)+(dum1-real(dumi))*           &
             (itabcoll(dumjj,dumii+1,dumi+1,dumj+1,index)-itabcoll(dumjj,dumii+1,   &
             dumi,dumj+1,index))

   gproc1  = dproc1+(dum3-real(dumj))*(dproc2-dproc1)
   tmp1    = iproc1+(dum4-real(dumii))*(gproc1-iproc1)





   dproc1  = itabcoll(dumjj+1,dumii,dumi,dumj,index)+(dum1-real(dumi))*             &
             (itabcoll(dumjj+1,dumii,dumi+1,dumj,index)-itabcoll(dumjj+1,dumii,     &
                 dumi,dumj,index))

   dproc2  = itabcoll(dumjj+1,dumii,dumi,dumj+1,index)+(dum1-real(dumi))*           &
             (itabcoll(dumjj+1,dumii,dumi+1,dumj+1,index)-itabcoll(dumjj+1,dumii,   &
             dumi,dumj+1,index))

   iproc1  = dproc1+(dum3-real(dumj))*(dproc2-dproc1)



   dproc1  = itabcoll(dumjj+1,dumii+1,dumi,dumj,index)+(dum1-real(dumi))*           &
             (itabcoll(dumjj+1,dumii+1,dumi+1,dumj,index)-itabcoll(dumjj+1,dumii+1, &
             dumi,dumj,index))

   dproc2  = itabcoll(dumjj+1,dumii+1,dumi,dumj+1,index)+(dum1-real(dumi))*         &
             (itabcoll(dumjj+1,dumii+1,dumi+1,dumj+1,index)-itabcoll(dumjj+1,       &
                 dumii+1,dumi,dumj+1,index))

   gproc1  = dproc1+(dum3-real(dumj))*(dproc2-dproc1)
   tmp2    = iproc1+(dum4-real(dumii))*(gproc1-iproc1)


   proc    = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)

 END SUBROUTINE access_lookup_table_coll



 SUBROUTINE access_lookup_table_colli(dumjjc,dumiic,dumic,dumjj,dumii,dumj,dumi,     &
                                     index,dum1c,dum4c,dum5c,dum1,dum4,dum5,proc)

 implicit none

 real    :: dum1,dum3,dum4,dum5,dum1c,dum4c,dum5c,proc,dproc1,dproc2,iproc1,iproc2, &
            gproc1,gproc2,rproc1,rproc2,tmp1,tmp2,dproc11,dproc12
 integer :: dumjj,dumii,dumj,dumi,index,dumjjc,dumiic,dumic












  if (index.eq.1) then

   dproc11 = itabcolli1(dumic,dumiic,dumjjc,dumi,dumii,dumjj)+(dum1c-real(dumic))*    &
             (itabcolli1(dumic+1,dumiic,dumjjc,dumi,dumii,dumjj)-                     &
             itabcolli1(dumic,dumiic,dumjjc,dumi,dumii,dumjj))

   dproc12 = itabcolli1(dumic,dumiic,dumjjc,dumi+1,dumii,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli1(dumic+1,dumiic,dumjjc,dumi+1,dumii,dumjj)-                   &
             itabcolli1(dumic,dumiic,dumjjc,dumi+1,dumii,dumjj))


   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)




   dproc11 = itabcolli1(dumic,dumiic,dumjjc,dumi,dumii+1,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli1(dumic+1,dumiic,dumjjc,dumi,dumii+1,dumjj)-                   &
             itabcolli1(dumic,dumiic,dumjjc,dumi,dumii+1,dumjj))

   dproc12 = itabcolli1(dumic,dumiic,dumjjc,dumi+1,dumii+1,dumjj)+(dum1c-real(dumic))*&
             (itabcolli1(dumic+1,dumiic,dumjjc,dumi+1,dumii+1,dumjj)-                 &
             itabcolli1(dumic,dumiic,dumjjc,dumi+1,dumii+1,dumjj))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp1    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)



   dproc11 = itabcolli1(dumic,dumiic,dumjjc,dumi,dumii,dumjj+1)+(dum1c-real(dumic))*  &
             (itabcolli1(dumic+1,dumiic,dumjjc,dumi,dumii,dumjj+1)-                   &
             itabcolli1(dumic,dumiic,dumjjc,dumi,dumii,dumjj+1))

   dproc12 = itabcolli1(dumic,dumiic,dumjjc,dumi+1,dumii,dumjj+1)+(dum1c-real(dumic))*&
             (itabcolli1(dumic+1,dumiic,dumjjc,dumi+1,dumii,dumjj+1)-                 &
             itabcolli1(dumic,dumiic,dumjjc,dumi+1,dumii,dumjj+1))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli1(dumic,dumiic,dumjjc,dumi,dumii+1,dumjj+1)+(dum1c-real(dumic))*&
             (itabcolli1(dumic+1,dumiic,dumjjc,dumi,dumii+1,dumjj+1)-                 &
             itabcolli1(dumic,dumiic,dumjjc,dumi,dumii+1,dumjj+1))

   dproc12 = itabcolli1(dumic,dumiic,dumjjc,dumi+1,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic,dumjjc,dumi+1,dumii+1,dumjj+1)-                  &
             itabcolli1(dumic,dumiic,dumjjc,dumi+1,dumii+1,dumjj+1))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp2    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)

   gproc1    = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)




   dproc11 = itabcolli1(dumic,dumiic+1,dumjjc,dumi,dumii,dumjj)+(dum1c-real(dumic))*   &
             (itabcolli1(dumic+1,dumiic+1,dumjjc,dumi,dumii,dumjj)-                    &
             itabcolli1(dumic,dumiic+1,dumjjc,dumi,dumii,dumjj))

   dproc12 = itabcolli1(dumic,dumiic+1,dumjjc,dumi+1,dumii,dumjj)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc,dumi+1,dumii,dumjj)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc,dumi+1,dumii,dumjj))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli1(dumic,dumiic+1,dumjjc,dumi,dumii+1,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli1(dumic+1,dumiic+1,dumjjc,dumi,dumii+1,dumjj)-                   &
             itabcolli1(dumic,dumiic+1,dumjjc,dumi,dumii+1,dumjj))

   dproc12 = itabcolli1(dumic,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp1    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)



   dproc11 = itabcolli1(dumic,dumiic+1,dumjjc,dumi,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc,dumi,dumii,dumjj+1)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc,dumi,dumii,dumjj+1))

   dproc12 = itabcolli1(dumic,dumiic+1,dumjjc,dumi+1,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc,dumi+1,dumii,dumjj+1)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc,dumi+1,dumii,dumjj+1))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli1(dumic,dumiic+1,dumjjc,dumi,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc,dumi,dumii+1,dumjj+1)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc,dumi,dumii+1,dumjj+1))

   dproc12 = itabcolli1(dumic,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj+1)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj+1))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp2    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)

   gproc2  = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)

   rproc1  = gproc1+(dum4c-real(dumiic))*(gproc2-gproc1)




   dproc11 = itabcolli1(dumic,dumiic,dumjjc+1,dumi,dumii,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli1(dumic+1,dumiic,dumjjc+1,dumi,dumii,dumjj)-                   &
             itabcolli1(dumic,dumiic,dumjjc+1,dumi,dumii,dumjj))

   dproc12 = itabcolli1(dumic,dumiic,dumjjc+1,dumi+1,dumii,dumjj)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic,dumjjc+1,dumi+1,dumii,dumjj)-                  &
             itabcolli1(dumic,dumiic,dumjjc+1,dumi+1,dumii,dumjj))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli1(dumic,dumiic,dumjjc+1,dumi,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic,dumjjc+1,dumi,dumii+1,dumjj)-                  &
             itabcolli1(dumic,dumiic,dumjjc+1,dumi,dumii+1,dumjj))

   dproc12 = itabcolli1(dumic,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj)-                  &
             itabcolli1(dumic,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp1    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)



   dproc11 = itabcolli1(dumic,dumiic,dumjjc+1,dumi,dumii,dumjj+1)+(dum1c-real(dumic))*  &
             (itabcolli1(dumic+1,dumiic,dumjjc+1,dumi,dumii,dumjj+1)-                   &
             itabcolli1(dumic,dumiic,dumjjc+1,dumi,dumii,dumjj+1))

   dproc12 = itabcolli1(dumic,dumiic,dumjjc+1,dumi+1,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic,dumjjc+1,dumi+1,dumii,dumjj+1)-                  &
             itabcolli1(dumic,dumiic,dumjjc+1,dumi+1,dumii,dumjj+1))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli1(dumic,dumiic,dumjjc+1,dumi,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic,dumjjc+1,dumi,dumii+1,dumjj+1)-                  &
             itabcolli1(dumic,dumiic,dumjjc+1,dumi,dumii+1,dumjj+1))

   dproc12 = itabcolli1(dumic,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj+1)-                  &
             itabcolli1(dumic,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj+1))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp2    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)

   gproc1    = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)




   dproc11 = itabcolli1(dumic,dumiic+1,dumjjc+1,dumi,dumii,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli1(dumic+1,dumiic+1,dumjjc+1,dumi,dumii,dumjj)-                   &
             itabcolli1(dumic,dumiic+1,dumjjc+1,dumi,dumii,dumjj))

   dproc12 = itabcolli1(dumic,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli1(dumic,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj))

   dproc12 = itabcolli1(dumic,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp1    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)



   dproc11 = itabcolli1(dumic,dumiic+1,dumjjc+1,dumi,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc+1,dumi,dumii,dumjj+1)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc+1,dumi,dumii,dumjj+1))

   dproc12 = itabcolli1(dumic,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj+1)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj+1))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli1(dumic,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj+1)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj+1))

   dproc12 = itabcolli1(dumic,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli1(dumic+1,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj+1)-                  &
             itabcolli1(dumic,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj+1))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp2    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)

   gproc2  = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)

   rproc2  = gproc1+(dum4c-real(dumiic))*(gproc2-gproc1)




   proc    = rproc1+(dum5c-real(dumjjc))*(rproc2-rproc1)

 else if (index.eq.2) then

   dproc11 = itabcolli2(dumic,dumiic,dumjjc,dumi,dumii,dumjj)+(dum1c-real(dumic))*    &
             (itabcolli2(dumic+1,dumiic,dumjjc,dumi,dumii,dumjj)-                     &
             itabcolli2(dumic,dumiic,dumjjc,dumi,dumii,dumjj))

   dproc12 = itabcolli2(dumic,dumiic,dumjjc,dumi+1,dumii,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli2(dumic+1,dumiic,dumjjc,dumi+1,dumii,dumjj)-                   &
             itabcolli2(dumic,dumiic,dumjjc,dumi+1,dumii,dumjj))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli2(dumic,dumiic,dumjjc,dumi,dumii+1,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli2(dumic+1,dumiic,dumjjc,dumi,dumii+1,dumjj)-                   &
             itabcolli2(dumic,dumiic,dumjjc,dumi,dumii+1,dumjj))

   dproc12 = itabcolli2(dumic,dumiic,dumjjc,dumi+1,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc,dumi+1,dumii+1,dumjj)-                  &
             itabcolli2(dumic,dumiic,dumjjc,dumi+1,dumii+1,dumjj))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp1    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)



   dproc11 = itabcolli2(dumic,dumiic,dumjjc,dumi,dumii,dumjj+1)+(dum1c-real(dumic))*  &
             (itabcolli2(dumic+1,dumiic,dumjjc,dumi,dumii,dumjj+1)-                   &
             itabcolli2(dumic,dumiic,dumjjc,dumi,dumii,dumjj+1))

   dproc12 = itabcolli2(dumic,dumiic,dumjjc,dumi+1,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc,dumi+1,dumii,dumjj+1)-                  &
             itabcolli2(dumic,dumiic,dumjjc,dumi+1,dumii,dumjj+1))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli2(dumic,dumiic,dumjjc,dumi,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc,dumi,dumii+1,dumjj+1)-                  &
             itabcolli2(dumic,dumiic,dumjjc,dumi,dumii+1,dumjj+1))

   dproc12 = itabcolli2(dumic,dumiic,dumjjc,dumi+1,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc,dumi+1,dumii+1,dumjj+1)-                  &
             itabcolli2(dumic,dumiic,dumjjc,dumi+1,dumii+1,dumjj+1))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp2    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)

   gproc1    = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)




   dproc11 = itabcolli2(dumic,dumiic+1,dumjjc,dumi,dumii,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc,dumi,dumii,dumjj)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc,dumi,dumii,dumjj))

   dproc12 = itabcolli2(dumic,dumiic+1,dumjjc,dumi+1,dumii,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc,dumi+1,dumii,dumjj)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc,dumi+1,dumii,dumjj))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli2(dumic,dumiic+1,dumjjc,dumi,dumii+1,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli2(dumic+1,dumiic+1,dumjjc,dumi,dumii+1,dumjj)-                   &
             itabcolli2(dumic,dumiic+1,dumjjc,dumi,dumii+1,dumjj))

   dproc12 = itabcolli2(dumic,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp1    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)



   dproc11 = itabcolli2(dumic,dumiic+1,dumjjc,dumi,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc,dumi,dumii,dumjj+1)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc,dumi,dumii,dumjj+1))

   dproc12 = itabcolli2(dumic,dumiic+1,dumjjc,dumi+1,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc,dumi+1,dumii,dumjj+1)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc,dumi+1,dumii,dumjj+1))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli2(dumic,dumiic+1,dumjjc,dumi,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc,dumi,dumii+1,dumjj+1)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc,dumi,dumii+1,dumjj+1))

   dproc12 = itabcolli2(dumic,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj+1)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc,dumi+1,dumii+1,dumjj+1))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp2    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)

   gproc2  = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)

   rproc1  = gproc1+(dum4c-real(dumiic))*(gproc2-gproc1)




   dproc11 = itabcolli2(dumic,dumiic,dumjjc+1,dumi,dumii,dumjj)+(dum1c-real(dumic))*  &
             (itabcolli2(dumic+1,dumiic,dumjjc+1,dumi,dumii,dumjj)-                   &
             itabcolli2(dumic,dumiic,dumjjc+1,dumi,dumii,dumjj))

   dproc12 = itabcolli2(dumic,dumiic,dumjjc+1,dumi+1,dumii,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc+1,dumi+1,dumii,dumjj)-                  &
             itabcolli2(dumic,dumiic,dumjjc+1,dumi+1,dumii,dumjj))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli2(dumic,dumiic,dumjjc+1,dumi,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc+1,dumi,dumii+1,dumjj)-                  &
             itabcolli2(dumic,dumiic,dumjjc+1,dumi,dumii+1,dumjj))

   dproc12 = itabcolli2(dumic,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj)-                  &
             itabcolli2(dumic,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp1    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)



   dproc11 = itabcolli2(dumic,dumiic,dumjjc+1,dumi,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc+1,dumi,dumii,dumjj+1)-                  &
             itabcolli2(dumic,dumiic,dumjjc+1,dumi,dumii,dumjj+1))

   dproc12 = itabcolli2(dumic,dumiic,dumjjc+1,dumi+1,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc+1,dumi+1,dumii,dumjj+1)-                  &
             itabcolli2(dumic,dumiic,dumjjc+1,dumi+1,dumii,dumjj+1))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli2(dumic,dumiic,dumjjc+1,dumi,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc+1,dumi,dumii+1,dumjj+1)-                  &
             itabcolli2(dumic,dumiic,dumjjc+1,dumi,dumii+1,dumjj+1))

   dproc12 = itabcolli2(dumic,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj+1)-                  &
             itabcolli2(dumic,dumiic,dumjjc+1,dumi+1,dumii+1,dumjj+1))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp2    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)

   gproc1    = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)




   dproc11 = itabcolli2(dumic,dumiic+1,dumjjc+1,dumi,dumii,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc+1,dumi,dumii,dumjj)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc+1,dumi,dumii,dumjj))

   dproc12 = itabcolli2(dumic,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli2(dumic,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj))

   dproc12 = itabcolli2(dumic,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp1    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)



   dproc11 = itabcolli2(dumic,dumiic+1,dumjjc+1,dumi,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc+1,dumi,dumii,dumjj+1)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc+1,dumi,dumii,dumjj+1))

   dproc12 = itabcolli2(dumic,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj+1)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc+1,dumi+1,dumii,dumjj+1))

   iproc1  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)



   dproc11 = itabcolli2(dumic,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj+1)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc+1,dumi,dumii+1,dumjj+1))

   dproc12 = itabcolli2(dumic,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj+1)+(dum1c-real(dumic))* &
             (itabcolli2(dumic+1,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj+1)-                  &
             itabcolli2(dumic,dumiic+1,dumjjc+1,dumi+1,dumii+1,dumjj+1))

   iproc2  = dproc11+(dum1-real(dumi))*(dproc12-dproc11)

   tmp2    = iproc1+(dum4-real(dumii))*(iproc2-iproc1)

   gproc2  = tmp1+(dum5-real(dumjj))*(tmp2-tmp1)

   rproc2  = gproc1+(dum4c-real(dumiic))*(gproc2-gproc1)




   proc    = rproc1+(dum5c-real(dumjjc))*(rproc2-rproc1)

 endif 

 END SUBROUTINE access_lookup_table_colli



 real function polysvp1(T,i_type)








      implicit none

      real    :: DUM,T
      integer :: i_type




      real a0i,a1i,a2i,a3i,a4i,a5i,a6i,a7i,a8i
      data a0i,a1i,a2i,a3i,a4i,a5i,a6i,a7i,a8i /&
        6.11147274, 0.503160820, 0.188439774e-1, &
        0.420895665e-3, 0.615021634e-5,0.602588177e-7, &
        0.385852041e-9, 0.146898966e-11, 0.252751365e-14/


      real a0,a1,a2,a3,a4,a5,a6,a7,a8


      data a0,a1,a2,a3,a4,a5,a6,a7,a8 /&
        6.11239921, 0.443987641, 0.142986287e-1, &
        0.264847430e-3, 0.302950461e-5, 0.206739458e-7, &
        0.640689451e-10,-0.952447341e-13,-0.976195544e-15/
      real dt



      if (i_type.EQ.1 .and. T.lt.273.15) then



         dt       = max(-80.,t-273.16)
         polysvp1 = a0i + dt*(a1i+dt*(a2i+dt*(a3i+dt*(a4i+dt*(a5i+dt*(a6i+dt*(a7i+       &
                    a8i*dt)))))))
         polysvp1 = polysvp1*100.







      elseif (i_type.EQ.0 .or. T.ge.273.15) then



         dt       = max(-80.,t-273.16)
         polysvp1 = a0 + dt*(a1+dt*(a2+dt*(a3+dt*(a4+dt*(a5+dt*(a6+dt*(a7+a8*dt)))))))
         polysvp1 = polysvp1*100.








         endif


 end function polysvp1



 real function gamma(X)




















































































      implicit none
      integer :: I,N
      logical :: l_parity
      real ::                                                       &
          CONV,EPS,FACT,HALF,ONE,res,sum,TWELVE,                    &
          TWO,X,XBIG,XDEN,XINF,XMININ,XNUM,Y,Y1,YSQ,Z,ZERO
      real, dimension(7) :: C
      real, dimension(8) :: P
      real, dimension(8) :: Q
      real, parameter    :: constant1 = 0.9189385332046727417803297




      data ONE,HALF,TWELVE,TWO,ZERO/1.0E0,0.5E0,12.0E0,2.0E0,0.0E0/



      data XBIG,XMININ,EPS/35.040E0,1.18E-38,1.19E-7/,XINF/3.4E38/




      data P/-1.71618513886549492533811E+0,2.47656508055759199108314E+1,  &
             -3.79804256470945635097577E+2,6.29331155312818442661052E+2,  &
             8.66966202790413211295064E+2,-3.14512729688483675254357E+4,  &
             -3.61444134186911729807069E+4,6.64561438202405440627855E+4/
      data Q/-3.08402300119738975254353E+1,3.15350626979604161529144E+2,  &
             -1.01515636749021914166146E+3,-3.10777167157231109440444E+3, &
              2.25381184209801510330112E+4,4.75584627752788110767815E+3,  &
            -1.34659959864969306392456E+5,-1.15132259675553483497211E+5/



      data C/-1.910444077728E-03,8.4171387781295E-04,                      &
           -5.952379913043012E-04,7.93650793500350248E-04,                 &
           -2.777777777777681622553E-03,8.333333333333333331554247E-02,    &
            5.7083835261E-03/



      CONV(I) = REAL(I)
      l_parity=.FALSE.
      FACT=ONE
      N=0
      Y=X
      if (Y.LE.ZERO) then



        Y=-X
        Y1=AINT(Y)
        res=Y-Y1
        if (res.NE.ZERO) then
          if(Y1.NE.AINT(Y1*HALF)*TWO)l_parity=.TRUE.
          FACT=-PI/SIN(PI*res)
          Y=Y+ONE
        else
          res=XINF
          goto 900
        endif
      endif



      if (Y.LT.EPS) then



        if (Y.GE.XMININ) then
          res=ONE/Y
        else
          res=XINF
          goto 900
        endif
      elseif (Y.LT.TWELVE) then
        Y1=Y
        if (Y.LT.ONE) then



          Z=Y
          Y=Y+ONE
        else



          N=INT(Y)-1
          Y=Y-CONV(N)
          Z=Y-ONE
        endif



        XNUM=ZERO
        XDEN=ONE
        do I=1,8
          XNUM=(XNUM+P(I))*Z
          XDEN=XDEN*Z+Q(I)
        enddo
        res=XNUM/XDEN+ONE
        if (Y1.LT.Y) then



          res=res/Y1
        elseif (Y1.GT.Y) then



          do I=1,N
            res=res*Y
            Y=Y+ONE
          enddo
        endif
      else



        if (Y.LE.XBIG) then
          YSQ=Y*Y
          sum=C(7)
          do I=1,6
            sum=sum/YSQ+C(I)
          enddo
          sum=sum/Y-Y+constant1
          sum=sum+(Y-HALF)*log(Y)
          res=exp(sum)
        else
          res=XINF
          goto 900
        endif
      endif



      if (l_parity)res=-res
      if (FACT.NE.ONE)res=FACT/res
  900 gamma=res
      return


 end function gamma



 real function DERF(X)

 implicit none

 real :: X
 real, dimension(0 : 64) :: A, B
 real :: W,T,Y
 integer :: K,I
      data A/                                                 &
         0.00000000005958930743E0, -0.00000000113739022964E0, &
         0.00000001466005199839E0, -0.00000016350354461960E0, &
         0.00000164610044809620E0, -0.00001492559551950604E0, &
         0.00012055331122299265E0, -0.00085483269811296660E0, &
         0.00522397762482322257E0, -0.02686617064507733420E0, &
         0.11283791670954881569E0, -0.37612638903183748117E0, &
         1.12837916709551257377E0,                            &
         0.00000000002372510631E0, -0.00000000045493253732E0, &
         0.00000000590362766598E0, -0.00000006642090827576E0, &
         0.00000067595634268133E0, -0.00000621188515924000E0, &
         0.00005103883009709690E0, -0.00037015410692956173E0, &
         0.00233307631218880978E0, -0.01254988477182192210E0, &
         0.05657061146827041994E0, -0.21379664776456006580E0, &
         0.84270079294971486929E0,                            &
         0.00000000000949905026E0, -0.00000000018310229805E0, &
         0.00000000239463074000E0, -0.00000002721444369609E0, &
         0.00000028045522331686E0, -0.00000261830022482897E0, &
         0.00002195455056768781E0, -0.00016358986921372656E0, &
         0.00107052153564110318E0, -0.00608284718113590151E0, &
         0.02986978465246258244E0, -0.13055593046562267625E0, &
         0.67493323603965504676E0,                            &
         0.00000000000382722073E0, -0.00000000007421598602E0, &
         0.00000000097930574080E0, -0.00000001126008898854E0, &
         0.00000011775134830784E0, -0.00000111992758382650E0, &
         0.00000962023443095201E0, -0.00007404402135070773E0, &
         0.00050689993654144881E0, -0.00307553051439272889E0, &
         0.01668977892553165586E0, -0.08548534594781312114E0, &
         0.56909076642393639985E0,                            &
         0.00000000000155296588E0, -0.00000000003032205868E0, &
         0.00000000040424830707E0, -0.00000000471135111493E0, &
         0.00000005011915876293E0, -0.00000048722516178974E0, &
         0.00000430683284629395E0, -0.00003445026145385764E0, &
         0.00024879276133931664E0, -0.00162940941748079288E0, &
         0.00988786373932350462E0, -0.05962426839442303805E0, &
         0.49766113250947636708E0 /
      data (B(I), I = 0, 12) /                                 &
         -0.00000000029734388465E0,  0.00000000269776334046E0, &
         -0.00000000640788827665E0, -0.00000001667820132100E0, &
         -0.00000021854388148686E0,  0.00000266246030457984E0, &
          0.00001612722157047886E0, -0.00025616361025506629E0, &
          0.00015380842432375365E0,  0.00815533022524927908E0, &
         -0.01402283663896319337E0, -0.19746892495383021487E0, &
          0.71511720328842845913E0 /
      data (B(I), I = 13, 25) /                                &
         -0.00000000001951073787E0, -0.00000000032302692214E0, &
          0.00000000522461866919E0,  0.00000000342940918551E0, &
         -0.00000035772874310272E0,  0.00000019999935792654E0, &
          0.00002687044575042908E0, -0.00011843240273775776E0, &
         -0.00080991728956032271E0,  0.00661062970502241174E0, &
          0.00909530922354827295E0, -0.20160072778491013140E0, &
          0.51169696718727644908E0 /
      data (B(I), I = 26, 38) /                                &
         0.00000000003147682272E0, -0.00000000048465972408E0,  &
         0.00000000063675740242E0,  0.00000003377623323271E0,  &
        -0.00000015451139637086E0, -0.00000203340624738438E0,  &
         0.00001947204525295057E0,  0.00002854147231653228E0,  &
        -0.00101565063152200272E0,  0.00271187003520095655E0,  &
         0.02328095035422810727E0, -0.16725021123116877197E0,  &
         0.32490054966649436974E0 /
      data (B(I), I = 39, 51) /                                &
         0.00000000002319363370E0, -0.00000000006303206648E0,  &
        -0.00000000264888267434E0,  0.00000002050708040581E0,  &
         0.00000011371857327578E0, -0.00000211211337219663E0,  &
         0.00000368797328322935E0,  0.00009823686253424796E0,  &
        -0.00065860243990455368E0, -0.00075285814895230877E0,  &
         0.02585434424202960464E0, -0.11637092784486193258E0,  &
         0.18267336775296612024E0 /
      data (B(I), I = 52, 64) /                                &
        -0.00000000000367789363E0,  0.00000000020876046746E0,  &
        -0.00000000193319027226E0, -0.00000000435953392472E0,  &
         0.00000018006992266137E0, -0.00000078441223763969E0,  &
        -0.00000675407647949153E0,  0.00008428418334440096E0,  &
        -0.00017604388937031815E0, -0.00239729611435071610E0,  &
         0.02064129023876022970E0, -0.06905562880005864105E0,  &
         0.09084526782065478489E0 /
      W = ABS(X)
      if (W .LT. 2.2D0) then
          T = W * W
          K = INT(T)
          T = T - K
          K = K * 13
          Y = ((((((((((((A(K) * T + A(K + 1)) * T +              &
              A(K + 2)) * T + A(K + 3)) * T + A(K + 4)) * T +     &
              A(K + 5)) * T + A(K + 6)) * T + A(K + 7)) * T +     &
              A(K + 8)) * T + A(K + 9)) * T + A(K + 10)) * T +    &
              A(K + 11)) * T + A(K + 12)) * W
      elseif (W .LT. 6.9D0) then
          K = INT(W)
          T = W - K
          K = 13 * (K - 2)
          Y = (((((((((((B(K) * T + B(K + 1)) * T +               &
              B(K + 2)) * T + B(K + 3)) * T + B(K + 4)) * T +     &
              B(K + 5)) * T + B(K + 6)) * T + B(K + 7)) * T +     &
              B(K + 8)) * T + B(K + 9)) * T + B(K + 10)) * T +    &
              B(K + 11)) * T + B(K + 12)
          Y = Y * Y
          Y = Y * Y
          Y = Y * Y
          Y = 1 - Y * Y
      else
          Y = 1
      endif
      if (X .LT. 0) Y = -Y
      DERF = Y

 end function DERF



 logical function isnan(arg1)
       real,intent(in) :: arg1
       isnan=( arg1  .ne. arg1 )
       return
 end function isnan




 subroutine icecat_destination(Qi,Di,D_nuc,deltaD_init,log_ni_add,iice_dest)

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 implicit none


 real, intent(in), dimension(:) :: Qi,Di
 real, intent(in)               :: D_nuc,deltaD_init
 integer, intent(out)           :: iice_dest
 logical, intent(out)           :: log_ni_add


 logical                        :: all_full,all_empty
 integer                        :: i_firstEmptyCategory,iice,i_mindiff,n_cat
 real                           :: mindiff,diff
 real, parameter                :: qsmall_loc = 1.e-14

 

 n_cat      = size(Qi)
 log_ni_add = .true.
 iice_dest  = -99






 if (sum(Qi(:))<qsmall_loc) then

 
    iice_dest = 1
    return

 else

    all_full  = .true.
    all_empty = .false.
    mindiff   = 9.e+9
    i_firstEmptyCategory = 0

    do iice = 1,n_cat
       if (Qi(iice) .ge. qsmall_loc) then
          all_empty = .false.
          diff      = abs(Di(iice)-D_nuc)
          if (diff .lt. mindiff) then
             mindiff   = diff
             i_mindiff = iice
          endif
       else
          all_full = .false.
          if (i_firstEmptyCategory.eq.0) i_firstEmptyCategory = iice
       endif
    enddo

    if (all_full) then
 
       iice_dest = i_mindiff
       if (mindiff .ge. 100.e-6) log_ni_add=.false.
       return
    else
       if (mindiff .lt. deltaD_init) then
 
          iice_dest = i_mindiff
          return
       else
 
          iice_dest = i_firstEmptyCategory
          return
       endif
    endif

 endif

 print*, 'ERROR in s/r icecat_destination -- made it to end'
 stop


 end subroutine icecat_destination




 subroutine find_lookupTable_indices_1a(dumi,dumjj,dumii,dumzz,dum1,dum4,dum5,dum6,      &
                                        isize,rimsize,densize,zsize,qitot,nitot,qirim,   &
                                        zitot_in,rhop)





 implicit none


 integer, intent(out) :: dumi,dumjj,dumii,dumzz
 real,    intent(out) :: dum1,dum4,dum5,dum6
 integer, intent(in)  :: isize,rimsize,densize,zsize
 real,    intent(in)  :: qitot,nitot,qirim,zitot_in,rhop


 real                 :: zitot



           




             dum1 = (alog10(qitot/nitot)+18.)/(0.1*alog10(261.7))-10.
             dumi = int(dum1)

             dum1 = min(dum1,real(isize))
             dum1 = max(dum1,1.)
             dumi = max(1,dumi)
             dumi = min(isize-1,dumi)

           
             dum4  = (qirim/qitot)*3. + 1.
             dumii = int(dum4)
             
             dum4  = min(dum4,real(rimsize))
             dum4  = max(dum4,1.)
             dumii = max(1,dumii)
             dumii = min(rimsize-1,dumii)

           
           
             if (rhop.le.650.) then
                dum5 = (rhop-50.)*0.005 + 1.
             else
                dum5 =(rhop-650.)*0.004 + 4.
             endif
             dumjj = int(dum5)
             
             dum5  = min(dum5,real(densize))
             dum5  = max(dum5,1.)
             dumjj = max(1,dumjj)
             dumjj = min(densize-1,dumjj)











             dum6  = -99
             dumzz = -99

 end subroutine find_lookupTable_indices_1a



 subroutine find_lookupTable_indices_1b(dumj,dum3,rcollsize,qr,nr)

 
 
 

 implicit none


 integer, intent(out) :: dumj
 real,    intent(out) :: dum3
 integer, intent(in)  :: rcollsize
 real,    intent(in)  :: qr,nr


 real                 :: dumlr



           
           
             if (qr.ge.qsmall .and. nr.gt.0.) then
              
                dumlr = (qr/(pi*rhow*nr))**thrd
                dum3  = (alog10(1.*dumlr)+5.)*10.70415
                dumj  = int(dum3)
              
                dum3  = min(dum3,real_rcollsize)
                dum3  = max(dum3,1.)
                dumj  = max(1,dumj)
                dumj  = min(rcollsize-1,dumj)
             else
                dumj  = 1
                dum3  = 1.
             endif

 end subroutine find_lookupTable_indices_1b



 subroutine find_lookupTable_indices_2(dumi,   dumii,   dumjj,  dumic, dumiic, dumjjc,  &
                                       dum1,   dum4,    dum5,   dum1c, dum4c,  dum5c,   &
                                       iisize, rimsize, densize,                        &
                                       qitot_1, qitot_2, nitot_1, nitot_2,                      &
                                       qirim_1, qirim_2, birim_1, birim_2)





 implicit none


 integer, intent(out) :: dumi,   dumii,   dumjj,  dumic, dumiic, dumjjc
 real,    intent(out) :: dum1,   dum4,    dum5,   dum1c, dum4c,  dum5c
 integer, intent(in)  :: iisize, rimsize, densize
 real,    intent(in)  :: qitot_1,qitot_2,nitot_1,nitot_2,qirim_1,qirim_2,birim_1,birim_2


 real                 :: drhop



                    

                    

                      dum1 = (alog10(qitot_1/nitot_1)+18.)/(0.2*alog10(261.7))-5.
                      dumi = int(dum1)
                      dum1 = min(dum1,real(iisize))
                      dum1 = max(dum1,1.)
                      dumi = max(1,dumi)
                      dumi = min(iisize-1,dumi)

   
   
   

                    
                      dum4  = qirim_1/qitot_1*3. + 1.
                      dumii = int(dum4)
                      dum4  = min(dum4,real(rimsize))
                      dum4  = max(dum4,1.)
                      dumii = max(1,dumii)
                      dumii = min(rimsize-1,dumii)


                    
                    
                    
                      if (birim_1.ge.bsmall) then
                         drhop = qirim_1/birim_1
                      else
                         drhop = 0.
                      endif

                      if (drhop.le.650.) then
                         dum5 = (drhop-50.)*0.005 + 1.
                      else
                         dum5 =(drhop-650.)*0.004 + 4.
                      endif
                      dumjj = int(dum5)
                      dum5  = min(dum5,real(densize))
                      dum5  = max(dum5,1.)
                      dumjj = max(1,dumjj)
                      dumjj = min(densize-1,dumjj)



                    

      		      dum1c = (alog10(qitot_2/nitot_2)+18.)/(0.2*alog10(261.7))-5.
                      dumic = int(dum1c)
                      dum1c = min(dum1c,real(iisize))
                      dum1c = max(dum1c,1.)
                      dumic = max(1,dumic)
                      dumic = min(iisize-1,dumic)


                    
                      dum4c  = qirim_2/qitot_2*3. + 1.
                      dumiic = int(dum4c)
                      dum4c  = min(dum4c,real(rimsize))
                      dum4c  = max(dum4c,1.)
                      dumiic = max(1,dumiic)
                      dumiic = min(rimsize-1,dumiic)
                    
                      if (birim_2.ge.1.e-15) then            
                         drhop = qirim_2/birim_2
                      else
                         drhop = 0.
                      endif

                    
                    
                      if (drhop.le.650.) then
                         dum5c = (drhop-50.)*0.005 + 1.
                      else
                         dum5c =(drhop-650.)*0.004 + 4.
                      endif
                      dumjjc = int(dum5c)
                      dum5c  = min(dum5c,real(densize))
                      dum5c  = max(dum5c,1.)
                      dumjjc = max(1,dumjjc)
                      dumjjc = min(densize-1,dumjjc)

 end subroutine find_lookupTable_indices_2



 subroutine find_lookupTable_indices_3(dumii,dumjj,dum1,rdumii,rdumjj,inv_dum3,mu_r,lamr)





 implicit none


 integer, intent(out) :: dumii,dumjj
 real,    intent(out) :: dum1,rdumii,rdumjj,inv_dum3
 real,    intent(in)  :: mu_r,lamr



        
          dum1 = (mu_r+1.)/lamr
          if (dum1.le.195.e-6) then
             inv_dum3  = 0.1
             rdumii = (dum1*1.e6+5.)*inv_dum3
             rdumii = max(rdumii, 1.)
             rdumii = min(rdumii,20.)
             dumii  = int(rdumii)
             dumii  = max(dumii, 1)
             dumii  = min(dumii,20)
          elseif (dum1.gt.195.e-6) then
             inv_dum3  = thrd*0.1            
             rdumii = (dum1*1.e+6-195.)*inv_dum3 + 20.
             rdumii = max(rdumii, 20.)
             rdumii = min(rdumii,300.)
             dumii  = int(rdumii)
             dumii  = max(dumii, 20)
             dumii  = min(dumii,299)
          endif

        
          rdumjj = mu_r+1.
          rdumjj = max(rdumjj,1.)
          rdumjj = min(rdumjj,10.)
          dumjj  = int(rdumjj)
          dumjj  = max(dumjj,1)
          dumjj  = min(dumjj,9)

 end subroutine find_lookupTable_indices_3



 subroutine get_cloud_dsd(qc,nc,mu_c,rho,nu,dnu,lamc,lammin,lammax,k,cdist, &
                          cdist1,qcindex,log_qcpresent)

 implicit none


 real, dimension(:), intent(in)  :: dnu
 real,     intent(in)            :: qc,rho
 real,     intent(inout)         :: nc
 real,     intent(out)           :: mu_c,nu,lamc,cdist,cdist1
 integer,  intent(in)            :: k
 integer, intent(out)            :: qcindex
 logical, intent(inout)          :: log_qcpresent


 real                            :: lammin,lammax
 integer                         :: dumi



       if (qc.ge.qsmall) then

        
          nc   = max(nc,nsmall)
          mu_c = 0.0005714*(nc*1.e-6*rho)+0.2714
          mu_c = 1./(mu_c**2)-1.
          mu_c = max(mu_c,2.)
          mu_c = min(mu_c,15.)

        
          if (iparam.eq.1) then
             dumi = int(mu_c)
             nu   = dnu(dumi)+(dnu(dumi+1)-dnu(dumi))*(mu_c-dumi)
          endif

        
          lamc = (cons1*nc*(mu_c+3.)*(mu_c+2.)*(mu_c+1.)/qc)**thrd

        
          lammin = (mu_c+1.)*2.5e+4   
          lammax = (mu_c+1.)*1.e+6    

          if (lamc.lt.lammin) then
             lamc = lammin
             nc   = 6.*lamc**3*qc/(pi*rhow*(mu_c+3.)*(mu_c+2.)*(mu_c+1.))
          elseif (lamc.gt.lammax) then
             lamc = lammax
             nc   = 6.*lamc**3*qc/(pi*rhow*(mu_c+3.)*(mu_c+2.)*(mu_c+1.))
             if (.not. log_qcpresent) then
                qcindex = k
             endif
             log_qcpresent = .true.

          endif

          cdist  = nc*(mu_c+1.)/lamc
          cdist1 = nc/gamma(mu_c+1.)

       else

          lamc   = 0.
          cdist  = 0.
          cdist1 = 0.

       endif

 end subroutine get_cloud_dsd



 subroutine get_rain_dsd(qr,nr,mu_r,rdumii,dumii,lamr,mu_r_table,cdistr,logn0r, &
                         log_qrpresent,qrindex,k)



 implicit none


 real, dimension(:), intent(in)  :: mu_r_table
 real,     intent(in)            :: qr
 real,     intent(inout)         :: nr
 real,     intent(out)           :: rdumii,lamr,mu_r,cdistr,logn0r
 integer,  intent(in)            :: k
 integer,  intent(out)           :: dumii,qrindex
 logical,  intent(inout)         :: log_qrpresent


 real                            :: inv_dum,lammax,lammin



       if (qr.ge.qsmall) then

       
       

       
       
          nr      = max(nr,nsmall)
          inv_dum = (qr/(cons1*nr*6.))**thrd

          if (inv_dum.lt.282.e-6) then
             mu_r = 8.282
          elseif (inv_dum.ge.282.e-6 .and. inv_dum.lt.502.e-6) then
           
             rdumii   = (inv_dum-250.e-6)*1.e+6*0.5
             rdumii   = max(rdumii,1.)
             rdumii   = min(rdumii,150.)
             dumii    = int(rdumii)
             dumii    = min(149,dumii)
             mu_r     = mu_r_table(dumii)+(mu_r_table(dumii+1)-mu_r_table(dumii))*(rdumii-  &
                        real(dumii))
          elseif (inv_dum.ge.502.e-6) then
             mu_r = 0.
          endif

          lamr = (cons1*nr*(mu_r+3.)*(mu_r+2)*(mu_r+1.)/(qr))**thrd  
          lammax = (mu_r+1.)*1.e+5   
          lammin = (mu_r+1.)*1250.   

        
          if (lamr.lt.lammin) then
             lamr = lammin
             nr   = exp(3.*log(lamr)+log(qr)+log(gamma(mu_r+1.))-log(gamma(mu_r+4.)))/(cons1)
          elseif (lamr.gt.lammax) then
             lamr = lammax
             nr   = exp(3.*log(lamr)+log(qr)+log(gamma(mu_r+1.))-log(gamma(mu_r+4.)))/(cons1)
          endif

          if (.not. log_qrpresent) then
             qrindex = k
          endif
          log_qrpresent = .true.

          cdistr = nr/gamma(mu_r+1.)
          logn0r    = alog10(nr)+(mu_r+1.)*alog10(lamr)-alog10(gamma(mu_r+1)) 

       else

          lamr = 0.
          cdistr = 0.
          logn0r = 0.

       endif


 end subroutine get_rain_dsd



 subroutine calc_bulkRhoRime(qi_tot,qi_rim,bi_rim,rho_rime)






 implicit none


 real, intent(in)    :: qi_tot
 real, intent(inout) :: qi_rim,bi_rim
 real, intent(out)   :: rho_rime

 

 if (bi_rim.ge.1.e-15) then

    rho_rime = qi_rim/bi_rim
    
    if (rho_rime.lt.rho_rimeMin) then
       rho_rime = rho_rimeMin
       bi_rim   = qi_rim/rho_rime
    elseif (rho_rime.gt.rho_rimeMax) then
       rho_rime = rho_rimeMax
       bi_rim   = qi_rim/rho_rime
    endif
 else
    qi_rim   = 0.
    bi_rim   = 0.
    rho_rime = 0.
 endif

 
 if (qi_rim.gt.qi_tot .and. rho_rime.gt.0.) then
    qi_rim = qi_tot
    bi_rim = qi_rim/rho_rime
 endif

 
 if (qi_rim.lt.qsmall) then
    qi_rim = 0.
    bi_rim = 0.
 endif


 end subroutine calc_bulkRhoRime



 subroutine impose_max_total_Ni(nitot_local,max_total_Ni,inv_rho_local)







 implicit none


 real, intent(inout), dimension(:) :: nitot_local           
 real, intent(in)                  :: max_total_Ni,inv_rho_local


 real                              :: dum

 if (sum(nitot_local(:)).ge.1.e-20) then
    dum = max_total_Ni*inv_rho_local/sum(nitot_local(:))
    nitot_local(:) = nitot_local(:)*min(dum,1.)
 endif

 end subroutine impose_max_total_Ni




 real function qv_sat(t_atm,p_atm,i_wrt)







 implicit none

 
 real    :: t_atm  
 real    :: p_atm  
 integer :: i_wrt  

 
 real            :: e_pres         

 

 e_pres = polysvp1(t_atm,i_wrt)
 qv_sat = ep_2*e_pres/max(1.e-3,(p_atm-e_pres))

 return
 end function qv_sat



 subroutine check_values(Qv,T,Qc,Qr,Nr,Qitot,Qirim,Nitot,Birim,i,timestepcount,          &
                         check_consistency,force_abort,source_ind)

















  implicit none

 
  real, dimension(:,:),   intent(in) :: Qv,T,Qc,Qr,Nr 
  real, dimension(:,:,:), intent(in) :: Qitot,Qirim,Nitot,Birim
  integer,                intent(in) :: source_ind,i,timestepcount
  logical,                intent(in) :: force_abort         
  logical,                intent(in) :: check_consistency   

 
  real, parameter :: T_low  = 173.
  real, parameter :: T_high = 323.
  real, parameter :: Q_high = 40.e-3
  real, parameter :: N_high = 1.e+20
  real, parameter :: B_high = Q_high*1.e-3
  real, parameter :: x_high = 1.e+30
  real, parameter :: x_low  = 0.
  integer         :: k,iice,ni,nk,ncat
  logical         :: trap,badvalue_found

  nk   = size(Qitot,dim=2)
  ncat = size(Qitot,dim=3)

  trap = .false.

  k_loop: do k = 1,nk

      
        if (.not.(T(i,k)>T_low .and. T(i,k)<T_high)) then
           write(6,'(a41,4i5,1e15.6)') '** WARNING IN P3_MAIN -- src,i,k,step,T: ',      &
              source_ind,i,k,timestepcount,T(i,k)
           trap = .true.
        endif
        if (.not.(Qv(i,k)>=0. .and. Qv(i,k)<Q_high)) then
           write(6,'(a42,4i5,1e15.6)') '** WARNING IN P3_MAIN -- src,i,k,step,Qv: ',     &
              source_ind,i,k,timestepcount,Qv(i,k)

          
        endif

      
         badvalue_found = .false.





























      































  enddo k_loop

  if (trap .and. force_abort) then
     print*
     print*,'** DEBUG TRAP IN P3_MAIN, s/r CHECK_VALUES -- source: ',source_ind
     print*
     if (source_ind/=100) stop
  endif

 end subroutine check_values


 END MODULE MODULE_MP_P3   

