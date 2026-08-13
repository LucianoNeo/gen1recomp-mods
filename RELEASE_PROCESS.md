# HGSS Visual Overhaul release process

This is the mandatory release procedure for `HGSS_SPRITES`. A release is not
complete until the ZIP downloaded from GitHub has been imported successfully by
g1recomp itself.

Run every command from the repository root:

```powershell
Set-Location "C:\Users\Luciano\Documents\mods-gen1recomp"
```

Confirm that the required local automation exists before changing the version:

```powershell
$required = @(
  ".\scripts\build-mod-release.ps1",
  ".\scripts\publish-github-release.ps1",
  ".\tools\test_mod_zip_import.lua",
  ".\tools\gen1recomp_app\gen1recomp-win64\gen1recomp.exe"
)
$missing = @($required | Where-Object { -not (Test-Path -LiteralPath $_) })
if ($missing.Count) { throw "Missing release tools: $($missing -join ', ')" }
```

## Non-negotiable rules

1. Never publish a release before completing every validation in this document.
2. Never use PowerShell `Compress-Archive` for the mod package. On Windows it
   can store ZIP entry names with `\`, which can make g1recomp/PHYSFS recurse
   incorrectly and fail with `import failed: stack overflow`.
3. Every ZIP entry must use `/`, as required by the ZIP specification.
4. The ZIP must contain `manifest.json` at its root. Do not wrap the mod in an
   additional `HGSS_SPRITES/` directory.
5. Package only tracked runtime files. Exclude documentation media, templates,
   captures, tests, debug assets, PSD files and build directories.
6. Test the exact ZIP that will be uploaded.
7. After publishing, download the public asset and import that downloaded copy
   again. Testing only the local ZIP is insufficient.
8. Use Git Credential Manager and the GitHub API for publication. Do not save,
   print or commit credentials.
9. Do not move or recreate an existing release tag. Corrections require a new
   patch version.
10. Write every JSON manifest and card as UTF-8 **without a BOM**. The
    g1recomp JSON parser rejects a BOM as an unexpected `ï` character and the
    Mod Manager reports `import failed: invalid mod manifest`.

## 1. Choose the version

Use semantic versioning. For an import or packaging correction, increment the
patch version, for example `0.2.4` to `0.2.5`.

Update all of these files:

- `hgss_sprites/manifest.json`
- `hgss_sprites/CHANGELOG.md`
- `hgss_sprites/README.md`
- `README.md`

Confirm that the manifest retains the intended compatibility metadata:

```json
"optional_dependencies": ["CRYSTAL_251"]
```

Check for stale version references:

```powershell
$version = "0.2.5"
rg -n "0\.2\.[0-9]+" README.md hgss_sprites/README.md `
  hgss_sprites/CHANGELOG.md hgss_sprites/manifest.json
```

Review the changes and reject whitespace errors:

```powershell
git diff --check
git diff -- README.md hgss_sprites/README.md `
  hgss_sprites/CHANGELOG.md hgss_sprites/manifest.json
```

## 2. Build a portable runtime ZIP

Use the repository build script:

```powershell
$version = "0.2.5"
& ".\scripts\build-mod-release.ps1" -Version $version
```

Expected output:

- file: `build/HGSS_SPRITES-<version>.zip`;
- `PathFormat`: `POSIX`;
- one `manifest.json` at the archive root;
- no synthetic directory entries;
- no untracked files.

The build script uses tracked files under `hgss_sprites/` and excludes
`hgss_sprites/docs/`. It writes each ZIP member with an explicit POSIX entry
name instead of relying on the host operating system's separator.

## 3. Validate archive structure and contents

Run this before starting g1recomp:

```powershell
$version = "0.2.5"
$zipPath = (Resolve-Path ".\build\HGSS_SPRITES-$version.zip").Path

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    $entries = @($zip.Entries)
    $badSeparators = @($entries | Where-Object { $_.FullName.Contains("\") })
    $directories = @($entries | Where-Object { $_.FullName.EndsWith("/") })
    $rootManifest = @($entries | Where-Object { $_.FullName -eq "manifest.json" })

    if ($badSeparators.Count -ne 0) { throw "Windows separators in ZIP" }
    if ($directories.Count -ne 0) { throw "Synthetic directories in ZIP" }
    if ($rootManifest.Count -ne 1) { throw "Root manifest count is not one" }
}
finally {
    $zip.Dispose()
}
```

Also confirm that every packaged file is byte-identical to its source. The
`build-mod-release.ps1` script performs its own structure checks, but the
release operator must still review its entry count, byte size and SHA-256.

Record the hash:

```powershell
Get-FileHash ".\build\HGSS_SPRITES-$version.zip" -Algorithm SHA256
```

## 4. Import the local ZIP through g1recomp

Use the same import path as the Mod Manager. The driver calls
`LauncherMods.installZip`, with replacement enabled and the expected mod ID.

```powershell
$root = "C:\Users\Luciano\Documents\mods-gen1recomp"
$version = "0.2.5"
$app = Join-Path $root "tools\gen1recomp_app\gen1recomp-win64"
$runId = Get-Date -Format "yyyyMMdd-HHmmss"
$report = Join-Path $root "build\import-$version-$runId-result.txt"
$stdoutPath = Join-Path $app "import-$version-$runId.out"
$stderrPath = Join-Path $app "import-$version-$runId.err"

Set-Location $app
$env:POKEPORT_DRIVER = "..\..\..\tools\test_mod_zip_import.lua"
$env:POKEPORT_VERSION = "yellow"
# Do not invent a new POKEPORT_IDENTITY here.  A fresh identity has no ROM/save
# cache and launches a blank/zeroed game.  The normal local identity is exactly
# the cache used by the installed g1recomp instance, so leave this variable
# unset (or remove it from the current PowerShell session first).
Remove-Item Env:POKEPORT_IDENTITY -ErrorAction SilentlyContinue
$env:HGSS_IMPORT_ZIP = Join-Path $root "build\HGSS_SPRITES-$version.zip"
$env:HGSS_IMPORT_REPORT = $report

$process = Start-Process -FilePath (Join-Path $app "gen1recomp.exe") `
  -WorkingDirectory $app `
  -RedirectStandardOutput $stdoutPath `
  -RedirectStandardError $stderrPath `
  -PassThru -Wait -WindowStyle Hidden

if ($process.ExitCode -ne 0) { throw "g1recomp exited with $($process.ExitCode)" }
if (-not (Test-Path -LiteralPath $report)) { throw "Import report is missing" }

$result = Get-Content -Raw -LiteralPath $report
$stderr = Get-Content -Raw -LiteralPath $stderrPath
if ($result -notmatch "^OK HGSS_SPRITES") { throw "Import failed: $result" }
if (-not [string]::IsNullOrWhiteSpace($stderr)) { throw "stderr is not empty" }

$result
```

Required result:

```text
OK HGSS_SPRITES
```

### Import failure checklist

If the report says `invalid mod manifest` and mentions an unexpected `ï`,
inspect the first bytes of the archive's manifest. They must begin with `{`
(`7B`), not `EF BB BF`. Rebuild the package using a no-BOM writer, for
example:

```powershell
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText($manifestPath, $manifestText, $utf8NoBom)
```

Then rerun the archive-structure checks and the complete import test. Do not
work around this by copying the mod directly into a `mods` folder: that does
not exercise the Mod Manager's ZIP installer and can leave the UI showing
“No mods installed”.

The process exit code must be `0`, and stderr must be empty. Stop immediately
if the report is missing, contains `ERROR`, or mentions `stack overflow`.

## 5. Run a game smoke test

With the imported mod installed, run at least one scripted in-game capture.
The intro smoke test covers Nidoran, Professor Oak, Red and Blue:

```powershell
$runId = Get-Date -Format "yyyyMMdd-HHmmss"
$captureDir = Join-Path $root "build\smoke-$version-$runId-intro"
$stdoutPath = Join-Path $app "smoke-$version-$runId.out"
$stderrPath = Join-Path $app "smoke-$version-$runId.err"
New-Item -ItemType Directory -Path $captureDir -Force | Out-Null

$env:POKEPORT_DRIVER = "..\..\..\tools\capture_clean_intro_all.lua"
$env:POKEPORT_VERSION = "yellow"
# Keep the default identity so the smoke test opens the same populated local
# game.  A new identity is an empty sandbox and must not be used for this test.
Remove-Item Env:POKEPORT_IDENTITY -ErrorAction SilentlyContinue
$env:HGSS_CAPTURE_DIR = $captureDir

$process = Start-Process -FilePath (Join-Path $app "gen1recomp.exe") `
  -WorkingDirectory $app `
  -RedirectStandardOutput $stdoutPath `
  -RedirectStandardError $stderrPath `
  -PassThru -Wait -WindowStyle Hidden

if ($process.ExitCode -ne 0) { throw "g1recomp exited with $($process.ExitCode)" }
$stdout = Get-Content -Raw -LiteralPath $stdoutPath
$stderr = Get-Content -Raw -LiteralPath $stderrPath
if ($stdout -notmatch "loaded mod HGSS_SPRITES $([regex]::Escape($version))") {
    throw "Expected mod version was not loaded"
}
if ($stdout -notmatch "game loaded") { throw "Game did not finish loading" }
if (-not [string]::IsNullOrWhiteSpace($stderr)) { throw "stderr is not empty" }
```

Required checks:

- exit code is `0`;
- stderr is empty;
- stdout contains `loaded mod HGSS_SPRITES <version>`;
- stdout contains `game loaded`;
- all expected PNG captures exist and are visually inspected;
- no character is clipped, duplicated, transparent in the wrong place or
  drawn over the interface.

Additional gameplay-specific changes require their corresponding movement,
party, overworld or battle driver. Passing the intro smoke test does not replace
testing the area changed by the release.

## 6. Commit, push and tag

Return to the repository root and verify that only intended tracked files are
modified:

```powershell
Set-Location $root
git status --short
git diff --check
```

Stage files explicitly. Never use `git add .` in this workspace because it
contains local captures, builds, templates and attachments.

```powershell
git add -- README.md hgss_sprites/README.md `
  hgss_sprites/CHANGELOG.md hgss_sprites/manifest.json
git diff --cached --check
git diff --cached
git commit -m "fix: publish portable HGSS $version archive"
git push origin master
git tag -a "v$version" -m "HGSS Visual Overhaul $version"
git push origin "v$version"
```

If the release includes sprites or Lua changes, add only those exact paths to
the explicit `git add` command.

## 7. Publish directly to GitHub

Use the API publication script. It obtains the existing GitHub credential from
Git Credential Manager, keeps it only in process memory and uploads the asset
without opening a browser.

```powershell
Set-Location $root
& ".\scripts\publish-github-release.ps1" `
  -Tag "v$version" `
  -AssetPath ".\build\HGSS_SPRITES-$version.zip" `
  -Title "HGSS Visual Overhaul $version" `
  -Notes "Describe the verified changes and tests here."
```

The command must return both `ReleaseUrl` and `AssetUrl`. Never paste a token
into this command, a script, a README or a Git commit.

## 8. Download and reimport the public asset

This is the final release gate and cannot be skipped.

```powershell
$releaseUrl = "https://github.com/LucianoNeo/gen1recomp-mods/releases/download/v$version/HGSS_SPRITES-$version.zip"
$publicZip = Join-Path $root "build\HGSS_SPRITES-$version-public.zip"
Invoke-WebRequest -Uri $releaseUrl -OutFile $publicZip -UseBasicParsing

$localHash = (Get-FileHash `
  (Join-Path $root "build\HGSS_SPRITES-$version.zip") `
  -Algorithm SHA256).Hash
$publicHash = (Get-FileHash $publicZip -Algorithm SHA256).Hash

if ($localHash -ne $publicHash) {
    throw "The public release asset differs from the tested local ZIP."
}
```

Repeat the complete section 4 test with the public file and new report/log
paths. Never reuse the local-import report:

```powershell
$publicRunId = "public-" + (Get-Date -Format "yyyyMMdd-HHmmss")
$env:HGSS_IMPORT_ZIP = $publicZip
$env:HGSS_IMPORT_REPORT = Join-Path $root `
  "build\import-$version-$publicRunId-result.txt"
$stdoutPath = Join-Path $app "import-$version-$publicRunId.out"
$stderrPath = Join-Path $app "import-$version-$publicRunId.err"

# Execute the same Start-Process and result assertions from section 4.
```

Required result:

```text
OK HGSS_SPRITES
```

Only after the public download imports successfully may the release be reported
as complete.

## Release evidence to report

The final release report must include:

- release version and commit hash;
- release page and direct asset links;
- ZIP byte size and SHA-256;
- number of ZIP entries;
- confirmation of zero `\` entries and zero synthetic directories;
- local import result;
- public-download import result;
- g1recomp exit code and stderr status;
- smoke-test scenarios performed.

## Failure policy

If any step fails:

1. do not publish, or stop updating the release if publication already began;
2. preserve the failing ZIP and logs for diagnosis;
3. fix the source or packaging script;
4. increment the patch version if a tag or public release already exists;
5. restart this procedure from section 1.

Never replace a failed release with an untested archive and never state that a
release is fixed based only on ZIP creation or a successful upload.
