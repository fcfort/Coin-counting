#!perl

use Data::Dumper;
use strict;
use warnings;
 use List::Util qw(min sum);
 
use Test::Simple tests => 6;
	ok(change_coin_count(25,[5]) == 5);
	ok(change_coin_count(5,[5]) == 1);
	ok(change_coin_count(5,[]) == 0);
	ok(change_coin_count(50,[50,5,10]) == 1);
	ok(change_coin_count(95, [100,5]) == 19);
	ok(change_coin_count(5, [5,33]) == 1);
	
use Math::Combinatorics;

my @coin_values = map { 5 * $_ } 2..19;

# Enumerate all combinations of 5 cent coins choose 4
# i.e. [5,10,15,...,95]
my $combinat = Math::Combinatorics->new(
	count => 3,
	data => [@coin_values],
);

my %avg_coin_map;

while(my @combo = $combinat->next_combination) {
	# print "Examining " . join(",", @combo) . "\n";
	
	# For each change possibility [5,10,15,...,95] calculate how many coins are minimally required to make change	
	my @coin_counts;
	for my $change_value ( 5, @coin_values ) {		
		my $count = change_coin_count($change_value, [5,@combo]);
		# print "Got coin count of $count change for $change_value\n";
		push(@coin_counts, $count);		
	}
	# print "Got array of coin counts: " . join("," , @coin_counts) . "\n";
	
	# Average those numbers
	my $average = avg(\@coin_counts);
	
	print "For combo " . join(",", @combo) . ", got average of $average\n";
	# Store for that combo
	$avg_coin_map{join(",", sort {$a <=> $b} (5,@combo)) } = $average ;
}

# Print ordered lists
for my $combo ( sort { $avg_coin_map{$b} <=> $avg_coin_map{$a} } keys %avg_coin_map ) {
	print "For combo $combo, got value " . $avg_coin_map{$combo} . "\n";
}

sub change_coin_count {
		my ($value, $coin_set) = @_;

		my %coin_map = map { $_ => 1 } @$coin_set;

		return change_coin_count_helper($value, \%coin_map);
}

sub change_coin_count_helper {
		my ($value, $coin_set) = @_;

		# print "Calling with $value and coin set " . join(",", keys %$coin_set) . "\n";
		# Clone coin_set
		# Delete coin from set if it's too big	
		my %new_coin_set = map { $_ => 1 } grep { $value - $_ >=  0 } keys %$coin_set;

		# If set of coins empty, return 0
		if ( scalar(keys %new_coin_set) == 0 ) {
				# print "Found leaf node\n";
				return 0;
		}

		return min(map { 1 + change_coin_count_helper($value - $_, \%new_coin_set) } keys %new_coin_set);
}

sub avg {
	my @array = @{$_[0]};
	return sum(@array) / @array;
}