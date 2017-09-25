#!/bin/bash

# Copyright 2013-2015, Derrick Wood <dwood@cs.jhu.edu>
#
# This file is part of the Kraken taxonomic sequence classification system.
#
# Kraken is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Kraken is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Kraken.  If not, see <http://www.gnu.org/licenses/>.

# Build the standard Kraken database
# Designed to be called by kraken_build

set -u  # Protect against uninitialized vars.
set -e  # Stop on error
set -o pipefail  # Stop on failures in non-final pipeline commands

WOD_FLAG=""
if [ -n "$KRAKEN_WORK_ON_DISK" ]
then
  WOD_FLAG="--work-on-disk"
fi

check_for_jellyfish.sh
krakenu-download -o $KRAKEN_DB_NAME/taxonomy --download-taxonomy
krakenu-download -o $KRAKEN_DB_NAME/library -d archaea,bacteria refseq > $KRAKEN_DB_NAME/seqid2taxid.map
krakenu-download -o $KRAKEN_DB_NAME/library -d viral -a Any refseq >> $KRAKEN_DB_NAME/seqid2taxid.map
krakenu-build --db $KRAKEN_DB_NAME --build --threads $KRAKEN_THREAD_CT \
               --jellyfish-hash-size "$KRAKEN_HASH_SIZE" \
               --max-db-size "$KRAKEN_MAX_DB_SIZE" \
               --minimizer-len $KRAKEN_MINIMIZER_LEN \
               --kmer-len $KRAKEN_KMER_LEN \
               $WOD_FLAG