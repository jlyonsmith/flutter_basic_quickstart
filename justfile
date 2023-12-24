# List the available recipes
default:
  just --list

# Generate clean SVG's to avoid problems creating .vec's
svg:
  #!/usr/bin/env fish
  set targetDir (pwd)/raw_assets/clean_svg
  if not test -d $targetDir
    mkdir -p $targetDir
  end
  for file1 in (pwd)/raw_assets/raw_svg/*.svg
    set file2 $targetDir/(basename $file1)
    if test $file1 -nt $file2
      printf 'Cleaning "'(basename $file1)'". '
      svgcleaner --allow-bigger-file $file1 $file2
    end
  end

# Generate .vec files to optimize loading of images for `flutter_svg`
vec:
  #!/usr/bin/env fish
  set targetDir (pwd)/assets/images
  if not test -d $targetDir
    mkdir -p $targetDir
  end
  for file1 in (pwd)/raw_assets/clean_svg/*.svg
    set file2 $targetDir/(basename $file1).vec
    if test $file1 -nt $file2
      printf 'Generating .vec for "'(basename $file1)'". '
      dart run vector_graphics_compiler -i $file1 -o $file2
    end
  end

# Generates `json_serializable`, `equatable` and `go_router_builder` files
runner:
  dart run build_runner build --delete-conflicting-outputs

# Generate icons with `icons_launcher`
icons:
  dart run icons_launcher:create
  dart run icons_launcher:create --flavor next

# Generate the splash screens with `flutter_native_splash`
splash:
  dart run flutter_native_splash:create

# Clean all .vec files
clean-vec:
    for file in (pwd)/raw_assets/clean_svg/*.vec; rm $file; end

# Show outdated packages
outdated:
  dart pub outdated

# Update version information
version OPERATION='incrRevision':
  stampver {{OPERATION}} -u -i version.json5

# Run all generators
generate: runner svg vec icons splash

# Branch
branch VERSION:
  #!/usr/bin/env fish
  function info; set_color green; echo "👉 "$argv; set_color normal; end
  function warning; set_color yellow; echo "🐓 "$argv; set_color normal; end
  function error; set_color red; echo "💥 "$argv; set_color normal; end

  if not string match -q -r '\d+\.\d+' -- {{VERSION}}
    error "Branch name must match format 'M.m', e.g. 3.5"
    exit 1
  end

  if not git rev-parse --verify 3.1 2>/dev/null
    error "Branch {{VERSION}} already exists locally"
    exit 1
  end

  git checkout -b {{VERSION}}
  git push -u origin HEAD
  git branch -vv

  info "Branch {{VERSION}} created locally and remotely"

# Generate a release build, run tests, tag or re-tag the build
release OPERATION='incrBuild' BUNDLES='apk,ipa':
  #!/usr/bin/env fish
  function info; set_color green; echo "👉 "$argv; set_color normal; end
  function warning; set_color yellow; echo "🐓 "$argv; set_color normal; end
  function error; set_color red; echo "💥 "$argv; set_color normal; end

  function rollBackConfig
    info "Restoring configuration"
    mv "scratch/app_config_provider.dart" "lib/providers/"
  end

  function rollbackChanges
    info "Undoing build changes"
    git checkout $branch .
  end

  if test ! -e "pubspec.yaml"
    error "pubspec.yaml file should be in the justfile directory"
    exit 1
  end

  if not git diff --quiet HEAD
    error "There are uncomitted changes - commit or stash them and try again"
    exit 1
  end

  set operation {{OPERATION}}
  set branch (string trim (git rev-parse --abbrev-ref HEAD 2> /dev/null))
  set projectName (basename (pwd))
  set bundles (string split ',' {{BUNDLES}})

  if string match -q -r '\d+\.\d+' -- $branch; and test $operation != 'incrBuild' -a $operation != 'incrPatch'
    error "You can only perform incrPatch or incrBuild builds on a branch"
    exit 1
  end

  info "Starting release build of '"$projectName"' on branch '"$branch"'"
  info "Checking out '"$branch"'"
  git checkout $branch

  info "Pulling latest"
  git pull

  mkdir scratch 2> /dev/null

  info "Saving & swapping in default configuration"
  mv "lib/providers/app_config_provider.dart" "scratch/"
  cp "lib/providers/app_config_provider.default.dart" "lib/providers/app_config_provider.dart"

  if not stampver $operation -u -i version.json5
    error "Unable to generation version information"
    rollBackConfig
    exit 1
  end

  set tagName (cat "scratch/version.tag.txt")
  set tagDescription (cat "scratch/version.desc.txt")

  # If the patch exists already we are doing a new build and we need to delete the old tag so we can move it
  if git rev-parse -q --verify $tagName 2>/dev/null >/dev/null; and test $operation = 'incrBuild'
    warning "Detected existing tag'"$tagName"' - we will move the old tag to the new build"
    set deleteExistingTag 1
  end

  flutter pub get

  just generate

  if test $status -ne 0
    error "Asset & code generation failed"
    rollbackChanges
    rollBackConfig
    exit 1
  end

  flutter test

  if test $status -ne 0
    error "Tests failed"
    rollbackChanges
    rollBackConfig
    exit 1
  end

  if contains ipa $bundles
    info "Building IPA"
    flutter build ipa --flavor current

    if test $status -ne 0
      error "IPA build failed"
      rollbackChanges
      rollBackConfig
      exit 1
    end
  end

  if contains apk $bundles
    info "Building AppBundle"
    flutter build appbundle --flavor current

    if test $status -ne 0
      error "APK build failed"
      rollbackChanges
      rollBackConfig
      exit 1
    end
  end

  info "Staging version changes"
  git add :/

  info "Committing version changes"
  git commit -m $tagDescription

  if set -q deleteExistingTag
    warning "Deleting tag '"$tagName"' locally and remotely"
    git tag -d $tagName
    git push -d origin $tagName
  end

  info "Tagging '"$tagName"' as '"$tagDescription"'"
  git tag -a $tagName -m $tagDescription

  info "Pushing changes & tag to 'origin'"
  git push --follow-tags origin

  rollBackConfig

  info "Finished release of '"$projectName"\' on branch '"$branch"'. You can publish the app to Apple & Google stores now..."
  exit 0

# Upload IPA to TestFlight
publish-ios:
  #!/usr/bin/env fish
  if test -n "$APPLE_API_KEY"
    echo "Set the environment variable APPLE_API_KEY to your value"
    exit 1
  end
  if test -n "$APPLE_API_ISSUER"
    echo "Set the environment variable APPLE_API_ISSUER to your value"
    exit 1
  end
  xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey $APPLE_API_KEY --apiIssuer $APPLE_API_ISSUER

# Upload AAB to Google Play
publish-android:
  #!/usr/bin/env fish
  if test -n "$GOOGLE_CRED_FILE"
    echo "Set the environment variable GOOGLE_CRED_FILE to the location of your Google cloud credential file"
    exit 1
  end
  gplay --cred-file $GOOGLE_CRED_FILE --package-name com.example.flutter_basic_quickstart upload --bundle-file build/app/outputs/bundle/currentRelease/app-current-release.aab --track-name internal

