FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y \
      sqlite3 \
      curl \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install mysql2sqlite (script)
RUN curl -L https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite \
    -o /usr/local/bin/mysql2sqlite && \
    chmod +x /usr/local/bin/mysql2sqlite

WORKDIR /data

ENTRYPOINT ["/bin/bash"]
