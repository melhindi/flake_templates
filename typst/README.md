# Typst Development Shell

This template provides a Nix development shell for Typst documents.

## Shells

Enter the default shell:

```bash
nix develop
```

Enter the shell with the configured Neovim package:

```bash
nix develop .#nvim
```

If you use `direnv`, create `.envrc` with the shell you want:

```bash
echo 'use flake' > .envrc
direnv allow
```

Use `use flake .#nvim` in `.envrc` for the Neovim-enabled shell.

Editors started from inside the shell use the project's `typst` and `tinymist` instead of their own copies.

## Included Tools

- `typst`
- `tinymist` language server
- `nixcats` Neovim package in the `nvim` shell (Linux only)

## Building Documents

This template does not define a `nix build` target. Compile documents from inside the development shell:

```bash
typst compile main.typ
```

or rebuild on every change:

```bash
typst watch main.typ
```
