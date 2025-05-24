# SleepHoldService Makefile

PROJECT_NAME = SleepHoldService
SCHEME = $(PROJECT_NAME)
CONFIGURATION = Release
BUILD_DIR = build
INSTALL_PATH = /usr/local/sbin
LAUNCHD_PATH = /Library/LaunchDaemons
PLIST_NAME = launched.sleepholdservice.plist

.PHONY: all build clean install uninstall install_service uninstall_service

all: build

build:
	xcodebuild -scheme $(SCHEME) -configuration $(CONFIGURATION) -derivedDataPath $(BUILD_DIR) \
		CODE_SIGN_IDENTITY="" CODE_SIGNING_ALLOWED=NO \
		| xcpretty

clean:
	rm -rf $(BUILD_DIR)
	xcodebuild clean -scheme $(SCHEME)

install: build
	sudo mkdir -p $(INSTALL_PATH)
	sudo cp $(BUILD_DIR)/Build/Products/$(CONFIGURATION)/$(PROJECT_NAME) $(INSTALL_PATH)/
	sudo chown root:wheel $(INSTALL_PATH)/$(PROJECT_NAME)
	sudo chmod 755 $(INSTALL_PATH)/$(PROJECT_NAME)

uninstall:
	sudo rm -f $(INSTALL_PATH)/$(PROJECT_NAME)

install_service: build install
	sudo cp LaunchDaemon/$(PLIST_NAME) $(LAUNCHD_PATH)/
	sudo chown root:wheel $(LAUNCHD_PATH)/$(PLIST_NAME)
	sudo chmod 644 $(LAUNCHD_PATH)/$(PLIST_NAME)
	sudo launchctl load $(LAUNCHD_PATH)/$(PLIST_NAME)
	@echo "Service installed and started successfully"

uninstall_service:
	-sudo launchctl unload $(LAUNCHD_PATH)/$(PLIST_NAME)
	sudo rm -f $(LAUNCHD_PATH)/$(PLIST_NAME)
	sudo rm -f $(INSTALL_PATH)/$(PROJECT_NAME)
	@echo "Service uninstalled successfully"

help:
	@echo "Available targets:"
	@echo "  build           - Build the project using xcodebuild"
	@echo "  install         - Build and install to $(INSTALL_PATH)"
	@echo "  uninstall       - Remove installed binary"
	@echo "  install_service - Build, install binary and install as LaunchDaemon service"
	@echo "  uninstall_service - Uninstall service and remove binary"
	@echo "  clean           - Clean build artifacts"
	@echo "  help            - Show this help message"
