#!/usr/bin/env perl

# Perl standalone script
#
# Install libraries:
# $ cpanm XML::Compile::SOAP
#
# Run client:
# $ perl sms-sender-ws-client.pl http://endpoint content=TEST recipient=507998000

use warnings;
use strict;

use XML::Compile::WSDL11;
use XML::Compile::SOAP11;
use XML::Compile::Transport::SOAPHTTP;

use Log::Report syntax => 'LONG';

use Data::Dumper;

dispatcher PERL => 'default', mode => 'VERBOSE';

my $wsdl_filename = 'sms-sender-ws.wsdl';

my $wsdl = XML::Compile::WSDL11->new($wsdl_filename);
$wsdl->importDefinitions( [ <com.osa.mdsp.enabler.*.xsd> ] );

my $endpoint = defined $ARGV[0] && $ARGV[0] =~ m{^https?://} ? shift @ARGV : $wsdl->endPoint;
my $operation = 'sendSMS';
my %args = map { /^(.*?)=(.*)$/ and ($1 => $2) } @ARGV;
my $request = { sms => \%args };

my $http = XML::Compile::Transport::SOAPHTTP->new(
    address => $endpoint,
);

$http->userAgent->env_proxy;

my $action = $wsdl->operation($operation)->soapAction();

my $transport = $http->compileClient(
    action => $action,
);

$wsdl->compileCalls(
    sloppy_floats   => 1,
    sloppy_integers => 1,
    transport       => $transport,
);

my ($response, $trace) = $wsdl->call($operation, $request);
die $trace->errors unless $response;

my $sms_id = $response->{sendSMSResponse}{sendSMSReturn};
die Dumper $response unless defined $sms_id;

print $sms_id, "\n";
