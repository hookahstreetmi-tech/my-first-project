$rootFiles = @("execute_me.ps1", "output.txt", "VICTORY.txt")
$targetFolder = "DEBUG_TOOLS"

if (-not (Test-Path $targetFolder)) {
    New-Item -ItemType Directory -Path $targetFolder | Out-Null
}

foreach ($file in $rootFiles) {
    if (Test-Path $file) {
        if ($file -eq "VICTORY.txt") {
            Remove-Item $file -Force
            $log = "Deleted: $file"
        }
        else {
            Move-Item $file -Destination "$targetFolder\$file" -Force
            $log = "Moved: $file to $targetFolder"
        }
        Write-Host $log
    }
}

"--- CLEANUP COMPLETE ---" | Out-File -FilePath "$targetFolder\output.txt" -Encoding Ascii
