# List the available recipes
default:
  just --list

# Generate SVG by cleaning and compiling all SVG's from `raw_assets/raw_svg` to `assets/images`
svg:
  #!/usr/bin/env fish
  set targetDir (pwd)/raw_assets/clean_svg
  if not test -d $targetDir
    mkdir -p $targetDir
  else
    for file in $targetDir/*.svg; rm $file; end
  end
  for file in (pwd)/raw_assets/raw_svg/*.svg
    printf 'Cleaning "'(basename $file)'". '
    svgcleaner --allow-bigger-file $file $targetDir/(basename $file)
  end

# Generate binary .vec files to optimize loading of images for `flutter_svg`
vec:
  #!/usr/bin/env fish
  set targetDir (pwd)/assets/images
  if not test -d $targetDir
    mkdir -p $targetDir
  else
    for file in $targetDir/*.vec; rm $file; end
  end
  for file in (pwd)/raw_assets/clean_svg/*.svg
    printf 'Generating .vec for "'(basename $file)'". '
    dart run vector_graphics_compiler -i $file -o $targetDir/(basename $file).vec
  end

# Generates `json_serializable`, `equatable` and `go_router_builder` files
json:
  dart run build_runner build --delete-conflicting-outputs

# Generate icons with `icons_launcher`
icons:
  dart run icons_launcher:create
  dart run icons_launcher:create --flavor beta

# Generate the splash screens with `flutter_native_splash`
splash:
  dart run flutter_native_splash:create

# Show outdated packages
outdated:
  flutter pub outdated

# Update version information
version OPERATION='incrRevision':
  stampver {{OPERATION}} -u -i version.json5

# Run all generators
generate: json svg vec icons splash

# Generate a release build, run tests & tag the build
release OPERATION='incrPatch':
  #!/usr/bin/env fish
  function info
    set_color green; echo "👉 "$argv; set_color normal
  end
  function warning
    set_color yellow; echo "🐓 "$argv; set_color normal
  end
  function error
    set_color red; echo "💥 "$argv; set_color normal
  end

  if test ! -e "pubspec.yaml"
    error "pubspec.yaml file not found"
    exit 1
  end

  info "Checking for uncommitted changes"

  if not git diff-index --quiet HEAD -- > /dev/null 2> /dev/null
    error "There are uncomitted changes - commit or stash them and try again"
    exit 1
  end

  set branch (string trim (git rev-parse --abbrev-ref HEAD 2> /dev/null))
  set name (basename (pwd))

  info "Starting release of '"$name"' on branch '"$branch"'"

  info "Checking out '"$branch"'"
  git checkout $branch

  info "Pulling latest"
  git pull

  mkdir scratch 2> /dev/null

  if not stampver {{OPERATION}} -u -i version.json5
    error "Unable to generation version information"
    exit 1
  end

  set tagName (cat "scratch/version.tag.txt")
  set tagDescription (cat "scratch/version.desc.txt")

  git rev-parse $tagName > /dev/null 2> /dev/null
  if test $status -ne 0; set isNewTag 1; end

  if set -q isNewTag
    info "'"$tagName"' is a new tag"
  else
    warning "Tag '"$tagName"' already exists and will not be moved"
  end

  flutter test

  if test $status -ne 0
    # Rollback
    git checkout $branch .
    error "Tests failed '"$name"' on branch '"$branch"'"
    exit 1
  end

  info "Staging version changes"
  git add :/

  info "Committing version changes"
  git commit -m $tagDescription

  if set -q isNewTag
    info "Tagging"
    git tag -a $tagName -m $tagDescription
  end

  info "Pushing to 'origin'"
  git push --follow-tags

  info "Finished release of '"$name"\' on branch '"$branch"'. You can publish the app to Apple & Google stores now..."
  exit 0
