! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel locals math math.blas.matrices
math.blas.vectors math.functions sequences ;
IN: math-project

:: gen-matrix ( rows cols quot -- matrix )
    rows cols [ swap [ quot call ] curry map ] curry map >double-blas-matrix ;

: input-matrix ( size -- matrix )
    dup [ [ 1+ ] bi@ 1- + 1 swap / ] gen-matrix ;

: input-vector ( size -- vector )
    0.1 over 3 / ^ <array> >double-blas-vector ;

: e1 ( size -- vector )
    1- 0 <array> 1.0 1array swap append >double-blas-vector ;

! : hh-vector ( vector -- vector' )
!     dup [ Vnorm ] [ first sgn ] [ length e1 ] tri n*V! n*V! V+ ;

: hh-vector ( vector -- vector' )
    clone 0 over dup Vnorm [ + ] curry change-nth ;

: identity ( size -- matrix )
    dup [ = [ 1.0 ] [ 0.0 ] if ] gen-matrix ;

! : M+ ( matrix matrix -- matrix' )
!     [ Mrows ] bi@ [ V+ ] 2map >double-blas-matrix ;

! : M- ( matrix matrix -- matrix' )
!     [ Mrows ] bi@ [ V- ] 2map >double-blas-matrix ;

! : Vnormalize ( vector -- vector' )
!     dup Vnorm V/n ;

: householder ( vector -- matrix )
    [ length identity ] keep [ 2.0 ] dip hh-vector Vnormalize dup n*V(*)V M- ;

! : Mnth ( i j matrix -- number )
!     Mrows [ swap ] dip nth nth ;

:: (hh-pad) ( size start matrix -- matrix )
    size size [  ] gen-matrix ;

: hh-pad ( size matrix -- matrix )
    [ rows>> ] keep [ dupd - ] dip (hh-pad) ;