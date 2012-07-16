#!/usr/bin/env perl

# PSGI service

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
use Plack::Request;
use Plack::Response;
use HTTP::Status;

builder {
    enable sub {
        my $app = shift;
        sub {
            my $env = shift;

            # do preprocessing
            my $req = Plack::Request->new($env);
            $env->{'psgi.errors'}->print( sprintf
                "Request\n---\n%s %s %s\n%s\n%s---\n",
                $req->method, $req->uri, $req->protocol,
                $req->headers->as_string,
                $req->content,
            );

            my $resarr = $app->($env);

            # do postprocessing
            my $res = Plack::Response->new(@$resarr);
            $env->{'psgi.errors'}->print( sprintf
                "Response\n---\nHTTP/1.0 %s %s\n%s\n%s---\n",
                $res->status, HTTP::Status::status_message($res->status),
                $res->headers->as_string,
                join('', @{$res->body}),
            );

            return $resarr;
        };
    };
    $app;
};
