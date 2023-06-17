#!/usr/bin/env -S deno run --unstable --allow-run --allow-read --allow-write
import {
  Command,
  ValidationError,
} from "https://deno.land/x/cliffy@v0.25.7/command/mod.ts";
import {
  snakeCase,
  titleCase,
  pascalCase,
} from "https://deno.land/x/case@2.1.1/mod.ts";
import {
  Input,
  Confirm,
} from "https://deno.land/x/cliffy@v0.25.7/prompt/mod.ts";
import { Karacho } from "https://deno.land/x/karacho@v1.0.25/main.ts";
import * as path from "https://deno.land/std@0.184.0/path/mod.ts";

await new Command()
  .name("customize.ts")
  .version("1.0.0")
  .description("Customizes the Flutter template")
  .arguments("<PROJECTNAME:string>")
  .error((error) => {
    if (error instanceof ValidationError) {
      console.error(error.message);
      Deno.exit(1);
    }
  })
  .action(async (_options, args) => {
    const oldProjectNameSnake = "flutter_basic_quickstart";
    const oldProjectNameTitle = "Flutter Basic Quickstart";
    const oldProjectNamePascal = "FlutterBasicQuickstart";
    const oldBundleId = "com.example.flutter-basic-quickstart";
    const oldApplicationId = "com.example.flutter_basic_quickstart";
    const oldMainActivityKtPath =
      "android/app/src/main/kotlin/com/example/flutter_basic_quickstart/MainActivity.kt";
    const projectName = args;
    const projectNameSnake = snakeCase(projectName);
    const projectNamePascal = pascalCase(projectName);
    const projectNameTitle = titleCase(projectName);
    const pubspecYamlPath = "pubspec.yaml";
    const readMePath = "README.md";
    const mainDartPath = "lib/main.dart";
    const widgetTestDartPath = "test/widget_test.dart";
    const versionJson5Path = "version.json5";
    const infoPlistPath = "ios/Runner/Info.plist";
    const projectPbxproj1Path = "ios/Runner.xcodeproj/project.pbxproj";
    const buildGradlePath = "android/app/build.gradle";
    const androidManifestXml1Path = "android/app/src/debug/AndroidManifest.xml";
    const androidManifestXml2Path = "android/app/src/main/AndroidManifest.xml";
    const androidManifestXml3Path =
      "android/app/src/profile/AndroidManifest.xml";
    const cmakelistsText1Path = "linux/CMakeLists.txt";
    const myApplicationCcPath = "linux/my_application.cc";
    const appInfoXcconfigPath = "macos/Runner/Configs/AppInfo.xcconfig";
    const projectPbxproj2Path = "macos/Runner.xcodeproj/project.pbxproj";
    const runnerXcschemePath =
      "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme";
    const indexHtmlPath = "web/index.html";
    const manifestJsonPath = "web/manifest.json";
    const cmakelistsText2Path = "windows/CMakeLists.txt";
    const runnerRcPath = "windows/runner/Runner.rc";
    const mainCppPath = "windows/runner/Main.cpp";
    const oldCompany = "ExampleCompany";

    const description = await Input.prompt(
      "Enter the description for the project"
    );
    const company = await Input.prompt("Enter the company name");
    let bundleId = await Input.prompt("Enter the iOS bundle ID");
    const karacho = new Karacho();

    bundleId = bundleId.replaceAll("_", "-");

    const applicationId = bundleId.replaceAll("-", "_");

    console.info(`iOS/macOS Bundle ID is '${bundleId}'`);
    console.info(`Android Application ID is '${applicationId}'`);

    // iOS
    Deno.writeTextFileSync(
      infoPlistPath,
      Deno.readTextFileSync(infoPlistPath)
        .replaceAll(oldProjectNameSnake, projectNameSnake)
        .replaceAll(oldProjectNameTitle, projectNameTitle)
    );

    Deno.writeTextFileSync(
      projectPbxproj1Path,
      Deno.readTextFileSync(projectPbxproj1Path).replaceAll(
        oldBundleId,
        bundleId
      )
    );

    // macOS

    Deno.writeTextFileSync(
      appInfoXcconfigPath,
      Deno.readTextFileSync(appInfoXcconfigPath)
        .replaceAll(oldBundleId, bundleId)
        .replaceAll(oldCompany, company)
        .replaceAll(oldProjectNameSnake, projectNameSnake)
    );

    Deno.writeTextFileSync(
      projectPbxproj2Path,
      Deno.readTextFileSync(projectPbxproj2Path).replaceAll(
        oldProjectNameSnake,
        projectNameSnake
      )
    );

    Deno.writeTextFileSync(
      runnerXcschemePath,
      Deno.readTextFileSync(runnerXcschemePath).replaceAll(
        oldProjectNameSnake,
        projectNameSnake
      )
    );

    // Android

    const mainActivityKtPath = `android/app/src/main/kotlin/${applicationId
      .split(".")
      .join("/")}/MainActivity.kt`;

    // Move the MainActivity.kt file into the right directory
    Deno.mkdirSync(path.dirname(mainActivityKtPath), { recursive: true });
    Deno.renameSync(oldMainActivityKtPath, mainActivityKtPath);

    if (applicationId.startsWith("com.")) {
      Deno.removeSync("android/app/src/main/kotlin/com/example", {
        recursive: true,
      });
    } else {
      Deno.removeSync("android/app/src/main/kotlin/com", { recursive: true });
    }

    Deno.writeTextFileSync(
      mainActivityKtPath,
      Deno.readTextFileSync(mainActivityKtPath).replaceAll(
        oldApplicationId,
        applicationId
      )
    );

    Deno.writeTextFileSync(
      buildGradlePath,
      Deno.readTextFileSync(buildGradlePath).replaceAll(
        oldApplicationId,
        applicationId
      )
    );

    Deno.writeTextFileSync(
      androidManifestXml1Path,
      Deno.readTextFileSync(androidManifestXml1Path).replaceAll(
        oldApplicationId,
        applicationId
      )
    );

    Deno.writeTextFileSync(
      androidManifestXml2Path,
      Deno.readTextFileSync(androidManifestXml2Path)
        .replaceAll(oldApplicationId, applicationId)
        .replaceAll(oldProjectNameSnake, projectNameSnake)
    );

    Deno.writeTextFileSync(
      androidManifestXml3Path,
      Deno.readTextFileSync(androidManifestXml3Path).replaceAll(
        oldApplicationId,
        applicationId
      )
    );

    // Linux

    Deno.writeTextFileSync(
      cmakelistsText1Path,
      Deno.readTextFileSync(cmakelistsText1Path)
        .replaceAll(oldBundleId, bundleId)
        .replaceAll(oldProjectNameSnake, projectNameSnake)
    );

    Deno.writeTextFileSync(
      myApplicationCcPath,
      Deno.readTextFileSync(myApplicationCcPath).replaceAll(
        oldProjectNameSnake,
        projectNameSnake
      )
    );

    // Web

    Deno.writeTextFileSync(
      indexHtmlPath,
      Deno.readTextFileSync(indexHtmlPath).replaceAll(
        oldProjectNameSnake,
        projectNameSnake
      )
    );

    Deno.writeTextFileSync(
      manifestJsonPath,
      Deno.readTextFileSync(manifestJsonPath).replaceAll(
        oldProjectNameSnake,
        projectNameSnake
      )
    );

    // Windows

    Deno.writeTextFileSync(
      cmakelistsText2Path,
      Deno.readTextFileSync(cmakelistsText2Path).replaceAll(
        oldProjectNameSnake,
        projectNameSnake
      )
    );

    Deno.writeTextFileSync(
      mainCppPath,
      Deno.readTextFileSync(mainCppPath).replaceAll(
        oldProjectNameSnake,
        projectNameSnake
      )
    );

    Deno.writeTextFileSync(
      runnerRcPath,
      Deno.readTextFileSync(runnerRcPath)
        .replaceAll(oldCompany, company)
        .replaceAll(oldProjectNameSnake, projectNameSnake)
    );

    // General

    Deno.writeTextFileSync(
      pubspecYamlPath,
      Deno.readTextFileSync(pubspecYamlPath)
        .replaceAll(oldProjectNameSnake, projectNameSnake)
        .replaceAll(oldProjectNameTitle, projectNameTitle)
    );

    Deno.writeTextFileSync(
      mainDartPath,
      Deno.readTextFileSync(mainDartPath)
        .replaceAll(oldProjectNameTitle, projectNameTitle)
        .replaceAll(oldProjectNamePascal, projectNamePascal)
    );

    Deno.writeTextFileSync(
      widgetTestDartPath,
      Deno.readTextFileSync(widgetTestDartPath)
        .replaceAll(oldProjectNameSnake, projectNameSnake)
        .replaceAll(oldProjectNamePascal, projectNamePascal)
    );

    Deno.writeTextFileSync(
      readMePath,
      karacho.compile(Deno.readTextFileSync(readMePath))({
        title: projectNameTitle,
        description: description,
      })
    );

    Deno.writeTextFileSync(
      versionJson5Path,
      karacho.compile(Deno.readTextFileSync(versionJson5Path))({
        company,
      })
    );

    // Clean-up

    if (await Confirm.prompt("Delete customization script?")) {
      Deno.removeSync("customize.ts");
    }

    const reinitializeRepo = await Confirm.prompt("Reinitialize Git repo?");

    // Finalization

    console.info("Copying default configuration");
    Deno.copyFileSync(
      "lib/providers/app_config_provider.default.dart",
      "lib/providers/app_config_provider.dart"
    );

    console.info("Downloading public packages");
    await new Deno.Command("flutter", { args: ["pub", "get"] }).spawn().status;

    console.info("Generating all build files");
    await new Deno.Command("just", { args: ["generate"] }).spawn().status;

    if (reinitializeRepo) {
      Deno.removeSync(".git", { recursive: true });
      await new Deno.Command("git", { args: ["init"] }).spawn().status;
      await new Deno.Command("git", { args: ["add", "-A", ":/"] }).spawn()
        .status;
      await new Deno.Command("git", {
        args: ["commit", "-m", "Initial commit"],
      }).spawn().status;
    }

    console.info("Customization complete");
  })
  .parse(Deno.args);
