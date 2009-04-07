! Copyright (C) 2009 Matt Moriarity.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math sequences ;
IN: crypto

GENERIC# encode 1 ( cipher in-bytes -- out-bytes )
GENERIC# decode 1 ( cipher in-bytes -- out-bytes )

TUPLE: caesar-cipher { key integer } ;
C: <caesar-cipher> caesar-cipher

: shift ( n byte -- byte )
    + 255 mod dup 0 < [ 255 + ] [ ] if ;

M: caesar-cipher encode
    [ key>> ] dip [ dupd shift ] map nip ;