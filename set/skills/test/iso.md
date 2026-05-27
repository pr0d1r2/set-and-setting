# Test: ISO

ISO artifact validation runs before QEMU boot tests and triggers a
build if no ISO exists.

## What it checks

- ISO file exists and is reasonably sized
- ISO9660 magic `CD001` at expected byte offset
- Filename matches canonical pattern
- El Torito boot catalog is declared (required for BIOS/UEFI boot)

## When to update

- Changed boot loader configuration -- verify El Torito is still
  present
- Changed filename format -- update the regex in the filename test
- Added a new mandatory file to the ISO -- add a structural check
