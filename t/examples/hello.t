use Test2::Tools::xUnit;
use Test2::V0;

sub startup : BeforeAll {
    my $self = shift;

    $self->{true}  = 1;
    $self->{false} = 0;
}

sub shutdown : AfterAll {}

sub setup : BeforeEach {}

sub teardown : AfterEach {}

sub hello_world : Test {
    my $self = shift;

    ok $self->{true};
}

sub hello_again_world : Test Skip {
    my $self = shift;

    ok $self->{true}, 'pass';
    ok $self->{true}, 'pass again';
}

sub hello_again_world_skip_with_reason : Test Skip(A Good Reason) {
    my $self = shift;

    ok $self->{true}, 'pass';
    ok $self->{true}, 'pass again';
}

sub hello_again_world_todo : Test Todo(Not done yet) {
    my $self = shift;

    ok $self->{false}, 'fail';
    ok $self->{true},  'unexpected pass';
}

done_testing;
