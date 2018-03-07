use Test2::Tools::xUnit;
use Test2::V0;

sub startup : Startup {
}

sub shutdown : Shutdown {

}

sub setup : Setup {

}

sub teardown : Teardown {
}

sub hello_world : Test {
    ok(1);
}

sub hello_again_world : Tests {
    ok( 1, "pass" );
    ok( 1, "pass again" );
}

done_testing();
