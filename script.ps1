# Construire le nom du fichier à télécharger
$tag = "1.0.2"
$fileName = "$tag.zip"
$appFolder = "C:\Tribu"
$destinationFolder = "C:\tmp"

# URL du référentiel GitHub
$repoUrl = "https://github.com/larbagit/TribuTotem_Install/releases/latest/tag/$tag"

# URL de téléchargement pour le fichier
$downloadUrl = "https://github.com/larbagit/TribuTotem_Install/releases/download/$tag/$fileName"

Write-Host "$downloadUrl"

# Créer un header pour l'authentification (pas nécessaire pour les référentiels publics)
$headers = @{
    "User-Agent" = "PowerShell"  # L'agent utilisateur est requis pour les requêtes vers l'API GitHub
}


# Vérifier si le dossier de telechargement existe, sinon le créer
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

# Télécharger le fichier depuis GitHub
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile "$destinationFolder\$fileName" -ErrorAction Stop
    Write-Host "Téléchargement terminé : $destinationFolder\$fileName"
} catch {
    Write-Host "Erreur lors du téléchargement du fichier : $_"
}

# Construire le chemin complet du fichier téléchargé
$downloadedFilePath = Join-Path -Path $destinationFolder -ChildPath $fileName

# Décompresser le fichier téléchargé
try {
    Expand-Archive -Path $downloadedFilePath -DestinationPath $destinationFolder -Force
    Write-Host "Décompression terminée : $downloadedFilePath"
} catch {
    Write-Host "Erreur lors de la décompression du fichier : $_"
}

# Vérifier si le dossier d'installation existe, sinon le créer
if (-not (Test-Path -Path $appFolder)) {
    New-Item -ItemType Directory -Path $appFolder | Out-Null
}

# Construire le chemin complet du sous-dossier à déplacer
$subFolderToMove = Join-Path -Path $extractedFolder -ChildPath "win-unpacked"
$destinationSubFolder = Join-Path -Path $appFolder -ChildPath "tribu_app"

# Déplacer le sous-dossier vers le dossier d'installation avec un nouveau nom
try {
    Move-Item -Path $subFolderToMove -Destination $destinationSubFolder -Force -ErrorAction Stop
    Write-Host "Déplacement du sous-dossier terminé : $subFolderToMove -> $destinationSubFolder"
} catch {
    Write-Host "Erreur lors du déplacement du sous-dossier : $_"
}

# Supprimer les fichiers temporaires (zip et dossier extrait)
try {
    Remove-Item -Path $downloadedFilePath -Force -ErrorAction Stop
    Remove-Item -Path $extractedFolder -Force -Recurse -ErrorAction Stop
    Write-Host "Suppression des fichiers temporaires terminée"
} catch {
    Write-Host "Erreur lors de la suppression des fichiers temporaires : $_"
}

# Chemin complet de l'exécutable Tribu.exe
$executablePath = Join-Path -Path $destinationSubFolder -ChildPath "Tribu.exe"

# Chemin du dossier de démarrage
$startupFolder = [System.Environment]::GetFolderPath("Startup")

# Créer un raccourci vers l'exécutable dans le dossier de démarrage
$shortcutPath = Join-Path -Path $startupFolder -ChildPath "Tribu.lnk"

# Créer un objet pour créer le raccourci
$WshShell = New-Object -ComObject WScript.Shell

# Créer le raccourci
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $executablePath
$Shortcut.Save()

Write-Host "Raccourci créé vers $executablePath dans le dossier de démarrage de Windows."