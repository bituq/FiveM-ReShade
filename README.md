# FiveM-ReShade Installer

## Description
This installer, created with NSIS, simplifies the complex and specific process of installing ReShade for FiveM, a modification for Grand Theft Auto V. The project also includes a Rust program, `hash_string`, designed to mimic FiveM's hashing algorithm.

## Usage
Run the compiled installer and follow the on-screen instructions to install ReShade on FiveM.

## Building the Installer
To build the installer:
1. Open a command prompt or terminal.
2. Navigate to the script's directory.
3. Run `makensis Main.nsi` or execute `build.bat`.

## The `hash_string` Program
- Written in Rust, designed to mimic FiveM's hashing algorithm.
- This is required for setting an entry in `CitizenFX.ini` to make FiveM work with ReShade.

### Building hash_string
To build hash_string:
1. Navigate to the `hash_string` directory.
2. Run `cargo build --release`.

## License
Licensed under the [BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause).

## Additional Notes
For issues or queries, open an issue in the [GitHub repository](https://github.com/bituq/FiveM-ReShade).