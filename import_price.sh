#!/bin/sh

curl -s -H "X-CMC_PRO_API_KEY: YOUR_API_KEY" -H "Accept: application/json" -d "amount=1&id=1" -G https://pro-api.coinmarketcap.com/v2/tools/price-conversio>

PRICE=$(sudo cat /home/ubuntu/prices.txt | grep -oP '"price":\w+.\w+' | grep -oP ":\w+.\w+" | grep -oP '\w+.\w+')

sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db <<EOF
insert into BITPRICE (date,price) values (datetime('now', 'localtime'),$PRICE);
EOF
