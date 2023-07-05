#!/bin/bash

# Usage: ./build.sh "$(pwd)" "$(pwd)" "x86_64-unknown-linux-gnu" 2.17 true
#
# It composes the "build" command and executes it at the end.
#
# This script is also responsible for selecting the correct NIF version
# using an ENV var or a cargo feature, depending on Rustler version.

initial_dir=$1
project_dir=$2
target_arch=$3
nif_version=$4
use_cross=${5:-"false"}
logging=$(mktemp)

# Version 0.29 is where RUSTLER_NIF_VERSION env var was deprecated.
rustler_features_since="v0.29.0"
# Version 0.30 is where RUSTLER_NIF_VERSION env var was removed.
rustler_features_required_since="v0.30.0"

function build_tool() {
  if [ "$1" == "true" ]; then
    echo "cross"
  else
    echo "cargo"
  fi
}

function check_cross_config() {
  if [ ["$1" < "$rustler_features_since"] ]; then
    if grep --quiet "RUSTLER_NIF_VERSION" "Cross.toml"; then
      echo "Cross configuration looks good." >> "$logging"
    else
      echo "::error file=Cross.toml,line=1::Missing configuration for passing the RUSTLER_NIF_VERSION env var to cross. Please read the precompilation guide: https://hexdocs.pm/rustler_precompiled/precompilation_guide.html#additional-configuration-before-build"
      exit 1
    fi
  else
    echo "No need to check env var presence." >> $logging
  fi
}

# Get the Rustler version from "cargo tree -e features" output.
#
# It takes the first line that is in the format of "{p};{f}"
# from the command:
#
#     $ cargo tree -e features --depth 1 -i rustler -f "{p};{f}" --prefix none
#
# ## Examples
#
#     my_string="rustler v0.29.0;derive,nif_version_2_14,nif_version_2_15,rustler_codegen"
#     rustler_version "$my_string"
#     #=> "v0.29.0"
#
function rustler_version() {
  echo "$1" | cut -d\; -f1 | cut -d' ' -f2
}

# Get the Rustler NIF versions features from "cargo tree -e features" output.
#
# It takes the first line that is in the format of "{p};{f}"
# from the command:
#
#     $ cargo tree -e features --depth 1 -i rustler -f "{p};{f}" --prefix none
#
# Alternatively one can pass the "--features" flag, in order to activate a desired
# feature - of the project being compiled - and get the list of active features from Rustler.
#
# The NIF versions are returned sorted by the higher to the lowest version,
# separated by a new line.
#
# ## Examples
#
#     my_string="rustler v0.29.0;derive,nif_version_2_14,nif_version_2_15,rustler_codegen"
#     rustler_nif_versions "$my_string"
#     #=> "nif_version_2_15\nnif_version_2_14"
#
function rustler_nif_versions() {
  echo "$1" | cut -d\; -f2 | tr ',' '\n' | grep "nif_version" | sort -r
}

echo "Going from path: $initial_dir" >> "$logging"
echo "To path: $project_dir" >> "$logging"

cd "$project_dir"

cargo_features=$(cargo tree -e features --depth 1 -i rustler -f "{p};{f}" --prefix none | head -n 1)

rustler_version=$(rustler_version "$cargo_features")
rustler_nif_versions=$(rustler_nif_versions "$cargo_features")
highest_nif_version=$(echo "$rustler_nif_versions" | head -n1)

nif_version=$(echo -n "$nif_version" | tr '.' '_')
desired_feature="nif_version_$nif_version"

tool=$(build_tool "$use_cross")

if [ "$tool" == "cross" ]; then
  check_cross_config "$rustler_version"
fi

args="build --release --target=$target_arch"

echo "Rustler version: $rustler_version"
echo "NIF version: $nif_version"
echo "Tool: $tool"

# We try to modify args in case the desired feature is not the highest
# activated, and the Rustler version is at least v0.29.0.
#
# In case Rustler v0.30 or above is in use and the desired NIF version feature
# could not be activated, we log an error and exit.
if [ "$highest_nif_version" != "$desired_feature" ]; then
  if [ ["$rustler_version" > "$rustler_features_since"] ] ||  ["$rustler_version" == "$rustler_features_since"]; then
    # So we test if the desired feature appears when we active it in the project.
    cargo_features=$(cargo tree -e features --depth 1 -i rustler -f "{p};{f}" --prefix none -F "$desired_feature" 2>/dev/null | head -n 1)

    rustler_nif_versions=$(rustler_nif_versions "$cargo_features")
    highest_nif_version=$(echo "$rustler_nif_versions" | head -n1)

    if [ "$highest_nif_version" == "$desired_feature" ]; then
      args="$args --features $desired_feature"
    else
      if [ ["$rustler_version" > "$rustler_features_required_since"] ] ||  ["$rustler_version" == "$rustler_features_required_since"]; then
        echo "::error file=Cargo.toml,line=1::The desired feature \"$desired_feature\" is not equal to the highest NIF version that is active: \"$highest_nif_version\""
        echo "::error file=Cargo.toml,line=1::Missing setup of NIF features that is required since Rustler $rustler_features_required_since. Please read the precompilation guide: https://hexdocs.pm/rustler_precompiled/precompilation_guide.html#additional-configuration-before-build"
        exit 1
      fi
    fi
  fi
fi

echo "Arguments: $args"
echo
echo "Logs:"
echo "$(cat $logging)"

## Finally executes the command
echo "Building..."
eval "$tool" "$args"
echo "Done."

echo "Going back to original dir: $INITIAL_DIR"
cd "$INITIAL_DIR"
