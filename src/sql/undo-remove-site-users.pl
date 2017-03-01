#!/usr/bin/perl
#
# Generates SQL to undelete all CTools users from specified sites
#
# undo-remove-site-users.pl: {site-id-file} {output-file}
#
#      site-id-file : text file of specified site-ids (each on separate line)
#      output-file  : SQL file to be executed
#
use strict;

my $CPM_ACTION_LOG_SQL = "insert into CPM_ACTION_LOG (ACTION_TIME, SITE_ID, ACTION_TAKEN) VALUES (CURRENT_TIMESTAMP,'SITE-ID','UNDELETE_MEMBERS');\n";
my $USER_SQL = "INSERT INTO SAKAI_SITE_USER (SITE_ID, USER_ID, PERMISSION) SELECT SITE_ID, USER_ID, PERMISSION FROM ARCHIVE_SAKAI_SITE_USER where site_id = 'SITE-ID';\n";
my $REALM_SQL = "INSERT INTO SAKAI_REALM_RL_GR (REALM_KEY,  USER_ID ,ROLE_KEY,ACTIVE,PROVIDED) SELECT REALM_KEY,  USER_ID ,ROLE_KEY,ACTIVE,PROVIDED FROM ARCHIVE_SAKAI_REALM_RL_GR where realm_key in (select realm_key from sakai_realm where realm_id like '/site/SITE-ID%');\n";
## publish site?
## my $SITE_SQL = "update SAKAI_SITE set published=1 where site_id = 'SITE-ID'; \n";
my $COMMIT_SQL = "commit;\n";

main:
{
   if ( $#ARGV != 1 )
   {
       print " remove-site-users.pl: {site-id-file} {output-file}\n";
       exit -1;
   }

   ## set up default values
   my $inFile  = $ARGV[0];
   my $outFile = $ARGV[1];

   open INFILE, $inFile or die "$!";
   my @sites = <INFILE>;
   close INFILE;

   open OUTFILE, "> $outFile" or die "$!";

   ## set up count value
   my $count = 0;
   SITE: foreach $_ (@sites)
   {
       $count = $count + 1;
       
       $_ =~ s/\r?\n$//;
       chomp;
       next SITE if ( !$_ );
       my $sql;
       
       print OUTFILE "-- Site $count: for site id = $_\n";
       
       ## update the change record
       $sql = $CPM_ACTION_LOG_SQL;
       $sql =~ s/SITE-ID/$_/;
       print OUTFILE $sql;
       print OUTFILE "\n";

       ## recover site user
       $sql = $USER_SQL;
       $sql =~ s/SITE-ID/$_/;
       print OUTFILE $sql;
       print OUTFILE "\n";
       
       ## recover site user role
       $sql = $REALM_SQL;
       $sql =~ s/SITE-ID/$_/;
       print OUTFILE $sql;
       print OUTFILE "\n";
   }
   print OUTFILE $COMMIT_SQL;
   close OUTFILE;

   print "\n\n...Finished...\n\n";
}
