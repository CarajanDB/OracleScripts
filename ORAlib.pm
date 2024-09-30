package ORAlib;
# @(#) ================================================================================================================
# @(#) File        : ORAlib.pm
# @(#) Author      : Marcel Pils
# @(#)
# @(#) Version     : 1.1
# @(#) Date        : 22.08.2024
# @(#)
# @(#) Description : Perl module (library) with useful Oracle functions
# @(#) Functions:
# @(#)   get_ldap_server:      Get ldap server information from ldap.ora file
# @(#)
# @(#) Syntax      : It have to be imported into other perl scripts.
# @(#)               'use ORAlib'
#
# @@(#) Change History:
# @@(#)
# @@(#) 1.0  08.02.2024 M.Pils     Module created
# @@(#) 1.1  22.08.2024 M.Pils     Added defaults to get_ldap_server
# @(#) ================================================================================================================

use strict;
use warnings;
use Data::Dumper;
use Exporter;
our @ISA = qw(Exporter);
# these sub's are exported by default.
our @EXPORT = qw(get_ldap_server);
# these sub's CAN be exported.
our @EXPORT_OK = qw(get_ldap_server);

$| = 1;                      # make filehandles 'hot' -> means perl flushes the buffer immediately -> means perl flush the buffer every time you write another line to the log file
open(STDERR, ">&STDOUT");    # redirect STDERR to STDOUT -> mans all errormessages are written into logfiles too.

# Get ldap server information from ldap.ora file.
# - Last available DIRECTORY_SERVERS line is used.
# - First available ldap server is used defined in DIRECTORY_SERVERS value.
# Parameter $1 = full path qualified ldap.ora file
# Values are returned as an array.
sub get_ldap_server{
  die "no parameter!\n" unless @_;
  my $ldapora = $_[0];  # full path qualified ldap.ora file
  my ($ldap_server,$ldap_server_name,$ldap_server_domain,$ldap_port,$ldaps_port);
  if (! -e $ldapora) {
    warn "Could not find file $ldapora.";
    warn "Fall back to default values.";
    $ldap_server_name = 'oud';
    $ldap_server_domain = 'unix.lan';
    $ldap_server = "$ldap_server_name.$ldap_server_domain";
    $ldap_port = '389';
    $ldaps_port = '636';
  }
  else {
    open (LDAPORAFH, '<', $ldapora) or die "Error opening $ldapora $!";
    foreach my $line (<LDAPORAFH>)  {
      if ($line =~ '^DIRECTORY_SERVERS=') {
        # remove *( in front of first ldap server
        my @oudline = split /\(/, $line;
        # get first server only if multiple are defined
        @oudline = split /,/, $oudline[1];
        # remove )* from end of line
        @oudline = split /\)/, $oudline[0];
        my $oud = $oudline[0];
        chomp $oud;
        # get ldap server and ports
        my @oud_rec = split /:/, $oud;
        $ldap_server = $oud_rec[0];
        $ldap_port   = $oud_rec[1];
        $ldaps_port  = $oud_rec[2];
        # remove ldap server domain if defined
        my @server_rec = split /\./, $ldap_server;
        $ldap_server_name = $server_rec[0];
        shift(@server_rec);
        $ldap_server_domain = join('.',@server_rec);
      }
    }
  }
  return (
    $ldap_server_name,
    $ldap_server_domain,
    $ldap_server,
    $ldap_port,
    $ldaps_port
  );
}

1;
