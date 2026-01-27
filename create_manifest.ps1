# --- CONFIGURATION ---
# L'URL où tes amis téléchargeront les fichiers (GitHub, ton site, etc.)
# IMPORTANT : Doit finir par un "/"
$BaseUrl = "https://raw.githubusercontent.com/clement-masquelier/script_mod_update_circord/refs/heads/main/mods/"
# ---------------------

$ModDir = Join-Path $PSScriptRoot "mods"
$OutputFile = Join-Path $PSScriptRoot "mods.json"

Write-Host "Génération du manifeste depuis : $ModDir" -ForegroundColor Cyan

# Récupère tous les .jar
$Files = Get-ChildItem -Path $ModDir -Filter "*.jar"

$JsonList = @()

foreach ($File in $Files) {
    # On encode le nom du fichier pour l'URL (gestion des espaces, symboles...)
    $EncodedName = [System.Web.HttpUtility]::UrlPathEncode($File.Name)
    
    # Si [System.Web.HttpUtility] n'est pas dispo (vieux PowerShell), on utilise une méthode simple :
    if (-not $EncodedName) { $EncodedName = $File.Name.Replace(" ", "%20") }

    # Création de l'objet
    $ModObject = [PSCustomObject]@{
        file = $File.Name
        url  = "$BaseUrl$EncodedName"
    }

    $JsonList += $ModObject
}

# Export en JSON propre
$JsonList | ConvertTo-Json -Depth 2 | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Fichier 'mods.json' créé avec succès !" -ForegroundColor Green
Write-Host "Nombre de mods : $($JsonList.Count)"
Write-Host "Aperçu :"
$JsonList | Select-Object -First 3