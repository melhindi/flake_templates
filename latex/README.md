# LaTeX Development Shell

This template provides a Nix development shell for LaTeX projects.

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

- `latexrun`
- A curated TeX Live environment with common LaTeX collections and fonts
- `drawio` on Linux
- `nixcats` Neovim package in the `nvim` shell

## Building Documents

This template does not define a `nix build` target. Compile documents from inside the development shell with the command appropriate for the project, for example:

```bash
latexrun --latex-cmd=pdflatex main.tex
```

or:

```bash
latexmk -pdf main.tex
```
