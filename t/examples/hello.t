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

sub hello_again_world : Test Skip {
    ok( 1, "pass" );
    ok( 1, "pass again" );
}

sub hello_again_world_skip_with_reason : Test Skip(A Good Reason) {
    ok( 1, "pass" );
    ok( 1, "pass again" );
}

sub hello_again_world_todo : Test Todo(Not done yet) {
    ok( 0, "fail" );
    ok( 1, "unexpected pass" );
}

done_testing();
