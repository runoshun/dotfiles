# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI agent container execution system (`agent-docker`) that creates isolated Docker environments for running AI agents. The system uses Git worktrees to provide persistent workspaces and mise for development environment management.

## Core Architecture

- **agent-runner.js**: Main orchestration script for creating and managing agent containers
- **Git worktrees**: Each agent gets its own worktree in `../agent-workspaces/<repo-name>/`
- **Docker containers**: Ubuntu 22.04 base with mise for tool management
- **Persistent workspaces**: Work is preserved between container sessions

## Common Commands

### Starting/Resuming an Agent
```bash
./agent-runner.js <agent-name>
```

### Listing All Agents
```bash
./agent-runner.js list
```

### Cleaning Up an Agent
```bash
./agent-runner.js clean <agent-name>
```

### Testing the Environment
```bash
node test-app.js
```

## Development Environment

- **Tool management**: mise with Node.js 20 and Python 3.11 (configured in `.mise.toml`)
- **Container base**: Ubuntu 22.04 with build-essential, git, curl
- **User setup**: Non-root user `devuser` with sudo access
- **Mount points**: 
  - Worktree: `/workspace` (working directory)
  - Mise cache: `~/.local/share/mise` (for persistence)

## Key Implementation Details

### Worktree Management
- Branch naming: `feature/agent-<agent-name>`
- Workspace path: `../agent-workspaces/<repo-name>/<agent-name>`
- Automatic corruption detection and recovery
- Supports multiple repositories with same agent names

### Container Lifecycle
- Temporary Dockerfiles generated in `/tmp/Dockerfile-agent-*`
- Interactive bash session with mise environment
- Automatic cleanup of temporary files on exit
- Work preservation for resuming sessions

### Validation Requirements
- Must be run from within a Git repository
- Docker must be available and running
- Agent names: alphanumeric, hyphens, underscores only

## File Structure

- Root directory contains the main script and configuration
- Temporary Dockerfiles are auto-generated and cleaned up
- Agent workspaces are created outside the main repository
- Branch management is separate from worktree cleanup