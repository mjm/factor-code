! Copyright (C) 2009 Matt Moriarity.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays kernel math sequences sequences.repeating
;
IN: crypto

MIXIN: cipher

GENERIC: encode ( in-bytes cipher -- out-bytes )
GENERIC: decode ( in-bytes cipher -- out-bytes )
GENERIC: reverse-cipher ( encoder -- decoder )

GENERIC: encode-file ( in-path out-path cipher -- )
GENERIC: decode-file ( in-path out-path cipher -- )

M: cipher decode
    reverse-cipher encode ;

TUPLE: caesar-cipher { key integer } ;
C: <caesar-cipher> caesar-cipher
INSTANCE: caesar-cipher cipher

: shift ( n byte -- byte )
    + 256 mod dup 0 < [ 256 + ] [ ] if ;

M: caesar-cipher encode
    key>> swap [ dupd shift ] map nip ;

M: caesar-cipher reverse-cipher
    clone [ neg ] change-key ;

TUPLE: vigenere-cipher { key byte-array } ;
C: <vigenere-cipher> vigenere-cipher
INSTANCE: vigenere-cipher cipher

M: vigenere-cipher encode
    key>> over length repeated [ shift ] 2map ;

M: vigenere-cipher reverse-cipher
    clone [ [ neg ] map ] change-key ;

TUPLE: vernam-cipher { key byte-array } ;
C: <vernam-cipher> vernam-cipher
INSTANCE: vernam-cipher cipher

M: vernam-cipher encode
    key>> [ bitxor ] 2map ;

M: vernam-cipher reverse-cipher ;