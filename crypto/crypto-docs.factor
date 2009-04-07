USING: byte-arrays crypto help.markup help.syntax ;

HELP: encode
{ $values { "in-bytes" byte-array } { "cipher" cipher } { "out-bytes" byte-array } }
{ $description "Uses " { $snippet "cipher" } " to encode the bytes in " { $snippet "in-bytes" } "." } ;