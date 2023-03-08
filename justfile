# Generate SVG by cleaning and compiling all SVG's from `raw_assets/raw_svg` to `assets/images`
generate-clean-svg:
  #!/usr/bin/env fish
  for file in (pwd)/raw_assets/raw_svg/*.svg
    printf 'Cleaning "'(basename $file)'". '
    svgcleaner $file (pwd)/raw_assets/clean_svg/(basename $file)
  end

# Generate all the .g.dart files in the project
generate-g-files:
  dart run build_runner build --delete-conflicting-outputs

# Generate binary .vec files to optimize loading of images for `flutter_svg`
generate-vec:
  #!/usr/bin/env fish
  for file in (pwd)/raw_assets/clean_svg/*.svg
    printf 'Generating .vec for "'(basename $file)'". '
    dart run vector_graphics_compiler -i $file -o (pwd)/assets/images/(basename $file).vec
  end

# Generate icons with `icons_launcher`
generate-icons:
  flutter pub run icons_launcher:create

# Generate the splash screens with `flutter_native_splash`
generate-splash:
  flutter pub run flutter_native_splash:create

# Show outdated packages
show-outdated:
  flutter pub outdated

# Update version information
version OPERATION='incrRevision':
  stampver {{OPERATION}} -u -i version.json5

# Run all generators
generate: generate-g-files generate-icons generate-splash generate-clean-svg generate-vec
