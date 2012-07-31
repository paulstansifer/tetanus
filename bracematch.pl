#!/usr/bin/perl

local $/ = undef;

$_ = <>;

#  `#m[...]` -> `m!{...}`
s/\#(\w+)  #macro head (`#fmt`, etc.)
      [[(]
      ( #2nd capture group
        (?:
          [[({]
          (?2)
          [])}]
        |
          [^][)(}{]
        )*
      )
      [])]
/($1 ne "macro" and $1 ne "ast")? "$1!{$2}" : ("#"."$1"."[$2]") /gxse;

print;

