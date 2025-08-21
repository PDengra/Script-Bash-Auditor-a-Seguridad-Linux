#!/bin/bash
# ============================================
# Script de Auditoría de Seguridad en Linux (Avanzado)
# Autor: Pablo Dengra
# Fecha: $(date +"%Y-%m-%d")
# ============================================


# Variables
INFORME="/var/log/auditoria_seguridad_$(date +%Y%m%d).log"
EMAIL="admin@tuservidor.com"
TELEGRAM_BOT_TOKEN="AQUI_TU_TOKEN"
TELEGRAM_CHAT_ID="AQUI_TU_CHAT_ID"


echo "============================================" > "$INFORME"
echo " AUDITORÍA DE SEGURIDAD - $(date)" >> "$INFORME"
echo "============================================" >> "$INFORME"


# 1. Usuarios conectados
echo -e "\n[+] Usuarios conectados:" >> "$INFORME"
who >> "$INFORME"


# 2. Últimos logins fallidos
echo -e "\n[+] Últimos intentos de login fallidos:" >> "$INFORME"
lastb -n 10 2>/dev/null >> "$INFORME"


# 3. Usuarios con privilegios sudo
echo -e "\n[+] Usuarios con privilegios sudo:" >> "$INFORME"
getent group sudo | cut -d: -f4 >> "$INFORME"


# 4. Procesos en ejecución (top 5 por consumo CPU)
echo -e "\n[+] Procesos sospechosos (TOP 5 CPU):" >> "$INFORME"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 6 >> "$INFORME"


# 5. Puertos abiertos y servicios
echo -e "\n[+] Puertos abiertos:" >> "$INFORME"
ss -tulnp >> "$INFORME"


# 6. Archivos con permisos SUID
echo -e "\n[+] Archivos con permisos SUID:" >> "$INFORME"
find / -perm -4000 -type f 2>/dev/null | head -n 10 >> "$INFORME"


# 7. Estado de actualizaciones
echo -e "\n[+] Actualizaciones disponibles:" >> "$INFORME"
if command -v apt &> /dev/null; then
apt list --upgradable 2>/dev/null | grep -v "Listing" >> "$INFORME"
elif command -v dnf &> /dev/null; then
dnf check-update >> "$INFORME"
fi


echo -e "\n============================================" >> "$INFORME"
echo " Auditoría finalizada. Revisa: $INFORME" >> "$INFORME"
echo "============================================" >> "$INFORME"


# ============================
# 📧 Envío por Email
# ============================
if command -v mail &> /dev/null; then
mail -s "Informe de Auditoría de Seguridad - $(hostname)" "$EMAIL" < "$INFORME"
echo "📧 Informe enviado por correo a $EMAIL"
fi


# ============================
# 📲 Envío por Telegram
# ============================
# ============================
# 📲 Envío por Telegram
# ============================
if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" \
        -F chat_id="$TELEGRAM_CHAT_ID" \
        -F document=@"$INFORME" \
        -F caption="Informe de Auditoría de Seguridad - $(hostname)"
    echo "📲 Informe enviado por Telegram"
fi
