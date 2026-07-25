Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

# =====================================================================
#  New-HatchlingGame.ps1
#
#  Scaffolds a new LOVE2D game from the hatchling-engine "template"
#  folder, initializes it as its own git repo, and adds
#  hatchling-engine as a git submodule at <game>\engine.
#
#  EDIT THIS VALUE BEFORE FIRST USE:
# =====================================================================
$HatchlingRepoUrl = "https://github.com/eglinmartin/hatchling-engine"
# =====================================================================

function Show-Error($msg) {
    [System.Windows.Forms.MessageBox]::Show($msg, "Error", 'OK', 'Error') | Out-Null
}

# --- Check git is available ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Show-Error "git was not found on PATH. Install Git for Windows and try again."
    exit 1
}

# --- Ask where to put the new game (folder browser) ---
$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderDialog.Description = "Choose the parent folder where your game repos live"
if ($folderDialog.ShowDialog() -ne 'OK') { exit }
$RootReposDir = $folderDialog.SelectedPath

# --- Ask for the new game's name (text input) ---
$GameName = [Microsoft.VisualBasic.Interaction]::InputBox(
    "Enter a name for the new game (this becomes the folder and repo name):",
    "New Hatchling Game",
    ""
)
if ([string]::IsNullOrWhiteSpace($GameName)) {
    Show-Error "No name entered. Aborting."
    exit
}

$DestDir = Join-Path $RootReposDir $GameName

if (Test-Path $DestDir) {
    Show-Error "`"$DestDir`" already exists. Choose a different name or remove it first."
    exit
}

# --- Clone hatchling-engine into a temp folder ---
$TempDir = Join-Path $env:TEMP ("hatchling_temp_" + [System.Guid]::NewGuid().ToString("N"))
Write-Host "[1/5] Cloning hatchling-engine into temp folder..."
git clone --depth 1 $HatchlingRepoUrl $TempDir
if ($LASTEXITCODE -ne 0) {
    Show-Error "Clone failed. Check the repo URL and your network/auth."
    exit 1
}

$TemplateSrc = Join-Path $TempDir "template"
if (-not (Test-Path $TemplateSrc)) {
    Show-Error "No 'template' folder found in the cloned repo. Aborting."
    Remove-Item -Recurse -Force $TempDir
    exit 1
}

# --- Copy template -> new game folder ---
Write-Host "[2/5] Copying template into `"$DestDir`"..."
New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
Copy-Item -Path (Join-Path $TemplateSrc '*') -Destination $DestDir -Recurse -Force

# --- Clean up temp clone ---
Write-Host "[3/5] Cleaning up temp files..."
Remove-Item -Recurse -Force $TempDir

# --- Init git repo in the new game folder ---
Write-Host "[4/5] Initializing git repository..."
Push-Location $DestDir
git init -q
if ($LASTEXITCODE -ne 0) {
    Show-Error "git init failed."
    Pop-Location
    exit 1
}

# --- Add hatchling-engine as a submodule at .\hatchling ---
Write-Host "[5/5] Adding hatchling-engine as submodule at 'hatchling\'..."
git submodule add $HatchlingRepoUrl hatchling
if ($LASTEXITCODE -ne 0) {
    Show-Error "Submodule add failed."
    Pop-Location
    exit 1
}

git add -A
git commit -q -m "Initial commit: hatchling-engine template + engine submodule"
Pop-Location

[System.Windows.Forms.MessageBox]::Show("New game created at:`n$DestDir", "Done", 'OK', 'Information') | Out-Null
