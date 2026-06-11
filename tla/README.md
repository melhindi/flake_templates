# TLA+ Development Shell

This template provides a Nix development environment for TLA+ specifications.

## Usage

Enter the development shell:

```bash
nix develop
```

Launch the packaged VSCodium environment:

```bash
nix run .#codium
```

## Included Tools

- TLA+ tools from nixpkgs
- Community Modules
- `tlc-community`
- `sany-community`
- Graphviz
- VSCodium with the pinned TLA+ extension

The shell creates project-local helper directories such as `.nix-tlaplus`, `.nix-vscode`, and `.vscode` when needed.
