param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$ModDirectory = "hgss_sprites",
    [string]$OutputDirectory = "build"
)

$ErrorActionPreference = "Stop"

$repositoryRoot = (Resolve-Path -LiteralPath ".").Path
$modRoot = (Resolve-Path -LiteralPath $ModDirectory).Path
$outputRoot = (Resolve-Path -LiteralPath $OutputDirectory).Path
$outputPath = Join-Path $outputRoot "HGSS_SPRITES-$Version.zip"

if (-not $modRoot.StartsWith($repositoryRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Mod directory is outside the repository."
}
if (-not $outputRoot.StartsWith($repositoryRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Output directory is outside the repository."
}

$prefix = $ModDirectory.TrimEnd("/", "\") + "/"
$files = @(git ls-files "$ModDirectory/**" | Where-Object {
    $_.StartsWith($prefix) -and $_ -notlike "${prefix}docs/*"
})

if (-not $files.Count) {
    throw "No tracked runtime files found under $ModDirectory."
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$stream = [IO.File]::Open($outputPath, [IO.FileMode]::Create)
try {
    $archive = [IO.Compression.ZipArchive]::new(
        $stream,
        [IO.Compression.ZipArchiveMode]::Create,
        $false
    )
    try {
        foreach ($trackedPath in $files) {
            $sourcePath = Join-Path $repositoryRoot ($trackedPath.Replace("/", "\"))
            if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
                throw "Tracked runtime file is missing: $trackedPath"
            }

            # ZIP entry names are POSIX paths by specification. Never use the
            # Windows separator here: PHYSFS may interpret malformed directory
            # trees recursively and overflow the g1recomp importer stack.
            $entryName = $trackedPath.Substring($prefix.Length).Replace("\", "/")
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $archive,
                $sourcePath,
                $entryName,
                [IO.Compression.CompressionLevel]::Optimal
            ) | Out-Null
        }
    }
    finally {
        $archive.Dispose()
    }
}
finally {
    $stream.Dispose()
}

$check = [IO.Compression.ZipFile]::OpenRead($outputPath)
try {
    $entries = @($check.Entries)
    $badSeparators = @($entries | Where-Object { $_.FullName.Contains("\") })
    $directoryEntries = @($entries | Where-Object { $_.FullName.EndsWith("/") })
    $manifestEntry = $check.GetEntry("manifest.json")

    if ($badSeparators.Count) {
        throw "Archive contains Windows path separators."
    }
    if ($directoryEntries.Count) {
        throw "Archive contains synthetic directory entries."
    }
    if (-not $manifestEntry) {
        throw "Archive has no root manifest.json."
    }

    $reader = [IO.StreamReader]::new($manifestEntry.Open())
    try { $manifestText = $reader.ReadToEnd() }
    finally { $reader.Dispose() }

    $manifest = $manifestText | ConvertFrom-Json
    if ($manifest.version -ne $Version) {
        throw "Manifest version $($manifest.version) does not match $Version."
    }
}
finally {
    $check.Dispose()
}

$hash = Get-FileHash -LiteralPath $outputPath -Algorithm SHA256
[PSCustomObject]@{
    Path = $outputPath
    Entries = $files.Count
    Bytes = (Get-Item -LiteralPath $outputPath).Length
    SHA256 = $hash.Hash
    PathFormat = "POSIX"
}
