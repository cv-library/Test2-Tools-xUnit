package Test2::Tools::xUnit 0.001;

use strict;
use warnings;

use B;
use Test2::Workflow;
use Test2::Workflow::Runner;
use Test2::Workflow::Task::Action;

sub import {
    my @caller = caller;

    my $root = Test2::Workflow::init_root(
        $caller[0],
        code  => sub {},
        frame => \@caller,
    );

    Test2::API::test2_stack->top->follow_up(
        sub { Test2::Workflow::Runner->new( task => $root->compile )->run } );

    my $modify_code_attributes = sub {
        my ( undef, $code, @attrs ) = @_;

        my $name = B::svref_2object($code)->GV->NAME;

        my ( $method, %options, @unhandled );

        for (@attrs) {
            if ( $_ eq 'Test' ) {
                $method = 'add_primary';
            }
            elsif ( $_ eq 'BeforeEach' ) {
                $method = 'add_primary_setup';
                $options{scaffold} = 1;
            }
            elsif ( $_ eq 'AfterEach' ) {
                $method = 'add_primary_teardown';
                $options{scaffold} = 1;
            }
            elsif ( $_ eq 'BeforeAll' ) {
                $method = 'add_setup';
                $options{scaffold} = 1;
            }
            elsif ( $_ eq 'AfterAll' ) {
                $method = 'add_teardown';
                $options{scaffold} = 1;
            }
            elsif ( /^Skip(?:\((.+)\))?/ ) {
                $options{skip} = $1 || $name;
            }
            elsif ( /^Todo(?:\((.+)\))?/ ) {
                $options{todo} = $1 || $name;
            }
            else {
                push @unhandled, $_;
            }
        }

        if ($method) {
            my $task = Test2::Workflow::Task::Action->new(
                code  => $code,
                frame => \@caller,
                name  => $name,
                %options,
            );

            $root->$method($task);
        }

        return @unhandled;
    };

    no strict 'refs';

    *{"$caller[0]::MODIFY_CODE_ATTRIBUTES"} = $modify_code_attributes;
}

1;
