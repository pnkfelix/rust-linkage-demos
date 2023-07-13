#![no_builtins]

pub fn some_alloc() -> Vec<u8> {
    let mut vector = Vec::new();
    vector.push(1);
    vector
}
