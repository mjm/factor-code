USING: byte-arrays crypto tools.test ;

! shift tests
[ 49 ] [ 3 46 shift ] unit-test
[ 25 ] [ -6 31 shift ] unit-test
[ 0 ] [ 6 250 shift ] unit-test
[ 1 ] [ 7 250 shift ] unit-test
[ 251 ] [ -10 5 shift ] unit-test

! caesar encoding test
[ B{ 4 5 6 } ]
[ B{ 1 2 3 } 3 <caesar-cipher> encode ] unit-test
[ B{ 255 0 1 2 } ]
[ B{ 250 251 252 253 } 5 <caesar-cipher> encode ] unit-test

! caesar decoding test
[ B{ 1 2 3 } ]
[ B{ 4 5 6 } 3 <caesar-cipher> decode ] unit-test
[ B{ 250 251 252 253 } ]
[ B{ 255 0 1 2 } 5 <caesar-cipher> decode ] unit-test

! vigenere encoding test
[ B{ 3 5 7 } ]
[ B{ 2 3 4 } B{ 1 2 3 } <vigenere-cipher> encode ] unit-test
[ B{ 98 100 102 101 103 105 } ]
[ "abcdef" >byte-array B{ 1 2 3 } <vigenere-cipher> encode ] unit-test
[ B{ 98 100 102 101 103 } ]
[ "abcde" >byte-array B{ 1 2 3 } <vigenere-cipher> encode ] unit-test

! vigenere decoding test
[ B{ 2 3 4 } ]
[ B{ 3 5 7 } B{ 1 2 3 } <vigenere-cipher> decode ] unit-test
[ B{ 97 98 99 100 101 102 } ]
[ "bdfegi" >byte-array B{ 1 2 3 } <vigenere-cipher> decode ] unit-test
[ B{ 97 98 99 100 101 } ]
[ "bdfeg" >byte-array B{ 1 2 3 } <vigenere-cipher> decode ] unit-test

! vernam encoding test
[ B{ 5 7 5 } ]
[ B{ 1 2 3 } B{ 4 5 6 } <vernam-cipher> encode ] unit-test

! vernam decoding test
[ B{ 1 2 3 } ]
[ B{ 5 7 5 } B{ 4 5 6 } <vernam-cipher> decode ] unit-test