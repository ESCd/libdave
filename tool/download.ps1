[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Version,

    [Parameter(Mandatory)]
    [string]$OutputDir
)

function Get-NetCoreRuntime {
    param([string]$runtime)

    if ($runtime -eq "windows-x64") { return "win-x64" }
    return $runtime
}

$runtimes = @("linux-arm64", "linux-x64", "macos-arm64", "macos-x64", "windows-x64")
$cache = ([System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName()))

New-Item -ItemType Directory -Path $cache | Out-Null
Write-Host "[!] Downloading Packages $Version to '$cache'..."

$version = "v$Version/cpp"
foreach ($runtime in $runtimes) {
    $package = "libdave-$runtime-boringssl.zip"
    $url = "https://github.com/discord/libdave/releases/download/$([Uri]::EscapeDataString($version))/$package"

    $destination = [System.IO.Path]::Combine($cache, $package)
    Invoke-WebRequest -Uri $url -OutFile $destination

    Write-Host "[!] Downloaded $package to '$destination'"
}

$obj = ([System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName()))

Write-Host "[!] Extracting Packages to '$obj'..."
foreach ($runtime in $runtimes) {
    $package = "libdave-$runtime-boringssl.zip"

    $destination = [System.IO.Path]::Combine($obj, $runtime)
    Expand-Archive -Path ([System.IO.Path]::Combine($cache, $package)) -DestinationPath $destination

    Write-Host "[!] Extracted $package to '$destination'"
}


Write-Host "[!] Moving Assets to '$OutputDir'..."
foreach ($runtime in $runtimes) {
    $rid = $(Get-NetCoreRuntime $runtime)

    foreach ($file in Get-ChildItem -Path ([System.IO.Path]::Combine($obj, $runtime, "lib")) -Recurse -File) {
        New-Item -ItemType Directory -Path ([System.IO.Path]::Combine($OutputDir, "static", $rid, "native")) -Force | Out-Null

        $destination = [System.IO.Path]::Combine($OutputDir, "static", $rid, "native", $file.Name)
        Move-Item -Path $file.FullName -Destination $destination -Force

        Write-Host "[!] Moved ${file.FullName} to '$destination'"
    }

    foreach ($file in Get-ChildItem -Path ([System.IO.Path]::Combine($obj, $runtime, "bin")) -Recurse -File) {
        New-Item -ItemType Directory -Path ([System.IO.Path]::Combine($OutputDir, "runtimes", $rid, "native")) -Force | Out-Null

        $destination = [System.IO.Path]::Combine($OutputDir, "runtimes", $rid, "native", $file.Name)
        Move-Item -Path $file.FullName -Destination $destination -Force

        Write-Host "[!] Moved ${file.FullName} to '$destination'"
    }

    Write-Host "[!] Moved Assets for runtime '$runtime'"
}