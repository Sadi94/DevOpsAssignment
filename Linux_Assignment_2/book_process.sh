#!/usr/bin/env bash

# Ensure the file exists
if [ ! -f book.txt ]; then
  echo "book.txt not found!"
  exit 1
fi

# Create a temp file for lowercase and cleaned text
tmpfile=$(mktemp)

# Convert to lowercase and remove punctuation
tr '[:upper:]' '[:lower:]' < book.txt | tr -d '[:punct:]' > "$tmpfile"

echo " Word Frequencies "
tr ' ' '\n' < "$tmpfile" | grep -v '^$' | sort | uniq -c | sort -nr

echo
echo " Top 10 Most Frequent Words "
tr ' ' '\n' < "$tmpfile" | grep -v '^$' | sort | uniq -c | sort -nr | head -n 10

echo
echo " Sentences with Word Counts "
# For sentence splitting, we use the original text
awk -v RS='[.!?]' '
{
  gsub(/\n/, " ")
  n=split($0, words, /[[:space:]]+/)
  if(length($0)>0) {
    print "Sentence: \"" $0 "\""
    print "Word count: " n
    print ""
  }
}' book.txt

echo
echo " Sentences with More Than 10 Words "
awk -v RS='[.!?]' '
{
  gsub(/\n/, " ")
  n=split($0, words, /[[:space:]]+/)
  if(n > 10) {
    print "Sentence: \"" $0 "\""
    print "Word count: " n
    print ""
  }
}' book.txt

echo
echo " Average Number of Words Per Sentence "
awk -v RS='[.!?]' '
{
  gsub(/\n/, " ")
  if(length($0)>0) {
    n=split($0, words, /[[:space:]]+/)
    count++
    total += n
  }
}
END {
  if(count > 0) {
    print total / count
  } else {
    print "No sentences found."
  }
}' book.txt

# Clean up temp file
rm "$tmpfile"
