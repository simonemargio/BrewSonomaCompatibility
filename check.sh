#!/bin/bash

echo "Script execution started..."

touch .temp.json

formulas=$(brew list)
header="Formula"
status_header="Status"
max_formula_length=${#header}
max_status_length=${#status_header}

table=()

for formula in $formulas; do
  echo -ne "Checking formula: $formula\r"
  
  > .temp.json

  api_url="https://formulae.brew.sh/api/formula/$formula.json"
  curl -s "$api_url" -o .temp.json

  status="❓" 

  if grep -qEi "sonoma" .temp.json; then
    status="✅"
  elif grep -qEi "ventura" .temp.json; then
    status="❌"
  fi

  formula_length=${#formula}
  status_length=${#status}

  if [ $formula_length -gt $max_formula_length ]; then
    max_formula_length=$formula_length
  fi

  if [ $status_length -gt $max_status_length ]; then
    max_status_length=$status_length
  fi

  table+=("$formula" "$status")
done

rm .temp.json

printf "\n\n| %-$(($max_formula_length))s | %-$(($max_status_length))s |\n" "$header" "$status_header"

for ((i = 0; i < ${#table[@]}; i += 2)); do
  formula="${table[i]}"
  status="${table[i + 1]}"
  printf "| %-$(($max_formula_length))s | %-$(($max_status_length))s |\n" "$formula" "$status"
done

printf "\n\n✅: Sonoma supported\n❌: Sonoma unsupported\n❓: No info"
