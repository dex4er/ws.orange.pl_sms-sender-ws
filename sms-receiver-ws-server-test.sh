#!/bin/sh

if ! command -v soapcli >/dev/null 2>&1; then
    echo "Install App::soapcli Perl module:"
    echo "cpanm App::soapcli"
    exit 1
fi

soapcli -v '{sendSMSReceiver:{sms:{toLa:123,fromMsisdn:507998000,content:"TEST"}}}' sms-receiver-ws.wsdl ${1:-http://localhost:5000/}
