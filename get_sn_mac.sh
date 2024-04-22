#!/bin/ash

if [ "$1" = "model" ]; then
  echo "CR-K1"
elif [ "$1" = "board" ]; then
  echo "CR4CU220812S12"
else
  echo ""
fi
