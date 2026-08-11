param(
    [Parameter(Mandatory = $true)]
    [string]$Tag,

    [Parameter(Mandatory = $true)]
    [string]$AssetPath,

    [string]$Repository = "LucianoNeo/gen1recomp-mods",
    [string]$Target = "master",
    [string]$Title = $Tag,
    [string]$Notes = ""
)

$ErrorActionPreference = "Stop"

$resolvedAsset = (Resolve-Path -LiteralPath $AssetPath).Path
$assetName = [IO.Path]::GetFileName($resolvedAsset)

# Reuse the credential already managed by Git Credential Manager. The secret is
# held only in process memory and is never written to disk or printed.
$credentialLines = "protocol=https`nhost=github.com`n`n" | git credential fill 2>$null
$credential = @{}
foreach ($line in $credentialLines) {
    $separator = $line.IndexOf("=")
    if ($separator -gt 0) {
        $credential[$line.Substring(0, $separator)] = $line.Substring($separator + 1)
    }
}

if (-not $credential.username -or -not $credential.password) {
    throw "GitHub credentials were not returned by Git Credential Manager."
}

$basicBytes = [Text.Encoding]::UTF8.GetBytes("$($credential.username):$($credential.password)")
$headers = @{
    Authorization = "Basic $([Convert]::ToBase64String($basicBytes))"
    Accept = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent" = "gen1recomp-mods-release-script"
}

$apiRoot = "https://api.github.com/repos/$Repository"
$release = $null

try {
    $release = Invoke-RestMethod -Uri "$apiRoot/releases/tags/$Tag" -Headers $headers
}
catch {
    if ($_.Exception.Response.StatusCode.value__ -ne 404) {
        throw
    }
}

if (-not $release) {
    $payload = @{
        tag_name = $Tag
        target_commitish = $Target
        name = $Title
        body = $Notes
        draft = $false
        prerelease = $false
    } | ConvertTo-Json

    $release = Invoke-RestMethod -Method Post -Uri "$apiRoot/releases" `
        -Headers $headers -ContentType "application/json" -Body $payload
}

$existingAsset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1
if ($existingAsset) {
    Invoke-RestMethod -Method Delete -Uri "$apiRoot/releases/assets/$($existingAsset.id)" -Headers $headers
}

$encodedName = [Uri]::EscapeDataString($assetName)
$uploadUri = "https://uploads.github.com/repos/$Repository/releases/$($release.id)/assets?name=$encodedName"
$uploadedAsset = Invoke-RestMethod -Method Post -Uri $uploadUri -Headers $headers `
    -ContentType "application/zip" -InFile $resolvedAsset

# Explicitly discard all in-memory credential material before returning.
$credential.Clear()
$credentialLines = $null
$basicBytes = $null
$headers.Authorization = $null

[PSCustomObject]@{
    ReleaseUrl = $release.html_url
    AssetUrl = $uploadedAsset.browser_download_url
    AssetSize = $uploadedAsset.size
}
