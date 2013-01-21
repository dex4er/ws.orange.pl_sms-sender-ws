#!/bin/sh

if ! command -v xsoapcli >/dev/null 2>&1; then
    echo "Install App::soapcli Perl module"
fi

soapcli -v '{sendSMSReceiver:{sms:{toLa:123,fromMsisdn:507998000,content:"TEST"}}}' sms-receiver-ws.wsdl ${1:-http://localhost:5000/}
