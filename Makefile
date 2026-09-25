# boot_masta - one USB stick that boots everything.
# Run `make` with no target to see this list.

SHELL := /bin/bash
DEST  ?=

.PHONY: help doctor list check fetch fetch-all verify sync menu persistence windows-to-go install-ventoy clean

help:
	@echo "boot_masta targets"
	@echo "  make doctor                     - is this computer ready?"
	@echo "  make list                       - show the catalog and what is downloaded"
	@echo "  make check                      - test every download link, download nothing"
	@echo "  make fetch                      - download the enabled images into images/"
	@echo "  make fetch-all                  - download every image, even the ones turned off"
	@echo "  make fetch ID=ubuntu-desktop    - download just one"
	@echo "  make verify                     - hash every file in images/ and watch for changes"
	@echo "  make install-ventoy DEV=/dev/sdX - put Ventoy on the stick (Linux, ERASES the stick)"
	@echo "  make sync DEST=/Volumes/BOOTMASTA  - copy images to the stick and write the menu"
	@echo "  make menu DEST=...              - rewrite only the boot menu"
	@echo "  make persistence DEST=... ISO=... SIZE=8G - keep files between reboots (Linux)"
	@echo "  make windows-to-go DEST=...     - how to run Windows from the stick"
	@echo "  make clean                      - delete the download cache, keep the images"

doctor:
	@scripts/doctor.sh

list:
	@scripts/list.sh

check:
	@scripts/check.sh

fetch:
	@scripts/fetch.sh $(ID)

fetch-all:
	@ALL=1 scripts/fetch.sh

verify:
	@scripts/verify.sh

install-ventoy:
	@scripts/install-ventoy.sh $(DEV)

sync:
	@test -n "$(DEST)" || { echo "set DEST, e.g. make sync DEST=/Volumes/BOOTMASTA"; exit 1; }
	@scripts/sync.sh "$(DEST)"

menu:
	@test -n "$(DEST)" || { echo "set DEST, e.g. make menu DEST=/Volumes/BOOTMASTA"; exit 1; }
	@scripts/gen-ventoy-json.sh "$(DEST)"

persistence:
	@test -n "$(DEST)" || { echo "set DEST and ISO"; exit 1; }
	@scripts/persistence.sh "$(DEST)" "$(ISO)" "$(SIZE)"

windows-to-go:
	@scripts/windows-to-go.sh "$(DEST)"

clean:
	@rm -rf .cache
	@echo "cache removed. images/ was not touched."
