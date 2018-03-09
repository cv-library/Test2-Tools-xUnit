use Test2::V0;
use Test2::API 'intercept';

my $events = intercept {
    eval <<'END';
use Test2::Tools::xUnit;

sub foo : Test {
    ok(1, "pass");
}

done_testing;
END
};

is $events, array {
    event 'Subtest';
    event 'Plan';
    end;
}, 'Events should contain one subtest then a plan';

is $events->[0]->name, 'foo', 'Subtest should be named "foo"';
is $events->[0]->subevents, array {
    event 'Ok';
    event 'Plan';
    end;
}, 'Subtest should contain one Ok event then a plan';


done_testing;
