# Plan: Generic Folder Persistence Feature

## Problem

Several existing features (azure-cli-persistence, azd-cli-persistence, shell-history) each solve the same problem — persisting user data across dev container rebuilds — but are each hardcoded to a single directory. A generic feature would let users persist arbitrary folders via a single configuration, replacing the need for purpose-built features over time.

## Proposed Approach

A new dev container feature that:

1. Accepts a list of folders to persist (home-relative or absolute paths)
2. Mounts a single Docker volume and maps each folder to a subdirectory within it
3. Uses symlinks (consistent with existing persistence features in this repo)
4. Handles coexistence with the `shell-history` feature, migrating data and taking over as the active writer
5. Combines and deduplicates folders when referenced from multiple sources

## Feature Name

**Proposed: `persist-folders`**

Alternatives considered:
- `folder-persistence` — fine but slightly less verb-oriented
- `persist` — too generic, could confuse with volume-level persistence
- `persist-data` — data is vague

## Options Design

```jsonc
{
  "options": {
    "folders": {
      "type": "string",
      "default": "",
      "description": "Comma-separated list of folder paths to persist. Supports ~ for home dir. E.g. '~/.azure,~/.config/gh'"
    },
    "additionalFolders": {
      "type": "string",
      "default": "",
      "description": "Additional folders to persist (combined with 'folders'). Useful when feature is referenced from multiple sources."
    }
  }
}
```

The two-option design addresses the multi-installation problem (see section below).

Path format rules:
- `~` or `$HOME` prefix → resolved to `_REMOTE_USER_HOME` at install time
- Absolute paths (e.g. `/var/data`) → used as-is
- No trailing slashes
- Empty entries ignored (allows trailing commas)

---

## OPEN QUESTION 1: Folder-to-Volume Mapping Strategy

All persisted folders live inside a single volume mounted at `/dc/persist`. The question is how to name each folder's subdirectory in the volume.

### Option A: Sanitized full path

Map the canonical path to a volume subdirectory by replacing `/` with `--` and stripping a leading `--`.

| Source path | Volume subdirectory |
|---|---|
| `~/.azure` (user=vscode) | `home--vscode--.azure` |
| `~/.config/gh` | `home--vscode--.config--gh` |
| `/var/data` | `var--data` |

**Pros:**
- Deterministic and reversible — you can reconstruct the original path from the volume name
- No collisions
- Human-readable (debuggable by looking at the volume contents)

**Cons:**
- Long names for deeply nested paths
- Tied to the username (if user changes, old data is orphaned under old name)

### Option B: User-specified mapping names

Require the user to provide a short label for each folder:

```jsonc
"folders": "~/.azure:azure,~/.config/gh:gh-config,/var/data:vardata"
```

| Source path | Volume subdirectory |
|---|---|
| `~/.azure` | `azure` |
| `~/.config/gh` | `gh-config` |
| `/var/data` | `vardata` |

**Pros:**
- Short, clean names
- User has full control; stable across username changes
- Easy to reason about volume contents

**Cons:**
- More verbose configuration
- User must ensure uniqueness (error if labels collide)
- Changes the options syntax (colon separator adds parsing complexity)

### Option C: Auto-name from deepest unique component

Use the last path component, with progressively longer prefixes to break ties:

| Source path | Volume subdirectory |
|---|---|
| `~/.azure` | `.azure` |
| `~/.config/gh` | `gh` |
| `/var/data` | `data` |

If two paths end with the same component (e.g. `~/.config/data` and `/var/data`), use more components: `.config--data` and `var--data`.

**Pros:**
- Short names in the common case
- No extra user input

**Cons:**
- Non-deterministic when folder list changes (adding a folder could rename an existing mapping)
- Harder to predict what name will be used
- Could cause data loss if mapping changes between rebuilds

### Recommendation

Lean toward **Option A** as default with **Option B** as a stretch goal. Option A is fully automatic and safe. Option B could be added later as an optional override syntax.

---

## OPEN QUESTION 2: Multi-Installation Folder Deduplication

When the same feature is referenced in multiple places (user-level dotfiles `devcontainer.json` and project-level `devcontainer.json`), the devcontainer CLI merges feature options. For simple string options, **last definition wins** — values are not concatenated.

This means if user settings has `"folders": "~/.azure"` and the project has `"folders": "~/.config/gh"`, only the project's value survives.

### Option A: Two options (`folders` + `additionalFolders`)

The feature declares two options: `folders` and `additionalFolders`. Convention: project uses `folders`, user-level config uses `additionalFolders` (or vice versa).

**Pros:**
- Simple to implement (both are just comma-separated strings, combined at install time)
- Works with existing devcontainer option merging

**Cons:**
- Only supports two sources (user + project). If a third source is added, there's no slot for it
- Convention-dependent — users must know which option to use where
- If both sources use the same option key, one still overwrites the other

### Option B: Append-file mechanism

`install.sh` writes the folder list to a config file (e.g. `/usr/local/share/.../persist-folders/folders.conf`). If the feature is somehow invoked multiple times, each invocation appends. The oncreate script reads and deduplicates.

**Pros:**
- Scales to any number of sources
- No convention needed

**Cons:**
- The devcontainer CLI only runs install.sh once per feature (merging options beforehand), so this doesn't actually help with multiple references to the same feature
- Would only work if there were separate features that each appended to the shared config

### Option C: Accept the limitation, document workaround

Document that when the feature is referenced from multiple sources, users should combine all folders into the winning (usually project-level) `folders` option.

**Pros:**
- No added complexity
- Honest about the platform limitation

**Cons:**
- Users managing shared dotfiles can't add personal persistence folders without editing the project config

### Recommendation

Start with **Option A** (two options). It covers the primary two-source case (user + project) with minimal complexity. Document the convention clearly.

---

## Install Script Logic (`install.sh`)

```
1. Validate _REMOTE_USER and _REMOTE_USER_HOME are set
2. Combine `folders` and `additionalFolders` options, split by comma, deduplicate
3. Resolve ~ / $HOME to _REMOTE_USER_HOME
4. For each folder:
   a. Compute the volume subdirectory name (per chosen mapping strategy)
   b. Create the subdirectory in /dc/persist/ if it doesn't exist
   c. If the folder already exists, move to <folder>-old (backup)
   d. Create symlink: <folder> → /dc/persist/<mapped-name>
   e. Fix ownership to _REMOTE_USER
5. Write the resolved folder list to a config file for oncreate.sh to reference
6. Detect shell-history feature (check for marker at /usr/local/share/stuartleeks-devcontainer-features/shell-history/)
   a. If found, set migration flag
7. Copy oncreate.sh to lifecycle scripts dir
8. Write install marker
```

## Lifecycle Script Logic (`oncreate.sh`)

```
1. Read config file written by install.sh (resolved folder list + mappings)
2. Fix permissions on /dc/persist
3. For each folder:
   a. If <folder>-old exists (backup from install), merge contents into volume subdirectory
4. If shell-history migration flag is set:
   a. Copy history files from /dc/shellhistory/ to appropriate volume subdirectories
   b. Reconfigure HISTFILE in .bashrc/.zshrc to point at new volume paths
   c. Handle fish history symlink
   d. Write migration-complete marker
5. Write oncreate marker (idempotency)
```

## Shell History Migration

### Coexistence Model

When both `shell-history` and `persist-folders` are installed:

1. **Install order**: `persist-folders` declares `installsAfter` including the shell-history feature, so its `install.sh` runs second at build time.

2. **Data migration**: `persist-folders` oncreate.sh detects `/dc/shellhistory` and copies history files to its own volume:
   - `/dc/shellhistory/.bash_history` → `/dc/persist/<home-mapped>/.bash_history` (or wherever the user's persisted home maps to)
   - `/dc/shellhistory/.zsh_history` → same pattern
   - `/dc/shellhistory/fish_history` → appropriate fish data dir

3. **Taking over as active writer**: This is the tricky part. `shell-history`'s oncreate.sh appends `export HISTFILE=/dc/shellhistory/.bash_history` to `.bashrc`. `persist-folders` needs its HISTFILE to win.

### OPEN QUESTION 3: How to Override Shell-History's HISTFILE

The challenge: both features' oncreate.sh scripts append to `.bashrc`/`.zshrc`, but they run as separate `onCreateCommand` entries with no guaranteed ordering.

#### Option A: Use `/etc/profile.d/` instead of `.bashrc`

`persist-folders` writes its HISTFILE config to `/etc/profile.d/persist-folders.sh`, which is sourced after `.bashrc` in login shells. This guarantees it overrides shell-history.

**Pros:**
- Reliable ordering without race conditions
- Clean separation

**Cons:**
- `/etc/profile.d/` is only sourced for login shells; interactive non-login shells (the common case in terminals) source `.bashrc` but not `/etc/profile.d/`
- May not work in all shell configurations

#### Option B: Write override in `install.sh` at build time

Since `install.sh` runs in guaranteed order (thanks to `installsAfter`), the new feature can append a `.bashrc` snippet at build time that overrides HISTFILE. When shell-history's oncreate later appends its HISTFILE, the new feature's line is already in .bashrc and appears earlier. But shell-history's oncreate appends AFTER the new feature's line, so shell-history's value would actually win.

**Problem:** This is the wrong order — shell-history appends last and wins.

#### Option C: Wrap HISTFILE in a guard

The new feature's `install.sh` (at build time) appends a snippet to `.bashrc.d/` or to the end of `.bashrc` that checks for a marker file and sets HISTFILE accordingly:

```bash
# Added by persist-folders
if [ -f /usr/local/share/stuartleeks-devcontainer-features/persist-folders/markers/install ]; then
    export HISTFILE=/dc/persist/<mapped>/.bash_history
fi
```

Since `.bashrc` is read top-to-bottom at shell startup (not at append time), and shell-history's oncreate.sh also appends a plain `export HISTFILE=...`, the last one in the file wins.

**Problem:** Same ordering issue — we can't guarantee which line ends up last in .bashrc.

#### Option D: Write the override at the end of oncreate.sh execution

The new feature's oncreate.sh, after running, explicitly re-appends its HISTFILE line to the bottom of `.bashrc`. If shell-history's oncreate.sh has already run, the new feature's line is now last. If it hasn't run yet, shell-history's line will be last (wrong order).

To handle both cases, append a self-correcting snippet:

```bash
# persist-folders: ensure we override shell-history
# This works regardless of oncreate execution order because
# it runs every time a new shell starts
cat << 'EOF' >> "$HOME/.bashrc"
# persist-folders override
[ -f /dc/persist/.histfile-path ] && export HISTFILE=$(cat /dc/persist/.histfile-path)
EOF
```

And in oncreate.sh, write the target path to `/dc/persist/.histfile-path`.

**Pros:**
- Order-independent: works regardless of which oncreate runs first
- The file-based indirection means oncreate.sh can update the path even if .bashrc was already sourced in an earlier setup step

**Cons:**
- Adds a file read on every shell startup (negligible cost)
- Slightly more complex

#### Recommendation

**Option D** is the most robust. It decouples the HISTFILE configuration from the ordering of oncreate scripts.

---

## Feature Metadata (`devcontainer-feature.json`)

```jsonc
{
    "name": "Persist Folders",
    "id": "persist-folders",
    "version": "0.0.1",
    "description": "Persist arbitrary folders across dev container rebuilds using Docker volumes and symlinks",
    "options": {
        "folders": {
            "type": "string",
            "default": "",
            "description": "Comma-separated folder paths to persist (supports ~ for home). E.g. '~/.azure,~/.config/gh'"
        },
        "additionalFolders": {
            "type": "string",
            "default": "",
            "description": "Additional folders to persist, combined with 'folders'. Use when feature is referenced from multiple sources."
        }
    },
    "mounts": [
        {
            "source": "${devcontainerId}-persist",
            "target": "/dc/persist",
            "type": "volume"
        }
    ],
    "installsAfter": [
        "ghcr.io/devcontainers/features/common-utils",
        "ghcr.io/stuartleeks/dev-container-features/shell-history"
    ],
    "onCreateCommand": {
        "persist-folders": "/usr/local/share/stuartleeks-devcontainer-features/persist-folders/scripts/oncreate.sh"
    }
}
```

## Tests

| Scenario | Description |
|---|---|
| `single_folder` | Persist one home-relative folder, verify symlink and writability |
| `multiple_folders` | Persist several folders, verify all are symlinked |
| `absolute_path` | Persist an absolute path like `/var/mydata` |
| `duplicate_folders` | Same folder in both `folders` and `additionalFolders`, verify dedup (no error) |
| `existing_folder_backup` | Folder exists before install, verify backup created and contents preserved |
| `with_shell_history` | Both `shell-history` and `persist-folders` installed, verify migration and HISTFILE override |
| `root_user` | Run as root user |

## Implementation Phases

### Phase 1: Core feature
- Basic `devcontainer-feature.json`, `install.sh`, `oncreate.sh`
- Single `folders` option with comma-separated paths
- Volume mapping using the chosen strategy
- Symlink creation with backup of existing folders
- Tests for single/multiple/absolute folders

### Phase 2: Multi-source support
- Add `additionalFolders` option
- Deduplication logic
- Documentation of user-level vs project-level convention

### Phase 3: Shell-history migration
- Detection of shell-history feature
- Data migration in oncreate.sh
- HISTFILE override mechanism
- Coexistence test

### Phase 4: Documentation & release
- README notes (auto-generated) + NOTES.md
- Migration guide in NOTES.md
- Update repo README feature table

## Open Questions Summary

| # | Question | Options | Current Leaning |
|---|---|---|---|
| 1 | How to map folder paths to volume subdirectory names | A: Sanitized full path, B: User-specified labels, C: Auto-name from deepest component | A (sanitized path) — safe, automatic, reversible |
| 2 | How to handle multi-source folder deduplication | A: Two options, B: Append-file, C: Accept limitation | A (two options) — practical for user+project |
| 3 | How to override shell-history's HISTFILE | A: /etc/profile.d, B: Build-time .bashrc, C: Guard snippet, D: File-based indirection | D (file-based indirection) — order-independent |
