```
                                                           
       ,,                    ,...,,    ,,                  
     `7MM           mm     .d' ""db  `7MM                  
       MM           MM     dM`         MM                  
  ,M""bMM  ,pW"Wq.mmMMmm  mMMmm`7MM    MM  .gP"Ya  ,pP"Ybd 
,AP    MM 6W'   `Wb MM     MM    MM    MM ,M'   Yb 8I   `" 
8MI    MM 8M     M8 MM     MM    MM    MM 8M"""""" `YMMMa. 
`Mb    MM YA.   ,A9 MM     MM    MM    MM YM.    , L.   I8 
 `Wbmd"MML.`Ybmd9'  `Mbmo.JMML..JMML..JMML.`Mbmmd' M9mmmP' 
                                                           
                                                           
```

# dotfiles

This repository contains my personal dotfiles for development, primarily configured for use with [ohmyzsh](https://ohmyz.sh/) on macOS.

## Table of Contents
- [dotfiles](#dotfiles)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Updating](#updating)
  - [Contributing](#contributing)
  - [License](#license)

## Introduction

Dotfiles are configuration files for various applications and tools. This repository helps in managing and updating these files efficiently.

## Installation

### Fresh machine (one command)

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/adityataps/dotfiles/main/bootstrap.sh)"
```

This installs Xcode CLT, Homebrew, git, clones the repo, and runs full setup automatically.

### Existing machine

```zsh
git clone https://github.com/adityataps/dotfiles.git
cd dotfiles
./make_dotfiles.sh -i   # -i installs Homebrew packages
```

## Usage

Dotfiles in `dotfiles/` are symlinked to `$HOME` — editing `~/.zshrc` is editing the repo file directly.

Machine-specific shell config (aliases, env vars that don't belong in the repo) goes in `~/.zshrc.local`, which is sourced automatically at the end of `.zshrc`.

## Updating

```zsh
cd ~/dotfiles
git pull origin main
./make_dotfiles.sh
```

## Contributing

While this repository is meant as a personal project to manage my dotfiles, feel free to fork it as a template for your own dotfiles configuration files. Contributions are welcome! If you have suggestions or improvements, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE.md](LICENSE.md) file for more details.
