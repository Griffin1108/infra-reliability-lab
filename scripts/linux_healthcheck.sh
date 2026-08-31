#!/bin/bash

# Infrastructure Reliability Health Check
# Author: Tanaka Kambasha

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

echo ""
echo "Filesystem Usage:"
df -h -x tmpfs -x devtmpfs