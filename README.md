Tetanus is a collection of quick-and-dirty scripts to make developing (and 
perhaps even using) Rust easier.

You'll want to make a file `~/.rust_build_dir` containing the name of your
build directory, and add the directory containing these files to your $PATH.
(Or symlink them into someplace in your $PATH with names you like better.)

Useful commands:

 * `m` / `m c` / `m c=my-test-name` / `m d` — make / make, with tests / make with specific tests / run `gdb` on failure

 * `. st 3` — use stage 3 binaries

 * `rc` — run the `rustc` selected by `. st`

 * `rusti` — a Rust REPL (run `. st` first)

 * `try` — push to `try`

 * `push-rust-master` — push to the actual Rust repo

