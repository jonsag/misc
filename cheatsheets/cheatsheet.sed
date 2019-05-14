replace e with a
# echo test | sed -e 's/e/a/g'


replace all 'old' with new in file
$ sed -i 's/old/new/g' file.txt

examples:
sed -i 's/\ו/å/g' The.Hateful.Eight.2015.720p.BluRay.H264.AAC-RARBG.sv.srt
sed -i 's/\ה/ä/g' The.Hateful.Eight.2015.720p.BluRay.H264.AAC-RARBG.sv.srt
sed -i 's/\צ/ö/g' The.Hateful.Eight.2015.720p.BluRay.H264.AAC-RARBG.sv.srt

sed -i 's/\ײ/Ö/g' The.Hateful.Eight.2015.720p.BluRay.H264.AAC-RARBG.sv.srt


replace first 16 characters of every line with 'new text'
$ sed -r "s/^(.{0})(.{16})/\new text/" infile.txt >> outfile.txt


delete everything after and including last occurence of character '-'
$ sed 's/\(.*\)-.*/\1/' infile.txt >> outfile.txt


rm emerge.txt
rm emerge.list
sed -r "s/^(.{0})(.{16})/\emerge -1 --nodeps /" emerge.log >> emerge.txt
sed 's/\(.*\)-.*/\1/' emerge.txt >> emerge.list


delete all leading space
$ cat file | sed -e 's/^[ \t]*//'


add two spaces at end of each line
$ sed 's/$/  /' filename > newfilename


if line starts with $, then substitute with >$
$ sed '/^\$/s/^\$/>\$/' file
$ sed '/^start_string/s/search_string/replace_string/'

sed -i.bak2 '/^#/s/^#/>\\#/'


edit file in place
$ sed -i 

example
$ cat foo.txt
hello world
$ sed -i 's/o/X/g' foo.txt
$ cat foo.txt
hellX wXrld

edit file in place and save backup as .bak
$ sed -i.bak