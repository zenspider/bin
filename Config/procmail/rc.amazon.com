############################################################
# Amazon.com Domain Procmail RC file
############################################################

############################################################
# Specific matches

:0 W
* ^Subject: Obidos Error Report
/dev/null

:0 W
* ^Subject:.*(commit|checkin)
$SPOOLDIR/commit

:0 W
* TO.*build-info.*
$SPOOLDIR/build

:0 W
* TOhouston.*
$SPOOLDIR/build

:0 W
* ^From:.*build
$SPOOLDIR/build

:0 W
* ^Subject:.*BACKEND BUILD/INSTALL
$SPOOLDIR/build

:0 W
* ^From:.*(hobbs|maryann)@
$SPOOLDIR/build

:0 W
* ^Subject:.*frank.*
$SPOOLDIR/frank

:0 W
* TO.*frank-users.*
$SPOOLDIR/frank

:0:
* ^TOdowntown@
$SPOOLDIR/downtown

:0:
* ^TOamazon@
$SPOOLDIR/downtown

:0:
* ^TOseattle@
$SPOOLDIR/downtown

:0:
* ^TOseattle-reg@
$SPOOLDIR/downtown

:0:
* ^TOcolumbia@
$SPOOLDIR/downtown

:0:
* ^TOpacmed@
$SPOOLDIR/downtown

:0:
* ^TOpac@
$SPOOLDIR/downtown

:0:
* ^TOsoftware
$SPOOLDIR/software

:0:
* ^TOqa
$SPOOLDIR/qa
