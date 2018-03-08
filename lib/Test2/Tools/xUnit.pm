package Test2::Tools::xUnit;

use strict;
use warnings;

use B;
use Carp qw/croak/;
use Test2::Workflow qw/current_build root_build init_root/;
use Test2::Workflow::Runner();
use Test2::Workflow::Task::Action();

our $VERSION = '0.01';

sub import {
    my $class  = shift;
    my @caller = caller(0);

    my $root = init_root(
        $caller[0],
        frame => \@caller,
        code  => sub {1},
    );

    my $runner = Test2::Workflow::Runner->new();

    my $stack = Test2::API::test2_stack;
    $stack->top;    # Insure we have a hub
    my ($hub) = Test2::API::test2_stack->all;
    $hub->set_active(1);
    $hub->follow_up(
        sub {
            return unless $root->populated;
            my $g = $root->compile;
            $runner->push_task($g);
            $runner->run;
        }
    );

    no strict 'refs';
    *{ $caller[0] . '::MODIFY_CODE_ATTRIBUTES' } = \&handle_attributes;
}

# This gets exported into the caller's namespace as MODIFY_CODE_ATTRIBUTES.
sub handle_attributes {
    my ( $pkg, $code, @attrs, @unhandled ) = @_;

    my $name = B::svref_2object($code)->GV->NAME;
    my ( $method, %options );

    for my $attr (@attrs) {
        if ( $attr eq 'Test' ) {
            $method = 'add_primary';
        }
        elsif ( $attr eq 'BeforeEach' ) {
            $method = 'add_primary_setup';
            $options{scaffold} = 1;
        }
        elsif ( $attr eq 'AfterEach' ) {
            $method = 'add_primary_teardown';
            $options{scaffold} = 1;
        }
        elsif ( $attr eq 'BeforeAll' ) {
            $method = 'add_setup';
            $options{scaffold} = 1;
        }
        elsif ( $attr eq 'AfterAll' ) {
            $method = 'add_teardown';
            $options{scaffold} = 1;
        }
        elsif ( $attr =~ m/^Skip(?:\((.+)\))?/ ) {
            $options{skip} = $1 || $name;
        }
        elsif ( $attr =~ m/^Todo(?:\((.+)\))?/ ) {
            $options{todo} = $1 || $name;
        }
        else {
            push @unhandled, $attr;
        }
    }

    if ($method) {
        my ( undef, $filename, $linenum ) = caller 2;

        my $task = Test2::Workflow::Task::Action->new(
            code  => $code,
            frame => [ $pkg, $filename, $linenum ],
            name  => $name,
            %options,
        );

        my $current = current_build() || root_build($pkg)
            or croak "No current workflow build!";

        $current->$method($task);
    }

    return @unhandled;
}

1;
