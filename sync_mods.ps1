# --- CONFIGURATION ---
$ManifestUrl = "https://raw.githubusercontent.com/clement-masquelier/script_mod_update_circord/main/manifest.json"
$ModDir = Join-Path $PWD "mods"
# ---------------------

Write-Host "=== Synchronisation des mods ===" -ForegroundColor Cyan
Write-Host ""

# Telecharger le manifeste depuis GitHub
Write-Host "Telechargement du manifeste depuis GitHub..." -ForegroundColor Yellow
try {
    $WebClient = New-Object System.Net.WebClient
    $WebClient.Encoding = [System.Text.Encoding]::UTF8
    $JsonContent = $WebClient.DownloadString($ManifestUrl)
    $RemoteManifest = $JsonContent | ConvertFrom-Json
    
    # S'assurer que c'est un tableau
    if ($RemoteManifest -isnot [array]) {
        $RemoteManifest = @($RemoteManifest)
    }
    
    Write-Host "OK Manifeste telecharge avec succes !" -ForegroundColor Green
    Write-Host "Nombre de mods dans le manifeste : $($RemoteManifest.Count)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "X Erreur lors du telechargement du manifeste : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Creer le dossier mods s'il n'existe pas
if (-not (Test-Path $ModDir)) {
    Write-Host "Creation du dossier mods..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ModDir -Force | Out-Null
}

# Obtenir la liste des fichiers locaux (.jar uniquement)
$LocalFiles = @(Get-ChildItem -Path $ModDir -Filter "*.jar" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
Write-Host "Nombre de mods locaux : $($LocalFiles.Count)" -ForegroundColor Cyan
Write-Host ""

# Creer des listes pour le traitement
$FilesToDownload = @()
$FilesToDelete = @()

# Extraire les noms de fichiers du manifeste
$ManifestFiles = @($RemoteManifest | Select-Object -ExpandProperty file)

# Determiner quels fichiers telecharger (dans le manifeste mais pas localement)
foreach ($ModEntry in $RemoteManifest) {
    if ($ModEntry.file -notin $LocalFiles) {
        $FilesToDownload += $ModEntry
    }
}

# Determiner quels fichiers supprimer (localement mais pas dans le manifeste)
foreach ($LocalFile in $LocalFiles) {
    if ($LocalFile -notin $ManifestFiles) {
        $FilesToDelete += $LocalFile
    }
}

# Afficher le resume
Write-Host "--- Resume ---" -ForegroundColor Cyan
Write-Host "Mods a telecharger : $($FilesToDownload.Count)" -ForegroundColor Yellow
Write-Host "Mods a supprimer   : $($FilesToDelete.Count)" -ForegroundColor Yellow
Write-Host ""

# Telecharger les nouveaux mods
if ($FilesToDownload.Count -gt 0) {
    Write-Host "=== Telechargement des mods ===" -ForegroundColor Cyan
    $DownloadedCount = 0
    $FailedCount = 0
    
    foreach ($Mod in $FilesToDownload) {
        Write-Host "Telechargement : $($Mod.file)..." -ForegroundColor Yellow
        $OutputPath = Join-Path $ModDir $Mod.file
        
        try {
            Invoke-WebRequest -Uri $Mod.url -OutFile $OutputPath -ErrorAction Stop
            Write-Host "  OK $($Mod.file)" -ForegroundColor Green
            $DownloadedCount++
        } catch {
            Write-Host "  X Echec : $($_.Exception.Message)" -ForegroundColor Red
            $FailedCount++
        }
    }
    
    Write-Host ""
    Write-Host "Telecharges : $DownloadedCount / Echoues : $FailedCount" -ForegroundColor $(if ($FailedCount -eq 0) { "Green" } else { "Yellow" })
    Write-Host ""
} else {
    Write-Host "Aucun mod a telecharger." -ForegroundColor Green
    Write-Host ""
}

# Supprimer les mods obsoletes
if ($FilesToDelete.Count -gt 0) {
    Write-Host "=== Suppression des mods obsoletes ===" -ForegroundColor Cyan
    $DeletedCount = 0
    
    foreach ($File in $FilesToDelete) {
        Write-Host "Suppression : $File..." -ForegroundColor Yellow
        $FilePath = Join-Path $ModDir $File
        
        try {
            Remove-Item -Path $FilePath -Force -ErrorAction Stop
            Write-Host "  OK $File" -ForegroundColor Green
            $DeletedCount++
        } catch {
            Write-Host "  X Echec : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Supprimes : $DeletedCount" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Aucun mod a supprimer." -ForegroundColor Green
    Write-Host ""
}

Write-Host "=== Synchronisation terminee ===" -ForegroundColor Cyan
