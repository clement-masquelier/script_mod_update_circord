@echo off
cd /d "%~dp0"
title Mise a jour des Mods Minecraft

echo ==========================================
echo      LANCEMENT DE LA MISE A JOUR
echo ==========================================
echo.

:: Remplacer l'URL ci-dessous par le lien RAW de votre script modifié
set "ScriptURL=https://raw.githubusercontent.com/clement-masquelier/script_mod_update_circord/main/sync_mods.ps1"

:: Commande magique :
:: 1. Télécharge le contenu (iwr)
:: 2. L'exécute (iex)
:: 3. Tout ça en restant dans le dossier actuel grâce à la modif $PWD faite à l'étape 1

powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing '%ScriptURL%' | Invoke-Expression"

echo.
echo ==========================================
echo      OPERATION TERMINEE
echo ==========================================
pause