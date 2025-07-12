#!/usr/bin/env node

const { execSync, spawn } = require("child_process");
const path = require("path");
const fs = require("fs");
const os = require("os");
const MountUtils = require("./mount-utils");

class AgentRunner {
	constructor() {
		// Use repository name to create unique workspace directory
		const repoName = this.getRepoName();
		this.workspaceDir = path.resolve(
			process.env.HOME,
			".local",
			"share",
			"agent-workspaces",
			repoName,
		);
		this.tempDockerfile = null;
		this.mountPresets = [];
		this.customMounts = [];

		// Get current directory relative to git root
		this.gitRoot = this.getGitRoot();
		this.currentDir = process.cwd();
		this.relativeToGitRoot = path.relative(this.gitRoot, this.currentDir);
	}

	getRepoName() {
		try {
			const remoteUrl = execSync("git config --get remote.origin.url", {
				encoding: "utf8",
			}).trim();
			const match = remoteUrl.match(/\/([^\/]+?)(?:\.git)?$/);
			if (match) {
				return match[1];
			}
		} catch (error) {
			// Fallback to directory name if no remote
		}

		// Fallback to current directory name
		return path.basename(this.getGitRoot());
	}

	getGitRoot() {
		try {
			return execSync("git rev-parse --show-toplevel", {
				encoding: "utf8",
			}).trim();
		} catch (error) {
			throw new Error("Not in a git repository");
		}
	}

	async run() {
		try {
			const args = this.parseArgs();
			const command = args.command;
			const agentName = args.agentName;

			this.validateEnvironment();

			if (command === "clean") {
				await this.cleanupAgent(agentName);
			} else if (command === "list") {
				await this.listAgents();
			} else {
				await this.setupGitWorktree(agentName);
				await this.startContainer(agentName);
			}
		} catch (error) {
			console.error("Error:", error.message);
			process.exit(1);
		}
	}

	parseArgs() {
		const args = process.argv.slice(2);

		if (args.length === 0) {
			this.showUsage();
			process.exit(1);
		}

		// Check for help first
		if (args.includes("--help") || args.includes("-h")) {
			this.showUsage();
			process.exit(0);
		}

		let command = "start";
		let agentName;
		let i = 0;

		// Parse command
		if (args[0] === "clean" || args[0] === "list") {
			command = args[0];
			i = 1;
		}

		// Parse agent name (required for start and clean commands)
		if (command !== "list") {
			if (i >= args.length || args[i].startsWith("--")) {
				throw new Error(`Agent name is required for '${command}' command`);
			}
			agentName = args[i];
			i++;
		}

		// Parse mount options
		while (i < args.length) {
			const arg = args[i];

			if (arg.startsWith("--mount=")) {
				const mountSpec = arg.substring(8);
				const mount = MountUtils.parseCustomMount(mountSpec);
				this.customMounts.push(mount);
			} else if (arg.startsWith("--mounts=")) {
				const presets = arg.substring(9).split(",");
				this.mountPresets.push(...presets);
			} else {
				throw new Error(`Unknown argument: ${arg}`);
			}
			i++;
		}

		if (agentName && !/^[a-zA-Z0-9-_]+$/.test(agentName)) {
			throw new Error(
				"Agent name can only contain letters, numbers, hyphens, and underscores",
			);
		}

		return { command, agentName };
	}


	showUsage() {
		console.log(`
Usage: ./agent-runner.js <command> [options]

Commands:
  <agent-name>              Start or resume an agent
  clean <agent-name>        Clean up an agent's worktree
  list                      List all agents

Mount Options:
  --mounts=<presets>        Enable mount presets (comma-separated)
                            Available: ${Object.keys(MountUtils.getPresets()).join(", ")}
  --mount=<spec>            Custom mount (source:target[:readonly])

Examples:
  ./agent-runner.js my-agent
  ./agent-runner.js my-agent --mounts=git,ssh,aws
  ./agent-runner.js my-agent --mount=~/data:/workspace/data:readonly
  ./agent-runner.js clean my-agent
  ./agent-runner.js list

Mount Presets:
${Object.entries(MountUtils.getPresets())
	.map(([name, preset]) => `  ${name.padEnd(8)} ${preset.description}`)
	.join("\n")}
`);
	}

	validateEnvironment() {
		// Check if we're in a git repository
		try {
			execSync("git rev-parse --git-dir", { stdio: "ignore" });
		} catch {
			throw new Error("Not in a git repository");
		}

		// Check if Docker is available
		try {
			execSync("docker --version", { stdio: "ignore" });
		} catch {
			throw new Error("Docker is not available");
		}

		// Check if mise config exists
		const miseConfigs = [".mise.toml", ".tool-versions"];
		const hasMiseConfig = miseConfigs.some((config) => fs.existsSync(config));
		if (!hasMiseConfig) {
			console.warn(
				"Warning: No mise configuration found (.mise.toml or .tool-versions)",
			);
		}

		// Validate mount presets and custom mounts
		MountUtils.validateMounts(this.mountPresets, this.customMounts);
	}


	async setupGitWorktree(agentName) {
		const branchName = `feature/agent-${agentName}`;
		const worktreePath = path.join(this.workspaceDir, agentName);

		// Ensure workspace directory exists
		if (!fs.existsSync(this.workspaceDir)) {
			fs.mkdirSync(this.workspaceDir, { recursive: true });
		}

		// Check if worktree already exists (for resuming work)
		if (fs.existsSync(worktreePath)) {
			console.log(`Resuming existing worktree at '${worktreePath}'...`);
			// Verify it's a valid worktree
			try {
				execSync(`git -C "${worktreePath}" status`, { stdio: "ignore" });
				console.log("Existing worktree is valid, ready to resume");
				return;
			} catch (error) {
				console.log(
					"Existing worktree is corrupted, removing and recreating...",
				);
				try {
					execSync(`git worktree remove "${worktreePath}" --force`, {
						stdio: "ignore",
					});
				} catch (removeError) {
					// If git worktree remove fails, manually remove directory
					fs.rmSync(worktreePath, { recursive: true, force: true });
				}
			}
		}

		// Check if branch already exists
		let branchExists = false;
		try {
			const branches = execSync("git branch --list", { encoding: "utf8" });
			branchExists = branches.includes(branchName);
		} catch (error) {
			// Ignore error, assume branch doesn't exist
		}

		console.log(
			`Creating ${branchExists ? "worktree from existing branch" : "branch and worktree"} at '${worktreePath}'...`,
		);

		// Create worktree (with or without new branch)
		if (branchExists) {
			execSync(`git worktree add "${worktreePath}" "${branchName}"`, {
				stdio: "inherit",
			});
		} else {
			execSync(`git worktree add "${worktreePath}" -b "${branchName}"`, {
				stdio: "inherit",
			});
		}

		console.log("Git worktree ready");
	}

	async startContainer(agentName) {
		const worktreePath = path.join(this.workspaceDir, agentName);
		const containerName = `agent-${agentName}`;

		try {
			// Create temporary Dockerfile
			this.createTempDockerfile();

			console.log(`Starting container '${containerName}'...`);

			// Build Docker image with temporary Dockerfile
			execSync(`docker build -f "${this.tempDockerfile}" -t agent-dev .`, {
				stdio: "inherit",
			});

			// Get npm cache directory
			let npmCacheDir;
			try {
				npmCacheDir = execSync("npm config get cache", {
					encoding: "utf8",
				}).trim();
			} catch (error) {
				npmCacheDir = path.join(os.homedir(), ".npm"); // fallback
			}

			// Get mount arguments
			const mountArgs = MountUtils.getMountArguments(this.mountPresets, this.customMounts);

			// Show mount information if any mounts are configured
			MountUtils.showMountInfo(mountArgs);

			// Calculate working directory inside container
			const containerWorkDir = this.relativeToGitRoot
				? `/workspace/${this.relativeToGitRoot}`
				: "/workspace";

			// Run container with worktree mounted
			const dockerArgs = [
				"run",
				"-it",
				"--rm",
				"--name",
				containerName,
				"-v",
				`${worktreePath}:/workspace`,
				"-v",
				`${process.env.HOME}/.local/share/mise:/home/devuser/.local/share/mise`,
				"-v",
				`${npmCacheDir}:/home/devuser/.npm`, // npm cache for faster npx
				...mountArgs, // Add user-specified mounts
				"-w",
				containerWorkDir,
				"agent-dev",
				"bash",
				"-c",
				'eval "$(mise activate bash)" && (mise install 2>/dev/null || echo "No mise config found, skipping tool installation") && mise trust && exec bash',
			];

			console.log("Container is starting...");
			if (this.relativeToGitRoot) {
				console.log(
					`📂 Working directory: /workspace/${this.relativeToGitRoot}`,
				);
			}
			console.log('Run "exit" to stop the container and cleanup');

			// Start container interactively
			const containerProcess = spawn("docker", dockerArgs, {
				stdio: "inherit",
				detached: false,
			});

			containerProcess.on("close", (code) => {
				console.log(`\nContainer exited with code ${code}`);
				// Only cleanup temporary files, keep worktree for resuming work
				this.cleanupTempFiles();
				console.log(
					'Work preserved. Use the same command to resume or "clean" to remove worktree.',
				);
			});
		} catch (error) {
			this.cleanupTempFiles();
			throw error;
		}
	}

	createTempDockerfile() {
		const timestamp = Date.now();
		const randomId = Math.random().toString(36).substring(2, 8);
		const tempDir = os.tmpdir();
		this.tempDockerfile = path.join(
			tempDir,
			`Dockerfile-agent-${timestamp}-${randomId}`,
		);

		console.log("Creating temporary Dockerfile...");
		const dockerfileContent = `FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    curl \\
    git \\
    build-essential \\
    sudo \\
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash devuser && \\
    usermod -aG sudo devuser && \\
    echo 'devuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to non-root user
USER devuser
WORKDIR /home/devuser

# Install mise for the user
ENV MISE_VERSION=2025.6.8
RUN curl https://mise.run | sh
ENV PATH="/home/devuser/.local/bin:$PATH"

# Install Node.js globally via mise for npx availability
RUN /home/devuser/.local/bin/mise use -g node@20

# Initialize mise in bash profile
RUN echo 'eval "$(mise activate bash)"' >> /home/devuser/.bashrc

# Add aliases for common tools
RUN echo "alias claude='npx @anthropic-ai/claude-code'" >> /home/devuser/.bashrc
RUN echo "alias claude-yolo='npx @anthropic-ai/claude-code --dangerously-skip-permissions'" >> /home/devuser/.bashrc
RUN echo "alias gemini='npx @google/gemini-cli'" >> /home/devuser/.bashrc
RUN echo "alias gemini-yolo='npx @google/gemini-cli --yolo'" >> /home/devuser/.bashrc

# Set working directory
WORKDIR /workspace

# Default command
CMD ["bash"]
`;
		fs.writeFileSync(this.tempDockerfile, dockerfileContent);
		console.log(`Temporary Dockerfile created: ${this.tempDockerfile}`);
	}

	cleanupTempFiles() {
		if (this.tempDockerfile && fs.existsSync(this.tempDockerfile)) {
			try {
				fs.unlinkSync(this.tempDockerfile);
				console.log("Temporary Dockerfile cleaned up");
			} catch (error) {
				console.warn("Failed to cleanup temporary Dockerfile:", error.message);
			}
		}
	}

	async cleanupAgent(agentName) {
		const worktreePath = path.join(this.workspaceDir, agentName);
		const branchName = `feature/agent-${agentName}`;

		console.log(`Cleaning up agent '${agentName}'...`);

		try {
			// Remove worktree
			if (fs.existsSync(worktreePath)) {
				try {
					execSync(`git worktree remove "${worktreePath}" --force`, {
						stdio: "ignore",
					});
					console.log("Worktree removed");
				} catch (error) {
					// If git worktree remove fails, manually remove directory
					fs.rmSync(worktreePath, { recursive: true, force: true });
					console.log("Worktree directory removed manually");
				}
			} else {
				console.log("No worktree found to remove");
			}

			// Cleanup temporary files
			this.cleanupTempFiles();

			// Ask user if they want to remove the branch
			console.log(`\nBranch '${branchName}' still exists.`);
			console.log("To remove it manually, run:");
			console.log(`  git branch -D ${branchName}`);

			console.log("Cleanup completed");
		} catch (error) {
			console.error("Cleanup failed:", error.message);
		}
	}

	async listAgents() {
		const repoName = this.getRepoName();
		console.log(`\nAgents for repository: ${repoName}`);
		console.log("=" + "=".repeat(30 + repoName.length));

		// Check if workspace directory exists
		if (!fs.existsSync(this.workspaceDir)) {
			console.log("No agents found.");
			return;
		}

		try {
			const agents = fs
				.readdirSync(this.workspaceDir, { withFileTypes: true })
				.filter((dirent) => dirent.isDirectory())
				.map((dirent) => dirent.name);

			if (agents.length === 0) {
				console.log("No agents found.");
				return;
			}

			console.log(`\nFound ${agents.length} agent(s):\n`);

			for (const agentName of agents) {
				const worktreePath = path.join(this.workspaceDir, agentName);
				const branchName = `feature/agent-${agentName}`;

				// Check worktree status
				let status = "Unknown";
				let lastCommit = "";
				let uncommittedChanges = false;

				try {
					// Check if worktree is valid
					execSync(`git -C "${worktreePath}" status`, { stdio: "ignore" });

					// Get last commit info
					const commitInfo = execSync(
						`git -C "${worktreePath}" log -1 --format="%h - %s (%cr)"`,
						{ encoding: "utf8" },
					).trim();
					lastCommit = commitInfo;

					// Check for uncommitted changes
					const statusOutput = execSync(
						`git -C "${worktreePath}" status --porcelain`,
						{ encoding: "utf8" },
					);
					uncommittedChanges = statusOutput.trim().length > 0;

					status = uncommittedChanges ? "Modified" : "Clean";
				} catch (error) {
					status = "Invalid";
				}

				// Check if branch exists
				let branchExists = false;
				try {
					const branches = execSync("git branch --list", { encoding: "utf8" });
					branchExists = branches.includes(branchName);
				} catch (error) {
					// Ignore error
				}

				console.log(`📁 ${agentName}`);
				console.log(`   Path: ${worktreePath}`);
				console.log(`   Branch: ${branchName} ${branchExists ? "✓" : "✗"}`);
				console.log(
					`   Status: ${status}${uncommittedChanges ? " (has changes)" : ""}`,
				);
				if (lastCommit) {
					console.log(`   Last commit: ${lastCommit}`);
				}
				console.log("");
			}

			console.log("Commands:");
			console.log("  Resume work:  ./agent-runner.js <agent-name>");
			console.log("  Clean up:     ./agent-runner.js clean <agent-name>");
		} catch (error) {
			console.error("Failed to list agents:", error.message);
		}
	}
}

// Run the script
if (require.main === module) {
	const runner = new AgentRunner();
	runner.run();
}

module.exports = AgentRunner;
