# --- CONFIGURATION (CORRIGÉE) ---
# Notez bien : PAS de "refs/heads", et un "/" à la fin.
$BaseUrl = "https://raw.githubusercontent.com/clement-masquelier/script_mod_update_circord/main/mods/"
# --------------------------------

$ModDir = Join-Path $PSScriptRoot "mods"
$OutputFile = Join-Path $PSScriptRoot "manifest.json"

Write-Host "Génération du manifeste..." -ForegroundColor Cyan

$Files = Get-ChildItem -Path $ModDir -Filter "*.jar"
$JsonList = @()

foreach ($File in $Files) {
    # Encodage simple pour les espaces
    $EncodedName = $File.Name.Replace(" ", "%20")
    
    $ModObject = [PSCustomObject]@{
        file = $File.Name
        url  = "$BaseUrl$EncodedName"
    }
    $JsonList += $ModObject
}

$JsonList | ConvertTo-Json -Depth 2 | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "Fichier manifest.json régénéré avec les bonnes URLs !" -ForegroundColor Green