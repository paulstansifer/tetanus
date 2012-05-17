#!/usr/bin/perl

$| = 1; #flush output buffers all the time

$cont_line = 0;

while (<>) {
    print "$1 " if /(CFG_[nA-Z_]*)/;
    last if /including test rules/ or not /^cfg:/;
}

while (<>) {
    if (/^compiletime:/) { print "\n$_"; last; }

    #make
    if (/^make:/) { 
        print "\n$_" if (/[*][*][*]/);
        next;
    }


    next if /[.][ch]:[0-9]+:[0-9]+: warning/; #skip C warnings
    next if /^\s*rm / or /^\s*cp /;
    if (/^got download/) { print "\n$_"; next; }
    if (m|^[^/ ]*/stage(.)/bin/rustc[^&]*/(\w+.r[cs])|) {
        $stage = $1+1;
        print "[$2 @ $stage]"; #because it's building the *next* stage
        next;
    }

    #compile error
    if (/^([^ ]*\D):\d.{0,26}(warning|error)/i) {
        $cont_line = $1;
        $drop_chars = length $_;
        s/^[^ ]*?rust/rust/;
        $drop_chars -= length $_;
        print "\n$_"; next;
    }
    if ($cont_line and (/^\Q$cont_line\E/ or /^ *\^/)) {
        print substr("$_", $drop_chars); next;
    } else {
        $cont_line = 0;
    }

    #tidy problems
    if (/^IOError:/) { print "\n$_"; next; }
    if (/trailing whitespace/) { s/^[^ ]*?rust/rust/; print "\n$_"; next; }

    #spanless errors
    if (/.{0,6}error:/) { print "\n$_"; next; }

    print ".";
}

$line_ct = 0;
$dash_pfx = "";
$print_dashlines = 0;


while(<>) {
    if (/^-{40}/) { $dashlines--; next; }
    if ($dashlines >= 1) { 
        print if $print_dashlines;
        next;
    } else {
        $print_dashlines = 0;
    }
    
    next if (/^\s*$/);

    #make
    if (/^make:/) { 
        print "\n$_" if (/[*][*][*]/);
        next;
    }

    if (/^result:\s*([^.]+)\.\s*(\d+) passed; (\d+) failed; (\d+) ignored/) {
        print "[$1:$2/$3/$4]"; next;
    }
    if (/ \.\.\. FAILED/) {
        print "\n$_"; next;
    }

    #test errors
    if (/^error:/) {
        print "\n$_"; $prints = 1; next;
    }
    if (/^std...:/) {
        $print_dashlines = 1;
        chop; chop;
        print "\n---  $_  ---\n"; $dashlines = 2; next;
    }
    if (/^------stdout/) {
        $print_dashlines = 0;
        $dashlines = 1;
    }

    #ending
    if (/^summary of/) { print "\n$_"; next; }
    if (/^testtime:[^:]/) { print; next; }


    if ($prints-- >= 1) { print; next; }

    print "." if ($line_ct++ % 5 == 0);
}

