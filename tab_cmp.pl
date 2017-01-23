#!/usr/bin/env perl

use strict;
use Data::Dumper;

sub read_table_from_file($) {
    my $filename = shift;

    my $col = undef;
    my $atr = undef;
    my $size = undef;
    my @array_array = ();

    open(FD, $filename) or die "Subor $filename nemozno otvorit pre citanie.\n";

    while(<FD>) {
        chomp;
        # Vsetky biele znaky na zaciatku riadku zmazat
        s/^\s*//g;

        # rozdelenie na zaklade mnozstva bielych znakov
        ($col, $atr) = split /\s+/;

        # ak atribut obsahuje zatvorku, zaujima ma aj jeho presnost
        if ( $atr =~ /\(/ ) {
            ($atr, $size) = split /\(|\)/, $atr;
            push @array_array, [$col, $atr, $size];
        }
        else {
            push @array_array, [$col, $atr];
        }
    }

return @array_array;
}



### main #

