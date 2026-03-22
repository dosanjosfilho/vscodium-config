# vscodium-config

> Centralized [VSCodium](https://vscodium.com) configuration for teams.  
> Profile switching via a single shell script — no extensions required.

## Profiles

| Profile | Stack |
|---|---|
| `data-science` | Python · uv · ruff · ty · Jupyter · pytest |
| `software-engineer` | TypeScript · Expo · Bun · Biome |

Both profiles include:
- [Fira Code Nerd Font](https://github.com/ryanoasis/nerd-fonts) with ligatures
- [Starship](https://starship.rs) terminal font rendering
- Claude Code · Codex · Gemini AI agents

---

## Requirements

### VSCodium

```bash
brew install --cask vscodium
```

### Fira Code Nerd Font

```bash
brew install --cask font-fira-code-nerd-font
```

### Starship

```bash
brew install starship
```

Add to `~/.zshrc`:

```bash
eval "$(starship init zsh)"
```

---

## Usage

### Clone the repository

```bash
git clone https://github.com/dosanjosfilho/vscodium-config.git
cd vscodium-config
chmod +x switch-profile.sh
```

### Apply a profile

```bash
./switch-profile.sh data-science
```

```bash
./switch-profile.sh software-engineer
```

The script:
1. Copies `settings.json` to the VSCodium user directory
2. Installs all extensions listed in `extensions.txt`

### Reload VSCodium

```
Cmd+Shift+P → Developer: Reload Window
```

---

## Updating a Profile

Edit the files in the profile folder, then commit and push:

```bash
git add .
git commit -m "feat: update data-science settings"
git push
```

Other team members pull and re-run the script:

```bash
git pull
./switch-profile.sh data-science
```

---

## Repository Structure

```
vscodium-config/
├── switch-profile.sh          ← run this to apply a profile
├── data-science/
│   ├── settings.json
│   └── extensions.txt
└── software-engineer/
    ├── settings.json
    └── extensions.txt
```

---

## Stack Reference

### Data Science

| Tool | Role |
|---|---|
| [ty](https://astral.sh/blog/ty) | Type checker + language server |
| [ruff](https://docs.astral.sh/ruff/) | Linter + formatter |
| [uv](https://docs.astral.sh/uv/) | Package manager + virtual environments |
| Jupyter | Notebooks |
| pytest | Test runner |

### Software Engineer

| Tool | Role |
|---|---|
| [Biome](https://biomejs.dev) | Linter + formatter for JS/TS/JSX/TSX/JSON |
| [Bun](https://bun.sh) | JavaScript runtime + package manager |
| [Expo](https://expo.dev) | React Native framework |

---

## License

[MIT](LICENSE)
