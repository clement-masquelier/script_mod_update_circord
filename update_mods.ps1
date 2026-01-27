<#
.SYNOPSIS
Script de synchronisation de mods style "NPM" pour Minecraft.
#>

# --- CONFIGURATION (METTRE TON LIEN RAW ICI) ---
$ManifestUrl = "https://raw.githubusercontent.com/clement-masquelier/script_mod_update_circord/refs/heads/main/manifest.json?token=GHSAT0AAAAAADUAQPRGUVQRHRJLC3GDAE542LZEUPQ"
# -----------------------------------------------

$ModDir = Join-Path $PSScriptRoot "mods"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   SYNCHRONISATION DES MODS MINECRAFT     " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Vérification du dossier mods
if (-not (Test-Path $ModDir)) {
    Write-Host "[INFO] Le dossier 'mods' n'existe pas, création..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $ModDir | Out-Null
}

# 2. Récupération de la liste (le Manifeste)
Write-Host "[1/3] Récupération de la liste des mods..."
try {
    $Manifest = Invoke-RestMethod -Uri $ManifestUrl -Method Get
}
catch {
    Write-Error "[ERREUR] Impossible de télécharger la liste des mods. Vérifiez votre connexion."
    Read-Host "Appuyez sur Entrée pour quitter..."
    exit
}

# Liste des noms de fichiers valides
$ValidFiles = $Manifest.file

# 3. Nettoyage (Suppression des mods non listés)
Write-Host "[2/3] Vérification des fichiers obsolètes..."
$LocalFiles = Get-ChildItem -Path $ModDir -Filter "*.jar"

foreach ($File in $LocalFiles) {
    if ($File.Name -notin $ValidFiles) {
        Write-Host "  [-] Suppression de : $($File.Name)" -ForegroundColor Red
        Remove-Item $File.FullName -Force
    }
}

# 4. Téléchargement (Installation des manquants)
Write-Host "[3/3] Téléchargement des nouveaux mods..."
foreach ($Item in $Manifest) {
    $FilePath = Join-Path $ModDir $Item.file
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "  [+] Téléchargement de : $($Item.file)" -ForegroundColor Green
        try {
            Invoke-WebRequest -Uri $Item.url -OutFile $FilePath
        }
        catch {
            Write-Host "      [ERREUR] Échec du téléchargement pour $($Item.file)" -ForegroundColor DarkRed
        }
    } else {
        # (Optionnel) On pourrait vérifier la taille ou le hash ici, 
        # mais pour l'instant on suppose que si le nom est bon, le fichier est bon.
        Write-Host "  [OK] Déjà présent : $($Item.file)" -ForegroundColor Gray
    }
}

Write-Host "`nTout est à jour ! Bon jeu !" -ForegroundColor Cyan
Read-Host "Appuyez sur Entrée pour fermer..."