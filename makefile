CXX = x86_64-elf-g++
LD = x86_64-elf-ld
AS = nasm

TARGET = $(BUILD_DIRECTORY)/kernel.elf
ISO = scratchOS.iso

KERNEL_ARGS := -O0 -g -Isrc -Wall -Wextra -Werror -Wno-stringop-overflow -MMD -O2 -std=gnu++20 \
			  -ffreestanding \
			  -fno-rtti \
			  -fno-builtin \
			  -fno-exceptions \
			  -fno-stack-protector \
			  -mno-80387 \
			  -nostdlib \
			  -mno-mmx \
			  -mno-3dnow \
			  -mno-sse \
			  -mno-sse2 \
			  -mno-red-zone \
			  -mcmodel=kernel \
			  -fno-use-cxa-atexit

LDFLAGS := \
	-nostdlib                 \
	-static                   \
	-z max-page-size=0x1000  \
	-T link.ld

NASMFLAGS := -felf64

CPPFILES  := src/output.cpp src/bootstrap.cpp

CPP_OBJ = $(patsubst %.cpp, $(BUILD_DIRECTORY)/%.cpp.o, $(CPPFILES)) 

OBJ = $(CPP_OBJ)

DEPS = $(patsubst $(BUILD_DIRECTORY)/%.cpp.o, $(BUILD_DIRECTORY)/%.cpp.d, $(CPP_OBJ)) 


BUILD_DIRECTORY := build
DIRECTORY_GUARD = @mkdir -p $(@D)

.DEFAULT_GOAL = $(ISO)

limine:
	git clone https://github.com/limine-bootloader/limine.git --branch=v3.0-branch-binary --depth=1
	make -C limine

$(ISO): $(TARGET) limine
	@$(SHELL) scripts/make-image.sh > /dev/null
	@echo "SH     scripts/make-image.sh" 

-include $(DEPS)

src/output.cpp:
	scratch2exe.py fetch 706910275
	scratchnative project.json.sb3 -o $@ --freestanding
	rm -rf project.json.sb3

src/limine.h:
	curl https://raw.githubusercontent.com/limine-bootloader/limine/trunk/limine.h -o $@

$(BUILD_DIRECTORY)/%.cpp.o: %.cpp src/limine.h
	@$(DIRECTORY_GUARD)
	@$(CXX) $(KERNEL_ARGS) -c -o $@ $<
	@echo "CXX   " $<


$(TARGET): $(OBJ)
	@$(LD) $(LDFLAGS) $^ -o $@
	@echo "LD    " $@

run: $(ISO)
	qemu-system-x86_64 -cdrom $< -enable-kvm -serial stdio -rtc base=localtime -m 2G -no-shutdown -no-reboot -cpu host

.PHONY: clean
clean:
	rm -rf $(BUILD_DIRECTORY) $(TARGET) $(ISO) $(MODULE_OBJS) $(TEST_EXE)
