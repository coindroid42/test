#!/usr/bin/env bash
# Copyright (c) 2016-2019 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

DOGCOIND=${DOGCOIND:-$BINDIR/dogcoind}
DOGCOINCLI=${DOGCOINCLI:-$BINDIR/dogcoin-cli}
DOGCOINTX=${DOGCOINTX:-$BINDIR/dogcoin-tx}
DOGCOINQT=${DOGCOINQT:-$BINDIR/qt/dogcoin-qt}

[ ! -x $DOGCOIND ] && echo "$DOGCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
read -r -a BTCVER <<< "$($DOGCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }')"

# Create a footer file with copyright content.
# This gets autodetected fine for dogcoind if --version-string is not set,
# but has different outcomes for dogcoin-qt and dogcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$DOGCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $DOGCOIND $DOGCOINCLI $DOGCOINTX $DOGCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
