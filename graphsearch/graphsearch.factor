! Copyright (C) 2009 Matt Moriarity.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques dlists graph-theory hashtables kernel
locals sequences sets vectors ;
IN: graphsearch

TUPLE: vertex
data
{ neighbors hashtable } ;

: <vertex> ( data -- vertex )
    vertex new swap >>data H{ } clone >>neighbors ;

: (connect) ( vertex1 vertex2 weight -- )
    spin neighbors>> set-at ;

: connect ( vertex1 vertex2 weight -- )
    3dup swapd (connect) (connect) ;

TUPLE: undirected-graph
{ vertices vector } ;
INSTANCE: undirected-graph graph

: <undirected-graph> ( -- graph )
    undirected-graph new V{ } clone >>vertices ;

M: undirected-graph vertices
    vertices>> [ data>> ] map ;

M: undirected-graph add-blank-vertex
    vertices>> [ <vertex> ] dip push ;

: find-vertex ( index graph -- vertex )
    vertices>> [ dupd data>> = ] find -rot 2drop ;

: find-vertices ( a b graph -- vertex-a vertex-b )
    dup -rot [ find-vertex ] 2bi@ ;

M: undirected-graph add-edge
    find-vertices 1 connect ;

M: undirected-graph adjlist
    find-vertex neighbors>> keys ;

: <path-queue> ( vertex -- deque )
    1vector <dlist> swap over push-front ;

: <visited-set> ( graph -- seq )
    num-vertices <vector> ;

: 3dupd ( x y z w -- x y z x y z w )
    [ 3dup ] dip ;

: push-neighbors ( queue path visited vertex -- )
    neighbors>> keys [ 3dupd swap dupd member?
                       [ 3drop ]
                       [ suffix swap push-front ]
                       if ] each 3drop ;

: visit-vertex ( visited queue -- path vertex )
    pop-back dup peek rot dupd adjoin ;

:: (find-path) ( end visited queue -- seq )
    queue deque-empty? [ f ] [
        visited queue visit-vertex dup end = [ drop ] [
            [ queue swap visited ] dip push-neighbors
            end visited queue (find-path)
        ] if
    ] if ;

: find-path ( start end graph -- seq )
    [ find-vertices swap <path-queue> ] keep
    <visited-set> swap (find-path) [ data>> ] map ;