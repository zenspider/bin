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
* ^TO_build-info
$SPOOLDIR/build

:0 W
* ^TO_houston
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
* ^TO_frank-users
$SPOOLDIR/frank

:0:
* ^TO_downtown@
$SPOOLDIR/downtown

:0:
* ^TO_amazon@
$SPOOLDIR/downtown

:0:
* ^TO_seattle@
$SPOOLDIR/downtown

:0:
* ^TO_seattle-reg@
$SPOOLDIR/downtown

:0:
* ^TO_columbia@
$SPOOLDIR/downtown

:0:
* ^TO_pacmed@
$SPOOLDIR/downtown

:0:
* ^TO_pac@
$SPOOLDIR/downtown

:0:
* ^TO_software@
$SPOOLDIR/software

:0:
* ^TO_qa-tools@
$SPOOLDIR/qa
