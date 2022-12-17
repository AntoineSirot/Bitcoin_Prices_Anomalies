# Bitcoin_Prices_Anomalies

This project use the CoinMarketCap api to take Bitcoin's price and search anomalies in its evolution. 

The Website is deployed on http://13.37.217.93 but it won't be running all the time.

# How does it work ?

I used the API in import_price.sh to stock every values and dates in the Bitprice table (which is stored in bitcoinprice.db).

After that I implemented a html page in impl_html.sh with the last 10 values that are inside my database.

I check the anomalies in this file and put every single one in the anomalies.txt file.

After that I send every day telegram messages with every anomalies that occured in the last 24h.
