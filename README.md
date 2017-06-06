# nodemcu-web-server
Simple http server based on json request and response, with api key authentication. For small project on ESP8266 with NodeMCU

**Server implement 5 GPIO:**

* 3 gpios for led (RGB) 
* 1 gpio for relay 
* 1 gpio for buzzer ( play some sounds )

**NodeMCU build includes the following modules:** file, gpio, net, node, pcm, pwm, sjson, tmr, uart, wifi.

**Simple request:**
```
curl -X POST \
  http://192.168.1.120/231aa60602b56fe92a79d5687c97aef2 \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -H 'postman-token: 7de507d1-ff16-13f2-9378-335820161126' \
  -d '{
  "action": "domofon",
  "value": "on"
}'
```
