use no_builtins_lib::some_alloc;

fn main() {
    let mut vec = some_alloc();
    vec.push(2);
    dbg!(vec);
}
