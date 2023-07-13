// simple-dylib.rs
#![crate_type="dylib"]
pub fn main() { println!("Running main from {}", file!()); }
