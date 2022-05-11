#![crate_type = "proc-macro"]

extern crate proc_macro;

use proc_macro::TokenStream;

#[proc_macro_derive(Foo)]
pub fn derive_foo(_input: TokenStream) -> TokenStream {
    println!("hello from derive_foo in {}", file!());
    "".parse().unwrap()
}

#[proc_macro_derive(Bar, attributes(Baz))]
pub fn derive_bar(_input: TokenStream) -> TokenStream {
    println!("hello from derive_bar in {}; input: {:?}", file!(), _input);
    "".parse().unwrap()
}
