#!/bin/sh

# RUSTC="rustc +nightly"
RUSTC=rustc

# OUTDIR=$(pwd)/out
OUTDIR=out

rm -rf $OUTDIR/*
mkdir -p $OUTDIR

# set -x
set -e

# Note: Each of the below must have their (locally unique) key which determines
# output directory first. It will be popped off and passed to mkdir further
# down. Also, each must have the input file itself last. (This fact is not yet
# used in the script logic, but I'm close to taking that step.)

C_SL="ps/sl                   simple-lib.rs"
## As a special case, we need to compile simple-dylib.rs w/ `-Cprefer-dynamic`;
## otherwise we will get an error trying to build demo-simple-dylib.rs below.
C_SD="pd/sd -C prefer-dynamic simple-dylib.rs"
# C_SD="$OUTDIR/sd                   simple-dylib.rs"
C_SS="ps/ss                   simple-staticlib.rs"
C_SC="ps/sc                   simple-cdylib.rs"
C_SR="ps/sr                   simple-rlib.rs"
C_SPM="pd/spm -C prefer-dynamic simple-proc-macro.rs"

for C_S in "$C_SL" "$C_SD" "$C_SS" "$C_SC" "$C_SR" "$C_SPM"; do
    KEY=${C_S%% *}
    DIR=$OUTDIR/$KEY
    FILE=$(echo $C_S | awk '{print $NF}')
    mkdir -p $DIR
    RUSTC_OUTPUT=$DIR/rustc-output
    set -x
    $RUSTC --out-dir $OUTDIR/$C_S | tee $RUSTC_OUTPUT 2>&1
    ls $DIR
    set +x
    E=$?
    if [ "$E" = "0" ] ; then
        true
    else
        echo "Failed to compile:" $(echo "${C_S}" | awk -F' ' '{print $NF}')
        echo
        cat $RUSTC_OUTPUT
        echo "Failed to compile:" $(echo "${C_S}" | awk -F' ' '{print $NF}') "; output in $RUSTC_OUTPUT"
        echo
        exit $E
    fi
done

# set -e
# set -x

mkdir -p $OUTDIR/bins
mkdir -p $OUTDIR/bins/pd
mkdir -p $OUTDIR/bins/ps

OUT_PS="$OUTDIR/bins/ps"
OUT_PD="$OUTDIR/bins/pd"

IN_SB="dsb simple-bin.rs"
IN_SD="dsd demo-simple-dylib.rs       -L$OUTDIR/pd/sd"
IN_SL="dsl demo-simple-lib.rs         -L$OUTDIR/ps/sl"
IN_SS="dss demo-simple-staticlib.rs   -L$OUTDIR/ps/ss -lsimple_staticlib"
IN_SC="dsc demo-simple-cdylib.rs      -L$OUTDIR/ps/sc -lsimple_cdylib"
IN_SR="dsr demo-simple-rlib.rs        -L$OUTDIR/ps/sr"
IN_SPM="dspm demo-simple-proc-macro.rs -L$OUTDIR/pd/spm"

for IN in "$IN_SB" "$IN_SD" "$IN_SL" "$IN_SS" "$IN_SC" "$IN_SR" "$IN_SPM"; do
    KEY=${IN%% *}
    DIR=$OUT_PS
    RUSTC_OUTPUT=$DIR/$KEY-rustc-output
    set -x
    $RUSTC --out-dir $DIR/$IN | tee "$RUSTC_OUTPUT" 2>&1
    ls $DIR/$KEY
    set +x
    E=$?
    if [ "$E" = "0" ] ; then
        true
    else
        echo "Failed to compile under prefer-static:" $(echo ${IN%% *} | awk -F' ' '{print $NF}')
        echo
        cat $RUSTC_OUTPUT
        echo "Failed to compile under prefer-static:" $(echo ${IN%% *} | awk -F' ' '{print $NF}') "; output in $RUSTC_OUTPUT"
        echo
        exit $E
    fi

    DIR=$OUT_PD
    RUSTC_OUTPUT=$DIR/$KEY-rustc-output
    set -x
    $RUSTC --out-dir $DIR/$IN -C prefer-dynamic | tee "$RUSTC_OUTPUT" 2>&1
    ls $DIR/$KEY
    set +x
    E=$?
    if [ "$E" = "0" ] ; then
        true
    else
        echo "Failed to compile under prefer-dynamic:" $(echo ${IN%% *} | awk -F' ' '{print $NF}')
        echo
        cat $RUSTC_OUTPUT
        echo "Failed to compile under prefer-dynamic:" $(echo ${IN%% *} | awk -F' ' '{print $NF}') "; output in $RUSTC_OUTPUT"
        echo
        exit $E
    fi
done

set +x

SYSROOT_LIB=$($RUSTC --print=sysroot)/lib

BINS=$(find $OUTDIR/bins -type f -executable | xargs)

set -x

for b in $BINS; do
    case $b in
        "$OUTDIR/bins/ps/dsd/demo-simple-dylib")
            LD_LIBRARY_PATH=$OUTDIR/pd/sd:$SYSROOT_LIB $b | tee $b-exec-output 2>&1
            ;;
        "$OUTDIR/bins/ps/dsc/demo-simple-cdylib")
            LD_LIBRARY_PATH=$OUTDIR/ps/sc $b | tee $b-exec-output 2>&1
            ;;
        "$OUTDIR/bins/pd/dsd/demo-simple-dylib")
            LD_LIBRARY_PATH=$OUTDIR/pd/sd:$SYSROOT_LIB $b | tee $b-exec-output 2>&1
            ;;
        "$OUTDIR/bins/pd/dspm/demo-simple-proc-macro")
            LD_LIBRARY_PATH=$SYSROOT_LIB $b | tee $b-exec-output 2>&1
            ;;
        "$OUTDIR/bins/pd/dsr/demo-simple-rlib")
            LD_LIBRARY_PATH=$SYSROOT_LIB $b | tee $b-exec-output 2>&1
            ;;
        "$OUTDIR/bins/pd/dsl/demo-simple-lib")
            LD_LIBRARY_PATH=$SYSROOT_LIB $b | tee $b-exec-output 2>&1
            ;;
        "$OUTDIR/bins/pd/dsb/simple-bin")
            LD_LIBRARY_PATH=$SYSROOT_LIB $b | tee $b-exec-output 2>&1
            ;;
        "$OUTDIR/bins/pd/"*)
            $b | tee $b-exec-output 2>&1
            ;;
        "$OUTDIR/bins/ps/"*)
            $b | tee $b-exec-output 2>&1
            ;;
        *)
            echo "(Fell into default; unhandled)"
            # $b | tee $b-exec-output 2>&1
            exit 1
            ;;
    esac
done
