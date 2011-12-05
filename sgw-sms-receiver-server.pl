#!/usr/bin/env perl

use warnings;
use strict;

use XML::Compile::SOAP::Daemon::NetServer;
use XML::Compile::WSDL11;
use XML::Compile::SOAP11;

use Log::Report syntax => 'SHORT';

dispatcher PERL => 'default', mode => 'VERBOSE';

my $wsdl_filename = 'sgw-sms-receiver.wsdl';

my $wsdl = XML::Compile::WSDL11->new($wsdl_filename);

my $daemon = My::XML::Compile::SOAP::Daemon::NetServer->new;

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

$daemon->run(
    port => 8980,
    name => $0,
);


package My::XML::Compile::SOAP::Daemon::NetServer;
use base 'XML::Compile::SOAP::Daemon::NetServer';
use Log::Report syntax => 'SHORT';

sub default_values {
    +{ log_file => 'Log::Report', log_level => 2, client_maxreq => 1, client_reqbonus => 0, client_timeout => 30 }
}

sub process {
    my $self = shift;
    notice "Request\n---\n" . $_[1]->as_string . "---";
    $self->SUPER::process(@_);
}
