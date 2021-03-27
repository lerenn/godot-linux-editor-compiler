# Add version if not defined
ifeq ($(VERSION),)
	VERSION := master
endif

# Shortcut variables
SHORTCUT_NAME=org.godotengine.Godot.desktop
SHORTCUT_PATH=./code/$(VERSION)/misc/dist/linux/$(SHORTCUT_NAME)
SHORTCUT_INSTALL_PATH=${HOME}/.local/share/applications

# Templates variables
TEMPLATES_PATH=output/$(VERSION)/templates
TEMPLATES_INSTALL_PATH=${HOME}/.local/share/godot/templates

# Icon variables
ICON_NAME=icon.png
ICON_PATH=code/$(VERSION)
ICON_INSTALL_PATH=${HOME}/.local/share/godot

# Editor variables
ifeq ($(VERSION),master)
	EDITOR_NAME=godot.linuxbsd.tools.64
else 
	EDITOR_NAME=godot.x11.tools.64
endif
EDITOR_PATH=output/$(VERSION)/$(EDITOR_NAME)
EDITOR_INSTALL_PATH=${HOME}/.local/bin

all: build compile install

build:
	docker-compose build

compile:
	mkdir -p code/{master,3.2} output/{master,3.2}
	docker-compose up --remove-orphans

install: linux-install

linux-install:
	# Install editor
	mkdir -p $(EDITOR_INSTALL_PATH)
	cp -f $(EDITOR_PATH) $(EDITOR_INSTALL_PATH)
	# Install templates
	mkdir -p $(TEMPLATES_INSTALL_PATH)
	cp -rf $(TEMPLATES_PATH)/* $(TEMPLATES_INSTALL_PATH)
	# Install icon
	mkdir -p $(ICON_INSTALL_PATH)
	cp -rf $(ICON_PATH)/$(ICON_NAME) $(ICON_INSTALL_PATH)
	# Install shortcut
	cp -f $(SHORTCUT_PATH) output/$(VERSION)/
	sed -i "s|Exec=.*|Exec=$(EDITOR_INSTALL_PATH)/$(EDITOR_NAME) %f|" output/$(VERSION)/$(SHORTCUT_NAME)
	sed -i "s|Icon=.*|Icon=$(ICON_INSTALL_PATH)/$(ICON_NAME)|" output/$(VERSION)/$(SHORTCUT_NAME)
	cp -f output/$(VERSION)/$(SHORTCUT_NAME) $(SHORTCUT_INSTALL_PATH)