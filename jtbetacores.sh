#!/bin/bash
#set -x
set -u

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
######################################################################

JTKEYDIR="/media/fat/JTKEY"
JTKEYURL="https://archive.org/download/jtbetakey/beta.zip"
INSTALL="false"
INIFILE="$(pwd)/jtkeygetter.ini"

SSL_SECURITY_OPTION="${SSL_SECURITY_OPTION:---insecure}"
CURL_RETRY="${CURL_RETRY:---connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5 --show-error}"

EXITSTATUS=0


INIFILE_FIXED=$(mktemp)
if [[ -f "${INIFILE}" ]] ; then
    dos2unix < "${INIFILE}" 2> /dev/null > ${INIFILE_FIXED}
fi


if [ `grep -c "JTKEYDIR=" "${INIFILE_FIXED}"` -gt 0 ]
    then
        BIOSDIR=`grep "JTKEYDIR=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null

if [ `grep -c "INSTALL=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      INSTALL=`grep "INSTALL=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^ *"//' -e 's/" *$//'`
fi 2>/dev/null

if [ `grep -c "CURL_RETRY=" "${INIFILE_FIXED}"` -gt 0 ]
   then
      CURL_RETRY=`grep "CURL_RETRY=" "${INIFILE_FIXED}" | awk -F "=" '{print$2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/^"//' -e 's/"$//'`
fi 2>/dev/null

#####INFO TXT#####

if [ `egrep -c "JTKEYDIR|INSTALL|CURL_RETRY" "${INIFILE_FIXED}"` -gt 0 ]
    then
        echo ""
        echo "Using "${INIFILE}"" 
        echo ""
fi 2>/dev/null 

rm ${INIFILE_FIXED}

#########Auto Install##########
if [[ "${INSTALL^^}" == "TRUE" ]] && [ ! -e "/media/fat/Scripts/update_jtbetacores.sh" ]
   then
        echo "Downloading update_bios-getter.sh to /media/fat/Scripts"
        echo ""
        curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --location -o "/media/fat/Scripts/update_jtbetacores.sh" https://github.com/jtkeygetterscript/jtkeygetter/raw/main/update_jtbetacores.sh
        echo
fi

############### START ################

mkdir -p "${JTKEYDIR}"

curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} --fail --location -o "$JTKEYDIR" "$JTKEYURL"

echo


if [ $EXITSTATUS -eq 0 ]
    then
        echo "SUCCESS!"
else
        echo "Some error occurred."        
fi

echo

exit $EXITSTATUS
