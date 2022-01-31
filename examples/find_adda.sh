#!/bin/bash
# Copyright (C) ADDA contributors
# GNU General Public License version 3

# Finds adda binaries and set corresponding environmental variable (ADDA_SEQ, ADDA_MPI, or ADDA_OCL). If the variable
# is already defined, only tests that the file exist. Otherwise, first checks that it is directly available (on the
# PATH), then looks at the compilation folders, and finally (on Windows only) looks for precompiled binaries in win64/

# A single optional argument is the mode (seq, mpi, or ocl), which binary to search. 'seq' is the default one.
# The script must not be moved from this folder (searches for a few places relative to its position),
# but can be sourced from anywhere. It is important to source it (e.g. ". .../find_adda.sh seq") to define the
# variables for further usage.

mode=${1:-seq}

# We do not add .exe for Windows, since all Bash interpreters for Windows seem to work fine without it
if [ $mode == "seq" ]; then
  var=ADDA_SEQ
  bin=adda
elif [ $mode == "mpi" ]; then
  var=ADDA_MPI
  bin=adda_mpi
elif [ $mode == "ocl" ]; then
  var=ADDA_OCL
  bin=adda_ocl
else
  echo "ERROR: unkwnown mode '$mode'" >&2
  exit 1
fi

if [ -z "${!var}" ]; then
  # Locates root path for ADDA (relative to script's location), https://stackoverflow.com/a/246128/2633728
  top=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../" &> /dev/null && pwd)
  if command -v $bin &> /dev/null; then
    path="$bin"
  elif [ -f "$top/src/$mode/$bin" ]; then
    path="$top/src/$mode/$bin"
  elif [[ ("$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" || "$OSTYPE" == "win64" ) && -f "$top/win64/$bin" ]]; then 
    path="$top/win64/$bin"
  else      
    echo "ERROR: No $bin binary found (and variable $var is not defined)" >&2
    exit 1        
  fi
  export $var="$path"
elif [ ! -f "${!var}" ]; then
  echo "ERROR: No $bin binary found (path given by $var='${!var}' does not exist" >&2
  exit 1
fi