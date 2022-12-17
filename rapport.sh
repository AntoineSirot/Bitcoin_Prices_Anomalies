#!/bin/bash

your_chat_id="YOUR_CHAT_ID"
your_telegram_token="YOUR_TELEGRAM_TOKEN"
declare -a anomalies
readarray -t anomalies < <(awk '/^S/ {print $0}' anomalies.txt)
curl --data  chat_id=$your_chat_id --data-urlencode "text
Anomalies du jour : ${anomalies[@]} !" "https://api.telegram.org/bot$your_telegram_token/sendMessage?parse_mode=HTML"

 sudo cat > /var/www/html/api_bitcoin_price/anomalies.txt <<EOF

EOF #Reinitialisation du fichier tous les jours
