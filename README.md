# opensips-bats

Automated testing framework for [OpenSIPS](https://opensips.org/) using [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System). The project spins up a containerized SIP environment with Docker Compose and validates OpenSIPS routing behavior through real SIP traffic.

## Architecture

```
┌─────────┐         ┌──────────────┐         ┌─────────┐
│  uac01  │──INVITE─▶  opensips01  │──INVITE─▶  uas01  │
│ (SIPp)  │◀────────│  (SIP Proxy) │◀────────│ (SIPp)  │
└─────────┘         └──────┬───────┘         └─────────┘
                           │
                    ┌──────┴──────┐
                    │   tcpdump   │
                    │  (capture)  │
                    └─────────────┘
```

- **opensips01** - OpenSIPS proxy under test (residential proxy configuration)
- **uac01** - SIPp UAC (caller) that initiates SIP calls
- **uas01** - SIPp UAS (callee) that answers SIP calls
- **tcpdump** - Packet capture sidecar for debugging

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with the [Compose plugin](https://docs.docker.com/compose/install/)
- Bash

## Getting Started

Clone the repository with submodules:

```bash
git clone --recurse-submodules https://github.com/nuno-ferreira-five9/opensips-bats
cd opensips-bats
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

## Running Tests

Run all tests:

```bash
./tests/run_tests.sh
```

Run tests filtered by tag:

```bash
./tests/run_tests.sh --filter-tags 001
```

Run tests in parallel:

```bash
./tests/run_tests.sh --jobs 2
```

Test results are saved to `tests/results/`, including:
- `report.xml` - JUnit XML report
- Per-test directories with container logs and `.pcap` packet captures

## Project Structure

```
opensips-bats/
├── Dockerfile                  # Builds the OpenSIPS container image
├── src/
│   └── opensips/
│       └── opensips.cfg        # OpenSIPS routing configuration
└── tests/
    ├── run_tests.sh            # Entry point to run all tests
    ├── setup.bash              # Suite-level setup/teardown hooks
    ├── tools.bash              # Shared helper functions
    ├── 001-tests.bats          # Test cases
    ├── compose.yml             # Docker Compose environment
    ├── helpers/
    │   └── sipp/
    │       ├── basic_uac.xml   # SIPp caller scenario
    │       └── basic_uas.xml   # SIPp callee scenario
    ├── libs/                   # Git submodules (bats-core, bats-assert, bats-support)
    └── results/                # Test output (gitignored)
```

## Tests

| Tag | Test | Description |
|-----|------|-------------|
| `000` | bats version | Validates BATS >= 1.13.0 |
| `000` | docker is installed | Checks Docker is available |
| `000` | docker compose is available | Checks Docker Compose plugin |
| `000` | check opensips version | Verifies OpenSIPS starts correctly |
| `001` | UAC can successfully make a call (inline) | End-to-end SIP INVITE call flow |
| `002` | UAC can successfully make a call (refactored) | Same test using shared helper functions |

## Helper Functions (`tools.bash`)

| Function | Description |
|----------|-------------|
| `start_containers <name>` | Starts Docker Compose and waits for the named service to exit |
| `get_container_log <name>` | Saves container logs to the test artifacts directory |
| `assert_file_occurrences <file> <count> <pattern>` | Asserts a pattern appears exactly N times (or N+ for "at least N") in a file |

## Docker Images used

| Image | Purpose |
|-------|---------|
| `opensips/opensips` | Base image for the OpenSIPS proxy |
| `ctaloi/sipp` | SIPp for UAC/UAS traffic generation |
| `nicolaka/netshoot` | tcpdump packet captures |
