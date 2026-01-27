#!/bin/bash

# scripts/approve.sh - Оптимизирован для внутреннего терминала Antigravity

# 1. Запуск уведомления в фоновом режиме через PowerShell
powershell.exe -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Antigravity: Жду вашего подтверждения в интерфейсе!', 'Jarvis Alert', 'OK', 'Information')" &

# 2. Красивый вывод в Bash
echo -e "\033[1;36m🔔 ALERT SYSTEM ACTIVE\033[0m"
echo -e "---------------------------------------------------"
echo -e "\033[1;33mATTENTION:\033[0m Check your IDE interface NOW."
echo -e "Look for the \033[1;32m'Approve'\033[0m button in the chat area."
echo -e "---------------------------------------------------"

# 3. Ожидание ввода
read -p "Press [ENTER] after you approve the action..."
