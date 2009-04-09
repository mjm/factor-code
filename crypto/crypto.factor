! Copyright (C) 2009 Matt Moriarity.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays io.encodings.binary io.files
kernel math math.order random sequences sequences.repeating sorting
strings ;
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
    + 256 mod dup 0 < [ 256 + ] when ;

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

ERROR: short-pad ;

: check-pad-length ( message pad -- )
    [ length ] bi@ > [ short-pad ] when ;

M: vernam-cipher encode
    key>> 2dup check-pad-length [ bitxor ] 2map ;

M: vernam-cipher reverse-cipher ;

: vernam-pad ( n -- bytes )
    random-bytes >byte-array ;

! cracking the caesar cipher

: sum ( seq -- number )
    0 [ + ] reduce ;

: freq-table ( bytes -- freq-table )
    256 0 <array> [ dupd swap [ 1 + ] change-nth ] reduce ;

: normalize ( freq-table -- freq-table' )
    dup sum >float [ / ] curry map ;

: corpus ( path -- freq-table )
    binary file-contents freq-table normalize ;

: table ( bytes -- freq-table )
    freq-table normalize ;

TUPLE: guess { cipher caesar-cipher initial: f } { quality float } ;

: <guess> ( shift quality -- guess )
    [ <caesar-cipher> ] dip guess boa ;

: shift-seq ( seq shift -- seq' )
    cut-slice swap append ;

: create-guess ( shift corpus freqs -- guess )
    [ dup ] 2dip rot shift-seq [ - abs ] 2map sum <guess> ;

: sort-guesses ( guesses -- guesses' )
    [ [ quality>> ] bi@ <=> ] sort ;

: caesar-guesses ( corpus encoded -- guesses )
    table [ create-guess ] 2curry 256 swap map sort-guesses ;

: test-strings ( guesses encoded -- seq )
    50 head [ swap cipher>> decode >string ] curry map ;