NAME      := cyrex
PREFIX    ?= /usr
DATADIR   ?= $(PREFIX)/share
DOCDIR    ?= $(DATADIR)/doc/xkb-cyrillic-phonetic-extended

# libxkbcommon >= 1.13 extensions directory. Ask pkg-config so that
# distributions with a non-default xkeyboard-config root just work.
XKB_EXTENSIONS_DIR ?= $(shell pkg-config --variable=xkb_unversioned_extensions_path xkbcommon 2>/dev/null)
ifeq ($(XKB_EXTENSIONS_DIR),)
XKB_EXTENSIONS_DIR := $(DATADIR)/xkeyboard-config.d
endif

# Per-user installation target (works with any libxkbcommon >= 1.0).
XDG_CONFIG_HOME ?= $(HOME)/.config
USER_XKB_DIR    ?= $(XDG_CONFIG_HOME)/xkb

PKGDIR := $(DESTDIR)$(XKB_EXTENSIONS_DIR)/$(NAME)

.PHONY: all check install uninstall install-user uninstall-user

all:

check:
	xmllint --noout rules/evdev.xml
	@# xkbcli exits 0 even for an unknown layout, so inspect the result.
	xkbcli compile-keymap --include . --include-defaults --layout $(NAME) \
		| grep -q 'key <TLDE> *{[[:space:]]*\[ *U044E'

install:
	install -Dm644 symbols/$(NAME)  $(PKGDIR)/symbols/$(NAME)
	install -Dm644 rules/evdev.xml  $(PKGDIR)/rules/evdev.xml
	install -Dm644 README.md        $(DESTDIR)$(DOCDIR)/README.md
	install -Dm644 layout.png       $(DESTDIR)$(DOCDIR)/layout.png

uninstall:
	rm -rf $(PKGDIR) $(DESTDIR)$(DOCDIR)

install-user:
	install -Dm644 symbols/$(NAME)  $(USER_XKB_DIR)/symbols/$(NAME)
	install -Dm644 rules/evdev.xml  $(USER_XKB_DIR)/rules/evdev.xml

uninstall-user:
	rm -f $(USER_XKB_DIR)/symbols/$(NAME) $(USER_XKB_DIR)/rules/evdev.xml
