ENV ?= debug
TARGET ?= glfw
MAIN = $(wildcard *.monkey)
TRANS = ./MonkeyPro58/bin/trans_macos
TRANS_ENV = $(TRANS) -config=$(ENV) -target=$(TARGET)

run:
	$(TRANS_ENV) -run $(MAIN)

check:
	$(TRANS_ENV) -check $(MAIN)

update:
	$(TRANS_ENV) -update $(MAIN)

build:
	$(TRANS_ENV) -build $(MAIN)

clean:
	$(TRANS_ENV) -clean $(MAIN)
