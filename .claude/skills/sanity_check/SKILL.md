---
description: "Tests nix files"
argument-hint: "specific files or modules"
---
Before testing the code always ask these questions:
1. Run only the changes or for the whole codebase?
2. Run using predefined settings or other custom command. For example, predefined in a `Makefile` or a `justfile`. If the user wants a custom command, suggest at lleast one for the user.

To run the build tests for this repository, in accordance with the host. For example, for mbp2023 you run `make test H=mbp2023`.



