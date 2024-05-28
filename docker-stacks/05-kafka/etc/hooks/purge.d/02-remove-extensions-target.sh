# Removing Extension data
for extension in $(find "${STACK_HOME}/extensions/kafka-connect-storage-common" -mindepth 1 -maxdepth 1 -type d); do
    if [[ -e "${extension}/target" ]]; then
        rm -rf  "${extension}/target"
        ./*
    fi
done