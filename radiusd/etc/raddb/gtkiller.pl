#!/usr/bin/env perl
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
#  Copyright 2002  The FreeRADIUS server project
#  Copyright 2002  Boian Jordanov <bjordanov@orbitel.bg>
#

#
# Example code for use with rlm_perl
#
# You can use every module that comes with your perl distribution!
#
use strict;
# use ...
# This is very important ! Without this script will not get the filled hashesh from main.
use vars qw(%RAD_REQUEST %RAD_REPLY %RAD_CHECK);
#use Data::Dumper;
#use CGI;
#use DBI;
#use DBD::mysql;

# This is hash wich hold original request from radius
#my %RAD_REQUEST;
# In this hash you add values that will be returned to NAS.
#my %RAD_REPLY;
#This is for check items
#my %RAD_CHECK;

#
# This the remapping of return values
#
	use constant    RLM_MODULE_REJECT=>    0;#  /* immediately reject the request */
	use constant	RLM_MODULE_FAIL=>      1;#  /* module failed, don't reply */
	use constant	RLM_MODULE_OK=>        2;#  /* the module is OK, continue */
	use constant	RLM_MODULE_HANDLED=>   3;#  /* the module handled the request, so stop. */
	use constant	RLM_MODULE_INVALID=>   4;#  /* the module considers the request invalid. */
	use constant	RLM_MODULE_USERLOCK=>  5;#  /* reject the request (user is locked out) */
	use constant	RLM_MODULE_NOTFOUND=>  6;#  /* user not found */
	use constant	RLM_MODULE_NOOP=>      7;#  /* module succeeded without doing anything */
	use constant	RLM_MODULE_UPDATED=>   8;#  /* OK (pairs modified) */
	use constant	RLM_MODULE_NUMCODES=>  9;#  /* How many return codes there are */

# Function to handle authorize
sub authorize {
	# For debugging purposes only
#	&log_request_attributes;

	$RAD_CHECK{'Auth-Type'} = 'PERL';

	return RLM_MODULE_OK;
}

# Function to handle authenticate
sub authenticate {
	# For debugging purposes only
	my @replies = ();
	my $callingstation = $RAD_REQUEST{'Calling-Station-Id'};

	my $calledstation = $RAD_REQUEST{'Called-Station-Id'};
	my $iddevice = $calledstation;
	my $gateip = "188.227.5.66:5060";
    push @replies, "h323-ivr-in=Routing:".$iddevice.'@'.$gateip.";"."expires=20;rid=-1;cli=$callingstation".";group=1";
	
   
#    my $calledstation = '55555579'.$RAD_REQUEST{'Called-Station-Id'};
#	my $gateip = "206.225.167.4:5060";
#    my $iddevice = $calledstation;
#	push @replies, "h323-ivr-in=Routing:".$iddevice.'@'.$gateip.";"."expires=60;rid=-1;cli=$callingstation".";group=2";
	
	my $gateip = "188.227.5.6:5060";
    push @replies, "h323-ivr-in=Routing:".$iddevice.'@'.$gateip.";"."expires=40;rid=-1;cli=$callingstation".";group=3";

    $RAD_REPLY{'Cisco-AVPair'} = \@replies;
	
	return RLM_MODULE_OK;
}

# Function to handle preacct
sub preacct {
	# For debugging purposes only
#	&log_request_attributes;

	return RLM_MODULE_OK;
}

# Function to handle accounting
sub accounting {
	# For debugging purposes only
#	&log_request_attributes;

	# You can call another subroutine from here
	&test_call;

	return RLM_MODULE_OK;
}

sub accounting_start {
	# For debugging purposes only
#	&log_request_attributes;


	return RLM_MODULE_OK;
}

sub accounting_stop {
	# For debugging purposes only
#	&log_request_attributes;


	return RLM_MODULE_OK;
}

# Function to handle checksimul
sub checksimul {
	# For debugging purposes only
#	&log_request_attributes;

	return RLM_MODULE_OK;
}

# Function to handle pre_proxy
sub pre_proxy {
	# For debugging purposes only
#	&log_request_attributes;

	return RLM_MODULE_OK;
}

# Function to handle post_proxy
sub post_proxy {
	# For debugging purposes only
#	&log_request_attributes;

	return RLM_MODULE_OK;
}

# Function to handle post_auth
sub post_auth {
	# For debugging purposes only
#	&log_request_attributes;

	return RLM_MODULE_OK;
}

# Function to handle xlat
sub xlat {
	# For debugging purposes only
#	&log_request_attributes;

	# Loads some external perl and evaluate it
	my ($filename,$a,$b,$c,$d) = @_;
	&radiusd::radlog(1, "From xlat $filename ");
	&radiusd::radlog(1,"From xlat $a $b $c $d ");
	local *FH;
	open FH, $filename or die "open '$filename' $!";
	local($/) = undef;
	my $sub = <FH>;
	close FH;
	my $eval = qq{ sub handler{ $sub;} };
	eval $eval;
	eval {main->handler;};
}

# Function to handle detach
sub detach {
	# For debugging purposes only
#	&log_request_attributes;

	# Do some logging.
	&radiusd::radlog(0,"rlm_perl::Detaching. Reloading. Done.");
}

#
# Some functions that can be called from other functions
#

sub test_call {
	# Some code goes here
}

sub log_request_attributes {
	# This shouldn't be done in production environments!
	# This is only meant for debugging!
	for (keys %RAD_REQUEST) {
		&radiusd::radlog(1, "RAD_REQUEST: $_ = $RAD_REQUEST{$_}");
	}
}

