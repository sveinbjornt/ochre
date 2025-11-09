#!/usr/bin/env bash
#
# Test binary by running various commands
#

set -o errexit  # Exit when a command fails

abs_path_to_enclosing_dir () {
   echo "$(dirname $(cd $(dirname "$1");pwd)/$(basename "$1"))"
}

TEST_ROOT=$(abs_path_to_enclosing_dir "${0}")
BIN_PATH="products/ochre"

test_ocr_file() {
    OUTPUT=$("$BIN_PATH" "$1")

    if [ "$OUTPUT" != "$2" ]; then
        echo "Unexpected output for '$1': ${OUTPUT}"
        exit 1
    fi
}

echo "Testing English"
EN_PNG_PATH="$TEST_ROOT/english.png"
test_ocr_file "${EN_PNG_PATH}" "The rain in Spain stays mainly in the plain."

echo "Testing French"
FR_PNG_PATH="$TEST_ROOT/french.png"
test_ocr_file $FR_PNG_PATH "C'est une entrecôte"

echo "Testing German"
DE_PNG_PATH="$TEST_ROOT/german.png"
test_ocr_file $DE_PNG_PATH "Die Walküre: „Wer meines Speeres Spitze fürchtet\""

echo "ALL TESTS PASSING"
exit 0
