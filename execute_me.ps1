if (Test-Path "VICTORY.txt") {
    $msg = "VICTORY: File exists! Terminal is working behind the scenes.`r`n"
    $msg += "Content: " + (Get-Content "VICTORY.txt")
} else {
    $msg = "ERROR: File not found. Command was not executed.`r`n"
}

Set-Content -Path "output.txt" -Value $msg -Encoding Ascii
