#!/usr/bin/env perl

# PSGI service
#
# Run with command: plackup sms-receiver-ws-server.psgi

use warnings;
use strict;

use XML::Compile::SOAP::Daemon::PSGI;
use XML::Compile::WSDL11;
use XML::Compile::SOAP11;

use Log::Report syntax => 'LONG';

dispatcher PERL => 'default', mode => 'VERBOSE';

my $wsdl_filename = 'sms-receiver-ws.wsdl';

my $wsdl = XML::Compile::WSDL11->new($wsdl_filename);
$wsdl->importDefinitions( [ <pl.net.amg.hdl.*.xsd> ] );

my $daemon = XML::Compile::SOAP::Daemon::PSGI->new;

$daemon->operationsFromWSDL(
    $wsdl,
    callbacks => {
        sendSMSReceiver => sub {
            my ($soap, $data) = @_;
            return +{
                sendSMSReceiverReturn => 1,
            };
        },
        sendSMSNotification => sub {
            my ($soap, $data) = @_;
            return +{
                sendSMSNotificationReturn => 1,
            };
        },
    },
);

$daemon->setWsdlResponse($wsdl_filename);

my $app = $daemon->to_app;


# Full debugging of requests and responses

use Plack::Builder;

builder {
    enable 'TrafficLog';
    $app;
};
