#!/bin/bash

# Infrastructure Reliability Health Check
# Author: Tanaka Kambasha

# Health thresholds
MEM_WARN="${MEM_WARN:-80}"
MEM_CRIT="${MEM_CRIT:-90}"

DISK_WARN="${DISK_WARN:-80}"
DISK_CRIT="${DISK_CRIT:-90}"

OVERALL_STATUS=0

echo "=========================================="
echo " INFRASTRUCTURE RELIABILITY HEALTH CHECK"
echo "=========================================="

echo ""
echo "Hostname:"
hostname

echo ""
echo "Current Date:"
date

echo ""
echo "System Uptime:"
uptime

echo ""
echo "Operating System:"
cat /etc/redhat-release

echo ""
echo "CPU Information:"
echo "CPU Cores: $(nproc)"
echo "Load Average: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"

echo ""
echo "Memory Usage:"
free -h

MEM_USED_PERCENT=$(awk '
/MemTotal:/ { total=$2 }
/MemAvailable:/ { available=$2 }
END {
    printf "%.0f", ((total-available)/total)*100
}' /proc/meminfo)

echo "Memory Used: ${MEM_USED_PERCENT}%"

if [ "$MEM_USED_PERCENT" -ge "$MEM_CRIT" ]; then
    echo "Memory Status: CRITICAL"
    OVERALL_STATUS=2

elif [ "$MEM_USED_PERCENT" -ge "$MEM_WARN" ]; then
    echo "Memory Status: WARNING"

    if [ "$OVERALL_STATUS" -lt 1 ]; then
        OVERALL_STATUS=1
    fi

else
    echo "Memory Status: OK"
fi

echo ""
echo "Filesystem Usage:"

df -h \
    -x tmpfs \
    -x devtmpfs \
    -x iso9660 \
    -x squashfs \
    -x efivarfs

echo ""
echo "Filesystem Health:"

while read -r usage mountpoint
do
    percent=${usage%\%}

    if [ "$percent" -ge "$DISK_CRIT" ]; then

        echo "$mountpoint: ${percent}% - CRITICAL"
        OVERALL_STATUS=2

    elif [ "$percent" -ge "$DISK_WARN" ]; then

        echo "$mountpoint: ${percent}% - WARNING"

        if [ "$OVERALL_STATUS" -lt 1 ]; then
            OVERALL_STATUS=1
        fi

    else

        echo "$mountpoint: ${percent}% - OK"

    fi

done < <(
    df -P \
        -x tmpfs \
        -x devtmpfs \
        -x iso9660 \
        -x squashfs \
        -x efivarfs \
        | awk 'NR > 1 {print $5, $6}'
)

echo ""
echo "=========================================="
echo " OVERALL HEALTH"
echo "=========================================="

case "$OVERALL_STATUS" in

    0)
        echo "Status: OK"
        ;;

    1)
        echo "Status: WARNING"
        ;;

    2)
        echo "Status: CRITICAL"
        ;;

esac

exit "$OVERALL_STATUS"