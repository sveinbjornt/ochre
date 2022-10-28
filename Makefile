# Makefile for Sloth app

XCODE_PROJ := "ocr.xcodeproj"
PROGRAM_NAME := "ocr"
BUILD_DIR := "products"
VERSION := "0.1"

all: clean build_unsigned

release: clean build_signed archive size

test: clean build_unsigned runtests

build_unsigned:
	mkdir -p $(BUILD_DIR)
	xcodebuild	-project "$(XCODE_PROJ)" \
	            -target "$(PROGRAM_NAME)" \
	            -configuration "Debug" \
	            CONFIGURATION_BUILD_DIR="$(BUILD_DIR)" \
	            CODE_SIGN_IDENTITY="" \
	            CODE_SIGNING_REQUIRED=NO \
	            build

build_signed:
	mkdir -p $(BUILD_DIR)
	xcodebuild  -parallelizeTargets \
	            -project "$(XCODE_PROJ)" \
	            -target "$(PROGRAM_NAME)" \
	            -configuration "Release" \
	            CONFIGURATION_BUILD_DIR="$(BUILD_DIR)" \
	            build

archive:
	@mkdir "$(BUILD_DIR)/$(PROGRAM_NAME)-$(VERSION)"
	@cp "$(BUILD_DIR)/$(PROGRAM_NAME)" "$(BUILD_DIR)/$(PROGRAM_NAME)-$(VERSION)/"
	@cp "$(PROGRAM_NAME).1" "$(BUILD_DIR)/$(PROGRAM_NAME)-$(VERSION)/"
	@cp "install.sh" "$(BUILD_DIR)/$(PROGRAM_NAME)-$(VERSION)/"
	@cd "$(BUILD_DIR)"; zip -qy --symlinks "$(PROGRAM_NAME)-$(VERSION).zip" -r "$(PROGRAM_NAME)-$(VERSION)"
	@cd "$(BUILD_DIR)"; rm -r "$(PROGRAM_NAME)-$(VERSION)"

size:
	@echo "Binary size:"
	@stat -f %z "$(BUILD_DIR)/$(PROGRAM_NAME)"
	@echo "Archive size:"
	@cd "$(BUILD_DIR)"; du -hs "$(PROGRAM_NAME)-$(VERSION).zip"

runtests:
	@echo "Running tests"
	@bash "test/test.sh"

clean:
	xcodebuild -project "$(XCODE_PROJ)" clean
	rm -rf products/* 2> /dev/null
