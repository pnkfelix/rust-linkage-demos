extern crate simple_proc_macro;

use simple_proc_macro::{Foo, Bar};

#[derive(Foo)] struct Q;
#[derive(Foo, Bar)] struct R;
#[derive(Bar)] #[Baz] struct S;
#[derive(Foo, Bar)] #[Baz] struct T;

fn main() { let _ = (Q, R, S, T); println!("Running main from {}", file!()); }
