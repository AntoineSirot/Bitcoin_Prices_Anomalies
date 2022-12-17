Prix_Moy=$(sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db  "SELECT * from BITPRICE;")

echo $Prix_Moy
