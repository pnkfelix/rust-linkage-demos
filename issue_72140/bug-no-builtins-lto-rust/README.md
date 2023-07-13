## LTO and `#![no_builtins]`, a repo to show a bug

This repository is to demonstrate a bug that occurs when you attempt to use link time optimization when having a dependency to a crate using `#![no_builtins]`.

Related to the issue [rust-lang/rust#72140](https://github.com/rust-lang/rust/issues/72140)

### How do I run it?

Having `cargo` and `git`:

```
git clone https://github.com/Deluvi/bug-no-builtins-lto-rust.git
cd bug-no-builtins-lto-rust
cargo run --release -p no-builtins-bin
```

### What am I supposed to see?

With `rustc --version` being `1.43.1` stable, here is my output:

```
cargo run --release -p no-builtins-bin
   Compiling no-builtins-lib v0.1.0 (/home/deluvi/tests/test/bug-no-builtins-lto-rust/no-builtins-lib)
   Compiling no-builtins-bin v0.1.0 (/home/deluvi/tests/test/bug-no-builtins-lto-rust/no-builtins-bin)
error: linking with `cc` failed: exit code: 1
  |
  = note: "cc" "-Wl,--as-needed" "-Wl,-z,noexecstack" "-m64" "-L" "/home/deluvi/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib" "/home/deluvi/tests/test/bug-no-builtins-lto-rust/target/release/deps/no_builtins_bin-d28e15586db11f8b.no_builtins_bin.ds5ffvdz-cgu.7.rcgu.o" "-o" "/home/deluvi/tests/test/bug-no-builtins-lto-rust/target/release/deps/no_builtins_bin-d28e15586db11f8b" "-Wl,--gc-sections" "-pie" "-Wl,-zrelro" "-Wl,-znow" "-Wl,-O1" "-nodefaultlibs" "-L" "/home/deluvi/tests/test/bug-no-builtins-lto-rust/target/release/deps" "-L" "/home/deluvi/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib" "-Wl,-Bstatic" "/home/deluvi/tests/test/bug-no-builtins-lto-rust/target/release/deps/libno_builtins_lib-cef2adf5c7c12373.rlib" "-Wl,--start-group" "/tmp/rustcawiD2r/libbacktrace_sys-dc606003556dfe9c.rlib" "-Wl,--end-group" "/home/deluvi/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/libcompiler_builtins-2541f1e09df1c67d.rlib" "-Wl,-Bdynamic" "-ldl" "-lrt" "-lpthread" "-lgcc_s" "-lc" "-lm" "-lrt" "-lpthread" "-lutil" "-lutil"
  = note: /usr/bin/ld: /home/deluvi/tests/test/bug-no-builtins-lto-rust/target/release/deps/libno_builtins_lib-cef2adf5c7c12373.rlib(no_builtins_lib-cef2adf5c7c12373.no_builtins_lib.2derfq4u-cgu.0.rcgu.o): in function `core::ptr::drop_in_place':
          no_builtins_lib.2derfq4u-cgu.0:(.text._ZN4core3ptr13drop_in_place17h107dbe4e36e3489dE+0x13): undefined reference to `__rust_dealloc'
          /usr/bin/ld: /home/deluvi/tests/test/bug-no-builtins-lto-rust/target/release/deps/libno_builtins_lib-cef2adf5c7c12373.rlib(no_builtins_lib-cef2adf5c7c12373.no_builtins_lib.2derfq4u-cgu.2.rcgu.o): in function `alloc::raw_vec::RawVec<T,A>::reserve':
          no_builtins_lib.2derfq4u-cgu.2:(.text._ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve17h791963cb9aa36cdbE+0x58): undefined reference to `__rust_realloc'
          /usr/bin/ld: no_builtins_lib.2derfq4u-cgu.2:(.text._ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve17h791963cb9aa36cdbE+0x7f): undefined reference to `__rust_alloc'
          /usr/bin/ld: no_builtins_lib.2derfq4u-cgu.2:(.text._ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve17h791963cb9aa36cdbE+0x8f): undefined reference to `__rust_dealloc'
          /usr/bin/ld: no_builtins_lib.2derfq4u-cgu.2:(.text._ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve17h791963cb9aa36cdbE+0x98): undefined reference to `core::alloc::Layout::dangling'
          /usr/bin/ld: no_builtins_lib.2derfq4u-cgu.2:(.text._ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve17h791963cb9aa36cdbE+0xa8): undefined reference to `core::alloc::Layout::dangling'
          /usr/bin/ld: no_builtins_lib.2derfq4u-cgu.2:(.text._ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve17h791963cb9aa36cdbE+0xc4): undefined reference to `alloc::raw_vec::capacity_overflow'
          /usr/bin/ld: no_builtins_lib.2derfq4u-cgu.2:(.text._ZN5alloc7raw_vec19RawVec$LT$T$C$A$GT$7reserve17h791963cb9aa36cdbE+0xd4): undefined reference to `alloc::alloc::handle_alloc_error'
          collect2: error: ld returned 1 exit status
          

error: aborting due to previous error

error: could not compile `no-builtins-bin`.
```
