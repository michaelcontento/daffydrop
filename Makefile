ENV ?= debug
MAIN = $(wildcard *.monkey)
TRANS = ./MonkeyPro58/bin/trans_macos
TRANS_ENV = $(TRANS) -config=$(ENV)

.PHONY: glfw html5 clean

glfw:
	$(TRANS) -target=glfw -run $(MAIN)

html5:
	$(TRANS) -target=html5 -run $(MAIN)

clean:
	$(TRANS) -clean

