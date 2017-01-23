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

sub print_help() {
    print << "END_OF_HELP";

Je potrebne zadat nazvy dvoch suborov, v torych sa nachadza popis tabuliek.
Ako prvy argument je tabulka z ODSky, alebo zdrojova tabulka.
Druhy argument je popis tabulky z odberatelskeho systemu.

END_OF_HELP

exit 1;
}



### main #
# Je potrebne porovnat 2 tabulky
&print_help if( (scalar @ARGV) != 2 );

