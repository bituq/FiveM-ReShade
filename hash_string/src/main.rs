use std::env;
use std::fs::{self, OpenOptions};
use std::io::{self, Write, Read};
use std::path::Path;

fn hash_string(string: &str) -> u32 {
    let mut hash: u32 = 0;

    for ch in string.chars() {
        let lower_ch = ch.to_ascii_lowercase();
        hash += lower_ch as u32;
        hash += hash << 10;
        hash ^= hash >> 6;
    }

    hash += hash << 3;
    hash ^= hash >> 11;
    hash += hash << 15;

    hash
}

fn main() -> io::Result<()> {
    let computer_name =
        env::var("COMPUTERNAME").expect("COMPUTERNAME not found in the environment");

    let hashed_computer_name = hash_string(&computer_name);

    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: {} <ini_file_path>", args[0]);
        std::process::exit(1);
    }

    let ini_file_path = Path::new(&args[1]);

    let mut file_contents = String::new();

    if ini_file_path.exists() {
        let mut file = fs::File::open(ini_file_path)?;
        file.read_to_string(&mut file_contents)?;
    }

    let entry = format!(
        "ReShade5=ID:{:x} acknowledged that ReShade 5.x has a bug that will lead to game crashes",
        hashed_computer_name
    );

    if !file_contents.contains(&entry) {
        let mut ini_file = OpenOptions::new()
            .write(true)
            .append(true)
            .open(ini_file_path)?;

        // Check if we need to add [Addon] section header
        if !file_contents.contains("[Addons]") {
            writeln!(ini_file, "\n\n[Addons]")?;
        }
        
        writeln!(ini_file, "{}", entry)?;
    } else {
        println!("Entry already exists in the INI file.");
    }

    Ok(())
}