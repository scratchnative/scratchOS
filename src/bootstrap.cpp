#include <stddef.h>
#include <stdint.h>
#include <stivale2.hpp>

static uint8_t stack[0x4000];

[[gnu::section(".stivale2hdr"),
  gnu::used]] static stivale2_header stivale_hdr = {.entry_point = 0,
                                                    .stack = (uintptr_t)stack +
                                                             sizeof(stack),
                                                    .flags = (1 << 1),
                                                    .tags = (uintptr_t)0};

static void done(void) {
  for (;;) {
    __asm__("hlt");
  }
}

void scratch_main(void);

// The following will be our kernel's entry point.
extern "C" void _start(void) {
  scratch_main();

  // We're done, just hang...
  done();
}
