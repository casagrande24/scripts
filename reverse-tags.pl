#!/usr/bin/perl

# usage: reverse-tag.pl <tags>

while (<>) {
    next if /^!/; # skip the header of tags format
    next if /^~/; # skip destructor functions in cpp
    chomp;

    /^([\w\.]*)\t.*/;
    $tagname = $1;
    next if ($tagname =~ /^$/);
    next if ($tagname eq $last);
    #print "------ tag name: [$tagname]\n";
    $last = $tagname;

    @global_rx = qx/global -rx $tagname/;
    if (@global_rx > 0) {
        foreach (@global_rx) {
            #print ">>> REF: $_\n";
            m#^(\w*)\s+(\d+)\s+([\w\/\.]*)\s(.*)$#;

            #print "> >>> tag:'$1'\n";
            #print "> >>> num:'$2'\n";
            #print "> >>> path:'$3'\n";
            #print "> >>> pattern:'$4'\n";
            $tag = $1;
            $path = $3;
            $pattern = $4;

            # ingore some patterns
            # e.g.) Foo.set() : this is not calling Foo.

            push @refernces, "$tag\t$path\t/^$pattern/\n";
            #print RTAGS "$tag\t$path\t/^$pattern/\n";
        }
    }

    #last if ($count++ > 10);
}

@sorted_refs = sort @refernces;

open(RTAGS, ">RTAGS");

print RTAGS <<HEADER;
! vim:filetype=tags
!_TAG_FILE_FORMAT   2   /extended format; --format=1 will not append ;" to lines/
!_TAG_FILE_SORTED   1   /0=unsorted, 1=sorted, 2=foldcase/
!_TAG_PROGRAM_AUTHOR    Tokikazu Ohya  /toki.ohya@gmail.com/
!_TAG_PROGRAM_NAME  Reverse Tag //
!_TAG_PROGRAM_URL   https://github.com/casagrande24/scripts //
!_TAG_PROGRAM_VERSION   0.1 //
HEADER

foreach (@sorted_refs) {
    print RTAGS  $_;
}
close(RTAGS);
