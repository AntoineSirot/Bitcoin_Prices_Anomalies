#!/bin/bash


# Déclaration des variables et des commandes sql basiques :
Prix=$(sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db  "SELECT * from BITPRICE;")
Mean=$(sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db  "SELECT avg(price) from BITPRICE;")
PRICES=$(sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db  "SELECT price from BITPRICE;")
EcartType=0
variance=0
moyenne_diff=0
diff_array=0
i=0
declare -a prices_array
declare -a anomalies_array


# Récupération des prix pour les mettre dans un tableau :
for line in $PRICES; do
    prices_array[$i]="$line"
    i=$((i+1))
done


# Calcul et création d'un tableau avec les différences entre chaque prix et calcul de la moyenne des différences de prix :
for ((i=0; i<${#prices_array[@]}-1; i++)); do
  diff_array[i]=$(printf "%.2f" "$(echo "${prices_array[i]} - ${prices_array[i+1]}" | bc -l)")
if [ $(echo "${diff_array[i]} < 0" | bc -l) == "1" ]; then
    diff_array[i]=$(printf "%.2f" "$(echo "- ${diff_array[i]}" | bc -l)")
  fi
moyenne_diff=$(printf "%.2f" "$(echo "${diff_array[i]} + $moyenne_diff" | bc -l)")
done
Length=$((${#prices_array[@]}-1))
moyenne_diff=$(printf "%.2f" "$(echo "$moyenne_diff / $Length" | bc -l)")
echo "Moyenne Diff : $moyenne_diff"


# Calcul de l'écart type pour créer notret intervalle de confiance à 95% :
for value in "${diff_array[@]}"; do
  if [ $(echo "$value < 0" | bc -l) == "1" ]; then
    value[i]=$(printf "%.2f" "$(echo "- $value" | bc -l)")
  fi
  diff=$(echo "$value - $moyenne_diff" | bc -l)
diff_squared=$(echo "$diff * $diff" | bc -l)
  variance=$(echo "$variance + $diff_squared" | bc -l)
done
variance=$(echo "$variance / ( ${#diff_array[@]} - 1 )" | bc -l)
EcartType=$(echo "sqrt($variance)" | bc -l)
echo "The ecart-type is $EcartType"


# Repérage des anomalies et je les mets dans le fichier anomalies.txt :
for ((i=0; i<${#diff_array[@]}-1; i++)); do

  if [ $(echo "${diff_array[i]} < 0" | bc -l) == "1" ]; then
    diff_array[i]=$(printf "%.2f" "$(echo "- ${diff_array[i]}" | bc -l)")
  fi
 borne_supp=$(printf "%.2f" "$(echo "$moyenne_diff + 1.96*$EcartType" | bc -l)")
  if [ $(echo "${diff_array[i]} > $borne_supp" | bc -l) == "1" ]; then
   echo "Anomaly with this value : ${prices_array[i+1]} Difference : ${diff_array[i]}"
   sudo cat > /var/www/html/api_bitcoin_price/anomalies.txt <<EOF
   ${prices_array[i+1]}
EOF
   fi
done


# Affichage du début de notre page HTML :
sudo cat > /var/www/html/api_bitcoin_price/index.html <<EOF
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8">
    <title>Bitcoin Price with API</title>
  </head>
  <body>
      <h1>Bitcoin Price</h1>
    <p>Mean of its price : $Mean </p>
    <p>Last 10 Prices :
<table>
  <tr>
    <th>Date</th>
    <th>Price</th>
  </tr>
EOF


# Recherche de notre dernière valeur pour l'afficher sue la page HTML :
last_price=$(sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db "SELECT price FROM BITPRICE WHERE DATETIME(date)=DATETIME((SELECT MAX(date) FROM BITPRICE));")
last_date=$(sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db "SELECT date FROM BITPRICE WHERE Datetime(date)=Datetime(( SELECT MAX(date) FROM BITPRICE));")
sudo cat >> /var/www/html/api_bitcoin_price/index.html <<EOF
  <tr>
    <td>$last_date</td>
    <td>$last_price</td>
  </tr>
  EOF


# Affichage des 9 prix possédant pour en avoir 10 sur la page :
for i in {0..8..1}
do
  new_price=$(sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db "SELECT price FROM BITPRICE WHERE date = (SELECT max(date) FROM BITPRICE WHERE date < '$last_date');")
  new_date=$(sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db "SELECT date FROM BITPRICE WHERE date = (SELECT max(date) FROM BITPRICE WHERE date < '$last_date');")
sudo cat >> /var/www/html/api_bitcoin_price/index.html <<EOF
  <tr>
    <td>$new_date</td>
    <td>$new_price</td>
  </tr>
EOF
  last_date=$new_date
done


# Code de fin de la page HTML :
sudo cat >> /var/www/html/api_bitcoin_price/index.html <<EOF
</table>
</body>
</html>
EOF
