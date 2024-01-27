cargo build --manifest-path ./hash_string/Cargo.toml --release
makensis src/scripts/Main.nsi
@REM upx -9 "./output/setup.exe"