#!/bin/bash
#
# Test binary by running various commands
#

abs_path_to_enclosing_dir () {
   echo "$(dirname $(cd $(dirname "$1");pwd)/$(basename "$1"))"
}

TEST_ROOT=$(abs_path_to_enclosing_dir $0)
BIN_PATH="products/ochre"

test_ocr_file() {
    OUTPUT=$("$BIN_PATH" "$1")

    if [ "$OUTPUT" != "$2" ]; then
        echo "Unexpected output: ${OUTPUT}"
        exit 1
    fi
}

EN_PNG_PATH="$TEST_ROOT/english.png"
test_ocr_file $EN_PNG_PATH "The rain in Spain stays mainly in the plain."

# FR_PNG_PATH="$TEST_ROOT/french.png"
# test_ocr_file $FR_PNG_PATH
