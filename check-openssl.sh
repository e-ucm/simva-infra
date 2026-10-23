echo "=== Checking all PEM files for notAfter date (excluding -key.pem) ==="
expired_files=()

for pemfile in ${1:-/home/ucm}/*.pem; do
	if [[ "$pemfile" == *-key.pem ]]; then
		continue
	fi
	if [[ "$pemfile" == *-privkey.pem ]]; then
		continue
	fi
    echo "----------------------------------------"
	echo "File: $pemfile"
	enddate=$(openssl x509 -noout -enddate -in "$pemfile" | cut -d= -f2)
	enddate_epoch=$(date -d "$enddate" +%s)
	now_epoch=$(date +%s)
    echo "End Date: $enddate"
    echo ""
	openssl x509 -noout -issuer -dates -subject -in "$pemfile"
	if [ "$enddate_epoch" -le "$now_epoch" ]; then
		expired_files+=("$pemfile")
	fi
done

if [ ${#expired_files[@]} -gt 0 ]; then
	echo "\n=== Expired Certificates ==="
	for file in "${expired_files[@]}"; do
		echo "$file"
	done
    exit 1
else
	echo "\nNo expired certificates found."
    exit 0
fi