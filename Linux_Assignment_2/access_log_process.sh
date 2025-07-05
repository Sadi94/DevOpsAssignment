#!/usr/bin/env bash

# Ensure the file exists
if [ ! -f access.log ]; then
  echo "access.log not found!"
  exit 1
fi

echo "========== Unique IP addresses and their counts =========="
awk '{print $1}' access.log | sort | uniq -c | sort -nr

echo
echo "========== IP address with the most requests =========="
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -n 1

echo
echo "========== All unique endpoints =========="
awk '{print $7}' access.log | sort | uniq

echo
echo "========== Endpoint request counts (ascending order) =========="
awk '{print $7}' access.log | sort | uniq -c | sort -n

