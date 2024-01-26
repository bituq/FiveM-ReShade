cargo build --manifest-path ./hash_string/Cargo.toml --release
makensis src/scripts/Main.nsi
upx -9 "./output/setup.exe"