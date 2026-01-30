$msg = "--- COMMAND CENTER MOVED ---`r`n"
$msg += "Now operating from DEBUG_TOOLS folder.`r`n"
Set-Content -Path "DEBUG_TOOLS\output.txt" -Value $msg -Encoding Ascii
