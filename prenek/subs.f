C------------------------------------------------------------------------------
C
C                          NEKTON 2.6  2/8/90
C
C			Copyright (C) 1990, by the 
C
C		Massachusetts Institute of Technology  and Nektonics, Inc.
C
C All Rights Reserved
C
C This program is a licenced product of MIT and Nektonics, Inc.,  and it is 
C not to be disclosed to others, copied, distributed, or displayed 
C without prior authorization.
C
C------------------------------------------------------------------------------
C
      SUBROUTINE SORT(A,IND,N)
C
C     Use Heap Sort (p 233 Num. Rec.), 5/26/93 pff.
C
      DIMENSION A(1),IND(1)
C
      if (n.le.1) return
      DO 10 J=1,N
         IND(j)=j
   10 continue
C
      if (n.eq.1) return
      L=n/2+1
      ir=n
  100 CONTINUE
         IF (l.gt.1) THEN
            l=l-1
            indx=ind(l)
            q=a(indx)
         ELSE
            indx=ind(ir)
            q=a(indx)
            ind(ir)=ind(1)
            ir=ir-1
            if (ir.eq.1) then
               ind(1)=indx
               return
            endif
         ENDIF
         i=l
         j=l+l
  200    CONTINUE
         IF (J.le.IR) THEN
            IF (J.lt.IR) THEN
               IF ( A(IND(j)).lt.A(IND(j+1)) ) j=j+1
            ENDIF
            IF (q.lt.A(IND(j))) THEN
               IND(I)=IND(J)
               I=J
               J=J+J
            ELSE
               J=IR+1
            ENDIF
         GOTO 200
         ENDIF
         IND(I)=INDX
      GOTO 100
      END
      SUBROUTINE SWAP(A,W,IND,N)
C
C     Use IND to sort array A   (p 233 Num. Rec.), 5/26/93 pff.
C
      DIMENSION A(1),W(1),IND(1)
C
      if (n.le.1) return
      DO 10 J=1,N
         W(j)=A(j)
   10 continue
C
      DO 20 J=1,N
         A(j)=W(ind(j))
   20 continue
      RETURN
      END
      SUBROUTINE ISORT(A,IND,N)
C
C     Use Heap Sort (p 233 Num. Rec.)
C
      INTEGER A(1),IND(1)
      INTEGER Q
C
      if (n.le.1) return
      DO 10 J=1,N
         IND(j)=j
   10 continue
C
      if (n.eq.1) return
      L=n/2+1
      ir=n
  100 CONTINUE
         IF (l.gt.1) THEN
            l=l-1
            indx=ind(l)
            q=a(indx)
         ELSE
            indx=ind(ir)
            q=a(indx)
            ind(ir)=ind(1)
            ir=ir-1
            if (ir.eq.1) then
               ind(1)=indx
               return
            endif
         ENDIF
         i=l
         j=l+l
  200    CONTINUE
         IF (J.le.IR) THEN
            IF (J.lt.IR) THEN
               IF ( A(IND(j)).lt.A(IND(j+1)) ) j=j+1
            ENDIF
            IF (q.lt.A(IND(j))) THEN
               IND(I)=IND(J)
               I=J
               J=J+J
            ELSE
               J=IR+1
            ENDIF
         GOTO 200
         ENDIF
         IND(I)=INDX
      GOTO 100
      END
      SUBROUTINE SWAP8(A,W,IND,N)
C
C     Use IND to sort array A
C
      real*8  A(1),w(1)
      INTEGER IND(1)
C
      if (n.le.1) return
      DO 10 J=1,N
         W(j)=A(j)
   10 continue
C
      DO 20 J=1,N
         A(j)=W(ind(j))
   20 continue
      RETURN
      END
      SUBROUTINE ISWAP(A,W,IND,N)
C
C     Use IND to sort array A
C
      INTEGER A(1),W(1),IND(1)
C
      if (n.le.1) return
      DO 10 J=1,N
         W(j)=A(j)
   10 continue
C
      DO 20 J=1,N
         A(j)=W(ind(j))
   20 continue
      RETURN
      END
      SUBROUTINE ChSWAP(A,W,L,IND,N)
C
C     Use IND to sort array A
C
      CHARACTER*1 A(L,1),W(L,1)
      INTEGER IND(1)
C
      if (n.le.1) return
      DO 10 J=1,L*N
         W(j,1)=A(j,1)
   10 continue
C
      DO 20 J=1,N
         ij=IND(J)
         DO 20 k=1,l
            A(l,j)=W(l,ij)
   20    continue
   30 continue
      RETURN
      END
      SUBROUTINE LJUST(STRING)
C     left justify string
      CHARACTER*1 STRING(80)
C
      IF (STRING(1).NE.' ') RETURN
C
      DO 100 I=2,80
C
         IF (STRING(I).NE.' ') THEN
            DO 20 J=1,81-I
               IJ=I+J-1
               STRING(J)=STRING(IJ)
   20       CONTINUE
            DO 30 J=82-I,80
               STRING(J)=' '
   30       CONTINUE
            RETURN
         ENDIF
C
  100 CONTINUE
      RETURN
      END
      SUBROUTINE CAPIT(LETTRS,N)
C     Capitalizes string of length n
      CHARACTER LETTRS(N)
C
      DO 5 I=1,N
         INT=ICHAR(LETTRS(I))
         IF(INT.GE.97 .AND. INT.LE.122) THEN
            INT=INT-32
            LETTRS(I)=CHAR(INT)
         ENDIF
5     CONTINUE
      RETURN
      END
      SUBROUTINE PARSE(LINES,ARGS,IA)
C       Capitalizes LINE and splits it into 5 ARGuments of 10 Characters.
C
      CHARACTER ARGS(10,5),COMAND*10,LINES(70)
      LOGICAL GAP
      INTEGER IAS(80),IES(80)
C
      IA=0
      IE=0
        GAP=.TRUE.
      DO 3 I=1,10
         DO 3 J=1,5
            ARGS(I,J)= ' '
3     CONTINUE
C       Capitalize LINE
      CALL CAPIT(LINES,70)
C
      DO 10 I=1,70
         IF(LINES(I).NE.' ' .AND. LINES(I).NE.',') THEN
            IF(GAP) THEN
C! Found the start of new argument
               IA=IA+1
               IAS(IA)=I
            ELSE
            ENDIF
            GAP = .FALSE.
         ELSE
            IF(.NOT.(GAP)) THEN
C!Found End of argument
               IE=IE+1
               IES(IE)=I-1
            ELSE
            ENDIF
            GAP = .TRUE.
         ENDIF
10    CONTINUE
C       COMMAND
C     Max 5 Arguments
      IF(IA.GT.5)IA=5
      DO 50 I=1,IA
         DO 50 IC=IAS(I),IES(I)
            ARGS(IC-IAS(I)+1,I)= LINES(IC)
50    CONTINUE
      DO 60 I=1,10
60            COMAND(I:I)=ARGS(I,1)
      RETURN
      END
      SUBROUTINE BLANK(STRING,N)
      CHARACTER*1 STRING(N)
      CHARACTER*1   BLNK
      DATA BLNK/' '/
C
      DO 100 I=1,N
         STRING(I)=BLNK
  100 CONTINUE
      RETURN
      END
c-----------------------------------------------------------------------
      function vlsum(a,n)
      real a(1)
      s = 0.
      do i=1,n
         s = s + a(i)
      enddo
      vlsum = s
      return
      end
c-----------------------------------------------------------------------
      function vlsc2(a,b,n)
      real a(1),b(1)
      s = 0.
      do i=1,n
         s = s + a(i)*b(i)
      enddo
      vlsc2 = s
      return
      end
c-----------------------------------------------------------------------
      SUBROUTINE CMULT(A,B,N)
      DIMENSION A(1)
      DO 100 I = 1, N
 100     A(I) = B*A(I)
      RETURN
      END
      SUBROUTINE CHCOPY(A,B,N)
      CHARACTER*1 A(1), B(1)
      DO 100 I = 1, N
 100     A(I) = B(I)
      RETURN
      END
C
      FUNCTION LTRUNC(STRING,L)
      CHARACTER*1 STRING(L)
      CHARACTER*1   BLNK
      DATA BLNK/' '/
      DO 100 I=L,1,-1
         L1=I
         IF (STRING(I).NE.BLNK) GOTO 200
  100 CONTINUE
      L1=0
  200 CONTINUE
      LTRUNC=L1
      RETURN
      END
      SUBROUTINE ROOTS(XVAL,NROOTS,FTARGT,F,N)
C
C     Find all values of I which yield F(I) close to FTARGT
C     and give the additional increment DI such that F(I+DI)+FTARGT,
C     where F(I+DI) is interpreted as the linear interpolation of F.
C
      DIMENSION XVAL(2,N),F(0:N)
C
      NROOTS=0
      DO 100 I=1,N
         F1=F(I-1)
         F2=F(I)
         DF1=FTARGT-F1
         DF2=F2-FTARGT
         IF (DF1*DF2.GE.0.0) THEN
            NROOTS=NROOTS+1
            DF=F2-F1
            IF (DF.EQ.0) THEN
               DI=0.5
            ELSE
               DI=(FTARGT-F1)/DF
            ENDIF
            XVAL(1,NROOTS)=FLOAT(I-1)
            XVAL(2,NROOTS)=DI
         ENDIF
  100 CONTINUE
      RETURN
      END
      SUBROUTINE VSQRT(A,N)
      DIMENSION  A(1)
      DO 100 I = 1, N
 100     A(I) = SQRT(A(I))
      RETURN
      END
      SUBROUTINE VCNVERT(A,N)
      REAL*4 A(1)
      DO 100 I=1,N
         CALL CONVERT(A(I))
  100 CONTINUE
      RETURN
      END
      SUBROUTINE CONVERT(T)
C
      CHARACTER*12 VC
      CHARACTER*1  V1(12)
      EQUIVALENCE (V1,VC)
      CHARACTER*1  CSIGN
C
      REAL*4 W
      CHARACTER*4  WC
      CHARACTER*1  W1(4)
      EQUIVALENCE (W1,W)
      EQUIVALENCE (W1,WC)
C
      CHARACTER*1 ALPH64(0:63)
      SAVE        ALPH64
      DATA        ALPH64 
     $  /'1','2','3','4','5','6','7','8','9','0'
     $   ,'a','b','c','d','e','f','g','h','i','j'
     $   ,'k','l','m','n','o','p','q','r','s','t'
     $   ,'u','v','w','x','y','z'
     $   ,'A','B','C','D','E','F','G','H','I','J'
     $   ,'K','L','M','N','O','P','Q','R','S','T'
     $   ,'U','V','W','X','Y','Z','+','-'/
C
C     Find out the usual decimal format for T
C
      WRITE(VC,10) T
   10 FORMAT(E12.5)
C
C     Begin converting the mantissa to base 64
C
      READ(VC,11) MANTIS
   11 FORMAT(3X,I5)
C
C     Sign?
C
      READ(VC,12) CSIGN
   12 FORMAT(A1)
      IF (CSIGN.EQ.'-') MANTIS=-MANTIS
      MANTIS=MANTIS+131072
C
C     ONES,TENS, HUNDREDS
C
      IONE=MOD(MANTIS,64)
      ITMP=MANTIS/64
      ITEN=MOD(ITMP,64)
      ITMP=ITMP/64
      IHUN=MOD(ITMP,64)
C
C     Exponent
C
      READ(VC,21) IEXP
   21 FORMAT(9X,I3)
C     We assume that the exponent is bounded by 31.
      IEXP=IEXP+31
C
C     Compute alpha equivalent
C
      W1(1)=ALPH64(IHUN)
      W1(2)=ALPH64(ITEN)
      W1(3)=ALPH64(IONE)
      W1(4)=ALPH64(IEXP)
C
C     Convert the input value
      T=W
      RETURN
      END
      SUBROUTINE DELTMP
      INCLUDE  'basics.inc'
      character*80 command
C     Remove all tmp.* files
C
      CALL BLANK(COMMAND,80)
      IF(IFVMS)THEN
C        VMS
         IERR=0
      ELSE
C        Ultrix
         write(command,10) 
   10    format('rm tmp.*')
         CALL SYSTEM(command)
      ENDIF
      RETURN
      END
c-----------------------------------------------------------------------
      function iglmax(a,n)
      integer a(1)
      iglmax=-999999999
      do 100 i=1,n
         iglmax=max(iglmax,a(i))
  100 continue
      return
      end
c-----------------------------------------------------------------------
      FUNCTION GLMAX(A,N)
      DIMENSION A(N)
      TEMP = A(1)
      DO 10 I=1,N
         TEMP = MAX(TEMP,A(I))
   10 CONTINUE
      GLMAX=TEMP
      RETURN
      END
      FUNCTION GLMIN(A,N)
      DIMENSION A(N)
      TEMP = A(1)
      DO 10 I=1,N
         TEMP = MIN(TEMP,A(I))
   10 CONTINUE
      GLMIN=TEMP
      RETURN
      END
      FUNCTION MOD1(I,N)
C
C     Yields MOD(I,N) with the exception that if I=K*N, result is N.
C
      MOD1 = 1
      IF (N.EQ.0) THEN
         CALL PRS(
     $  'WARNING:  Attempt to take MOD(I,0) in FUNCTION MOD1.$')
         RETURN
      ENDIF
      II = I+N-1
      MOD1 = MOD(II,N)+1
      RETURN
      END
      INTEGER FUNCTION INDX1(S1,S2,L2)
      CHARACTER*80 S1,S2
C
      N1=80-L2+1
      INDX1=0
      IF (N1.LT.1) RETURN
C
      DO 100 I=1,N1
         I2=I+L2-1
         IF (S1(I:I2).EQ.S2(1:L2)) THEN
            INDX1=I
            RETURN
         ENDIF
  100 CONTINUE
C
      RETURN
      END
      INTEGER FUNCTION NINDX1(S1,S2,L2)
C
C     Return index of first character Not equal to S2
C
      CHARACTER*80 S1,S2
C
      N1=80-L2+1
      NINDX1=0
      IF (N1.LT.1) RETURN
C
      DO 100 I=1,N1
         I2=I+L2-1
         IF (S1(I:I2).NE.S2(1:L2)) THEN
            NINDX1=I
            RETURN
         ENDIF
  100 CONTINUE
C
      RETURN
      END
c-----------------------------------------------------------------------
      subroutine ifill(x,i,n)
      integer x(1)
      do j=1,n
         x(j)=i
      enddo
      return
      end
c-----------------------------------------------------------------------
      function glsum(a,n)
      real a(1),tsum
      tsum= 0
      do i=1,n
         tsum=tsum+a(i)
      enddo
      glsum=tsum
      return
      end
C-----------------------------------------------------------------------
      subroutine add2s1(x,y,c,n)
      real x(1),y(1),c
      do i=1,n
         x(i) = c*x(i) + y(i)
      enddo
      return
      end
c-----------------------------------------------------------------------
      subroutine add2s2(x,y,c,n)
      real x(1),y(1),c
      do i=1,n
         x(i) = x(i) + c*y(i)
      enddo
      return
      end
c-----------------------------------------------------------------------
      subroutine cmult2(x,y,c,n)
      real x(1),y(1),c
      do i=1,n
         x(i) = c*y(i)
      enddo
      return
      end
c-----------------------------------------------------------------------
      subroutine cadd(x,c,n)
      real x(1),c
      do i=1,n
         x(i) = x(i)+c
      enddo
      return
      end
c-----------------------------------------------------------------------
      subroutine normalize(x,n)
      real x(1)
      s = 0.
      do i=1,n
         s = s + x(i)*x(i)
      enddo
      if (s.gt.0) then
         s = 1./sqrt(s)
         do i=1,n
            x(i) = s*x(i)
         enddo
      endif
      return
      end
c-----------------------------------------------------------------------
