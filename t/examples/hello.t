use Test2::Tools::xUnit;
use Test2::V0;

sub startup : BeforeAll {
}

sub shutdown : AfterAll {

}

sub setup : BeforeEach {

}

sub teardown : AfterEach {
}

sub hello_world : Test {
    ok(1);
}

sub hello_again_world : Test Disabled {
    ok( 1, "pass" );
    ok( 1, "pass again" );
}

sub hello_again_world_todo : Test TODO {
    ok( 0, "pass" );
    ok( 0, "pass again" );
}

done_testing();
