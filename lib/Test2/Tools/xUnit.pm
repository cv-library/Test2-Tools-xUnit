package Test2::Tools::xUnit;

use strict;
use warnings;

use B;
use Carp qw/croak/;
use Importer ();
use Test2::Workflow
    qw/parse_args build current_build root_build init_root build_stack/;
use Test2::Workflow::Runner();
use Test2::Workflow::Task::Action();
use Test2::Workflow::Task::Group();
use Test2::Tools::Mock();

our $VERSION = '0.01';

my %HANDLED;

sub import {
    my $class  = shift;
    my @caller = caller(0);

    no strict 'refs';
    *{ $caller[0] . '::MODIFY_CODE_ATTRIBUTES' } = \&handle_attributes;

    my %root_args;
    my %runner_args;
    my @import;
    while ( my $arg = shift @_ ) {
        if ( $arg =~ s/^-// ) {
            my $val = shift @_;

            if ( Test2::Workflow::Runner->can($arg) ) {
                $runner_args{$arg} = $val;
            }
            elsif ( Test2::Workflow::Task::Group->can($arg) ) {
                $root_args{$arg} = $val;
            }
            elsif ( $arg eq 'root_args' ) {
                %root_args = ( %root_args, %$val );
            }
            elsif ( $arg eq 'runner_args' ) {
                %runner_args = ( %runner_args, %$val );
            }
            else {
                croak "Unrecognized arg: $arg";
            }
        }
        else {
            push @import => $arg;
        }
    }

    if ( $HANDLED{ $caller[0] }++ ) {
        croak "Package $caller[0] has already been initialized"
            if keys(%root_args) || keys(%runner_args);
    }
    else {
        my $root = init_root(
            $caller[0],
            frame => \@caller,
            code  => sub {1},
            %root_args,
        );

        my $runner = Test2::Workflow::Runner->new(%runner_args);

        Test2::Tools::Mock->add_handler(
            $caller[0],
            sub {
                my %params = @_;
                my ( $class, $caller, $builder, $args )
                    = @params{qw/class caller builder args/};

                my $do_it = eval
                    "package $caller->[0];\n#line $caller->[2] \"$caller->[1]\"\nsub { \$runner\->add_mock(\$builder->()) }";

                # Running
                if ( @{ $runner->stack } ) {
                    $do_it->();
                }
                else {    # Not running
                    my $action = Test2::Workflow::Task::Action->new(
                        code     => $do_it,
                        name     => "mock $class",
                        frame    => $caller,
                        scaffold => 1,
                    );

                    my $build = current_build() || $root;

                    $build->add_primary_setup($action);
                    $build->add_stash( $builder->() ) unless $build->is_root;
                }

                return 1;
            }
        );

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
    }

    Importer->import_into( $class, $caller[0], @import );
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
        elsif ( $attr =~ m/^Skip(?:\((.+)\))?/i ) {
            $options{skip} = $1 || $name;
        }
        elsif ( $attr =~ m/^Todo(?:\((.+)\))?/i ) {
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
