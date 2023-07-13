// simple-staticlib.rs
#![crate_type="staticlib"]
#[no_mangle]
pub extern "C" fn staticlib_main() { println!("Running staticlib_main from {}", file!()); }
