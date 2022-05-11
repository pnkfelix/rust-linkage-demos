fn main() { extern "C" { fn staticlib_main(); } unsafe { staticlib_main(); } }
