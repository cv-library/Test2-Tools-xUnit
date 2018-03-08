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

sub hello_again_world : Test(7) Disabled("sucks") {
    ok( 1, "pass" );
    ok( 1, "pass again" );
}

done_testing();
