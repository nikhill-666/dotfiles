#!/bin/bash

# Generate two random numbers
# The first number will be a 3-digit number between 100 and 999
num1=$((RANDOM % 900 + 100))

# The second number will be a 3-digit number between 100 and 999
num2=$((RANDOM % 900 + 100))

# Print the formatted string to standard output
echo "[#trmnl c-0${num1}: l-${num2}]"