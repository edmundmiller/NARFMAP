use std::path::PathBuf;

use clap::{Parser, Subcommand};

include!(concat!(env!("OUT_DIR"), "/bindings.rs"));

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    /// Turn debugging information on
    #[arg(short, long, action = clap::ArgAction::Count)]
    debug: u8,

    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    BuildHashTable {
        #[arg(short, long, value_name = "FILE")]
        fasta: Option<PathBuf>,
    },

    Align {
        #[arg(short, long, value_name = "FILE")]
        fastq1: Option<PathBuf>,
        #[arg(short, long, value_name = "FILE")]
        fastq2: Option<PathBuf>,
    },
}

fn main() {
    let cli = Cli::parse();

    // You can see how many times a particular flag or argument occurred
    // Note, only flags can have multiple occurrences
    match cli.debug {
        0 => println!("Debug mode is off"),
        1 => println!("Debug mode is kind of on"),
        2 => println!("Debug mode is on"),
        _ => println!("Don't be crazy"),
    }

    // You can check for the existence of subcommands, and if found use their
    // matches just as you would the top level cmd
    match &cli.command {
        Some(Commands::BuildHashTable { fasta: _ }) => {}
        Some(Commands::Align {
            fastq1: _,
            fastq2: _,
        }) => {}
        None => {}
    }

    // Continued program logic goes here...
}
