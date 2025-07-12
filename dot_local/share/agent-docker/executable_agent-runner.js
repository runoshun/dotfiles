#!/usr/bin/env node

const { execSync, spawn } = require("child_process");
const path = require("path");
const fs = require("fs");
const os = require("os");
const MountUtils = require("./mount-utils");

function parseArgs() {
	const args = process.argv.slice(2);

	if (args.length === 0) {
		showUsage();
		process.exit(1);
	}

	// Check for help first
	if (args.includes("--help") || args.includes("-h")) {
		showUsage();
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
	const mountPresets = [];
	const customMounts = [];
	while (i < args.length) {
		const arg = args[i];

		if (arg.startsWith("--mount=")) {
			const mountSpec = arg.substring(8);
			const mount = MountUtils.parseCustomMount(mountSpec);
			customMounts.push(mount);
		} else if (arg.startsWith("--mounts=")) {
			const presets = arg.substring(9).split(",");
			mountPresets.push(...presets);
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

	return { command, agentName, mountPresets, customMounts };
}

function showUsage() {
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

class AgentRunner {
	constructor(args) {
		// Parse arguments first
		this.command = args.command;
		this.agentName = args.agentName;
		this.mountPresets = args.mountPresets;
		this.customMounts = args.customMounts;

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

	getAgentPaths(agentName) {
		const agentDir = path.join(this.workspaceDir, agentName);
		return {
			agentDir: agentDir,
			originalDir: path.join(agentDir, "original"),
			copiesDir: path.join(agentDir, "copies"),
			tempBundle: path.join(agentDir, "temp.bundle"),
			outputBundle: path.join(agentDir, "output.bundle"),
		};
	}

	// Common cleanup operations
	async removeWorktree(worktreePath) {
		try {
			execSync(`git worktree remove "${worktreePath}" --force`, {
				stdio: "ignore",
			});
		} catch (error) {
			// If git worktree remove fails, manually remove directory
			fs.rmSync(worktreePath, { recursive: true, force: true });
		}
	}

	async removeAgentDirectory(agentDir) {
		if (fs.existsSync(agentDir)) {
			fs.rmSync(agentDir, { recursive: true, force: true });
		}
	}

	async pruneWorktrees() {
		try {
			execSync("git worktree prune", { stdio: "ignore" });
		} catch (error) {
			// Ignore prune errors
		}
	}

	// Generate Dockerfile content
	generateDockerfileContent() {
		return `FROM ubuntu:22.04

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

# Configure git for container use
RUN git config --global user.name "Agent User" && \\
    git config --global user.email "agent@container.local" && \\
    git config --global --add safe.directory "*" && \\
    git config --global core.filemode false

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
	}

	async run() {
		try {
			this.validateEnvironment();

			if (this.command === "clean") {
				await this.cleanupAgent(this.agentName);
			} else if (this.command === "list") {
				await this.listAgents();
			} else {
				try {
					// Setup phase
					await this.setupWorktree(this.agentName);
					await this.setupCopyRepository(this.agentName);
					
					// Container phase
					await this.runContainer(this.agentName);
					
					// Merge phase
					await this.mergeCopyToWorktree(this.agentName);
				} finally {
					// Cleanup phase
					this.cleanupTempFiles();
				}
			}
		} catch (error) {
			console.error("Error:", error.message);
			process.exit(1);
		}
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


	async setupWorktree(agentName) {
		const branchName = `feature/agent-${agentName}`;
		const { agentDir, originalDir } = this.getAgentPaths(agentName);

		// Ensure agent directory exists
		if (!fs.existsSync(agentDir)) {
			fs.mkdirSync(agentDir, { recursive: true });
		}

		// Setup worktree
		if (fs.existsSync(originalDir)) {
			// Verify it's a valid worktree
			try {
				execSync(`git -C "${originalDir}" status`, { stdio: "ignore" });
				return; // Valid worktree exists
			} catch (error) {
				console.log("⚠️ Worktree corrupted, recreating...");
				try {
					execSync(`git worktree remove "${originalDir}" --force`, { stdio: "ignore" });
				} catch (removeError) {
					fs.rmSync(originalDir, { recursive: true, force: true });
				}
			}
		}

		await this.createWorktree(branchName, originalDir);
	}

	async setupCopyRepository(agentName) {
		const { originalDir, copiesDir, tempBundle } = this.getAgentPaths(agentName);

		// Setup copy repository if it doesn't exist
		if (!fs.existsSync(copiesDir)) {
			console.log("📦 Creating workspace...");
			await this.createCopyRepository(originalDir, copiesDir, tempBundle);
		}
	}

	async createWorktree(branchName, originalDir) {
		// Check if branch already exists
		let branchExists = false;
		try {
			const branches = execSync("git branch --list", { encoding: "utf8" });
			branchExists = branches.includes(branchName);
		} catch (error) {
			// Ignore error, assume branch doesn't exist
		}

		// Create worktree (with or without new branch)
		if (branchExists) {
			execSync(`git worktree add "${originalDir}" "${branchName}"`, {
				stdio: "ignore",
			});
		} else {
			execSync(`git worktree add "${originalDir}" -b "${branchName}"`, {
				stdio: "ignore",
			});
		}
	}

	async createCopyRepository(originalDir, copiesDir, tempBundle) {
		try {
			// Create bundle from worktree
			execSync(`git -C "${originalDir}" bundle create "${tempBundle}" HEAD`, {
				stdio: "ignore",
			});

			// Clone from bundle to create copy repository
			execSync(`git clone "${tempBundle}" "${copiesDir}"`, {
				stdio: "ignore",
			});

			// Clean up temporary bundle
			fs.unlinkSync(tempBundle);
		} catch (error) {
			throw new Error(`Failed to create copy repository: ${error.message}`);
		}
	}


	async mergeCopyToWorktree(agentName) {
		const { originalDir, copiesDir, outputBundle } = this.getAgentPaths(agentName);

		// Check if there are any commits to merge
		try {
			// Check for uncommitted changes
			const hasUncommitted = execSync(`git -C "${copiesDir}" diff-index --quiet HEAD --; echo $?`, {
				encoding: "utf8"
			}).trim() !== "0";

			if (hasUncommitted) {
				console.log("未コミット変更があります。作業を保持してコンテナを終了します。");
				return;
			}

			// Check for new commits to merge by comparing with original repo's HEAD
			const originalHead = execSync(`git -C "${originalDir}" rev-parse HEAD`, {
				encoding: "utf8"
			}).trim();
			
			const newCommits = execSync(`git -C "${copiesDir}" rev-list HEAD ^${originalHead} --count 2>/dev/null || echo 0`, {
				encoding: "utf8"
			}).trim();

			if (parseInt(newCommits) === 0) {
				return;
			}

			console.log(`💾 ${newCommits} commits merged`);

			// Create bundle from copy repository
			execSync(`git -C "${copiesDir}" bundle create "${outputBundle}" HEAD`, {
				stdio: "ignore",
			});

			// Pull changes from bundle to worktree
			execSync(`git -C "${originalDir}" pull "${outputBundle}"`, {
				stdio: "ignore",
			});

			// Clean up the output bundle
			fs.unlinkSync(outputBundle);
		} catch (error) {
			console.warn(`マージに失敗しました: ${error.message}`);
			if (fs.existsSync(outputBundle)) {
				console.log(`出力バンドルを保持しました: ${outputBundle}`);
				console.log("手動でマージするには:");
				console.log(`  git -C "${originalDir}" pull "${outputBundle}"`);
			}
		}
	}

	async runContainer(agentName) {
		const { copiesDir } = this.getAgentPaths(agentName);
		const containerName = `agent-${agentName}`;

		try {
			// Create temporary Dockerfile
			this.createTempDockerfile();

			// Build Docker image with temporary Dockerfile
			execSync(`docker build -f "${this.tempDockerfile}" -t agent-dev .`, {
				stdio: "ignore",
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

			// Run container with copy repository mounted
			const dockerArgs = [
				"run",
				"-it",
				"--rm",
				"--name",
				containerName,
				"-v",
				`${copiesDir}:/workspace`,
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
				[
					// Setup mise environment
					'eval "$(mise activate bash)"',
					'(mise install 2>/dev/null || echo "No mise config found, skipping tool installation")',
					'mise trust',
					// Start interactive bash
					'exec bash'
				].join(' && '),
			];

			console.log("🚀 Starting container...");
			if (this.relativeToGitRoot) {
				console.log(`📂 Working in: /workspace/${this.relativeToGitRoot}`);
			}

			// Start container interactively and wait for completion
			return new Promise((resolve, reject) => {
				const containerProcess = spawn("docker", dockerArgs, {
					stdio: "inherit",
					detached: false,
				});

				containerProcess.on("close", (code) => {
					resolve(code);
				});

				containerProcess.on("error", (error) => {
					reject(error);
				});
			});
		} catch (error) {
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

		const dockerfileContent = this.generateDockerfileContent();
		fs.writeFileSync(this.tempDockerfile, dockerfileContent);
	}

	cleanupTempFiles() {
		if (this.tempDockerfile && fs.existsSync(this.tempDockerfile)) {
			try {
				fs.unlinkSync(this.tempDockerfile);
			} catch (error) {
				// Ignore cleanup errors
			}
		}
	}

	async cleanupAgent(agentName) {
		const { agentDir, originalDir } = this.getAgentPaths(agentName);
		const branchName = `feature/agent-${agentName}`;

		console.log(`Cleaning up agent '${agentName}'...`);

		try {
			// Remove worktree
			if (fs.existsSync(originalDir)) {
				await this.removeWorktree(originalDir);
			}

			// Remove agent directory (includes copies)
			await this.removeAgentDirectory(agentDir);

			// Cleanup temporary files
			this.cleanupTempFiles();

			// Prune orphaned worktree entries
			await this.pruneWorktrees();

			console.log(`✅ Cleaned up '${agentName}'`);
			console.log(`To remove branch: git branch -D ${branchName}`);
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
				const { originalDir } = this.getAgentPaths(agentName);
				const branchName = `feature/agent-${agentName}`;

				// Check worktree status
				let status = "Unknown";
				let lastCommit = "";
				let uncommittedChanges = false;

				try {
					// Check if worktree is valid
					execSync(`git -C "${originalDir}" status`, { stdio: "ignore" });

					// Get last commit info
					const commitInfo = execSync(
						`git -C "${originalDir}" log -1 --format="%h - %s (%cr)"`,
						{ encoding: "utf8" },
					).trim();
					lastCommit = commitInfo;

					// Check for uncommitted changes
					const statusOutput = execSync(
						`git -C "${originalDir}" status --porcelain`,
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

				const { copiesDir } = this.getAgentPaths(agentName);
				const hasCopyRepo = fs.existsSync(copiesDir);

				console.log(`📁 ${agentName}`);
				console.log(`   Worktree: ${originalDir}`);
				console.log(`   Copy repo: ${hasCopyRepo ? "✓" : "✗"}`);
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
	const args = parseArgs();
	const runner = new AgentRunner(args);
	runner.run();
}

module.exports = AgentRunner;
