# Personal Nix Development Templates

This repository contains personal project templates for `nix flake init`.

## Templates

| Template | Description |
| --- | --- |
| `latex` | LaTeX development shell with TeX Live tooling. |
| `tla` | TLA+ development shell with TLC, Community Modules, and VSCodium. |
| `zig` | Zig development shell with a selectable Zig/ZLS toolchain. |

## Usage

Initialize a project from a named template:

```bash
nix flake init --template github:melhindi/flake_templates#latex
```

```bash
nix flake init --template github:melhindi/flake_templates#tla
```

```bash
nix flake init --template github:melhindi/flake_templates#zig
```

The default template is `latex`, so this also works:

```bash
nix flake init --template github:melhindi/flake_templates
```

For local testing from this checkout:

```bash
nix flake show .
mkdir -p /tmp/flake-template-test
cd /tmp/flake-template-test
nix flake init --template /home/melhindi/git/flake_templates#latex
```

## Notes

- Template files must be tracked by Git before Nix can see them through normal Git-backed flake references.
- `flake.lock` files are intentionally ignored here so new projects can resolve their own inputs.
- `nix flake init` copies files into the current directory and does not overwrite existing files.
