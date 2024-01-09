use std::process::Command;

fn main() -> miette::Result<()> {
    println!("cargo:rerun-if-changed=Makefile");
    let status = Command::new("make")
        .args(&["clean"])
        .status()
        .expect("failed to run \"make clean\"");
    assert!(status.success());

    // build dragen-os command and dragen static library
    let status = Command::new("make")
        .status()
        .expect("failed to run \"make\"");
    assert!(status.success());
    // Add instructions to link to any C++ libraries you need.
    Ok(())
}
