package Hello;

use parent 'Test2::Tools::Class';

use Test2::V0;

sub test : Test {
	ok(1);
}

Test2::Tools::Class->runtests();
