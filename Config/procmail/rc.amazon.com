############################################################
# Amazon.com Domain Procmail RC file
############################################################

############################################################
# Specific matches

:0 W
* ^Subject: Obidos Error Report
/dev/null

:0 W
* ^From:.*root\@
$SPOOLDIR/crontab

:0 W
* ^Subject: CRON:
$SPOOLDIR/crontab

:0 W
* ^Subject:.*P4 SUBMIT by .* \(mainline\)
$SPOOLDIR/commit-main

:0 W
* ^Subject:.*(commit|checkin|publish|submit)
$SPOOLDIR/commit

:0 W
* ^TO_poker@
$SPOOLDIR/poker

:0 W
* ^TO_(performance-interest|build-info|houston)@
$SPOOLDIR/build

:0 W
* ^From:.*build@
$SPOOLDIR/build

:0 W
* ^Subject:.*frank
$SPOOLDIR/frank

:0 W
* ^TO_frank-users
$SPOOLDIR/frank

# FIX: why :0: instead of :0 W?
:0:
* ^TO_(downtown|pac|pac-amzn-sal|amazon|seattle|seattle-reg|pac|pacmed|infrastructure)@
$SPOOLDIR/downtown

:0:
* ^TO_(software|pubsub-users|ute|perlhacker|infrastructure|codeline-owners)@
$SPOOLDIR/software

:0:
* ^TO_qa-tools@
$SPOOLDIR/qa

:0:
* ^TO_antlr-interest@
$SPOOLDIR/antlr
