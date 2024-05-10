#!/bin/ash

if [ "$1" = "model" ]; then
  echo "CR-K1"
elif [ "$1" = "board" ]; then
  echo "CR4CU220812S12"
elif [ "$1" = "structure_version" ]; then
  echo "0"
else
  echo ""
fi
