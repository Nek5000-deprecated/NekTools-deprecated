c-----------------------------------------------------------------------
      subroutine sphmesh
      include 'basics.inc'
      common /ctmp0/ sphctr(3),xcs(4,24),ycs(4,24),zcs(4,24)
      character*1 SHELL,HEMI,YESNO
      character*1 alphabet(52)
      character*26 alpha(2)
      equivalence (alphabet,alpha)
      save         alpha
      data         alpha 
     $      /'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'/
      logical ifpsph
c
      real xlat0(3)
C
C     Build either spherical or hemi-spherical meshes.
C
C     Modified to include stretching in X for prolate spheroird. pff 7/30/92
C
c     CALL PRS('A 6 or 24 element mesh?$')
c     CALL REI(MESH)
c
c        call get_lattice_0  (dlat,sphrad,xlat0)
c        call saddle_fcc     (dlat,sphrad,xlat0)
c        return
c
      MESH = 24
C
      CALL PRS
     $('H/W sph/hex-pkd hemi/tet/dia/lat/fcc/r12? (H/W/X/T/D/L/F/R):$')
      CALL RES(HEMI,1)
      CALL CAPIT(HEMI,1)
c
      if (hemi.eq.'t'.or.hemi.eq.'T') then
         call get_lattice_0  (dlat,sphrad,xlat0)
         call saddle_tet     (dlat,sphrad,xlat0,if_lat_sph_cent)
         return
c
      elseif (hemi.eq.'d'.or.hemi.eq.'D') then
         call get_lattice_0  (dlat,sphrad,xlat0)
         call saddle_dia     (dlat,sphrad,xlat0,if_lat_sph_cent)
         return
c
      elseif (hemi.eq.'l'.or.hemi.eq.'L') then
         call get_lattice_0  (dlat,sphrad,xlat0)
         call saddle_lat     (dlat,sphrad,xlat0)
         return
c
      elseif (hemi.eq.'f'.or.hemi.eq.'F') then
         call get_lattice_0  (dlat,sphrad,xlat0)
         call saddle_fcc     (dlat,sphrad,xlat0)
         return
c
      elseif (hemi.eq.'r'.or.hemi.eq.'R') then
         dlat = 1.
         call rzero(xlat0,3)
         call rhombic_dodec  (dlat,xlat0,if_sph_ctr)
         return
c
      endif
C
      CALL PRS('Enter the (X,Y,Z) coordinates of the center:$')
      CALL RERRR(SPHCTR(1),SPHCTR(2),SPHCTR(3))
c
      IF (HEMI.EQ.'H') THEN
         NELSPH=12
         IF (MESH.EQ.6) NELSPH=5
      ELSEIF (HEMI.EQ.'X') THEN
         NELSPH=12
         IF (MESH.EQ.6) NELSPH=5
      ELSE
c        CALL PRS('A 6 or 24 element mesh?$')
c        CALL REI(MESH)
         mesh = 24
         NELSPH=MESH
      ENDIF
      NLSPH4=4*NELSPH
C
C     PROLATE SPHEROID QUERY:
C
      IFpSPH=.FALSE.
      RATIO=1.0
      CALL PRS  ('Prolate spheroid? (Y/N):$')
      CALL RES  (YESNO,1)
      CALL CAPIT(YESNO,1)
      IF (YESNO.EQ.'Y') THEN
         IFpSPH=.TRUE.
         CALL PRS('Enter ratio:$')
         CALL RER (RATIO)
         CALL PRSR('The ratio is:$',RATIO)
      ENDIF
C
C---------------------------------------------------------------------------
C     Begin building shell sequence, working from the inner most to outer.
C---------------------------------------------------------------------------
C
      DO 6000 ISHLL=1,1000
C
         CALL PRS(
     $  'Enter S or C for a spherical or cartesian layer (E=exit):$')
         CALL RES(SHELL,1)
         CALL CAPIT(SHELL,1)
         IF (SHELL.EQ.'E') GOTO 9000
C
         IF (SHELL.EQ.'S') THEN
            CALL PRS('Enter radius:$')
            CALL RER(RADIUS)
            CALL SPHERE(XCS,YCS,ZCS,HEMI,MESH,RADIUS)
            CALL TRANS2(XCS,YCS,ZCS,SPHCTR,NLSPH4)
         ELSE
            CALL PRS(
     $     'Enter minimum distance from center to edge of the box:$')
            CALL RER(RADIUS)
            CALL CRTBOX(XCS,YCS,ZCS,HEMI,MESH,RADIUS)
            CALL TRANS2(XCS,YCS,ZCS,SPHCTR,NLSPH4)
         ENDIF
C
C        Update the elements
C
         IF (ISHLL.GT.1) NEL=NEL+NELSPH
         DO 1000 IE=1,NELSPH
C
            IEL=NEL+IE
            DO 101 I=1,4
               X(IEL,I)=XCS(I,IE)*RATIO
               Y(IEL,I)=YCS(I,IE)
               Z(IEL,I)=ZCS(I,IE)
  101       CONTINUE

            IF (SHELL.EQ.'S') THEN
               CCURVE(5,IEL)='s'
               IF (IFpSPH) CCURVE(5,IEL)='p'
               CURVE(1,5,IEL)=SPHCTR(1)
               CURVE(2,5,IEL)=SPHCTR(2)
               CURVE(3,5,IEL)=SPHCTR(3)
               CURVE(4,5,IEL)=RADIUS
               CURVE(5,5,IEL)=RATIO
            ENDIF
            IF (ISHLL.GT.1) THEN
               IEL=NEL-NELSPH+IE
               DO 201 I=1,4
                  J=I+4
                  X(IEL,J)=XCS(I,IE)*RATIO
                  Y(IEL,J)=YCS(I,IE)
                  Z(IEL,J)=ZCS(I,IE)
  201          CONTINUE
               IF (SHELL.EQ.'S') THEN
                  CCURVE(6,IEL)='s'
                  IF (IFpSPH) CCURVE(6,IEL)='p'
                  CURVE(1,6,IEL)=SPHCTR(1)
                  CURVE(2,6,IEL)=SPHCTR(2)
                  CURVE(3,6,IEL)=SPHCTR(3)
                  CURVE(4,6,IEL)=RADIUS
                  CURVE(5,6,IEL)=RATIO
               ENDIF
               NUMAPT(IEL)=ISHLL-1
               ilet = mod1(ie,52)
               LETAPT(IEL)=alphabet(ilet)
            ENDIF
 1000    CONTINUE
 6000 CONTINUE
C
 9000 CONTINUE

C     Recount the number of curved sides
C
      NCURVE=0
      DO 9001 IE=1,NEL
      DO 9001 IEDGE=1,8
         IF (CCURVE(IEDGE,IE).NE.' ') THEN
            NCURVE=NCURVE+1
            WRITE(6,*) 'Curve:',IE,IEDGE,CCURVE(IEDGE,IE)
         ENDIF
 9001 CONTINUE
C
      return
      end
c-----------------------------------------------------------------------
      subroutine sphere(xcs,ycs,zcs,hemi,mesh,radius)
      DIMENSION XCS(4,24),YCS(4,24),ZCS(4,24)
      character*1 HEMI
C
      ONE=1.0
      PI2=2.0*ATAN(ONE)
      PI =2.0*PI2
      RAD2=RADIUS/SQRT(2.0)
      RAD3=RADIUS/SQRT(3.0)
C
      IF (MESH.ne.24) THEN
         call prs('Sorry, no cubic gnomonics at this time.$')
         mesh=24
      endif
c
      IF (MESH.EQ.24) THEN
C
C        Form octant first, then replicate.
C
         XCS(1,1)=RADIUS
         YCS(1,1)=0.0
         ZCS(1,1)=0.0
C
         XCS(2,1)=RAD2
         YCS(2,1)=RAD2
         ZCS(2,1)=0.0
C
         XCS(3,1)=RAD3
         YCS(3,1)=RAD3
         ZCS(3,1)=RAD3
C
         XCS(4,1)=RAD2
         YCS(4,1)=0.0
         ZCS(4,1)=RAD2
C
         XCS(1,2)=RAD2
         YCS(1,2)=RAD2
         ZCS(1,2)=0.0
C
         XCS(2,2)=0.0
         YCS(2,2)=RADIUS
         ZCS(2,2)=0.0
C
         XCS(3,2)=0.0
         YCS(3,2)=RAD2
         ZCS(3,2)=RAD2
C
         XCS(4,2)=RAD3
         YCS(4,2)=RAD3
         ZCS(4,2)=RAD3
C
         XCS(1,3)=0.0
         YCS(1,3)=0.0
         ZCS(1,3)=RADIUS
C
         XCS(2,3)=RAD2
         YCS(2,3)=0.0
         ZCS(2,3)=RAD2
C
         XCS(3,3)=RAD3
         YCS(3,3)=RAD3
         ZCS(3,3)=RAD3
C
         XCS(4,3)=0.0
         YCS(4,3)=RAD2
         ZCS(4,3)=RAD2
C
C        Replicate octant
C
         CALL COPY(XCS(1,4),XCS(1,1),12)
         CALL COPY(YCS(1,4),YCS(1,1),12)
         CALL COPY(ZCS(1,4),ZCS(1,1),12)
         CALL ROTAT2(XCS(1,4),YCS(1,4),ZCS(1,4),12,'Z',PI2)
         IF (HEMI.EQ.'X') THEN
c
c           Modify vertices to yield hexagonal box
c
            rad32 = 0.5*radius*sqrt(3.)
            rad37 = radius*sqrt(3./7.)
            rad17 = radius*sqrt(1./7.)
            rad5  = 0.5*radius
c
            XCS(2,1)=rad5
            YCS(2,1)=RAD32
            ZCS(2,1)=0.0
C
            XCS(3,1)=RAD17
            YCS(3,1)=RAD37
            ZCS(3,1)=RAD37
C
            XCS(1,2)=rad5
            YCS(1,2)=RAD32
            ZCS(1,2)=0.0
C
            XCS(4,2)=RAD17
            YCS(4,2)=RAD37
            ZCS(4,2)=RAD37
C
            XCS(3,3)=RAD17
            YCS(3,3)=RAD37
            ZCS(3,3)=RAD37
c
            XCS(2,4)= -rad5
            YCS(2,4)=  rad32
            ZCS(2,4)=  0.0
C
            XCS(3,4)= -RAD17
            YCS(3,4)=  RAD37
            ZCS(3,4)=  RAD37
C
            XCS(1,5)= -rad5
            YCS(1,5)=  rad32
            ZCS(1,5)=  0.0
C
            XCS(4,5)= -RAD17
            YCS(4,5)=  RAD37
            ZCS(4,5)=  RAD37
C
            XCS(3,6)= -RAD17
            YCS(3,6)=  RAD37
            ZCS(3,6)=  RAD37
         ENDIF
C
C
C        Replicate quadrant
C
         CALL COPY(XCS(1,7),XCS(1,1),24)
         CALL COPY(YCS(1,7),YCS(1,1),24)
         CALL COPY(ZCS(1,7),ZCS(1,1),24)
         CALL ROTAT2(XCS(1,7),YCS(1,7),ZCS(1,7),24,'Z',PI)
         CALL ROUNDER(XCS,48)
         CALL ROUNDER(YCS,48)
         CALL ROUNDER(ZCS,48)
         IF (HEMI.EQ.'W') THEN
C
C           Replicate hemisphere
C
            CALL COPY(XCS(1,13),XCS(1,1),48)
            CALL COPY(YCS(1,13),YCS(1,1),48)
            CALL COPY(ZCS(1,13),ZCS(1,1),48)
            CALL ROTAT2(XCS(1,13),YCS(1,13),ZCS(1,13),48,'X',PI)
            CALL ROUNDER(XCS(1,13),48)
            CALL ROUNDER(YCS(1,13),48)
            CALL ROUNDER(ZCS(1,13),48)
         ENDIF
c     ELSE
C
C        We mesh the 6 element configuration here
C
      ENDIF
      return
      end
c-----------------------------------------------------------------------
      subroutine crtbox(xcs,ycs,zcs,hemi,mesh,radius)
      DIMENSION XCS(4,24),YCS(4,24),ZCS(4,24)
      character*1 HEMI
C
      ONE=1.0
      PI2=2.0*ATAN(ONE)
      PI =2.0*PI2
      RAD2=RADIUS
      RAD3=RADIUS
C
      IF (MESH.EQ.24) THEN
C
C        Form octant first, then replicate.
C
         XCS(1,1)=RADIUS
         YCS(1,1)=0.0
         ZCS(1,1)=0.0
C
         XCS(2,1)=RAD2
         YCS(2,1)=RAD2
         ZCS(2,1)=0.0
C
         XCS(3,1)=RAD3
         YCS(3,1)=RAD3
         ZCS(3,1)=RAD3
C
         XCS(4,1)=RAD2
         YCS(4,1)=0.0
         ZCS(4,1)=RAD2
C
         XCS(1,2)=RAD2
         YCS(1,2)=RAD2
         ZCS(1,2)=0.0
C
         XCS(2,2)=0.0
         YCS(2,2)=RADIUS
         ZCS(2,2)=0.0
C
         XCS(3,2)=0.0
         YCS(3,2)=RAD2
         ZCS(3,2)=RAD2
C
         XCS(4,2)=RAD3
         YCS(4,2)=RAD3
         ZCS(4,2)=RAD3
C
         XCS(1,3)=0.0
         YCS(1,3)=0.0
         ZCS(1,3)=RADIUS
C
         XCS(2,3)=RAD2
         YCS(2,3)=0.0
         ZCS(2,3)=RAD2
C
         XCS(3,3)=RAD3
         YCS(3,3)=RAD3
         ZCS(3,3)=RAD3
C
         XCS(4,3)=0.0
         YCS(4,3)=RAD2
         ZCS(4,3)=RAD2
C
C        Replicate octant
C
         CALL COPY(XCS(1,4),XCS(1,1),12)
         CALL COPY(YCS(1,4),YCS(1,1),12)
         CALL COPY(ZCS(1,4),ZCS(1,1),12)
         CALL ROTAT2(XCS(1,4),YCS(1,4),ZCS(1,4),12,'Z',PI2)
c
         IF (HEMI.EQ.'X') THEN
c
c           Modify vertices to yield hexagonal box
c
            rad13 =    radius/sqrt(3.)
            rad23 = 2.*radius/sqrt(3.)
c
            XCS(1,1)=rad23
            XCS(2,1)=rad13
            XCS(3,1)=rad13
            XCS(4,1)=rad23
C
            XCS(1,2)=rad13
            XCS(4,2)=rad13
C
            XCS(2,3)=rad23
            XCS(3,3)=rad13
c
            XCS(2,4)= -rad13
            XCS(3,4)= -rad13
C
            XCS(1,5)= -rad13
            XCS(2,5)= -rad23
            XCS(3,5)= -rad23
            XCS(4,5)= -rad13
C
            XCS(3,6)= -rad13
            XCS(4,6)= -rad23
C
         ENDIF
C
C
C        Replicate quadrant
C
         CALL COPY(XCS(1,7),XCS(1,1),24)
         CALL COPY(YCS(1,7),YCS(1,1),24)
         CALL COPY(ZCS(1,7),ZCS(1,1),24)
         CALL ROTAT2(XCS(1,7),YCS(1,7),ZCS(1,7),24,'Z',PI)
         CALL ROUNDER(XCS,48)
         CALL ROUNDER(YCS,48)
         CALL ROUNDER(ZCS,48)
         IF (HEMI.EQ.'W') THEN
C
C           Replicate hemisphere
C
            CALL COPY(XCS(1,13),XCS(1,1),48)
            CALL COPY(YCS(1,13),YCS(1,1),48)
            CALL COPY(ZCS(1,13),ZCS(1,1),48)
            CALL ROTAT2(XCS(1,13),YCS(1,13),ZCS(1,13),48,'X',PI)
            CALL ROUNDER(XCS(1,13),48)
            CALL ROUNDER(YCS(1,13),48)
            CALL ROUNDER(ZCS(1,13),48)
         ENDIF
c     ELSE
C
C        We mesh the 6 element configuration here
C
      ENDIF
      return
      end
c-----------------------------------------------------------------------
      subroutine rotat2(x,y,z,n,dir,angle)
C
      DIMENSION X(1),Y(1),Z(1)
      character*1 DIR
      DIMENSION ROTAT(3,3)
C
      CALL RZERO(ROTAT,9)
      COSANG=COS(ANGLE)
      SINANG=SIN(ANGLE)
C
      IF (DIR.EQ.'X') THEN
         ROTAT(1,1) =   1.0
         ROTAT(2,2) =   COSANG
         ROTAT(3,3) =   COSANG
         ROTAT(2,3) = - SINANG
         ROTAT(3,2) =   SINANG
      ENDIF
C
      IF (DIR.EQ.'Y') THEN
         ROTAT(1,1) =   COSANG
         ROTAT(2,2) =   1.0
         ROTAT(3,3) =   COSANG
         ROTAT(1,3) =   SINANG
         ROTAT(3,1) = - SINANG
      ENDIF
C
      IF (DIR.EQ.'Z') THEN
         ROTAT(1,1) =   COSANG
         ROTAT(2,2) =   COSANG
         ROTAT(3,3) =   1.0
         ROTAT(1,2) = - SINANG
         ROTAT(2,1) =   SINANG
      ENDIF
C
      DO 100 I=1,N
         XP=ROTAT(1,1)*X(I)+ROTAT(1,2)*Y(I)+ROTAT(1,3)*Z(I)
         YP=ROTAT(2,1)*X(I)+ROTAT(2,2)*Y(I)+ROTAT(2,3)*Z(I)
         ZP=ROTAT(3,1)*X(I)+ROTAT(3,2)*Y(I)+ROTAT(3,3)*Z(I)
         X(I)=XP
         Y(I)=YP
         Z(I)=ZP
  100 CONTINUE
      return
      end
c-----------------------------------------------------------------------
      subroutine rounder(x,n)
      DIMENSION X(1)
C
C     Try to Round X to fractional integer - eg .05 .1 .15 - if it's within 10-6
C
      DO 100 I=1,N
         EPS=1.0E-5
         XTMP=20.0*X(I)
         XTMP2=XTMP+0.5
         ITMP=INT(XTMP2)
         XTMP2=FLOAT(ITMP)
         IF (ABS(XTMP-XTMP2).LT.EPS) X(I)=XTMP2/20.0
  100 CONTINUE
      return
      end
c-----------------------------------------------------------------------
      subroutine trans2(x,y,z,xyzoff,n)
      DIMENSION X(1),Y(1),Z(1)
      DIMENSION XYZOFF(3)
C
      DO 10 I=1,N
         X(I)=X(I)+XYZOFF(1)
         Y(I)=Y(I)+XYZOFF(2)
         Z(I)=Z(I)+XYZOFF(3)
   10 CONTINUE
      return
      end
c-----------------------------------------------------------------------
      subroutine genmesh
      include 'basics.inc'
C
      common /ctmp0/ sphctr(3),xcs(4,24),ycs(4,24),zcs(4,24)
      DIMENSION CUBE(3,8),CANON(3,8),XCTR(15),YCTR(15),XYZCTR(3)
      DIMENSION ANG(2,15)
      DIMENSION IANG(2,15)
      SAVE ANG,XCTR,YCTR,CANON
      SAVE IANG
C
      DATA CANON/
     $ -1.,-1.,-1.,    1.,-1.,-1.,    1., 1.,-1.,   -1., 1.,-1.  ,
     $ -1.,-1., 1.,    1.,-1., 1.,    1., 1., 1.,   -1., 1., 1.  /
C
      DATA XCTR/ 1.0 , 3.0 , 5.0 , 7.0 , 9.0
     $         , 1.0 , 3.0 , 5.0 , 7.0 , 9.0
     $         , 1.0 , 3.0 , 5.0 , 7.0 , 9.0 /
C
      DATA YCTR/ 1.0 , 1.0 , 1.0 , 1.0 , 1.0  
     $         , 3.0 , 3.0 , 3.0 , 3.0 , 3.0  
     $         , 5.0 , 5.0 , 5.0 , 5.0 , 5.0 /
C
      DATA IANG/ 0,0 , 0,0 , 0,1 , 0,3 , 0,6
     $         , 2,0 , 0,0 , 2,0 , 0,1 , 2,2
     $         , 2,0 , 0,2 , 2,4 , 0,7 , 2,10 /
C
C
      ONE=1.0
      PI2=2.0*ATAN(ONE)
      PI =2.0*PI2
      DO 10 I=1,30
         ANG(I,1)=PI2*FLOAT(IANG(I,1))
   10 CONTINUE
C
      DO 1000 ILVEL=1,3
         ILEVEL=ILVEL
         write(6,*) 'generating level',ilevel
         ZCTR=1.0+2.0*FLOAT(ILEVEL-1)
         DO 100 III=1,15
            CALL COPY(CUBE,CANON,24)
            IF (ILEVEL.EQ.2) CALL ROTATE(CUBE,8,'Y',PI2)
            IF (ILEVEL.EQ.3) CALL ROTATE(CUBE,8,'Z',PI2)
            CALL ROTATE(CUBE,8,'Z',ANG(1,III))
            CALL ROTATE(CUBE,8,'X',ANG(2,III))
            XYZCTR(1)=XCTR(III)
            XYZCTR(2)=YCTR(III)
            XYZCTR(3)=ZCTR
            CALL TRANSL(CUBE,XYZCTR,8)
            CALL GENELE(CUBE)
         write(6,*) ilvel,iii,'element',nel,' created'
         write(8,*) ilvel,iii,'element',nel,' created'
  100    CONTINUE
 1000 CONTINUE
      return
      end
c-----------------------------------------------------------------------
      subroutine genele(xyz)
      DIMENSION XYZ(3,8)
      include 'basics.inc'
C
      NEL=NEL+1
      DO 10 I=1,8
         X(NEL,I)=XYZ(1,I)
         Y(NEL,I)=XYZ(2,I)
         Z(NEL,I)=XYZ(3,I)
   10 CONTINUE
      NUMAPT(NEL)=ILEVEL
      LETAPT(NEL)='A'
      return
      end
c-----------------------------------------------------------------------
      subroutine rotate(xyz,n,dir,angle)
C
      DIMENSION XYZ(3,1)
      character*1 DIR
      DIMENSION ROTAT(3,3)
C
      CALL RZERO(ROTAT,9)
      COSANG=COS(ANGLE)
      SINANG=SIN(ANGLE)
C
      IF (DIR.EQ.'X') THEN
         ROTAT(1,1) =   1.0
         ROTAT(2,2) =   COSANG
         ROTAT(3,3) =   COSANG
         ROTAT(2,3) = - SINANG
         ROTAT(3,2) =   SINANG
      ENDIF
C
      IF (DIR.EQ.'Y') THEN
         ROTAT(1,1) =   COSANG
         ROTAT(2,2) =   1.0
         ROTAT(3,3) =   COSANG
         ROTAT(1,3) =   SINANG
         ROTAT(3,1) = - SINANG
      ENDIF
C
      IF (DIR.EQ.'Z') THEN
         ROTAT(1,1) =   COSANG
         ROTAT(2,2) =   COSANG
         ROTAT(3,3) =   1.0
         ROTAT(1,2) = - SINANG
         ROTAT(2,1) =   SINANG
      ENDIF
C
      DO 100 I=1,N
         XP=ROTAT(1,1)*XYZ(1,I)+ROTAT(1,2)*XYZ(2,I)+ROTAT(1,3)*XYZ(3,I)
         YP=ROTAT(2,1)*XYZ(1,I)+ROTAT(2,2)*XYZ(2,I)+ROTAT(2,3)*XYZ(3,I)
         ZP=ROTAT(3,1)*XYZ(1,I)+ROTAT(3,2)*XYZ(2,I)+ROTAT(3,3)*XYZ(3,I)
         XYZ(1,I)=XP
         XYZ(2,I)=YP
         XYZ(3,I)=ZP
  100 CONTINUE
      return
      end
c-----------------------------------------------------------------------
      subroutine transl(xyz,xyzoff,n)
      DIMENSION XYZ(3,1)
      DIMENSION XYZOFF(3)
C
      DO 10 I=1,N
         XYZ(1,I)=XYZ(1,I)+XYZOFF(1)
         XYZ(2,I)=XYZ(2,I)+XYZOFF(2)
         XYZ(3,I)=XYZ(3,I)+XYZOFF(3)
   10 CONTINUE
      return
      end
c-----------------------------------------------------------------------
      subroutine get_lattice_0  (d,r,x)
c
      real x(3)
c
      call prs ('Input lattice spacing, d, and radius r < d/2:$')
      call rerr(d,r)
c
      call prs ('Input coordinates for 1st sphere or lattice ctr:$')
      call rerrr(x(1),x(2),x(3))
c
      return
      end
c-----------------------------------------------------------------------
      subroutine get_vert_lattice(x,d,x0)
c
c     Get vertices for 8-noded 3D rombus that forms a periodic
c     cell for hexagonally close packed spheres
c
c     x(:,1)=x0, and x(:,2)=x0+d
c
      real x(3,8),x0(3)
      real t(3,4)
c
      call get_vert_tet(t,d,x0) ! Base tet
c
      z1 = t(3,4)
c
      call copy(x,t,3*3)
      call copy(x(1,5),t(1,4),3)
c
      x(1,4) = x(1,3) + d
      x(2,4) = x(2,3)
      x(3,4) = x(3,3)
c
      x(1,6) = x(1,5) + d
      x(2,6) = x(2,5)
      x(3,6) = x(3,5)
c
      dy = x(2,3) - x(2,1)
c
      x(1,7) = x(1,2)
      x(2,7) = x(2,5) + dy
      x(3,7) = x(3,5)
c
      x(1,8) = x(1,7) + d
      x(2,8) = x(2,7)
      x(3,8) = x(3,7)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine permute_dia(x,p)
c
c     permute vertices for diamond
c
c     Input / Output diamonds oriented as follows:
c
c
c         Y                 6
c                          / \                 
c         ^            3 ./ . \. 1               INPUT
c         |             ./     \.              
c         |            2---------4
c         |               .   .                
c         |                 5
c         +-------> X
c
c
c         Y                 F
c                          / \                 
c         ^            c ./ . \. b               OUTPUT
c         |             ./     \.              
c         |            D---------E
c         |               .   .                
c         |                 a
c         +-------> X
c
c
c
c
      real x(3,6),p(3,6)
      character*1 blah
c
      call copy(x(1,2),p(1,1),3)
      call copy(x(1,4),p(1,2),3)
      call copy(x(1,3),p(1,3),3)
      call copy(x(1,5),p(1,4),3)
      call copy(x(1,1),p(1,5),3)
      call copy(x(1,6),p(1,6),3)
c
      call outmat(p,3,6,'before',1)
      call outmat(x,3,6,'permut',1)
      call prs('LOOK at window$')
      call res(blah,1)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine get_vert_dia(x,d,x0)
c
c     Get vertices for a diamond with lattice spacing d
c
c     Equilateral diamond is oriented as follows:
c
c
c
c         Y                 F
c                          / \                 
c         ^            c ./ . \. b
c         |             ./     \.              
c         |            D---------E
c         |               .   .                
c         |                 a
c         +-------> X
c
c
c     Here, x1=a, x2=b, etc., and "a=x0" is the prescribed input.
c
c     Lower case letters indicate vertices on the z=0 plane.
c
c     Upper case on the upper Z-plane
c
c     Separation (e.g., E-D) is d.
c
      real x0(3)
      real xs(3),x(3,6),p(3,8)
c
      call copy(xs,x0,3)
      xs(1) = x0(1) - d
      call get_vert_lattice(p,d,xs)
c
      call copy(x(1,1),p(1,2),3)
      call copy(x(1,2),p(1,4),3)
      call copy(x(1,3),p(1,3),3)
      call copy(x(1,4),p(1,5),3)
      call copy(x(1,5),p(1,6),3)
      call copy(x(1,6),p(1,7),3)
c
      write(6,*)
      do k=1,6
         write(6,1) k,(x(i,k),i=1,3)
      enddo
      write(6,*)
    1 format(i3,1p3e12.4,'   dia')
c
      return
      end
c-----------------------------------------------------------------------
      subroutine get_vert_fcc_lat(p,d,c0)
c
c     Get vertices for an fcc lattice with spacing d, ctr. c0:
c
c
      real p(3,8,2),c0(3)
      real x0(3)
c
      d2 = d/2
      do i=1,3
         x0(i) = c0(i) - d2
      enddo
c
      l = 0
      do k=0,1
      do j=0,1
      do i=0,1
         l = l+1
         p(1,l,1) = x0(1) + d*i
         p(2,l,1) = x0(2) + d*j
         p(3,l,1) = x0(3) + d*k
      enddo
      enddo
      enddo
c
      do k=1,6
         call copy(p(1,k,2),c0,3)
      enddo
c
      l = 0
      do k=1,3
      do i=-1,1,2
         l = l+1
         p(k,l,2) = c0(k) + d2*i
      enddo
      enddo
c
      return
      end
c-----------------------------------------------------------------------
      subroutine get_vert_tet(x,d,x0)
c
c     Get vertices for a tet with lattice spacing d
c
c     x(:,1) is presumed known, and x(:,2) is on the "x-axis"
c
      real x0(3)
      real x(3,4)
c
      x(1,1) = 0                    +  x0(1)
      x(2,1) = 0                    +  x0(2)
      x(3,1) = 0                    +  x0(3)
c
      x(1,2) = d                    +  x0(1)
      x(2,2) = 0                    +  x0(2)
      x(3,2) = 0                    +  x0(3)
c
      x3     = 3
      x(1,3) = d*.5                 +  x0(1)
      x(2,3) = d*.5*sqrt(x3)        +  x0(2)
      x(3,3) = 0                    +  x0(3)
c
      one    = 1.
      pi6    = 4.*atan(one)/6.
      y3     = .5*tan(pi6)
      z3     = 1 - .25 - y3*y3
      z3     = sqrt(z3)
c
      x(1,4) = d*.5                 +  x0(1)
      x(2,4) = d*y3                 +  x0(2)
      x(3,4) = d*z3                 +  x0(3)
c
      write(6,*)
      do k=1,4
         write(6,1) k,(x(i,k),i=1,3)
      enddo
      write(6,*)
    1 format(i3,1p3e12.4,'   tets')
c
      return
      end
c-----------------------------------------------------------------------
      subroutine sdl_element_dia(v,xdia,rad)
c
c     Update SEM element data for diamond saddle
c
      include 'basics.inc'
      real v(3,8,24),xdia(3,6)
c
      integer e
      integer e2pfv(8)
      save    e2pfv
      data    e2pfv / 1 , 2 ,4 ,3 ,5 ,6 ,8 ,7 /
c
      character*1 alphabet(52)
      character*26 alpha(2)
      equivalence (alphabet,alpha)
      save         alpha
      data         alpha 
     $      /'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'/
c
      k = 0
      do idia=1,6
      do itel=1,4
         k = k+1
         e = nel+k
         do i=1,8
            j      = e2pfv(i)
            x(e,i) = v(1,j,k)
            y(e,i) = v(2,j,k)
            z(e,i) = v(3,j,k)
         enddo
c
         ccurve(5,e)   = 's'
         curve (1,5,e) = xdia(1,idia)
         curve (2,5,e) = xdia(2,idia)
         curve (3,5,e) = xdia(3,idia)
         curve (4,5,e) = rad
         curve (5,5,e) = 0.
c
         if (if_lat_sph_cent) call rzero(curve(1,5,e),3)
c
         cbc   (5,e,1) = 'v  '
         cbc   (5,e,2) = 'f  '  ! flux bc as default for Temperature
c
         call rzero(bc(1,5,e,1),5)
         call rzero(bc(1,5,e,2),5)
c
         ilet      = mod1(e,52)
         letapt(e) = alphabet(ilet)
         numapt(e) = 1
c
      enddo
      enddo
c
      nel = nel+24
c
      return
      end
c-----------------------------------------------------------------------
      subroutine sdl_element_tet(v,xtet,rad)
c
c     Update SEM element data for tet saddle
c
      include 'basics.inc'
      real v(3,8,12),xtet(3,4)
c
      integer e
      integer e2pfv(8)
      save    e2pfv
      data    e2pfv / 1 , 2 ,4 ,3 ,5 ,6 ,8 ,7 /
c
      character*1 alphabet(52)
      character*26 alpha(2)
      equivalence (alphabet,alpha)
      save         alpha
      data         alpha 
     $      /'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'/
c
      k = 0
      do itet=1,4
      do itel=1,3
         k = k+1
         e = nel+k
         do i=1,8
            j      = e2pfv(i)
            x(e,i) = v(1,j,k)
            y(e,i) = v(2,j,k)
            z(e,i) = v(3,j,k)
         enddo
c
         ccurve(5,e)   = 's'
         curve (1,5,e) = xtet(1,itet)
         curve (2,5,e) = xtet(2,itet)
         curve (3,5,e) = xtet(3,itet)
         curve (4,5,e) = rad
         curve (5,5,e) = 0.
         if (if_lat_sph_cent) call rzero(curve(1,5,e),3)
c
         cbc   (5,e,1) = 'v  '
         cbc   (5,e,2) = 'f  '  ! flux bc as default for Temperature
c
         call rzero(bc(1,5,e,1),5)
         call rzero(bc(1,5,e,2),5)
c
         ilet      = mod1(e,52)
         letapt(e) = alphabet(ilet)
         numapt(e) = 1
c
      enddo
      enddo
c
      nel = nel+12
c
      return
      end
c-----------------------------------------------------------------------
      subroutine build_tet_saddle(v,xi,d,r,if_sph_ctr)
c
c     Build a saddle to fill the void between 4 spheres of radius r
c     situated at the vertices of a regular tet with distance d.
c
c     For now, assume that sphere 1 and 2 are separated along the x-axis.
c
      real v(3*8,12),xi(3,4)
      logical if_sph_ctr
c
      real x(3,4)
      integer e
      character*80 s
c
      call copy(x,xi,12)
      vol = tet_chk(xi)
      if (vol.lt.0) then
         write(6,*) 'in build.tet.saddle',vol
         call copy(x(1,1),xi(1,2),3)
         call copy(x(1,2),xi(1,1),3)
      endif
c
      c1 = ( x(1,1)+x(1,2)+x(1,3)+x(1,4) )/4
      c2 = ( x(2,1)+x(2,2)+x(2,3)+x(2,4) )/4
      c3 = ( x(3,1)+x(3,2)+x(3,3)+x(3,4) )/4
c
      write(s,1) c1,c2,c3,d,r
    1 format('Tet Ctr:',3g12.4,', Latt., R:',2g12.4,'$')
      call prs(s)
c
c     12 elements
c
      e = 0
      if (if_sph_ctr) call shift_xyz(x,x(1,1),4)
      call tet_saddle_element(v(1,e+1),x(1,1),x(1,2),x(1,3),x(1,4),r)
      call tet_saddle_element(v(1,e+2),x(1,1),x(1,4),x(1,2),x(1,3),r)
      call tet_saddle_element(v(1,e+3),x(1,1),x(1,3),x(1,4),x(1,2),r)
c
      e = e+3  ! Need a-cyclic permutation here
      if (if_sph_ctr) call shift_xyz(x,x(1,2),4)
      call tet_saddle_element(v(1,e+1),x(1,2),x(1,4),x(1,3),x(1,1),r)
      call tet_saddle_element(v(1,e+2),x(1,2),x(1,1),x(1,4),x(1,3),r)
      call tet_saddle_element(v(1,e+3),x(1,2),x(1,3),x(1,1),x(1,4),r)
c
      e = e+3
      if (if_sph_ctr) call shift_xyz(x,x(1,3),4)
      call tet_saddle_element(v(1,e+1),x(1,3),x(1,4),x(1,1),x(1,2),r)
      call tet_saddle_element(v(1,e+2),x(1,3),x(1,2),x(1,4),x(1,1),r)
      call tet_saddle_element(v(1,e+3),x(1,3),x(1,1),x(1,2),x(1,4),r)
c
      e = e+3  ! Need a-cyclic permutation here
      if (if_sph_ctr) call shift_xyz(x,x(1,4),4)
      call tet_saddle_element(v(1,e+1),x(1,4),x(1,3),x(1,2),x(1,1),r)
      call tet_saddle_element(v(1,e+2),x(1,4),x(1,1),x(1,3),x(1,2),r)
      call tet_saddle_element(v(1,e+3),x(1,4),x(1,2),x(1,1),x(1,3),r)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine tet_saddle_element(v,x1,x2,x3,x4,r)
c
c     Build a single element, situated on sph1, connecting to sph2
c
      real v(3,8),x1(3),x2(3),x3(3),x4(3),w(3,8)
      logical ifnonsym
c
      do i=1,3 
         v(i,5) = (x1(i)+x2(i)+x3(i)+x4(i))/4
         v(i,6) = (x1(i)+x2(i)+x4(i))/3
         v(i,7) = (x1(i)+x2(i)+x3(i))/3
         v(i,8) = (x1(i)+x2(i))/2
      enddo
c
      do k=1,4 
         call sub3 (v(1,k),v(1,k+4),x1,3)
         vnrm = vlsc2(v(1,k),v(1,k),3)
         vnrm = r/sqrt(vnrm)
         call cmult(v(1,k),vnrm,3)
         call add2 (v(1,k),x1,3)
      enddo
c
      ifnonsym = .true.
      if (ifnonsym) then  ! correction for non-regular tet
         call copy(w(1,6),v(1,6),3)
         call copy(w(1,7),v(1,7),3)
         call non_reg_tet_mod(v(1,7),x1,x2,x3,r)
         call non_reg_tet_mod(v(1,6),x1,x2,x4,r)
c
         do k=2,3 
            h  = .5
            call add2 (w(1,k+4),v(1,k+4),3)
            call cmult(w(1,k+4),h,3)
            call sub3 (v(1,k),w(1,k+4),x1,3)
            vnrm = vlsc2(v(1,k),v(1,k),3)
            vnrm = r/sqrt(vnrm)
            call cmult(v(1,k),vnrm,3)
            call add2 (v(1,k),x1,3)
         enddo
      endif
c
      write(6,*)
      do k=1,8
         write(6,1) k,(v(i,k),i=1,3)
      enddo
      write(6,*)
    1 format(i3,1p3e12.4,'   saddle')
c
      return
      end
c-----------------------------------------------------------------------
      subroutine dia_sdle(v,x1,x2,x3,x4,x5,x6,r)
c
c     Build a single element, situated on sph1, connecting to sph2
c
      real v(3,8),x1(3),x2(3),x3(3),x4(3),x5(3),x6(3)
c
      do i=1,3 
         v(i,5) = (x1(i)+x2(i)+x3(i)+x4(i)+x5(i)+x6(i))/6
         v(i,6) = (x1(i)+x2(i)+x5(i))/3
         v(i,7) = (x1(i)+x2(i)+x3(i))/3
         v(i,8) = (x1(i)+x2(i))/2
      enddo
c
      do k=1,4 
         call sub3 (v(1,k),v(1,k+4),x1,3)
         vnrm = vlsc2(v(1,k),v(1,k),3)
         vnrm = r/sqrt(vnrm)
         call cmult(v(1,k),vnrm,3)
         call add2 (v(1,k),x1,3)
      enddo
c
      write(6,*)
      do k=1,8
         write(6,1) k,(v(i,k),i=1,3),r
      enddo
      write(6,*)
    1 format(i3,1p4e12.4,' dia saddle')
c
      return
      end
c-----------------------------------------------------------------------
      subroutine build_dia_saddle(v,xi,d,r,if_sph_ctr)
c
c     Build a saddle to fill the void between 4 spheres of radius r
c     situated at the vertices of a regular diamond with distance d.
c
c     For now, assume that sphere 1 and 2 are separated along the x-axis.
c
      real v(3*8,24),xi(3,6)
      logical if_sph_ctr
c
      real x(3,6)
      integer e,face
      character*80 s
c
      call copy(x,xi,18)
c
      c1 = ( x(1,1)+x(1,2)+x(1,3)+x(1,4)+x(1,5)+x(1,6) )/6
      c2 = ( x(2,1)+x(2,2)+x(2,3)+x(2,4)+x(2,5)+x(2,6) )/6
      c3 = ( x(3,1)+x(3,2)+x(3,3)+x(3,4)+x(3,5)+x(3,6) )/6
c
      write(s,1) c1,c2,c3,d,r
    1 format('DIA Ctr:',3g12.4,', Latt., R:',2g12.4,'$')
      call prs(s)
c
c
c     24 elements, 4 for each of 6 nodes
c
      if (if_sph_ctr) call shift_xyz(x,x(1,1),6)
      call dia_sdle(v(1, 1),x(1,1),x(1,2),x(1,3),x(1,4),x(1,5),x(1,6),r)
      call dia_sdle(v(1, 2),x(1,1),x(1,5),x(1,2),x(1,3),x(1,4),x(1,6),r)
      call dia_sdle(v(1, 3),x(1,1),x(1,4),x(1,5),x(1,2),x(1,3),x(1,6),r)
      call dia_sdle(v(1, 4),x(1,1),x(1,3),x(1,4),x(1,5),x(1,2),x(1,6),r)
c
      if (if_sph_ctr) call shift_xyz(x,x(1,2),6)
      call dia_sdle(v(1, 5),x(1,2),x(1,3),x(1,1),x(1,5),x(1,6),x(1,4),r)
      call dia_sdle(v(1, 6),x(1,2),x(1,6),x(1,3),x(1,1),x(1,5),x(1,4),r)
      call dia_sdle(v(1, 7),x(1,2),x(1,5),x(1,6),x(1,3),x(1,1),x(1,4),r)
      call dia_sdle(v(1, 8),x(1,2),x(1,1),x(1,5),x(1,6),x(1,3),x(1,4),r)
c
      if (if_sph_ctr) call shift_xyz(x,x(1,3),6)
      call dia_sdle(v(1, 9),x(1,3),x(1,4),x(1,1),x(1,2),x(1,6),x(1,5),r)
      call dia_sdle(v(1,10),x(1,3),x(1,6),x(1,4),x(1,1),x(1,2),x(1,5),r)
      call dia_sdle(v(1,11),x(1,3),x(1,2),x(1,6),x(1,4),x(1,1),x(1,5),r)
      call dia_sdle(v(1,12),x(1,3),x(1,1),x(1,2),x(1,6),x(1,4),x(1,5),r)
c
      if (if_sph_ctr) call shift_xyz(x,x(1,4),6)
      call dia_sdle(v(1,13),x(1,4),x(1,5),x(1,1),x(1,3),x(1,6),x(1,2),r)
      call dia_sdle(v(1,14),x(1,4),x(1,6),x(1,5),x(1,1),x(1,3),x(1,2),r)
      call dia_sdle(v(1,15),x(1,4),x(1,3),x(1,6),x(1,5),x(1,1),x(1,2),r)
      call dia_sdle(v(1,16),x(1,4),x(1,1),x(1,3),x(1,6),x(1,5),x(1,2),r)
c
      if (if_sph_ctr) call shift_xyz(x,x(1,5),6)
      call dia_sdle(v(1,17),x(1,5),x(1,2),x(1,1),x(1,4),x(1,6),x(1,3),r)
      call dia_sdle(v(1,18),x(1,5),x(1,6),x(1,2),x(1,1),x(1,4),x(1,3),r)
      call dia_sdle(v(1,19),x(1,5),x(1,4),x(1,6),x(1,2),x(1,1),x(1,3),r)
      call dia_sdle(v(1,20),x(1,5),x(1,1),x(1,4),x(1,6),x(1,2),x(1,3),r)
c
      if (if_sph_ctr) call shift_xyz(x,x(1,6),6)
      call dia_sdle(v(1,21),x(1,6),x(1,2),x(1,5),x(1,4),x(1,3),x(1,1),r)
      call dia_sdle(v(1,22),x(1,6),x(1,3),x(1,2),x(1,5),x(1,4),x(1,1),r)
      call dia_sdle(v(1,23),x(1,6),x(1,4),x(1,3),x(1,2),x(1,5),x(1,1),r)
      call dia_sdle(v(1,24),x(1,6),x(1,5),x(1,4),x(1,3),x(1,2),x(1,1),r)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine saddle_tet(d,rad,x0,if_sph_ctr)
c
c     Build the void between 4 spheres on a regular tet lattice
c
      real x0(3)
      real v(3,8,12),x(3,4)
      logical if_sph_ctr
c
      call get_vert_tet     (x,d,x0)
      call build_tet_saddle (v,x,d,rad,if_sph_ctr)
      call sdl_element_tet  (v,x,rad)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine saddle_dia(d,rad,x0,if_sph_ctr)
c
c     Build the void between 6 spheres on a regular diamond lattice
c
      real x0(3)
      real v(3,8,24),x(3,6)
      logical if_sph_ctr
c
      call get_vert_dia     (x,d,x0)
      call build_dia_saddle (v,x,d,rad,if_sph_ctr)
      call sdl_element_dia  (v,x,rad)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine saddle_lat(d,rad,x0)
c
c     Build the void between 8 spheres on a regular diamond lattice
c
      include 'basics.inc'
      real x0(3)
      real v(3,8,48),p(3,8),q(3,8)  ! 48 elements total (12 + 24 + 12)
      real a0(3)
c
      call rzero(a0,3)  ! put first sphere at (0,0,0)
      call get_vert_lattice (p,d,a0)
c
      do i=1,8                  ! center point of lattice
         a0(1) = a0(1) + p(1,i)/8
         a0(2) = a0(2) + p(2,i)/8
         a0(3) = a0(3) + p(3,i)/8
      enddo
      call sub2(a0,x0,3)
      call shift_xyz(p,a0,8)    ! p = p - a0
c
      call prs ('Enter s/v for sphere- or void-centric mesh:$')
      call res(ans,1)
      if_lat_sph_cent = .true.  ! Build sphere-centric mesh
      if (ans.eq.'v'.or.ans.eq.'V') if_lat_sph_cent = .false.
c
      call copy(q(1,1),p(1,1),3)  ! 1st Tet
      call copy(q(1,2),p(1,2),3)
      call copy(q(1,3),p(1,3),3)
      call copy(q(1,4),p(1,5),3)
      call build_tet_saddle(v(1,1, 1),q,d,rad,if_lat_sph_cent)
      call sdl_element_tet (v(1,1, 1),q,rad)
c
      if_lattice = .true.                   ! Store unit lattice vectors
      call sub3   (ulat1,q(1,2),q(1,1),3)   ! -- needed for periodic bcs
      call norm3d (ulat1)
      call sub3   (ulat2,q(1,3),q(1,1),3)
      call norm3d (ulat2)
      call sub3   (ulat3,q(1,4),q(1,1),3)
      call norm3d (ulat3)
c
      call copy(q(1,1),p(1,2),3)  ! Diamond
      call copy(q(1,2),p(1,4),3)
      call copy(q(1,3),p(1,3),3)
      call copy(q(1,4),p(1,5),3)
      call copy(q(1,5),p(1,6),3)
      call copy(q(1,6),p(1,7),3)
      call build_dia_saddle(v(1,1,13),q,d,rad,if_lat_sph_cent)
      call sdl_element_dia (v(1,1,13),q,rad)
c
      call copy(q(1,1),p(1,4),3)  ! 1st Tet
      call copy(q(1,2),p(1,6),3)
      call copy(q(1,3),p(1,8),3)
      call copy(q(1,4),p(1,7),3)
      call build_tet_saddle(v(1,1,37),q,d,rad,if_lat_sph_cent)
      call sdl_element_tet (v(1,1,37),q,rad)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine get_lattice_per_bc
c
c     This routine will define the unit-lattice direction vectors
c     (ulat_k, k=1,...,3) that are used to determine coincidence
c     of periodic boundaries.
c
c
      include 'basics.inc'
c
      real x0(3),q(3,4)
c
      call prs ('Is this a lattice for hex-close-packed spheres?:$')
      call res(ans,1)
c
      if (ans.eq.'n'.or.ans.eq.'N') return
      call rzero(x0,3)
      dlat = 1.
      call get_vert_tet(q,dlat,x0) ! Base tet
c
      if_lattice = .true.                   ! Store unit lattice vectors
      call sub3   (ulat1,q(1,2),q(1,1),3)   ! -- needed for periodic bcs
      call norm3d (ulat1)
      call sub3   (ulat2,q(1,3),q(1,1),3)
      call norm3d (ulat2)
      call sub3   (ulat3,q(1,4),q(1,1),3)
      call norm3d (ulat3)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine shift_xyz(p,ai,n)
c
      real p(3,n),ai(3)
      common /ashift/ a(3)
c
      a(1) = ai(1) ! Avoid aliasing
      a(2) = ai(2)
      a(3) = ai(3)
c
      do i=1,n
         p(1,i) = p(1,i) - a(1)
         p(2,i) = p(2,i) - a(2)
         p(3,i) = p(3,i) - a(3)
      enddo
c
      return
      end
c-----------------------------------------------------------------------
      subroutine outmat(a,m,n,name5,k)
      real a(m,n)
      character*5 name5
c
      write(6,1) name5,k
      n10 = min(n,10)
      do i=1,m
         write(6,2) k,name5,(a(i,j),j=1,n10)
      enddo
    1 format(/,'MATRIX: ',a5,i9)
    2 format(i4,1x,a5,1p10e11.3)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine sdl_element_dodec(v,xrhm,rad)
c
c     Update SEM element data for dodec
c
      include 'basics.inc'
      real v(3,8,4),xrhm(3,4)
c
      integer e
      integer e2pfv(8)
      save    e2pfv
      data    e2pfv / 1 , 2 ,4 ,3 ,5 ,6 ,8 ,7 /
c
      character*1 alphabet(52)
      character*26 alpha(2)
      equivalence (alphabet,alpha)
      save         alpha
      data         alpha 
     $      /'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'/
c
      k = 0
      do irhm=1,4
         k = k+1
         e = nel+k
         do i=1,8
            j      = e2pfv(i)
            x(e,i) = v(1,j,k)
            y(e,i) = v(2,j,k)
            z(e,i) = v(3,j,k)
         enddo
c
         ccurve(5,e)   = ' '
         call rzero(curve(1,1,e),5)
c
         cbc   (5,e,1) = 'v  '
         cbc   (5,e,2) = 'f  '  ! flux bc as default for Temperature
c
         call rzero(bc(1,5,e,1),5)
         call rzero(bc(1,5,e,2),5)
c
         ilet      = mod1(e,52)
         letapt(e) = alphabet(ilet)
         numapt(e) = 1
c
      enddo
c
      nel = nel+4
c
      return
      end
c-----------------------------------------------------------------------
      subroutine rhombic_dodec(d,x0,if_sph_ctr)
c
      logical if_sph_ctr
c
c
c     x(:,1)=x0, and x(:,2)=x0+d
c
      real x(3,8),x0(3)
      real t(3,4),x00(3),v(3,4),ve(3,8,4)
c
      call get_vert_tet(t,d,x0) ! Base tet
c
c     Get unit vectors emanating from origin of tet
c
      call rzero(x00,3)
      do k=1,4
      do i=1,3
         x00(i) = x00(i) + t(i,k)
      enddo
      enddo
      scale = 0.25
      call cmult(x00,scale,3)
c
      do k=1,4
         do i=1,3
            v(i,k) = t(i,k)-x00(i)
         enddo
         v(3,k) = -v(3,k)   ! Need this for right-handedness of elements
         call norm3d (v(1,k))
      enddo
c
      call rzero(ve,3*8*4)
c
      call rhomboid(ve(1,1,1),v(1,4),v(1,3),v(1,2))
      call rhomboid(ve(1,1,2),v(1,3),v(1,4),v(1,1))
      call rhomboid(ve(1,1,3),v(1,2),v(1,1),v(1,4))
      call rhomboid(ve(1,1,4),v(1,1),v(1,2),v(1,3))
c
      call sdl_element_dodec  (ve,x,rad)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine rhomboid(ve,v1,v2,v4)
c
      real ve(3,0:7),v1(3),v2(3),v4(3)
c
      vol = triple_prod(v1,v2,v4) ! Check for positive volume
c
      call rzero(ve,24)
      call add3(ve(1,1),ve(1,0),v1,3)
      call add3(ve(1,2),ve(1,0),v2,3)
      call add3(ve(1,3),ve(1,1),v2,3)
c
c
      call add3(ve(1,4),ve(1,0),v4,3)
      call add3(ve(1,5),ve(1,1),v4,3)
      call add3(ve(1,6),ve(1,2),v4,3)
      call add3(ve(1,7),ve(1,3),v4,3)
c
      return
      end
c-----------------------------------------------------------------------
      function tet_chk(q)
c
c     Check for positive volume (i.e., right-handed tet)
c
      real q(3,0:3)
      real v(3,3)
c
c
      do i=1,3
         call sub3(v(1,i),q(1,i),q(1,0),3)
      enddo
c
      vol = triple_prod(v(1,1),v(1,2),v(1,3))
      if (vol.le.0) write(6,*) 'in tet chk'
c
      tet_chk = vol
c
      return
      end
c-----------------------------------------------------------------------
      function triple_prod(v1,v2,v3)
c
      real v1(3),v2(3),v3(3)
      real w1(3)
c
c     vol = triple_prod(v1,v2,v3) ! Check for positive volume
c
      call cross(w1,v1,v2)
      vol = dot(w1,v3,3)
c
      if (vol.le.0) then
         write(6,1) vol
         write(6,2) 'V1:',(v1(k),k=1,3)
         write(6,2) 'V2:',(v2(k),k=1,3)
         write(6,2) 'V3:',(v3(k),k=1,3)
      endif
    1 format(/,'Nonpositive volume:',1pe12.4)
    2 format(a3,1p3e14.4)
c
      triple_prod = vol
c
      return
      end
c-----------------------------------------------------------------------
      subroutine vswap2(x,y,n)
      real x(1),y(1)
c
      do i=1,n
         t    = x(i)
         x(i) = y(i)
         y(i) = t
      enddo
c
      return
      end
c-----------------------------------------------------------------------
      subroutine edge_tet_sdl(v,nt,p,i0,i1,k0,k1,d,rad)
c
c     Build the void for an fcc lattice
c
      real p(3,8,2) ! sphere centers 8 + 6
      real q(3,6)   ! permuted diamond sphere centers 6
c
      real v(3,8,288)  ! 288 elements total
c
c
c     Edge tets 3 x 4 = 12 total
c
      call copy(q(1,1),p(1,i0,1),3)  ! Tet 1
      call copy(q(1,2),p(1,i1,1),3)
      call copy(q(1,3),p(1,k0,2),3)
      call copy(q(1,4),p(1,k1,2),3)
c
      vol = tet_chk(q)
      if (vol.lt.0) write(6,*) 'in edge_tet_sdl',vol
      if (vol.lt.0) call vswap2(q(1,1),q(1,2),3)
c
      call build_tet_saddle(v(1,1,nt),q,d,rad,.false.)
      call sdl_element_tet (v(1,1,nt),q,rad)
      nt = nt + 12
c
      return
      end
c-----------------------------------------------------------------------
      subroutine crnr_tet_sdl(v,nt,p,i0,k0,k1,k2,d,rad)
c
c     Build the void for an fcc lattice
c
      real p(3,8,2) ! sphere centers 8 + 6
      real q(3,6)   ! permuted diamond sphere centers 6
c
      real v(3,8,288)  ! 288 elements total
c
c
c     Corner tets: 8 total
c
      call copy(q(1,1),p(1,i0,1),3)  ! Tet 1
      call copy(q(1,2),p(1,k0,2),3)
      call copy(q(1,3),p(1,k1,2),3)
      call copy(q(1,4),p(1,k2,2),3)
c
      vol = tet_chk(q)
      if (vol.lt.0) call vswap2(q(1,1),q(1,2),3)
c
      call build_tet_saddle(v(1,1,nt),q,d,rad,.false.)
      call sdl_element_tet (v(1,1,nt),q,rad)
      nt = nt + 12
c
      return
      end
c-----------------------------------------------------------------------
      subroutine saddle_fcc(d,radi,x0)
c
c     Build the void for an fcc lattice
c
      include 'basics.inc'
      real x0(3)
      real p(3,8,2) ! sphere centers 8 + 6
      real q(3,6)   ! permuted diamond sphere centers 6
c
      real v(3,8,288)  ! 48 elements total (12 + 24 + 12)
      real a0(3)
c
      two = 2.
      rad = radi/sqrt(two)
c
      call get_vert_fcc_lat (p,d,x0)
c
      nt = 1
c
c     Edge tets 3 x 4 = 12 total
c
      call edge_tet_sdl(v,nt,p,1,2,3,5,d,rad)
c     return
      call edge_tet_sdl(v,nt,p,3,4,4,5,d,rad)
      call edge_tet_sdl(v,nt,p,5,6,3,6,d,rad)
      call edge_tet_sdl(v,nt,p,7,8,4,6,d,rad)
c
      call edge_tet_sdl(v,nt,p,1,3,1,5,d,rad)
      call edge_tet_sdl(v,nt,p,2,4,2,5,d,rad)
      call edge_tet_sdl(v,nt,p,5,7,1,6,d,rad)
      call edge_tet_sdl(v,nt,p,6,8,2,6,d,rad)
c
      call edge_tet_sdl(v,nt,p,1,5,1,3,d,rad)
      call edge_tet_sdl(v,nt,p,2,6,2,3,d,rad)
      call edge_tet_sdl(v,nt,p,3,7,1,4,d,rad)
      call edge_tet_sdl(v,nt,p,4,8,2,4,d,rad)
c
c
c     BUILD CORNER TETS  (8 total)
c
c
      call crnr_tet_sdl(v,nt,p,1,1,3,5,d,rad)
      call crnr_tet_sdl(v,nt,p,2,2,3,5,d,rad)
      call crnr_tet_sdl(v,nt,p,3,1,4,5,d,rad)
      call crnr_tet_sdl(v,nt,p,4,2,4,5,d,rad)
      call crnr_tet_sdl(v,nt,p,5,1,3,6,d,rad)
      call crnr_tet_sdl(v,nt,p,6,2,3,6,d,rad)
      call crnr_tet_sdl(v,nt,p,7,1,4,6,d,rad)
      call crnr_tet_sdl(v,nt,p,8,2,4,6,d,rad)
c
      call permute_dia      (q,p(1,1,2))  ! Diamond
      call build_dia_saddle (v(1,1,nt),q,d,rad,if_sph_ctr)
      call sdl_element_dia  (v(1,1,nt),q,rad)
      nt = nt+24
c
c
      return
      end
c-----------------------------------------------------------------------
      subroutine add3s2(x,y,z,c,n)
      real x(1),y(1),z(1)
      do i=1,n
         x(i) = c * ( y(i) + z(i) )
      enddo
      return
      end
c-----------------------------------------------------------------------
      subroutine facind(kx1,kx2,ky1,ky2,kz1,kz2,nx1,ny1,nz1,iface)

c
c     Return face index, preprocessor notation
c

      kx1=1
      ky1=1
      kz1=1
      kx2=nx1
      ky2=ny1
      kz2=nz1

      if (iface.eq.1) ky2=1
      if (iface.eq.2) kx1=nx1
      if (iface.eq.3) ky1=ny1
      if (iface.eq.4) kx2=1
      if (iface.eq.5) kz2=1
      if (iface.eq.6) kz1=nz1

      return
      end
c-----------------------------------------------------------------------
      subroutine sfacind(kx1,kx2,ky1,ky2,kz1,kz2,nx1,ny1,nz1,iface)

c
c     Return face index, symmetric notation
c

      kx1=1
      ky1=1
      kz1=1
      kx2=nx1
      ky2=ny1
      kz2=nz1

      if (iface.eq.1) kx2=1
      if (iface.eq.2) kx1=nx1
      if (iface.eq.3) ky2=1
      if (iface.eq.4) ky1=ny1
      if (iface.eq.5) kz2=1
      if (iface.eq.6) kz1=nz1

      return
      end
c-----------------------------------------------------------------------
      subroutine non_reg_tet_mod(v,x1,x2,x3,r)
      real v(3),x1(3),x2(3),x4(3)
      real w(3),x(3,3),s(3),a(3,3),xr(3,3),sl(3),t(3)
c
      call copy(x(1,1),x1,3)
      call copy(x(1,2),x2,3)
      call copy(x(1,3),x3,3)
c
      h = .5
      call add3s2(a(1,1),x2,x3,h,3)
      call add3s2(a(1,2),x3,x1,h,3)
      call add3s2(a(1,3),x1,x2,h,3)
c
      call copy(w,v,3)

      do i=1,3
         call sub3(s,a(1,i),x(1,i),3)
         sli = sqrt(vlsc2(s,s,3)) - r
         slr = sli - r
         call sub3(t,v,x(1,i),3)
         sll   = sqrt(vlsc2(t,t,3)) - r
         ds    = 0.5*slr - sll
c
         ds  = -ds/sli
         call add2s2(w,s,ds,3)
      enddo
c
      call copy(v,w,3)
c
      return
      end
c-----------------------------------------------------------------------
      subroutine sph_intersect(xi,x0,x1,xc,r)
      real xi(3),x0(3),x1(3),xc(3),r
      real p0(3),p1(3),dx(3)

c     xi:   output point where [x0,x1] intersects sphere (xc,r)
c
c     x0    is assumed inside the sphere
c     x1    is assumed outside the sphere
c

      call sub3(p0,x0,xc,3)   ! subtract center
      call sub3(p1,x1,xc,3)

      scale = 1./r
      call cmult(p0,scale,3)  ! scale out radius
      call cmult(p1,scale,3)

      call sub3(dx,p1,p0,3)   ! compute unit vector pointing x0 --> x1
      scale = 1./dot(dx,dx,3)
      scale = sqrt(scale)
      call cmult(dx,scale,3)

      c = dot(p0,p0,3) - 1.   ! find intersection w/ unit sphere
      b = 2.*dot(p0,dx,3)
      d = b*b-4*c
      s = sqrt(d)
      ap = .5*(-b + s)        ! take positive root
      call copy  (xi,p0,3)
      call add2s2(xi,dx,ap,3)

      scale = r
      call cmult (xi,scale,3)  ! rescale by radius
      call add2  (xi,xc   ,3)  ! add back sphere center

c     write(6,*)
c     write(6,*) 'this is rad:',r
c     call outmat(x0,1,3,'xsph0',1)
c     call outmat(x1,1,3,'xsph1',2)
c     call outmat(xi,1,3,'xsph ',3)

      return
      end
c-----------------------------------------------------------------------
      subroutine nw_sphmesh

      call sph_wall_elmt
      call redraw_mesh

      return
      end
c-----------------------------------------------------------------------
      subroutine sph_wall_elmt
c
c     Place a sphere near a wall;   10/15/06  pff

      include 'basics.inc'
      real xvi(3),zvi(5),tsph(3)

c     tsph -- translation of sphere from base position

      real xt(3,25,6,4)  ! base coordinates
      real x0  (3,3)       ! sphere centers
      real rads(0:3)       ! sphere centers

      character*80 fname

      nelo = nel

      call prs('Input file name containing r0,h0,xvi,zvi,tsph:$')
      call blank(fname,80)
      call res  (fname,80)

      open(unit=80,file=fname)
      read(80,*) r0,h0,(xvi(k),k=1,3),(zvi(k),k=1,5),(tsph(k),k=1,3)
      read(80,*) s1,s2,s3
      close(unit=80)

c     r0 = 0.5
c     h0 = 0.505
   
c     xvi(1) = 0
c     xvi(2) = 0.4
c     xvi(3) = 0.8
   
c     zvi(1) = 0
c     zvi(2) = 0.2
c     zvi(3) = 0.4
c     zvi(4) = 0.8
c     zvi(5) = 1.3

c     tsph(1) = 0.
c     tsph(2) = 0.
c     tsph(3) = 0.

      rm = min(xvi(3),zvi(5)-h0)
      dm = rm - r0

c     r1 = r0 + 0.10*dm          ! 1st shell
c     r2 = r0 + 0.65*dm          ! 2nd shell
c     r3 = r0 + 1.00*dm          ! 3rd shell

      r1 = r0 + s1*dm          ! 1st shell
      r2 = r0 + s2*dm          ! 2nd shell
      r3 = r0 + s3*dm          ! 3rd shell

      rads(0) = r0
      rads(1) = r1
      rads(2) = r2
      rads(3) = r3


      ntp  = 5
      call sph_wall_elmt1(r0,h0,xvi,zvi,xt,x0,rads,ntp,tsph)
      call sph_wall_elmt2(r0,h0,xvi,zvi,xt,x0,rads,ntp,tsph)
      call sph_wall_elmt3(r0,h0,xvi,zvi,xt,x0,rads,ntp,tsph)

      call translate_sub_mesh(nelo,nel,tsph(1),tsph(2),tsph(3))
      write(6,*) 'this is nel:',nelo,nel

      return
      end
c-----------------------------------------------------------------------
      subroutine sph_w_gt_fc(xt,ntp,nlev,pface)
c
c     Place a sphere near a wall;   10/15/06  pff
c
c     Top & Bottom parts
c

      real xt(3,ntp,ntp,6,nlev)  ! base coordinates

      integer pface,f

      if (pface.eq.6) then

         k = ntp
         do ilev = 1,nlev
         do idir = 1,3

            f = 1
            i = ntp
            do j=1,ntp
               xt(idir,i,j,6,ilev) = xt(idir,j,k,f,ilev)
            enddo

            f = 2
            j = ntp
            l = 0
            do i=ntp,1,-1
               l = l+1
               xt(idir,i,j,6,ilev) = xt(idir,l,k,f,ilev)
            enddo
      
            f = 3
            i = 1
            l = 0
            do j=ntp,1,-1
               l = l+1
               xt(idir,i,j,6,ilev) = xt(idir,l,k,f,ilev)
            enddo
      
            f = 4
            j = 1
            do i=1,ntp
               xt(idir,i,j,6,ilev) = xt(idir,i,k,f,ilev)
            enddo
      
         enddo
         enddo

      elseif (pface.eq.5) then

         k = 1
         do ilev = 1,nlev
         do idir = 1,3

            f = 1
            i = ntp
            l = 0
            do j=ntp,1,-1
               l = l+1
               xt(idir,i,j,5,ilev) = xt(idir,l,k,f,ilev)
            enddo

            f = 2
            j = 1
            l = 0
            do i=ntp,1,-1
               l = l+1
               xt(idir,i,j,5,ilev) = xt(idir,l,k,f,ilev)
            enddo
      
            f = 3
            i = 1
            do j=1,ntp
               xt(idir,i,j,5,ilev) = xt(idir,j,k,f,ilev)
            enddo
      
            f = 4
            j = ntp
            do i=1,ntp
               xt(idir,i,j,5,ilev) = xt(idir,i,k,f,ilev)
            enddo
      
         enddo
         enddo
      endif


      return
      end
c-----------------------------------------------------------------------
      subroutine sph_wall_elmt1(r0,h0,xvi,zvi,xt,x0,rads,ntp,tsph)
c
c     Place a sphere near a wall;   10/15/06  pff
c
      include 'basics.inc'

      real r0,h0           ! radius and height of sphere from wall
      real xvi(3),zvi(5)   ! local coords of box vertices
      real rads(0:3)       ! location of sphere centers
      real tsph(3)         ! x-y location of sphere, after translation

      integer e,f
      integer pf2ev(8)
      save    pf2ev
      data    pf2ev / 1 , 2 ,4 ,3 ,5 ,6 ,8 ,7 /
c
      character*1 alphabet(52)
      character*26 alpha(2)
      equivalence (alphabet,alpha)
      save         alpha
      data         alpha 
     $      /'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'/

      real xt(3,25,6,4)  ! base coordinates
      real x0(3,3)
      real x2(3)
      real udata(3)

      integer pface


      r1 = rads(1)             ! 1st shell
      r2 = rads(2)             ! 2nd shell
      r3 = rads(3)             ! 3rd shell

      udata(1) = r0            ! this data passed to prenek as part
      udata(2) = h0            ! of the 'u' curve side parameter list
      udata(3) = r1

      h1 = .5*(h0-r0) + r1
      h1 = max(h1,h0)          ! outer sphere not closer then inner
      h2 = h1
      h3 = h2                  ! 3rd shell


      call rzero(x0,3*3)
      x0(3,1) = h0
      x0(3,2) = h1
      x0(3,3) = h2
      call rzero(x2,3)
      x2(1)   = -r2*1
      x2(3)   = h2
      r22     = r2*2

      nt2 = ntp/2 + 1

      call rzero(xt,3*ntp*ntp*6*4)

      pface = 1

      dy = r3/2.
      dz = r3/2.

      m = 0
      do k=1,ntp
      do j=1,ntp

         kk = k-nt2
         jj = j-nt2
         m  = m+1
         xt(1,m,pface,4) = r3
         xt(2,m,pface,4) = jj*dy
         xt(3,m,pface,4) = kk*dz + h3

         do kl = 1,3

            if (kl.eq.1) call sph_intersect
     $        (xt(1,m,pface,kl),x0,xt(1,m,pface,4),x0(1,kl),r0)
            if (kl.eq.2) call user_s
     $        (xt(1,m,pface,kl),xt(1,m,pface,4),udata,1,5)
            if (kl.eq.3) call sph_intersect
     $        (xt(1,m,pface,kl),x0,xt(1,m,pface,4),x2      ,r22)

            xt(3,m,pface,kl) = max(xt(3,m,pface,kl),0.)
            if (kl.ge.3.and.k.eq.1) xt(3,m,pface,kl) = 0.

         enddo

c        adjust x-pos on outer shell to user position, post-projection
         xt(1,m,pface,4) = xvi(nt2)
         ja = abs(jj)+1
         if (jj.lt.0) xt(2,m,pface,4) = -xvi(ja)
         if (jj.gt.0) xt(2,m,pface,4) =  xvi(ja)
         if (jj.eq.0) xt(2,m,pface,4) =  0

c        adjust z-level on outer shell to user position, post-projection
         xt(3,m,pface,4) = zvi(k)

c        floor z-level to zero
         xt(3,m,pface,4) = max(xt(3,m,pface,4),0.)
         if (k.eq.1) xt(3,m,pface,4) = 0.


      enddo
      enddo

      do f=2,4   !  save tensor-product brick

         if (f.eq.2) then     ! ang = 90
            ca = 0
            sa = 1
         elseif (f.eq.3) then ! ang = 180
            ca = -1
            sa = 0
         elseif (f.eq.4) then ! ang = 270
            ca = 0
            sa = -1
         endif

         do k = 1,4
         do m=1,ntp*ntp
               xx = xt(1,m,pface,k)
               yy = xt(2,m,pface,k)
               zz = xt(3,m,pface,k)
               xt(1,m,f,k) = ca*xx-sa*yy
               xt(2,m,f,k) = sa*xx+ca*yy
               xt(3,m,f,k) =    zz
         enddo
         enddo
      enddo

      
      nsh = 0
      do klev =1,3   ! fill all shells w/ solid

         m = 0
         do ke=1,ntp-1
         do je=1,ntp-1

            nsh = nsh+1
            e   = nel + nsh

            j = 0
            do kk=0,1
            do jj=0,1
            do ii=0,1

               m = je + ii + ntp*(ke-1 + jj)
               k = klev + kk

               j      = j+1
               i      = pf2ev(j)
               x(e,i) = xt(1,m,pface,k)
               y(e,i) = xt(2,m,pface,k)
               z(e,i) = xt(3,m,pface,k)

            enddo
            enddo
            enddo

            call rzero(curve(1,1,e),30)

            if (klev.eq.1) then
               ccurve(  5,e) = 's'
               curve (1,5,e) = x0(1,1)
               curve (2,5,e) = x0(2,1)
               curve (3,5,e) = x0(3,1)
               curve (4,5,e) = r0

               ccurve(  6,e) = 'u'
               curve (1,6,e) = udata(1)
               curve (2,6,e) = udata(2)
               curve (3,6,e) = udata(3)
               curve (4,6,e) = tsph(1)   ! x-loc of translated sphere
               curve (5,6,e) = tsph(2)   ! y-loc of translated sphere
            elseif (klev.eq.2) then
               ccurve(  5,e) = 'u'
               curve (1,5,e) = udata(1)
               curve (2,5,e) = udata(2)
               curve (3,5,e) = udata(3)
               curve (4,5,e) = tsph(1)   ! x-loc of translated sphere
               curve (5,5,e) = tsph(2)   ! y-loc of translated sphere
            endif

            do f=1,6
               cbc(f,e,1) = 'v  '
            enddo

            cbc   (5,e,1) = 'v  '
            cbc   (6,e,1) = 'v  '
            cbc   (5,e,2) = 'f  '  ! flux bc as default for Temperature

            call rzero(bc(1,5,e,1),5)
            call rzero(bc(1,5,e,2),5)

            ilet      = mod1(e,52)
            letapt(e) = alphabet(ilet)
            numapt(e) = 1
         enddo
         enddo
c
      enddo


      call copy_sub_mesh    (nel+1,nel+nsh,nel+nsh+1)
      call rotate_submesh_2d(nel+nsh+1,nel+2*nsh,90.)
      nsh = 2*nsh
      call copy_sub_mesh    (nel+1,nel+nsh,nel+nsh+1)
      call rotate_submesh_2d(nel+nsh+1,nel+2*nsh,180.)
      nsh = 2*nsh

      nel = nel+nsh

      return
      end
c-----------------------------------------------------------------------
      subroutine sph_wall_elmt2(r0,h0,xvi,zvi,xt,x0,rads,ntp,tsph)
c
c     Place a sphere near a wall;   10/15/06  pff
c
c     Top & Bottom parts
c
      include 'basics.inc'

      real r0,h0           ! radius and height of sphere from wall
      real xvi(3),zvi(5)   ! local coords of box vertices
      real rads(0:3)       ! location of sphere centers
      real tsph(3)         ! x-y location of sphere, after translation

      integer e,f
      integer pf2ev(8)
      save    pf2ev
      data    pf2ev / 1 , 2 ,4 ,3 ,5 ,6 ,8 ,7 /
c
      character*1 alphabet(52)
      character*26 alpha(2)
      equivalence (alphabet,alpha)
      save         alpha
      data         alpha 
     $      /'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'/

      real xt(3,ntp*ntp,6,4)  ! base coordinates
      real x0(3,3)
      real x2(3)

      integer pface
      real udata(3)

      r1 = rads(1)             ! 1st shell
      r2 = rads(2)             ! 2nd shell
      r3 = rads(3)             ! 3rd shell

      h1 = .5*(h0-r0) + r1
      h1 = max(h1,h0)          ! outer sphere not closer then inner
      h2 = h1
      h3 = h2                  ! 3rd shell

      udata(1) = r0
      udata(2) = h0
      udata(3) = r1

      call rzero(x2,3)
      x2(3)   = h2-r2
      r22     = r2*2

      nt2 = ntp/2 + 1

      pface = 6

      dx = r3/2.
      dy = r3/2.

      m = 0
      do j=1,ntp
      do i=1,ntp

         jj = j-nt2
         ii = i-nt2
         m  = m+1
         xt(1,m,pface,4) = ii*dx
         xt(2,m,pface,4) = jj*dy
         xt(3,m,pface,4) = h3 + r3

         do kl = 1,3
            if (kl.eq.1) call sph_intersect
     $        (xt(1,m,pface,kl),x0,xt(1,m,pface,4),x0(1,kl),r0)
            if (kl.eq.2) call user_s
     $        (xt(1,m,pface,kl),xt(1,m,pface,4),udata,1,5)
c           if (kl.eq.2) call sph_intersect
c    $        (xt(1,m,pface,kl),x0,xt(1,m,pface,4),x0(1,kl),r1)
            if (kl.eq.3) call sph_intersect
     $        (xt(1,m,pface,kl),x0,xt(1,m,pface,4),x2      ,r22)
         enddo

c        adjust xy-pos on outer shell to user position, post-projection

         if (ii.gt.0) then
            xt(1,m,pface,4) = xvi(ii+1)
         elseif (ii.lt.0) then
            ia = abs(ii)
            xt(1,m,pface,4) = -xvi(ia+1)
         else
            xt(1,m,pface,4) = 0
         endif

         if (jj.gt.0) then
            xt(2,m,pface,4) = xvi(jj+1)
         elseif (jj.lt.0) then
            ja = abs(jj)
            xt(2,m,pface,4) = -xvi(ja+1)
         else
            xt(2,m,pface,4) = 0
         endif
         xt(3,m,pface,4) = zvi(ntp)

      enddo
      enddo

      nlev = 4
      call sph_w_gt_fc(xt,ntp,nlev,pface)

      nsh = 0
      do klev =1,3   ! fill all shells w/ solid

         m = 0
         do ke=1,ntp-1
         do je=1,ntp-1

            nsh = nsh+1
            e   = nel + nsh

            j = 0
            do kk=0,1
            do jj=0,1
            do ii=0,1

               m = je + ii + ntp*(ke-1 + jj)
               k = klev + kk

               j      = j+1
               i      = pf2ev(j)
               x(e,i) = xt(1,m,pface,k)
               y(e,i) = xt(2,m,pface,k)
               z(e,i) = xt(3,m,pface,k)

            enddo
            enddo
            enddo

            call rzero(curve(1,1,e),30)

            if (klev.eq.1) then
               ccurve(  5,e) = 's'
               curve (1,5,e) = x0(1,1)
               curve (2,5,e) = x0(2,1)
               curve (3,5,e) = x0(3,1)
               curve (4,5,e) = r0

               ccurve(  6,e) = 'u'
               curve (1,6,e) = udata(1)
               curve (2,6,e) = udata(2)
               curve (3,6,e) = udata(3)
               curve (4,6,e) = tsph(1)   ! x-loc of translated sphere
               curve (5,6,e) = tsph(2)   ! y-loc of translated sphere
            elseif (klev.eq.2) then
               ccurve(  5,e) = 'u'
               curve (1,5,e) = udata(1)
               curve (2,5,e) = udata(2)
               curve (3,5,e) = udata(3)
               curve (4,5,e) = tsph(1)   ! x-loc of translated sphere
               curve (5,5,e) = tsph(2)   ! y-loc of translated sphere
            endif

            do f=1,6
               cbc(f,e,1) = 'v  '
            enddo

            cbc   (5,e,1) = 'v  '
            cbc   (6,e,1) = 'v  '
            cbc   (5,e,2) = 'f  '  ! flux bc as default for Temperature

            call rzero(bc(1,5,e,1),5)
            call rzero(bc(1,5,e,2),5)

            ilet      = mod1(e,52)
            letapt(e) = alphabet(ilet)
            numapt(e) = 1
         enddo
         enddo
c
      enddo

      nel = nel+nsh

      return
      end
c-----------------------------------------------------------------------
      subroutine sph_wall_elmt3(r0,h0,xvi,zvi,xt,x0,rads,ntp,tsph)
c
c     Place a sphere near a wall;   10/15/06  pff
c
c     Bottom parts
c
      include 'basics.inc'

      real r0,h0           ! radius and height of sphere from wall
      real xvi(3),zvi(5)   ! local coords of box vertices
      real rads(0:3)       ! location of sphere centers
      real tsph(3)         ! x-y location of sphere, after translation

      integer e,f
      integer pf2ev(8)
      save    pf2ev
      data    pf2ev / 1 , 2 ,4 ,3 ,5 ,6 ,8 ,7 /
c
      character*1 alphabet(52)
      character*26 alpha(2)
      equivalence (alphabet,alpha)
      save         alpha
      data         alpha 
     $      /'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'/

      real xt(3,ntp*ntp,6,4)  ! base coordinates
      real x0(3,3)
      real x2(3)

      integer pface
      real    udata(3)

      r1 = rads(1)             ! 1st shell
      r2 = rads(2)             ! 2nd shell
      r3 = rads(3)             ! 3rd shell

      h1 = .5*(h0-r0) + r1
      h1 = max(h1,h0)          ! outer sphere not closer then inner
      h2 = h1
      h3 = h2                  ! 3rd shell

      udata(1) = r0
      udata(2) = h0
      udata(3) = r1

      nt2 = ntp/2 + 1

      pface = 5

      dx  = r3/2.  ! to correspond to other sections
      dy  = r3/2.

      dxx = r2/3.
      dyy = r2/3.

      m = 0
      do j=1,ntp
      do i=1,ntp

         jj = nt2-j
         ii = i-nt2
         m  = m+1
         xt(1,m,pface,3) = ii*dxx
         xt(2,m,pface,3) = jj*dyy
         xt(3,m,pface,3) = 0

         xt(1,m,pface,4) = ii*dx
         xt(2,m,pface,4) = jj*dy
         xt(3,m,pface,4) = h3 - r3

         ia = abs(ii)
         ja = abs(jj)

         do kl = 1,2
            if (ia.le.1 .and. ja.le.1) then
               if (kl.eq.1) call sph_intersect
     $           (xt(1,m,pface,kl),x0,xt(1,m,pface,3),x0(1,kl),r0)
c              if (kl.eq.2) call sph_intersect
c    $           (xt(1,m,pface,kl),x0,xt(1,m,pface,3),x0(1,kl),r1)
               if (kl.eq.2) call user_s
     $           (xt(1,m,pface,kl),xt(1,m,pface,3),udata,1,5)
            else
               if (kl.eq.1) call sph_intersect
     $           (xt(1,m,pface,kl),x0,xt(1,m,pface,4),x0(1,kl),r0)
c              if (kl.eq.2) call sph_intersect
c    $           (xt(1,m,pface,kl),x0,xt(1,m,pface,4),x0(1,kl),r1)
               if (kl.eq.2) call user_s
     $           (xt(1,m,pface,kl),xt(1,m,pface,4),udata,1,5)
            endif
         enddo

      enddo
      enddo

      nlev = 3
      call sph_w_gt_fc(xt,ntp,nlev,pface)

      nsh = 0
      do klev =1,2   ! fill all shells w/ solid

         m = 0
         do ke=1,ntp-1
         do je=1,ntp-1

            nsh = nsh+1
            e   = nel + nsh

            j = 0
            do kk=0,1
            do jj=0,1
            do ii=0,1

               m = je + ii + ntp*(ke-1 + jj)
               k = klev + kk

               j      = j+1
               i      = pf2ev(j)
               x(e,i) = xt(1,m,pface,k)
               y(e,i) = xt(2,m,pface,k)
               z(e,i) = xt(3,m,pface,k)

            enddo
            enddo
            enddo

            call rzero(curve(1,1,e),30)

            if (klev.eq.1) then
               ccurve(  5,e) = 's'
               curve (1,5,e) = x0(1,1)
               curve (2,5,e) = x0(2,1)
               curve (3,5,e) = x0(3,1)
               curve (4,5,e) = r0

               ccurve(  6,e) = 'u'
               curve (1,6,e) = udata(1)
               curve (2,6,e) = udata(2)
               curve (3,6,e) = udata(3)
               curve (4,6,e) = tsph(1)   ! x-loc of translated sphere
               curve (5,6,e) = tsph(2)   ! y-loc of translated sphere
            elseif (klev.eq.2) then
               ccurve(  5,e) = 'u'
               curve (1,5,e) = udata(1)
               curve (2,5,e) = udata(2)
               curve (3,5,e) = udata(3)
               curve (4,5,e) = tsph(1)   ! x-loc of translated sphere
               curve (5,5,e) = tsph(2)   ! y-loc of translated sphere
            endif

            do f=1,6
               cbc(f,e,1) = 'v  '
            enddo

            cbc   (5,e,1) = 'v  '
            cbc   (6,e,1) = 'v  '
            cbc   (5,e,2) = 'f  '  ! flux bc as default for Temperature

            call rzero(bc(1,5,e,1),5)
            call rzero(bc(1,5,e,2),5)

            ilet      = mod1(e,52)
            letapt(e) = alphabet(ilet)
            numapt(e) = 1
         enddo
         enddo
c
      enddo

      nel = nel+nsh

      return
      end
c-----------------------------------------------------------------------
      subroutine sph_combine_d(xi,r0,x0,x1,xs1)
      real xi(3),x0(3),x1(3),xs1(0:3)

      real t1(3),t2(3),un(3),d1(3),d2(3)

c     xi:   output point where [x0,x1] intersects sphere (xc,r)
c
c     x0    is assumed inside the sphere
c     x1    is assumed outside the sphere
c

      call sph_intersect(t1,x0,x1,xs1(1),xs1(0))

      h0 = x0(3)

      call copy(xi,t1,3)
      if (x1(3).ge.h0) return

      call sub3(t2,t1,x0,3)
      call normalize(t2,3)

   
      call rzero(un,3) 
      un(3) = -1.
      cos_th = dot(t2,un,3)

      r = 0.5*(r0 + h0/cos_th)

      call add2s1(t2,x0,r,3)
      

c     Blend

      call sub3(d1,t1,x0,3)
      d12 = vlsc2(d1,d1,3)
      d12 = sqrt(d12)

      call sub3(d2,t2,x0,3)
      d22 = vlsc2(d2,d2,3)
      d22 = sqrt(d22)

      cos2   = cos_th**2
      sin2   = 1-cos2
      dm = min(d12,d22)
      w1 = dm/d12
      w2 = dm/d22
      a  = 12.
      w1 = sin2*(w1**a)
      w2 = cos2*(w2**a)
      ww = w1+w2
      w1 = w1/ww
      w2 = w2/ww
      do i=1,3
         xi(i) = w1*t1(i) + w2*t2(i)
      enddo
      write(6,1) (xi(k),k=1,3),(x1(k),k=1,3)
      write(29,1) (xi(k),k=1,3)
1     format(2(2x,3f11.5))

      return
      end
c-----------------------------------------------------------------------
      subroutine user_s(xu,xf,xo,eg,face)

      real xu(3),xf(3),xo(3)
      integer eg,face

      real x0(3),x1(0:3)    ! sphere center
      save x0,x1
      data x0,x1 / 7*0./

      
c     r0 = .5      ! sphere def'n
c     h0 = .505

      r0 = xo(1)   ! hack into user_s interface
      h0 = xo(2)
      r1 = xo(3)

      write(6,*) r0,h0,r1,' R0'

      x0 (1) = 0.
      x0 (2) = 0.
      x0 (3) = h0

c     r1 = .53
      h1 = r1 + (h0-r0)/2.
      h1 = h0
      x1(0) = r1
      x1(1) = 0.
      x1(2) = 0.
      x1(3) = h1

c     write(6,1) (xf(k),k=1,3)
c   1 format(6f11.3)

      call sph_combine_d(xu,r0,x0,xf,x1)

      return
      end
c-----------------------------------------------------------------------
