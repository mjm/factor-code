! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions html.forms http.server
http.server.dispatchers logging namespaces ;
IN: crypto-web

TUPLE: crypto-app < dispatcher ;

: <form-action> ( -- action )
    <page-action>
        [
            "your message here" "message" set-value
            { "Caesar" "Vigenere" "Vernam" } "ciphers" set-value
            "Caesar" "cipher" set-value
        ] >>init
        { crypto-app "form" } >>template ;

: <process-action> ( -- action )
    <action>
        ! [
        !     ! {
        !     !     { "message" [ v-required ] }
        !     !     { "key" [ v-required ] }
        !     !     { "cipher" [ v-required ] }
        !     ! } validate-params
        ! ] >>validate
        [
            "key" value \ <process-action> NOTICE log-message
            { crypto-app "processed" } <chloe-content>
        ] >>submit ;

: <crypto-app> ( -- responder )
    crypto-app new-dispatcher
    <form-action> "" add-responder
    <process-action> "process" add-responder ;

: run-crypto ( -- )
    <crypto-app> main-responder set-global
    8080 httpd ;