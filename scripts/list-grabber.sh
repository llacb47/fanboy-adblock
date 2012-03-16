#!/bin/bash
#
# Fanboy Adblock list grabber script v1.6 (16/03/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
TESTDIR="/tmp/ramdisk"
ZIP="nice -n 19 /usr/local/bin/7za"
NICE="nice -n 19"
SHRED="nice -n 19 /usr/bin/shred"
LOGFILE="/etc/crons/log-listgrabber.txt"
DATE="`date`"
ECHORESPONSE="List Changed: $LS2"
BADUPDATE="Bad Update: $LS2"
LS2="`ls -al $FILE`"
# OPENSSL=/usr/bin/openssl
OPENSSL=/usr/local/openssl/bin/openssl
ENCRYPT=sha256

# Make Ramdisk.
#
$GOOGLEDIR/scripts/ramdisk.sh
# Fallback if ramdisk.sh isn't excuted.
#
if [ ! -d "/tmp/ramdisk/" ]; then
  rm -rf /tmp/ramdisk/
  mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
  mount -t tmpfs -o size=30M tmpfs /tmp/ramdisk/
  mkdir /tmp/ramdisk/opera/
fi

# Make sure the shell scripts are exexcutable, all the time..
#
chmod a+x $GOOGLEDIR/scripts/ie/*.sh $GOOGLEDIR/scripts/iron/*.sh $GOOGLEDIR/scripts/*.sh $GOOGLEDIR/scripts/firefox/*.sh $GOOGLEDIR/scripts/combine/*.sh

# Grab Mercurial Updates
#
cd /home/fanboy/google/fanboy-adblock-list/
$NICE /usr/local/bin/hg pull
$NICE /usr/local/bin/hg update


# Main List
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_MAIN=$($OPENSSL $ENCRYPT $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt)
SSL_MAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-adblock.txt)

#
if [ "$SSLGOOGLE_MAIN" = "$SSL_MAIN" ]
 then
    # Make sure the old copy is cleared before we start
    rm -f $TESTDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-adblock.txt
    # Copy to ram disk first. (quicker)
    cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $TESTDIR/fanboy-adblock.txt
    # Re-generate checksum
    perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-adblock.txt
    cp -f $TESTDIR/fanboy-adblock.txt $MAINDIR/fanboy-adblock.txt
    # Compress file in Ram disk
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-adblock.txt > /dev/null
    # Clear Webhost-copy before copying
    rm -f $MAINDIR/fanboy-adblock.txt.gz
    # Now Copy over GZip'd list
    cp -f $TESTDIR/fanboy-adblock.txt.gz $MAINDIR/fanboy-adblock.txt.gz
    # perl $TESTDIR/addChecksum.pl $TESTDIR/firefox-expanded.txt-org2
    # cp -f $TESTDIR/firefox-expanded.txt-org2 $MAINDIR/fanboy-adblock.txt
    # cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    # cp -f $TESTDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    
    # Create a log
    FILE="$TESTDIR/fanboy-adblock.txt"
    echo $ECHORESPONSE >> $LOGFILE

    # The Dimensions List
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-dimensions.sh
    
    # The Adult List
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-adult.sh

    # The P2P List
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-p2p.sh

    # Seperate off CSS elements for Opera CSS
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-element-opera-generator.sh
    
    # Seperate off Elements
    #
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-noele.sh
    
    # Combine (Czech)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-czech.sh
    # Combine (Espanol)
		$NICE $GOOGLEDIR/scripts/combine/firefox-adblock-esp.sh
    # Combine (Russian)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-rus.sh
    # Combine (Japanese)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-jpn.sh
    # Combine (Swedish)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-swe.sh
    # Combine (Chinese)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-chn.sh
    # Combine (Vietnam)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-vtn.sh
    # Combine (Vietnam)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-krn.sh
    # Combine (Turkish)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-turk.sh
    # Combine (Italian)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ita.sh
    # Combine (Polish)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-pol.sh
    # Combine Regional trackers
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-tracking.sh
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
    # echo "Updated: fanboy-adblock.txt" > /dev/null
else
    echo "Files are the same"
fi

# Tracking List
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_STATS=$($OPENSSL $ENCRYPT $GOOGLEDIR/fanboy-adblocklist-stats.txt)
SSL_STATS=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-tracking.txt)

# Tracking
# Check for 0-sized file first
#
if [ "$SSLGOOGLE_STATS" = "$SSL_STATS" ]
 then
    # echo "Updated: fanboy-tracking.txt"
    # Clear old list
    rm -f $TESTDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking.txt
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/fanboy-adblocklist-stats.txt $TESTDIR/fanboy-tracking.txt
    # Re-generate checksum
    perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-tracking.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/fanboy-tracking.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and Copy over GZip'd list
    cp -f $TESTDIR/fanboy-tracking.txt $MAINDIR/fanboy-tracking.txt
    rm -f $MAINDIR/fanboy-tracking.txt.gz
    cp -f $TESTDIR/fanboy-tracking.txt.gz $MAINDIR/fanboy-tracking.txt.gz
    # Now combine with international list
    sh /etc/crons/hg-grab-intl.sh
    # Generate IE script
    $GOOGLEDIR/scripts/ie/tracking-ie-generator.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-tracking.sh
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
else
   echo "Files are the same"
fi

# Enhanced Trackers
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_NCD=$($OPENSSL $ENCRYPT $GOOGLEDIR/enhancedstats-addon.txt)
SSL_ENCD=$($OPENSSL $ENCRYPT $MAINDIR/enhancedstats.txt)

if [ "$SSLGOOGLE_NCD" = "$SSL_ENCD" ]
then
    # echo "Updated: enhancedstats-addon.txt"
    # Clear old list
    rm -f $TESTDIR/enhancedstats.txt $TESTDIR/enhancedstats.txt.gz
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/enhancedstats-addon.txt $TESTDIR/enhancedstats.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/enhancedstats.txt.gz $TESTDIR/enhancedstats.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/enhancedstats.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and now Copy over GZip'd list
    cp -f $TESTDIR/enhancedstats.txt $MAINDIR/enhancedstats.txt
    rm -f $MAINDIR/enhancedstats.txt.gz
    cp -f $TESTDIR/enhancedstats.txt.gz $MAINDIR/enhancedstats.txt.gz
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
else
   echo "Files are the same"
fi

# Addon/Annoyances
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_ANNOY=$($OPENSSL $ENCRYPT $GOOGLEDIR/fanboy-adblocklist-addon.txt)
SSL_ANNOY=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-addon.txt)

if [ "$SSLGOOGLE_ANNOY" = "$SSL_ANNOY" ]
then
    # echo "Updated: fanboy-addon.txt"
    # Clear old list
    rm -f $TESTDIR/fanboy-addon.txt $TESTDIR/fanboy-addon.txt.gz
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/fanboy-adblocklist-addon.txt $TESTDIR/fanboy-addon.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/fanboy-addon.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and now Copy over GZip'd list
    cp -f $TESTDIR/fanboy-addon.txt $MAINDIR/fanboy-addon.txt
    rm -f $MAINDIR/fanboy-addon.txt.gz
    cp -f $TESTDIR/fanboy-addon.txt.gz $MAINDIR/fanboy-addon.txt.gz
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
else
   echo "Files are the same"
fi

# CZECH
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_CZ=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt)
SSL_CZ=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-czech.txt)

if [ "$SSLGOOGLE_CZ" = "$SSL_CZ" ]
then
   echo "Updated: fanboy-czech.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $MAINDIR/fanboy-czech.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u $MAINDIR/fanboy-czech.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-czech.txt.gz $MAINDIR/fanboy-czech.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-czech.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/czech-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-czech.sh
else
   echo "Files are the same"
fi

# RUSSIAN
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_RU=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt)
SSL_RU=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-russian.txt)

if [ "$SSLGOOGLE_RU" = "$SSL_RU" ]
then
   echo "Updated: fanboy-russian.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $MAINDIR/fanboy-russian.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u $MAINDIR/fanboy-russian.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-russian.txt.gz $MAINDIR/fanboy-russian.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-russian.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/russian-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-rus.sh
   # Generate Opera RUS script also
   $GOOGLEDIR/scripts/firefox/opera-russian.sh
else
   echo "Files are the same"
fi

# TURK
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_TURK=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt)
SSL_TURK=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-turkish.txt)

if [ "$SSLGOOGLE_TURK" = "$SSL_TURK" ]
then
   echo "Updated: fanboy-turkish.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $MAINDIR/fanboy-turkish.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u  $MAINDIR/fanboy-turkish.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-turkish.txt.gz $MAINDIR/fanboy-turkish.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-turkish.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/turkish-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-turk.sh
else
   echo "Files are the same"
fi

# JAPANESE
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_JP=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt)
SSL_JP=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-japanese.txt)

if [ "$SSLGOOGLE_JP" = "$SSL_JP" ]
then
   echo "Updated: fanboy-japanese.txt"
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $MAINDIR/fanboy-japanese.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u  $MAINDIR/fanboy-japanese.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-japanese.txt.gz $MAINDIR/fanboy-japanese.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-japanese.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/italian-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-jpn.sh
else
   echo "Files are the same"
fi

# KOREAN
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_KR=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt)
SSL_KR=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-korean.txt)

if [ "$SSLGOOGLE_KR" = "$SSL_KR" ]
then
    echo "Updated: fanboy-korean.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $MAINDIR/fanboy-korean.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-korean.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-korean.txt.gz $MAINDIR/fanboy-korean.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-korean.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-krn.sh
else
   echo "Files are the same"
fi


# ITALIAN
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_IT=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt)
SSL_IT=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-italian.txt)

if [ "$SSLGOOGLE_IT" = "$SSL_IT" ]
then
    echo "Updated: fanboy-italian.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $MAINDIR/fanboy-italian.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-italian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-italian.txt.gz $MAINDIR/fanboy-italian.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-italian.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Generate IE script
    $GOOGLEDIR/scripts/ie/italian-ie-generator.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-ita.sh
else
   echo "Files are the same"
fi

# POLISH
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_PL=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt)
SSL_PL=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-italian.txt)

if [ "$SSLGOOGLE_PL" = "$SSL_PL" ]
then
    echo "Updated: fanboy-polish.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $MAINDIR/fanboy-polish.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-polish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-polish.txt.gz $MAINDIR/fanboy-polish.txt /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-polish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-pol.sh
else
   echo "Files are the same"
fi

# INDIAN
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_IN=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt)
SSL_IN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-indian.txt)

if [ "$SSLGOOGLE_IN" = "$SSL_IN" ]
then
    echo "Updated: fanboy-indian.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $MAINDIR/fanboy-indian.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-indian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-indian.txt.gz $MAINDIR/fanboy-indian.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-indian.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-ind.sh
else
   echo "Files are the same"
fi

# VIETNAM
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_VN=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt)
SSL_VN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-vietnam.txt)

if [ "$SSLGOOGLE_VN" = "$SSL_VN" ]
then
    echo "Updated: fanboy-vietnam.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $MAINDIR/fanboy-vietnam.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-vietnam.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-vietnam.txt.gz $MAINDIR/fanboy-vietnam.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-vietnam.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-vtn.sh
else
   echo "Files are the same"
fi

# CHINESE
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_CN=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt)
SSL_CN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-chinese.txt)

if [ "$SSLGOOGLE_CN" = "$SSL_CN" ]
then
    echo "Updated: fanboy-chinese.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $MAINDIR/fanboy-chinese.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-chinese.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-chinese.txt.gz $MAINDIR/fanboy-chinese.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-chinese.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-chn.sh
else
   echo "Files are the same"
fi

# ESPANOL
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_ES=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt)
SSL_ES=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-espanol.txt)

if [ "$SSLGOOGLE_ES" = "$SSL_ES" ]
then
    echo "Updated: fanboy-espanol.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $MAINDIR/fanboy-espanol.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-espanol.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-espanol.txt.gz $MAINDIR/fanboy-espanol.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-espanol.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
		# Generate IE script
		$GOOGLEDIR/scripts/ie/espanol-ie-generator.sh
		# Combine
		$GOOGLEDIR/scripts/combine/firefox-adblock-esp.sh
else
   echo "Files are the same"
fi

# SWEDISH
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_SW=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt)
SSL_SW=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-swedish.txt)

if [ "$SSLGOOGLE_SW" = "$SSL_SW" ]
then
    echo "Updated: fanboy-swedish.txt"
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $MAINDIR/fanboy-swedish.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-swedish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-swedish.txt.gz $MAINDIR/fanboy-swedish.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-swedish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-swe.sh
else
   echo "Files are the same"
fi

# Gannett
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE_GANNETT=$($OPENSSL $ENCRYPT $GOOGLEDIR/other/adblock-gannett.txt)
SSL_GANNETT=$($OPENSSL $ENCRYPT $MAINDIR/adblock-gannett.txt)

if [ "$SSLGOOGLE_GANNETT" = "$SSL_GANNETT" ]
then
    echo "Updated: fanboy-gannett.txt"
    cp -f $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u $MAINDIR/adblock-gannett.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/adblock-gannett.txt.gz $MAINDIR/adblock-gannett.txt > /dev/null
else
   echo "Files are the same"
fi

