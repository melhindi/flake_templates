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
