#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0.0"
//! str_inflector = "0.12.0"
//! dialoguer = "0.10.3"
//! handlebars = "4.3.6"
//! map-macro = "0.2.5"
//! duct = "0.13.6"
//! ```

use colored::*;
use dialoguer::{Confirm, Input};
use duct::cmd;
use handlebars::Handlebars;
use inflector::Inflector;
use map_macro::map;
use std::{env, error::Error, fs, process::ExitCode};

trait Logger {
    fn info(s: &str);
    fn error(s: &str);
    fn warning(s: &str);
}

struct Customizer {}

impl Logger for Customizer {
    fn info(s: &str) {
        println!("👉 {}", s);
    }

    fn error(s: &str) {
        eprintln!("💥 {}", s.red());
    }

    fn warning(s: &str) {
        eprintln!("🐓 {}", s.yellow());
    }
}

impl Customizer {
    fn new() -> Customizer {
        Customizer {}
    }

    fn run(&self, project_name: &str) -> Result<(), Box<dyn Error>> {
        let project_name_snake = project_name.to_snake_case();
        let project_name_pascal = project_name.to_pascal_case();
        let project_name_title = project_name.to_title_case();
        let pubspec_yaml_path = "pubspec.yaml";
        let read_me_path = "README.md";
        let main_dart_path = "lib/main.dart";
        let test_dart_path = "test/widget_test.dart";

        fs::write(
            &pubspec_yaml_path,
            fs::read_to_string(&pubspec_yaml_path)?
                .replace("flutter_basic_quickstart", &project_name_snake)
                .replace("FlutterBasicQuickstart", &project_name_pascal),
        )?;

        fs::write(
            &main_dart_path,
            fs::read_to_string(&main_dart_path)?
                .replace("FlutterBasicQuickstart", &project_name.to_pascal_case()),
        )?;

        fs::write(
            &test_dart_path,
            fs::read_to_string(&test_dart_path)?
                .replace("flutter_basic_quickstart", &project_name.to_snake_case())
                .replace("FlutterBasicQuickstart", &project_name.to_pascal_case()),
        )?;

        let description = Input::<String>::new()
            .with_prompt("Enter the description for the project")
            .interact_text()?;

        let handlebars = Handlebars::new();

        fs::write(
            &read_me_path,
            &handlebars.render_template(
                &fs::read_to_string(&read_me_path)?,
                &map! {
                    "title" => &project_name_title,
                    "description" => &description,
                },
            )?,
        )?;

        if Confirm::new()
            .with_prompt("Delete customization scripts?")
            .interact()?
        {
            fs::remove_file("customize.rs")?;
        }

        if Confirm::new()
            .with_prompt("Reinitialize Git repo?")
            .interact()?
        {
            fs::remove_dir_all(".git")?;
            cmd!("git", "init").run()?;
            cmd!("git", "add", "-A", ":/").run()?;
            cmd!("git", "commit", "-m", "'Initial commit'").run()?;
        }

        Self::info("Customization complete");

        Ok(())
    }
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    let customizer = Customizer::new();

    if args.len() < 2 {
        eprintln!("Usage: customize [PROJECT-NAME]");
        return ExitCode::SUCCESS;
    }

    if let Err(err) = customizer.run(&args[1]) {
        Customizer::error(&err.to_string());
        return ExitCode::FAILURE;
    }

    ExitCode::SUCCESS
}
