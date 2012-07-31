#!/bin/bash
# `m` - just build
# `m c=alucard` - only run tests with 'alucard' in their names
# `m d` - enable debug, and invoke GDB on failure
# `m d -j8 rustc-stage1` - pass arguments like normal

cd $(< ~/.rust_build_dir)

gdb=0
make_args=
maybe_check=true
vrb=1
tp=1
dvg=1
rl=

if [[ -e $(which notify-send) ]]; then
    notify=$(which notify-send)
else
    notify=true
fi

while true; do
    if [[ $# = 0 ]]; then break; fi
    case $1 in
        d)
            gdb=1
            export CFG_ENABLE_DEBUG=1
            shift ;;
        c1)
            maybe_check="time -f testtime:%E make check-stage1"
            make_args+=" rustc-stage1"
            shift ;;
        c1=*)
            maybe_check="time -f testtime:%E make check-stage1"
            make_args+=" rustc-stage1"
            export TESTNAME=${1#c1=}
            echo "Only running tests with '$TESTNAME'."
            shift ;;
        c | check)
            maybe_check="time -f testtime:%E make check"
            shift ;;
        c=*)
            maybe_check="time -f testtime:%E make check"
            export TESTNAME=${1#c=}
            echo "Only running tests with '$TESTNAME'."
            shift ;;
        l)
            rl=rustc=0,::rt::backtrace
            shift ;;
        x)
            tp=
            shift ;;
        v)
            dvg=
            shift ;;
        *)
            make_args+=" $1"
            shift ;;
    esac
done

export CFG_DISABLE_VALGRIND=$dvg

echo "((VERBOSE=1 RUST_LOG=$rl TIME_PASSES=$tp time -f "compiletime:%E" make $make_args) && $maybe_check $make_args) 2>&1 | tee make_log | make_spew_reducer.pl | tee abbr_make_log"

((VERBOSE=1 RUST_LOG=$rl TIME_PASSES=$tp time -f "compiletime:%E" make $make_args) && $maybe_check $make_args) 2>&1 | tee make_log | make_spew_reducer.pl | tee abbr_make_log


if [[ $PIPESTATUS = 0 ]]; then
    $notify "\\o/" -- "$(tail -n7 abbr_make_log)"
else
    $notify "..." -- "$(tail -n7 abbr_make_log)"
    if [[ $gdb = 1 ]]; then
        gdb --args `egrep "stage./bin/rust" make_log | tail -n1 | cut --delimiter="&" --fields=1`
    fi
fi

