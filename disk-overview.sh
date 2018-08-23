#!/bin/bash

# colors

BOLD=$(echo -e '\e[1m')
RESET=$(echo -e '\e[m')
GREEN=$(echo -e '\e[38;5;2m')
RED=$(echo -e '\e[38;5;1m')
GREY=$(echo -e '\e[38;5;8m')
PURPLE=$(echo -e '\e[38;5;5m')

# disk usage

echo "$BOLD${GREEN}Disk usage:$RESET"
echo "$GREY-----------$RESET"

AWK_S='/dev\/sd/ {print B P $6 R, " ", B $5 R, " ", $3, "/", $2, G $1}'
df -h | awk          \
	-v B=$BOLD   \
	-v R=$RESET  \
	-v P=$PURPLE \
	-v G=$GREY   \
	"$AWK_S"     \
	2>/dev/null  \
      | column -t
echo ""
# disk health

echo "$BOLD${GREEN}Disk health:$RESET"
echo "$GREY-------------$RESET"

get_drive_info() {
	# drive name
	echo "${BOLD}${PURPLE}$1${RESET}:"
	
	# health test
	echo -ne "\tHealth test: "
	RESULT=$(smartctl -H $1 | grep test | awk '{print $NF}')
	if [ $RESULT = "PASSED" ];
	then echo "${GREEN}$RESULT${RESET}";
	else echo "${BOLD}${RED}$RESULT${RESET}";
	fi;
	
	# temperature
	echo -ne "\tTemperature: "
	TEMP=$(smartctl -a $1 | grep -i temp | grep -i always)
	TEMP_CURRENT=$(echo $TEMP | awk '{print $10}')
	TEMP_RANGE=$(echo $TEMP | awk '{print $12}' \
		| awk '{gsub(/\//, " "); gsub(/\)/, ""); print}')
	TEMP_MIN=$(echo $TEMP_RANGE | awk '{print $1}')
	TEMP_MAX=$(echo $TEMP_RANGE | awk '{print $2}')
	if [ "$TEMP_CURRENT" -lt "$TEMP_MAX" ] && \
	   [ "$TEMP_CURRENT" -gt "$TEMP_MIN" ];
	then echo -n "${GREEN}$TEMP_CURRENT${RESET}";
	else echo -n "${BOLD}${RED}$TEMP_CURRENT${RESET}";
	fi;
	echo "${GREY} (range: $TEMP_MIN - $TEMP_MAX) $RESET"; 
}

get_drive_info /dev/sda
get_drive_info /dev/sdb
get_drive_info /dev/sdc
get_drive_info /dev/sdd
get_drive_info /dev/sde
