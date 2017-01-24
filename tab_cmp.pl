#!/usr/bin/env perl

use strict;
use Data::Dumper;
use Term::ANSIColor;

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

# read tables from files
my @ods_tab = &read_table_from_file( shift @ARGV );
my @dwh_tab = &read_table_from_file( shift @ARGV );

my ($long_tab, $short_tab) = undef;

# we looking for table with more columns
if ( (scalar @ods_tab) >= (scalar @dwh_tab) ) {
    $long_tab  = \@ods_tab;
    $short_tab = \@dwh_tab;         
}
else {
    $long_tab  = \@dwh_tab;
    $short_tab = \@ods_tab;         
}


foreach my $long_ref ( @$long_tab ) {
    my $short_ref = shift @$short_tab;

    # compare column name
    if($$long_ref[0] ne $$short_ref[0]) {
        my $txt = $$long_ref[0] . "\t\t" . $$long_ref[1];
        $txt .= '(' . $$long_ref[2] . ')' if defined $$long_ref[2];

        $txt .= "\t\t\t" . $$short_ref[0] . "\t\t" . $$short_ref[1];
        $txt .= '(' . $$short_ref[2] . ')' if defined $$short_ref[2];

        print colored($txt, 'bold'), "\n";
        next;
    }
}

