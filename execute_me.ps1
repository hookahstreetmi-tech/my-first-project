$report = "--- POST-REBOOT CHECK ---`r`n"
$report += "Current Directory: " + (Get-Location).Path + "`r`n"
$report += "Files in root:`r`n"
(Get-ChildItem).Name | ForEach-Object { $report += "- $_`r`n" }

# Проверка, видит ли терминал теперь команду 'claude' или аналоги
$report += "`r`nCommand Check:`r`n"
$report += "Search for 'antigravity': " + (Get-Command *antigravity* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source) + "`r`n"

Set-Content -Path "output.txt" -Value $report -Encoding Ascii
