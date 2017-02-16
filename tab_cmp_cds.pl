#!/usr/bin/env perl

use strict;
use Term::ANSIColor;
use Data::Dumper;

# first column size = name of column
my $fcol = 32;
# second column size = data type of column
my $scol = 16;

# tables
my %tab1;
my %tab2;



sub read_table_from_file($) {
    my $filename = shift;

    my $col = undef;
    my $atr = undef;
    my $size = undef;
    my %tab_hash;

    open(FD, $filename) or die "I can't open file $filename for reading.\n";

    while(<FD>) {
        chomp;
        # All white on the starting line removed
        s/^\s*//g;
        # irrelevant for comparing
        s/NOT NULL//g;

        # Splitting by white characters
        ($col, $atr) = split /\s+/;

        # Number between () if exist
        if ( $atr =~ /\(/ ) {
            ($atr, $size) = split /\(|\)/, $atr;
            $tab_hash{$col} = {'datatype' => $atr, 'size' => $size};
        }
        else { $tab_hash{$col} = {'datatype' => $atr} }
    }
    close(FD);

return %tab_hash;
}


sub print_help() {
    print << "END_OF_HELP";

Je potrebne zadat nazvy dvoch suborov, v torych sa nachadza popis tabuliek pre porovnanie.
Pricom na poradi stlpcov nezalezi.
Two arguments. Both are name of file with description of table for comparing.
The order of the columns is not important.

END_OF_HELP

exit 1;
}




sub table_header($$) {
    my ($firt_tab_name, $second_tab_name) = @_;

    print "\n\nStandard text = without diffrencies.\n";
    print colored('Bold text = no important diffrencies between atributes types.', 'bold'), "\n";
    print colored('Bold and red text = important diffrencies.', 'bold red'), "\n\n";
    print ${firt_tab_name} . ' ' x ($fcol + $scol - length(${firt_tab_name})) . ${second_tab_name} . "\n";

    &hr;
    print "\n";
}


sub table_header_2($) {
    my $tab_name = shift;

    print "\n";
    &hr;
    print "\nThe remaining columns in the table ${tab_name}\n\n";
}

sub txt_tab_compose($$) {
    my($k, $tab) = @_;
    
    # column name
    my $txt = $k . ' ' x ($fcol - length($k));
    # datatype of column
    $txt .= $tab->{$k}->{'datatype'} ;
    
    # ( and ) for data precision
    $txt .= '(' . $tab->{$k}->{'size'} . ')' if $tab->{$k}->{'size'};
    
return $txt;
}

# <HR>
sub hr() {
    print '-' x (($fcol + $scol) * 2) . "\n";
}


sub txt_compose($) {
    my $k = shift;

    # first (left) table description
    my $txt = txt_tab_compose($k, \%tab1);
    
    # space between tables
    $txt .= ' ' x (($fcol + $scol) - length($txt));

    # second (right) table description
    $txt .= txt_tab_compose($k, \%tab2);
    
return $txt;
}




### main ###
# Two argumets are mandatory
&print_help if( (scalar @ARGV) != 2 );

# read tables from files
%tab1 = &read_table_from_file( $ARGV[0] );
%tab2 = &read_table_from_file( $ARGV[1] );

&table_header($ARGV[0], $ARGV[1]);

foreach my $k ( keys %tab1 ) {

    # labelling of text, if reason exist
    my $color_name = undef;
    # output text
    my $txt = undef;

    # at first compare same columns in both tables
  next unless($tab2{$k});

    # compare data type
    if($tab1{$k}->{'datatype'} ne $tab2{$k}->{'datatype'}) {
        # CHAR and VARCHAR2 specialities :-)
        # It's not same, but diffrencies are irelevant
        if( ($tab1{$k}->{'datatype'} =~ /CHAR/) and ($tab2{$k}->{'datatype'} =~ /CHAR/) and ($tab1{$k}->{'size'} == $tab2{$k}->{'size'}) ) {
            $color_name = 'bold';
        }
        else { $color_name = 'bold red'; }
    }
    elsif($tab1{$k}->{'size'} != $tab2{$k}->{'size'}) {
        $color_name = 'bold';
    }
    
    my $txt = &txt_compose($k);

    print color($color_name) if defined $color_name;
    print "$txt", "\n";
    print color('reset') if defined $color_name;

    delete $tab1{$k};
    delete $tab2{$k};
}


&table_header_2($ARGV[0]);

foreach my $k ( keys %tab1 ) {
    print &txt_tab_compose($k, \%tab1), "\n";
}

&table_header_2($ARGV[1]);

foreach my $k ( keys %tab2 ) {
    print &txt_tab_compose($k, \%tab2), "\n";
}

print "\n";
&hr;
print "\n";

