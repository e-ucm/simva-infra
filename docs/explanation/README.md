# Explanation

Explanation is for **understanding**, not for doing. It answers *why* SIMVA is built the way
it is: why a numbered stack layout, why one shared network, why hooks instead of cron, why
environment variables instead of editor-shipped config files.

These pages assume you have operated an environment at least once (the
[tutorials](../tutorials/README.md)) or that you do not mind reading without running
anything.

| Page | Answers |
| --- | --- |
| [architecture.md](./architecture.md) | how the whole system is put together, briefly |
| [networking-and-tls.md](./networking-and-tls.md) | why there is one bridge, one entrypoint and host-managed certificates |
| [configuration-and-state.md](./configuration-and-state.md) | why configuration is the environment, and state lives in markers and named volumes |
| [decisions/](./decisions/README.md) | the Architecture Decision Records, in chronological order |