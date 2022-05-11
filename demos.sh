#!/bin/sh

OUTDIR=$(pwd)/out

rm -rf $OUTDIR/*
mkdir -p $OUTDIR

# set -x
set -e

# Note: All of the below must have their (locally unique) output directory
# first. It will be popped off and passed to mkdir further down.l
C_SL="$OUTDIR/sl                   simple-lib.rs"
## As a special case, we need to compile simple-dylib.rs w/ `-Cprefer-dynamic`;
## otherwise we will get an error trying to build demo-simple-dylib.rs below.
C_SD="$OUTDIR/sd -C prefer-dynamic simple-dylib.rs"
# C_SD="$OUTDIR/sd                   simple-dylib.rs"
C_SS="$OUTDIR/ss                   simple-staticlib.rs"
C_SC="$OUTDIR/sc                   simple-cdylib.rs"
C_SR="$OUTDIR/sr                   simple-rlib.rs"
C_SPM="$OUTDIR/spm -C prefer-dynamic simple-proc-macro.rs"

for C_S in "$C_SL" "$C_SD" "$C_SS" "$C_SC" "$C_SR" "$C_SPM"; do
    DIR=${C_S%% *}
    mkdir -p $DIR
    RUSTC_OUTPUT=$DIR/rustc-output
    rustc --out-dir $C_S > $RUSTC_OUTPUT 2>&1
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
OUT_PD="$OUTDIR/bins/pd -C prefer-dynamic"

IN_SB="simple-bin.rs"
IN_SD="demo-simple-dylib.rs       -L$OUTDIR/sd"
IN_SL="demo-simple-lib.rs         -L$OUTDIR/sl"
IN_SS="demo-simple-staticlib.rs   -L$OUTDIR/ss -lsimple_staticlib"
IN_SC="demo-simple-cdylib.rs      -L$OUTDIR/sc -lsimple_cdylib"
IN_SR="demo-simple-rlib.rs        -L$OUTDIR/sr"
IN_SPM="demo-simple-proc-macro.rs -L$OUTDIR/spm"

for IN in "$IN_SB" "$IN_SD" "$IN_SL" "$IN_SS" "$IN_SC" "$IN_SR" "$IN_SPM"; do
    RUSTC_OUTPUT=${OUT_PS%% *}/${IN%% *}-rustc-output
    rustc --out-dir ${OUT_PS%% *} $IN > "$RUSTC_OUTPUT" 2>&1
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
    RUSTC_OUTPUT=${OUT_PD%% *}/${IN%% *}-rustc-output
    rustc --out-dir ${OUT_PD%% *} $IN > "$RUSTC_OUTPUT" 2>&1
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

for b in $(find $OUTDIR/bins -type f -executable | xargs); do
    echo Running $b
    SYSROOT_LIB=$(rustc --print=sysroot)/lib
    case $b in
        #"$OUTDIR/bins/ps/demo-simple-dylib")
        #     LD_LIBRARY_PATH=$OUTDIR/sd:$SYSROOT_LIB $b > $b-exec-output 2>&1
        # ;;
        # "$OUTDIR/bins/pd/demo-simple-dylib")
        # LD_LIBRARY_PATH=$OUTDIR/sd:$SYSROOT_LIB $b > $b-exec-output 2>&1
        # ;;
        "$OUTDIR/bins/pd/demo-simple-proc-macro")
            LD_LIBRARY_PATH=$SYSROOT_LIB $b > $b-exec-output 2>&1
            ;;
        *)
            $b > $b-exec-output 2>&1
            ;;
    esac
done
