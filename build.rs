use std::path::Path;

fn main() -> miette::Result<()> {
    let include_dir = Path::new("src/include/");
    let boost_includedir = Path::new(env!("BOOST_INCLUDEDIR"));

    let path = std::path::PathBuf::from("src"); // include path
    let mut b = autocxx_build::Builder::new("src/main.rs", &[&path]).build()?;
    b.std("c++17")
        .include(include_dir)
        .include(boost_includedir)
        .file("src/dragen-os.cpp")
        .compile("dragen-os"); // arbitrary library name, pick anything
    println!("cargo:rerun-if-changed=src/main.rs");
    println!("cargo:rerun-if-changed=src/dragen-os.cpp");
    // Add instructions to link to any C++ libraries you need.
    Ok(())
}
