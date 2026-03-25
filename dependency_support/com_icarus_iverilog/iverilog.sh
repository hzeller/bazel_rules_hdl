#!/usr/bin/env bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Wrapper around iverilog binary. Adds the path to the dependencies to
# the command line of iverilog.

set -eu

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=;
# --- end runfiles.bash initialization v2 ---

iverilog_bin=$(rlocation "com_icarus_iverilog/iverilog-bin")
system_vpi=$(rlocation "com_icarus_iverilog/system.vpi")

if [[ -z "$iverilog_bin" || -z "$system_vpi" ]]; then
  echo >&2 "ERROR: cannot find binaries in runfiles"
  exit 1
fi

# We need to use absolute paths to ensure iverilog can resolve modules
# correctly across symlinks in the sandbox.
abs_vvp_dir=$(dirname "$(readlink -f "$system_vpi")")
abs_dir=$(dirname "$(readlink -f "$iverilog_bin")")

exec "$iverilog_bin" -B"$abs_dir" -BM"$abs_vvp_dir" -DIVERILOG "$@"
