#!/usr/bin/env bash

set -euo pipefail

cd "${0%/*}/"
source build-common.sh

pushd ..
TARGET_JSON_PATH="$(cargo run -p polkatool get-target-json-path --bitness 32)"
popd

function build_example () {
    output_path="output/$1.polkavm"

    echo "> Building: '$1' (-> $output_path)"

    RUSTFLAGS="--remap-path-prefix=$(pwd)= --remap-path-prefix=$HOME=~" \
    cargo build  \
        -Z build-std=core,alloc \
        --target $TARGET_JSON_PATH \
        -q --release --bin $1 -p $1

    pushd ..

    cargo run -q -p polkatool link \
        --run-only-if-newer -s guest-programs/target/riscv32emac-unknown-none-polkavm/release/$1 \
        -o guest-programs/$output_path

    popd
}

build_example "example-hello-world"
