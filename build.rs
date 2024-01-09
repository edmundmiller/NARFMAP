fn main() -> miette::Result<()> {
    let include_dir = Some(std::path::Path::new("src/include/"));

    let path = std::path::PathBuf::from("src"); // include path
    let mut b = autocxx_build::Builder::new("src/main.rs", &[&path]).build()?;
    b.flag_if_supported("-std=c++17")
        .includes(include_dir)
        .file("src/dragen-os.cpp")
        .compile("dragen-os"); // arbitrary library name, pick anything
    println!("cargo:rerun-if-changed=src/main.rs");
    println!("cargo:rerun-if-changed=src/dragen-os.cpp");
    // Add instructions to link to any C++ libraries you need.
    Ok(())
}
