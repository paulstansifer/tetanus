#invoke this as `. st 3` to choose stage 3, for example

if [[ $(basename $0) = "st" ]]; then
   echo "You can't run this directly; it sets up environment variables."
   echo "Use \`. st $1\` instead."
   exit
fi

RUST_BUILD_DIR=$(<~/.rust_build_dir)
if [[ ! -e $RUST_BUILD_DIR ]]; then
    echo "~/.rust_build_dir should contain the name of the Rust build library"
fi

export STAGE="stage$@"
export R_PATH="$RUST_BUILD_DIR/x86_64-unknown-linux-gnu/$STAGE"
export LD_LIBRARY_PATH="/lib:$R_PATH/lib"

export RUST_EXE="$R_PATH/bin/rustc  -L $R_PATH/lib/lib"
alias rc=$RUST_EXE
