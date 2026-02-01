if (Test-Path "DOCUMENTS") {
    Rename-Item -Path "DOCUMENTS" -NewName "PROJECTS" -Force
    Write-Host "Renamed 'DOCUMENTS' to 'PROJECTS' successfully."
}
else {
    Write-Host "Directory 'DOCUMENTS' not found. Maybe it was already renamed?"
}
