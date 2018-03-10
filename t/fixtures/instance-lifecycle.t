use Test2::Tools::xUnit;
use Test2::V0;

sub check_empty_list : Test {
    is scalar @{shift->{list}}, 0, "list should be empty";
}

sub add_one_to_list : Test {
    my $self = shift;
    push @{$self->{list}}, "one";
    is scalar @{$self->{list}}, 1, "list should have one element";
}

sub check_empty_list_again : Test {
    is scalar @{shift->{list}}, 0, "list should be empty";
}

done_testing;
