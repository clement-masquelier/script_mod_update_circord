<#
.SYNOPSIS
Script de synchronisation de mods style "NPM" pour Minecraft.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# --- CONFIGURATION (METTRE TON LIEN RAW ICI) ---
$ManifestUrl = "https://raw.githubusercontent.com/clement-masquelier/script_mod_update_circord/main/manifest.json"
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

Write-Host "[1/3] Récupération de la liste des mods..."
try {
    # On ajoute un paramètre nocache pour éviter les problèmes de version
    $Url = "$ManifestUrl"
    
    # ÉTAPE 1 : On télécharge le contenu BRUT (Raw)
    $RawContent = Invoke-WebRequest -Uri $Url -UseBasicParsing
    
    # ÉTAPE 2 : On force la conversion du texte en Objet JSON
    # C'est ici que la magie opère pour que .file fonctionne
    $Manifest = $RawContent.Content | ConvertFrom-Json
}
catch {
    Write-Error "[ERREUR] Impossible de télécharger ou lire le JSON."
    Write-Error $_.Exception.Message
    Read-Host "Entrée pour quitter..."
    exit
}

# DEBUG : Pour être sûr que ça a marché
Write-Host "DEBUG : Type reçu -> $($Manifest.GetType().Name)" -ForegroundColor Magenta
# Si ça affiche "Object[]", c'est gagné. Si ça affiche "String", c'est perdu.

# Liste des noms de fichiers valides
# Maintenant que $Manifest est un vrai tableau d'objets, .file va fonctionner
$ValidFiles = $Manifest.file

# 3. Nettoyage (Suppression des mods non listés)
Write-Host "[2/3] Vérification des fichiers obsolètes..."
$LocalFiles = Get-ChildItem -Path $ModDir -Filter "*.jar"

Write-Host "[info] validfiles : $($ValidFiles)"
foreach ($File in $LocalFiles) {
    if ($File.Name -notin $ValidFiles) {
        Write-Host "  [-] Suppression de : $($File.Name)" -ForegroundColor Red
        # Remove-Item $File.FullName -Force
    }
}

# AJOUT IMPORTANT : Force l'utilisation de TLS 1.2 (Requis par Modrinth)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 4. Téléchargement (Installation des manquants)
Write-Host "[3/3] Téléchargement des nouveaux mods..."
foreach ($Item in $Manifest) {
    $FilePath = Join-Path $ModDir $Item.file
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "  [+] Téléchargement de : $($Item.file)" -ForegroundColor Green
        try {
            # On ajoute un "UserAgent" pour faire croire à Modrinth qu'on est un navigateur (Chrome/Firefox)
            # Sinon Modrinth refuse la connexion (Erreur 403 ou reset)
            Invoke-WebRequest -Uri $Item.url -OutFile $FilePath -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        }
        catch {
            # Affiche l'erreur exacte pour comprendre
            Write-Host "      [ERREUR] Échec du téléchargement pour $($Item.file)" -ForegroundColor DarkRed
            Write-Host "      Détails : $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  [OK] Déjà présent : $($Item.file)" -ForegroundColor Gray
    }
}

Write-Host "`nTout est à jour ! Bon jeu !" -ForegroundColor Cyan
Read-Host "Appuyez sur Entrée pour fermer..."