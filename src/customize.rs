#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! colored = "2.0.0"
//! dialoguer = "0.10.3"
//! duct = "0.13.6"
//! handlebars = "4.3.6"
//! map-macro = "0.2.5"
//! str_inflector = "0.12.0"
//! ```

use colored::*;
use dialoguer::{Confirm, Input};
use duct::cmd;
use handlebars::Handlebars;
use inflector::Inflector;
use map_macro::map;
use std::{env, error::Error, fs, path::PathBuf, process::ExitCode};

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
        let old_project_name_snake = "flutter_basic_quickstart";
        let old_project_name_title = "Flutter Basic Quickstart";
        let old_project_name_pascal = "FlutterBasicQuickstart";
        let old_bundle_id = "com.example.flutter_basic_quickstart";
        let old_main_activity_kt_path = PathBuf::from(
            "android/app/src/main/kotlin/com/example/flutter_basic_quickstart/MainActivity.kt",
        );
        let project_name_snake = project_name.to_snake_case();
        let project_name_pascal = project_name.to_pascal_case();
        let project_name_title = project_name.to_title_case();
        let pubspec_yaml_path = "pubspec.yaml";
        let read_me_path = "README.md";
        let main_dart_path = "lib/main.dart";
        let widget_test_dart_path = "test/widget_test.dart";
        let version_json5_path = "version.json5";
        let info_plist_path = "ios/Runner/Info.plist";
        let project_pbxproj_1_path = "ios/Runner.xcodeproj/project.pbxproj";
        let build_gradle_path = "android/app/build.gradle";
        let android_manifest_xml_1_path = "android/app/src/debug/AndroidManifest.xml";
        let android_manifest_xml_2_path = "android/app/src/main/AndroidManifest.xml";
        let android_manifest_xml_3_path = "android/app/src/profile/AndroidManifest.xml";
        let cmakelists_text_1_path = "linux/CMakeLists.txt";
        let my_application_cc_path = "linux/my_application.cc";
        let app_info_xcconfig_path = "macos/Runner/Configs/AppInfo.xcconfig";
        let project_pbxproj_2_path = "macos/Runner.xcodeproj/project.pbxproj";
        let runner_xcscheme_path = "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme";
        let index_html_path = "web/index.html";
        let manifest_json_path = "web/manifest.json";
        let cmakelists_text_2_path = "windows/CMakeLists.txt";
        let runner_rc_path = "windows/runner/Runner.rc";
        let main_cpp_path = "windows/runner/Main.cpp";
        let old_company = "com.example";
        let handlebars = Handlebars::new();

        let description = Input::<String>::new()
            .with_prompt("What is the project description")
            .interact_text()?;
        let company = Input::<String>::new()
            .with_prompt("What is the company name")
            .interact_text()?;
        let mut bundle_id = Input::<String>::new()
            .with_prompt("What will the bundle ID be")
            .interact_text()?;

        bundle_id = bundle_id.replace("-", "_");

        // iOS

        fs::write(
            &info_plist_path,
            fs::read_to_string(&info_plist_path)?
                .replace(old_project_name_snake, &project_name_snake)
                .replace(old_project_name_title, &project_name_title),
        )?;

        fs::write(
            &project_pbxproj_1_path,
            fs::read_to_string(&project_pbxproj_1_path)?.replace(old_bundle_id, &bundle_id),
        )?;

        // macOS

        fs::write(
            &app_info_xcconfig_path,
            fs::read_to_string(&app_info_xcconfig_path)?
                .replace(old_company, &company)
                .replace(old_bundle_id, &bundle_id)
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        fs::write(
            &project_pbxproj_2_path,
            fs::read_to_string(&project_pbxproj_2_path)?
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        fs::write(
            &runner_xcscheme_path,
            fs::read_to_string(&runner_xcscheme_path)?
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        // Android

        let main_activity_kt_path = PathBuf::from(format!(
            "android/app/src/main/kotlin/{}/MainActivity.kt",
            bundle_id.split('.').collect::<Vec<&str>>().join("/")
        ));

        // Move the MainActivity.kt file into the right directory
        fs::create_dir_all(
            &main_activity_kt_path
                .parent()
                .ok_or(String::from("bad path"))?,
        )?;
        fs::rename(&old_main_activity_kt_path, &main_activity_kt_path)?;

        // TODO(john): Clean-up better need to check for empty directory
        // fs::remove_dir_all("android/app/src/main/kotlin/com")?;

        fs::write(
            &main_activity_kt_path,
            fs::read_to_string(&main_activity_kt_path)?.replace(old_bundle_id, &bundle_id),
        )?;

        fs::write(
            &build_gradle_path,
            fs::read_to_string(&build_gradle_path)?.replace(old_bundle_id, &bundle_id),
        )?;

        fs::write(
            &android_manifest_xml_1_path,
            fs::read_to_string(android_manifest_xml_1_path)?.replace(old_bundle_id, &bundle_id),
        )?;

        fs::write(
            &android_manifest_xml_2_path,
            fs::read_to_string(android_manifest_xml_2_path)?
                .replace(old_bundle_id, &bundle_id)
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        fs::write(
            &android_manifest_xml_3_path,
            fs::read_to_string(android_manifest_xml_3_path)?.replace(old_bundle_id, &bundle_id),
        )?;

        // Linux

        fs::write(
            &cmakelists_text_1_path,
            fs::read_to_string(cmakelists_text_1_path)?
                .replace(old_bundle_id, &bundle_id)
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        fs::write(
            &my_application_cc_path,
            fs::read_to_string(my_application_cc_path)?
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        // Web

        fs::write(
            &index_html_path,
            fs::read_to_string(&index_html_path)?
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        fs::write(
            &manifest_json_path,
            fs::read_to_string(&manifest_json_path)?
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        // Windows

        fs::write(
            &cmakelists_text_2_path,
            fs::read_to_string(&cmakelists_text_2_path)?
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        fs::write(
            &main_cpp_path,
            fs::read_to_string(&main_cpp_path)?
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        fs::write(
            &runner_rc_path,
            fs::read_to_string(&runner_rc_path)?
                .replace(old_company, &company)
                .replace(old_project_name_snake, &project_name_snake),
        )?;

        // General

        fs::write(
            &pubspec_yaml_path,
            fs::read_to_string(&pubspec_yaml_path)?
                .replace(old_project_name_snake, &project_name_snake)
                .replace(old_project_name_title, &project_name_title),
        )?;

        fs::write(
            &main_dart_path,
            fs::read_to_string(&main_dart_path)?
                .replace(old_project_name_title, &project_name_title)
                .replace(old_project_name_pascal, &project_name_pascal),
        )?;

        fs::write(
            &widget_test_dart_path,
            fs::read_to_string(&widget_test_dart_path)?
                .replace(old_project_name_snake, &project_name_snake)
                .replace(old_project_name_pascal, &project_name_pascal),
        )?;

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

        fs::write(
            &version_json5_path,
            &handlebars.render_template(
                &fs::read_to_string(&version_json5_path)?,
                &map! {
                    "company" => &company,
                },
            )?,
        )?;

        // Clean-up

        if Confirm::new()
            .with_prompt("Delete customization scripts?")
            .interact()?
        {
            fs::remove_dir_all("src")?;
            fs::remove_file("Cargo.toml")?;
            fs::remove_file("Cargo.lock")?;
        }

        let reinitialize_repo = Confirm::new()
            .with_prompt("Reinitialize Git repo?")
            .interact()?;

        // Finalization

        Self::info("Updating version information");
        cmd!("stampver", "-u", "incrBuild").run()?;

        Self::info("Downloading public packages");
        cmd!("flutter", "pub", "get").run()?;

        Self::info("Generating all build files");
        cmd!("just", "generate").run()?;

        if reinitialize_repo {
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
