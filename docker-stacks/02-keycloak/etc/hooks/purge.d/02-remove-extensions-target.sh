# Removing Extension data
EXTENSIONS_DIR="${STACK_HOME}/extensions"
for extension in $(find ${EXTENSIONS_DIR} -mindepth 1 -maxdepth 1 -type d); do
    cd "${extension}/target"
    rm -rf ./*
done