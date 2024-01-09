fn main() -> miette::Result<()> {
    let path = std::path::PathBuf::from("src"); // include path
    let mut b = autocxx_build::Builder::new("src/main.rs", &[&path]).build()?;
    b.flag_if_supported("-std=c++17")
        .flag_if_supported("-I src/include")
        .file("src/dragen-os.cpp")
        .compile("dragen-os"); // arbitrary library name, pick anything
    println!("cargo:rerun-if-changed=src/main.rs");
    println!("cargo:rerun-if-changed=src/dragen-os.cpp");
    // Add instructions to link to any C++ libraries you need.
    Ok(())
}
