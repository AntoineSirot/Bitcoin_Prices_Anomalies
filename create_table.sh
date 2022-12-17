#!/bin/sh
sqlite3 /var/www/html/api_bitcoin_price/bitcoinprice.db <<EOF
create table BITPRICE (date TEXT PRIMARY KEY, price REAL);
EOF


