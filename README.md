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

To get started with these dotfiles, follow the steps below:

1. **Clone the Repository:**

   ```zsh
   git clone https://github.com/adityataps/dotfiles.git
   ```

2. **Run the Setup Script:**

   Execute the `make_dotfiles` script to set up the environment. Use the `-i` flag to install necessary packages.

   ```zsh
   ./make_dotfiles -i
   ```

3. **Update Your Shell:**

   If necessary, update your shell configuration to apply the changes.

## Usage

After installation, your development environment should be configured with the provided dotfiles. You can customize these files further to suit your personal preferences.

## Updating

To update your dotfiles, pull the latest changes from the repository and rerun the setup script:

```zsh
git pull origin main
./make_dotfiles
```

## Contributing

While this repository is meant as a personal project to manage my dotfiles, feel free to fork it as a template for your own dotfiles configuration files. Contributions are welcome! If you have suggestions or improvements, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE.md](LICENSE.md) file for more details.
