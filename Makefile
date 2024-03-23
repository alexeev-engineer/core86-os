ASM=nasm
ASM_FLAGS=-f bin -g
CC=gcc
CC_FLAGS=-g -Wall
VM=qemu-system-i386

SRC_DIR=src
BIN_DIR=bin

BOOTLOADER_DIR=$(SRC_DIR)/boot
BOOTLOADER_SOURCES=$(wildcard $(BOOTLOADER_DIR)/*.asm)
KERNEL_DIR=$(SRC_DIR)/kernel

IMG=$(BIN_DIR)/core86os.img
RESULT_BOOT=$(BIN_DIR)/bootloader.bin

DEL_FILE      = rm -f
CHK_DIR_EXISTS= test -d
MKDIR         = mkdir -p
COPY          = cp -f
COPY_FILE     = cp -f
COPY_DIR      = cp -f -R
INSTALL_FILE  = install -m 644 -p
INSTALL_PROGRAM = install -m 755 -p
INSTALL_DIR   = cp -f -R
DEL_FILE      = rm -f
SYMLINK       = ln -f -s
DEL_DIR       = rmdir
MOVE          = mv -f
TAR           = tar -cf
COMPRESS      = gzip -9f
RANLIB        = 
SED           = sed
STRIP         = strip


build: $(IMG)

$(BIN_DIR):
	@echo "  MKDIR		$(BIN_DIR)"
	$(MKDIR) $(BIN_DIR)

$(RESULT_BOOT): $(BIN_DIR)
	@echo "  ASM		$(BOOTLOADER_SOURCES)"
	$(ASM) $(ASM_FLAGS) $(BOOTLOADER_SOURCES) -o $(RESULT_BOOT)

$(IMG): $(RESULT_BOOT)
	@echo "  DD		$(IMG)"
	dd if=/dev/zero of=$(IMG) bs=1024 count=4096
	dd if=$(RESULT_BOOT) of=$(IMG) conv=notrunc

clean:
	$(DEL_FILE) $(BIN_DIR)/*.bin

run:
	$(VM) $(IMG)
