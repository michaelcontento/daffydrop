CONFIG ?= debug
TARGET ?= glfw
MAIN = $(wildcard *.monkey)
TRANS = /Applications/MonkeyPro58/bin/trans_macos
TRANS_FULL = $(TRANS) -config=$(CONFIG) -target=$(TARGET)

run:
	$(TRANS_FULL) -run $(MAIN)

check:
	$(TRANS_FULL) -check $(MAIN)

update:
	$(TRANS_FULL) -update $(MAIN)

build:
	$(TRANS_FULL) -build $(MAIN)

clean:
	$(TRANS_FULL) -clean $(MAIN)
