#!/bin/bash

# Оптимизированный скрипт подтверждения для Bash-терминала Antigravity
# Путь: SKRIPTS/approve.sh

# 1. Запуск уведомления (через PowerShell, так как ОС Windows)
# Используем nohup и &, чтобы терминал не блокировался до закрытия окна
powershell.exe -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Antigravity: Требуется подтверждение в чате!', 'Approve Sync', 'OK', 'Information')" > /dev/null 2>&1 &

# 2. Визуальное оформление в терминале
echo -e "\n\033[1;36m[JARVIS] Система уведомлений активирована\033[0m"
echo -e "\033[1;33m---------------------------------------------------\033[0m"
echo -e "ПОЖАЛУЙСТА, ПЕРЕЙДИТЕ В ИНТЕРФЕЙС ЧАТА."
echo -e "Найдите кнопку \033[1;32m'Approve'\033[0m (Подтвердить) и нажмите её."
echo -e "\033[1;33m---------------------------------------------------\033[0m\n"

# 3. Ожидание завершения
read -p "После того как нажмете кнопку в чате, нажмите [ENTER] здесь... "
echo -e "\n\033[1;32m[OK] Продолжаем работу.\033[0m\n"
