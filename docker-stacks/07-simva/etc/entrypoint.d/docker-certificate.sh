if [ ! -e "/usr/local/share/ca-certificates/internal-CA.crt" ]; then
  cp /var/lib/simva/ca/rootCA.pem "/usr/local/share/ca-certificates/internal-CA.crt";
  update-ca-certificates;
  cat /etc/ca-certificates.conf;
  echo "Certificate added!";
else 
  echo "Certificate already present!";
fi;