# Zig Development Shell

This template provides a Zig development shell with a matching `zls`.

## Select A Zig Version

The default shell uses Zig 0.16:

```bash
nix develop
```

Use a named shell to select a different version:

```bash
nix develop .#zig_0_14
nix develop .#zig_0_15
nix develop .#zig_0_16
nix develop .#zig_master
```

Each shell selects the matching Zig and ZLS package pair:

- `zig_0_14` with `zls_0_14`
- `zig_0_15` with `zls_0_15`
- `zig_0_16` with `zls_0_16`
- `zig_master` with Zig nightly from `mitchellh/zig-overlay` and ZLS master from `zigtools/zls`

## Usage

Enter the default shell:

```bash
nix develop
```

Or select a specific Zig/ZLS pair:

```bash
nix develop .#zig_0_14
nix develop .#zig_0_15
nix develop .#zig_0_16
nix develop .#zig_master
```

If you use `direnv`, create `.envrc` with the shell you want:

```bash
echo 'use flake .#zig_0_16' > .envrc
direnv allow
```

Use `.#zig_0_14`, `.#zig_0_15`, `.#zig_0_16`, or `.#zig_master` in `.envrc` depending on the project.

Neovim LSP setups that resolve `zls` from `PATH` can use the project-local language server when Neovim is launched from inside the development shell.

## Verify

```bash
zig version
zls --version
```
