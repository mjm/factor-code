! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math math.blas.matrices math.blas.vectors
math.functions math.ranges sequences tools.time ;
IN: math-project

: bench ( quot -- )
    [ 1000 swap times ] time ; inline

: cross-2each ( seq1 seq2 quot -- )
    [ with each ] 2curry each ; inline

! :: (gen-matrix) ( matrix quot i j -- matrix quot )
!     i j quot call i j matrix Mset-nth matrix quot ;

! : gen-matrix ( rows cols quot -- matrix )
!     [ [ dmatrix{ { } } <empty-matrix> ] 2keep ] dip -rot [ (gen-matrix) ] cross-2each drop ;

! :: Mchange-nth ( matrix quot i j -- matrix quot )
!     i j quot call i j matrix Mset-nth matrix quot ; inline
 
:: gen-matrix ( rows cols quot -- matrix )
    rows cols [ swap [ quot call ] curry map ] curry map >double-blas-matrix ; inline

: input-matrix ( size -- matrix )
    dup [ [ 1+ ] bi@ 1- + 1 swap / ] gen-matrix ;

: input-vector ( size -- vector )
    0.1 over 3 / ^ <array> >double-blas-vector ;

: e1 ( size -- vector )
    1- 0 <array> 1.0 1array swap append >double-blas-vector ;

! Below implementation is faster
! : hh-vector ( vector -- vector' )
!     dup [ Vnorm ] [ first sgn ] [ length e1 ] tri n*V! n*V! V+ ;

: hh-vector ( vector -- vector' )
    clone 0 over dup Vnorm [ + ] curry change-nth ;

: identity ( size -- matrix )
    dup [ = [ 1.0 ] [ 0.0 ] if ] gen-matrix ;

: householder ( vector -- matrix )
    [ length identity ] keep [ 2.0 ] dip hh-vector Vnormalize dup n*V(*)V M- ;

! later: see if this can be done easily without locals
:: (hh-pad) ( size start matrix -- matrix )
    size identity size start - dup [| i j |
        dup [ i j matrix Mnth i start + j start + ] dip Mset-nth
    ] cross-2each ;

: hh-pad ( size matrix -- matrix )
    [ Mheight ] keep [ dupd - ] dip (hh-pad) ;

: sub-matrix ( matrix start -- matrix )
    [ dup Mheight ] dip [ - dup ] keep dup Msub ;

: hh-reduce ( R Q i -- R Q )
    pick swap sub-matrix Mcols first householder over Mheight swap hh-pad
    tuck M. spin M. swap ;

: QR-householder ( A -- Q R )
    dup [ Mheight identity ] [ Mheight ] bi 1 [a,b) [ hh-reduce ] each swap ;

: pivot ( A i -- A i pivot )
    2dup dup spin Mnth ;

: ~= ( a b -- ? )
    0.00000001 ~ ;

! : ones ( exemplar -- vector )
!     length 1.0 <array> >double-blas-vector ;

: fix-pivot-row ( A i pivot -- A i )
    recip [ 2dup ] dip spin Mrows nth n*V! drop ;

: eliminate-cell ( vec i pivot-vec -- )
    -rot over nth neg -rot n*V+V! drop ;

: (eliminate-column) ( A i -- )
    swap dupd [ Mrows swap head ] [ Mrows nth ] 2bi swapd
    [ eliminate-cell ] 2curry each ;

: eliminate-column ( A pivot -- A' )
    pivot dup 0 ~= [ 2drop ] [ fix-pivot-row dupd (eliminate-column) ] if ;

: back-sub ( matrix -- matrix )
    dup Mheight 0 (a,b] [ eliminate-column ] each ;

: augmentV ( A b -- A|b )
    [ Mcols ] dip suffix >double-blas-matrix Mtranspose ;

: solution ( A -- x )
    Mcols peek ;

: solve-QR ( Q R b -- x )
    [ swap Mtranspose ] dip M.V augmentV back-sub solution ;