#!/usr/bin/env bash
#
# test script for wireguard-vpn-masquerade
#
# Copyright (C) 2019  Christian Garbs <mitch@cgarbs.de>
# licensed under GNU GPL v3 or later

set -e

# run in autowatch mode with "--watch"
if [ "$1" = "--watch" ]; then
    ./run-tests.sh || true
    while inotifywait -e modify -e move -e move_self -e create -e delete -e delete_self tests tests/* run-tests.sh wg-conf.* ../wg-conf; do
        ./run-tests.sh || true
    done
    exit 0
fi

# single run mode from here on

# no need for actual wg command
wg()
{
    if [ "$*" != 'pubkey' ]; then
	echo "(fake) wg: unknown command: $*"
    fi
    read -r PRIVATE
    case "$PRIVATE" in
	PRIVATE-KEY)	echo 'PUBLIC-SERVER-KEY';;
	PRIVATE-KEY-1)	echo 'PUBLIC-CLIENT-KEY-1';;
	PRIVATE-KEY-2)	echo 'PUBLIC-CLIENT-KEY-2';;
	*)		echo "<unknown private key '$PRIVATE'>";;
    esac
}
export -f wg

# no need for actual qrencode command
# there are subtile differences in the codes generated
# by different versions of qrencode that break our tests
# (because of all the error corrections in a QR code,
#  slightly different results are valid, but using diff(1)
#  to check the result fails because of the differences)
qrencode()
{
    if [ "$*" != '-t utf8' ] ; then
	echo "(fake) qrencode: unknown command: $*"
    fi
    while read -r LINE; do
	echo "QRQRQR:: $LINE"
    done
}
export -f qrencode

# don't use actual tput command in tests,
# might fail because of different terminals
tput()
{
    :
}
export -f tput

TESTDIR=$(mktemp -d)
trap "rm -r \"$TESTDIR\"" EXIT
ACTUAL="$TESTDIR/actual"
DIFF="$TESTDIR/diff"

OK=0
FAILED=0
for TESTSCRIPT in tests/*.test; do

    TESTNAME=${TESTSCRIPT%.test}
    EXPECTED=${TESTNAME}.expected
    TESTNAME=${TESTNAME#tests/}
    
    echo ">>> running test $TESTNAME:"

    bash -e "$TESTSCRIPT" > "$ACTUAL" 2>&1 || true

    diff -Nau "$EXPECTED" "$ACTUAL" > "$DIFF" || true
    if [ -s "$DIFF" ]; then
	echo "!!! INPUT:"
	cat "$TESTSCRIPT"
	echo
	echo "!!! OUTPUT:"
	cat "$DIFF"
	echo
        echo "<<< TEST FAILED"
        FAILED=$(( FAILED + 1 ))
    else
        echo "<<< test ok"
        OK=$(( OK + 1 ))
    fi

    echo
    
done

echo "result:"
printf "%3d successful tests\n" $OK
printf "%3d failed tests\n" $FAILED

if [ $FAILED -gt 0 ]; then
    exit 1
fi
exit 0
