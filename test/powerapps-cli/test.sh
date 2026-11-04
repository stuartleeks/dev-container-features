#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "pac is available" command -v pac
check "pac runs with the installed runtime" pac help

for entry in data config; do
  if [ "$entry" = data ]; then
    source_dir="$HOME/.local/share/Microsoft/PowerAppsCli"
  else
    source_dir="$HOME/.config/Microsoft/PowerAppsCli"
  fi
  target_dir="/dc/powerapps-cli/$entry"

  check "$entry directory is persisted" test "$(readlink "$source_dir")" = "$target_dir"
  check "$entry directory is writable" test -w "$source_dir"
  check "$entry directory is private" test "$(stat -c %a "$target_dir")" = 700

  printf 'persisted\n' > "$source_dir/powerapps-cli-test"
  check "$entry writes reach the volume" grep -qx persisted "$target_dir/powerapps-cli-test"
done

check "oncreate is repeatable" bash /usr/local/share/stuartleeks-devcontainer-features/powerapps-cli/scripts/oncreate.sh

for entry in data config; do
  check "$entry survives repeated setup" grep -qx persisted "/dc/powerapps-cli/$entry/powerapps-cli-test"
  rm "/dc/powerapps-cli/$entry/powerapps-cli-test"
done

test_dir="$(mktemp -d)"
test_home="$test_dir/home with spaces"
mkdir -p "$test_home/.local/share/Microsoft/PowerAppsCli" "$test_home/.config/Microsoft/PowerAppsCli"

for relative_dir in .local/share/Microsoft/PowerAppsCli .config/Microsoft/PowerAppsCli; do
  printf 'image configuration\n' > "$test_home/$relative_dir/powerapps-cli-test-shared"
  printf 'image configuration\n' > "$test_home/$relative_dir/.powerapps-cli-test-local"
done
for entry in data config; do
  printf 'persisted credentials\n' > "/dc/powerapps-cli/$entry/powerapps-cli-test-shared"
done

check "existing configuration is migrated on rebuild" env HOME="$test_home" bash /usr/local/share/stuartleeks-devcontainer-features/powerapps-cli/scripts/oncreate.sh

for relative_dir in .local/share/Microsoft/PowerAppsCli .config/Microsoft/PowerAppsCli; do
  check "$relative_dir retains persisted credentials" grep -qx 'persisted credentials' "$test_home/$relative_dir/powerapps-cli-test-shared"
  check "$relative_dir migrates hidden files" grep -qx 'image configuration' "$test_home/$relative_dir/.powerapps-cli-test-local"
  check "$relative_dir keeps the original backup" grep -qx 'image configuration' "$test_home/$relative_dir-old/powerapps-cli-test-shared"
  check "$relative_dir remains private after migration" test "$(stat -Lc %a "$test_home/$relative_dir")" = 700
done

check "migrated setup is repeatable" env HOME="$test_home" bash /usr/local/share/stuartleeks-devcontainer-features/powerapps-cli/scripts/oncreate.sh

for relative_dir in .local/share/Microsoft/PowerAppsCli .config/Microsoft/PowerAppsCli; do
  rm "$test_home/$relative_dir-old/powerapps-cli-test-shared" "$test_home/$relative_dir-old/.powerapps-cli-test-local"
  rmdir "$test_home/$relative_dir-old"
  rm "$test_home/$relative_dir"
done
for entry in data config; do
  rm "/dc/powerapps-cli/$entry/powerapps-cli-test-shared" "/dc/powerapps-cli/$entry/.powerapps-cli-test-local"
done
rmdir "$test_home/.local/share/Microsoft" "$test_home/.local/share" "$test_home/.local" "$test_home/.config/Microsoft" "$test_home/.config" "$test_home" "$test_dir"

reportResults
