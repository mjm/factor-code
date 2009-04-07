! Copyright (C) 2009 Matt Moriarity.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays io.encodings.binary io.files kernel math
sequences sequences.repeating ;
IN: crypto

MIXIN: cipher

GENERIC: encode ( in-bytes cipher -- out-bytes )
GENERIC: decode ( in-bytes cipher -- out-bytes )
GENERIC: reverse-cipher ( encoder -- decoder )

GENERIC: encode-file ( out-path in-path cipher -- )
GENERIC: decode-file ( out-path in-path cipher -- )

M: cipher decode
    reverse-cipher encode ;

: change-file ( out-path in-path quot -- )
    [ binary file-contents ] dip call swap binary set-file-contents ; inline

M: cipher encode-file
    [ encode ] curry change-file ;

M: cipher decode-file
    [ decode ] curry change-file ;

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