package Test2::Tools::Class;

use strict;
use warnings;

use Attribute::Handlers;
use Test2::Tools::Basic 'done_testing';

our $VERSION = '0.01';

my @tests;

sub Test :ATTR(CODE) {
	my ($package, $typeglob, $sub, $name) = @_;
	push @tests, $sub;
}

sub runtests {
	for (@tests) {
		$_->();
	}
	done_testing();
}

1;
