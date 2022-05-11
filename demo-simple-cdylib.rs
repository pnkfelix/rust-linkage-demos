fn main() { extern "C" { fn cdylib_main(); } unsafe { cdylib_main(); } }
