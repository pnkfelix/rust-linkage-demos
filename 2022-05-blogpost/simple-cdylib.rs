#![crate_type="cdylib"]
#[no_mangle]
pub extern "C" fn cdylib_main() {
    println!("Running cdylib_main from {}", file!());
}
