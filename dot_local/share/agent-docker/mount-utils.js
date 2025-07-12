const fs = require("fs");
const path = require("path");
const os = require("os");

// Mount presets for common development tools
const MOUNT_PRESETS = {
	git: {
		files: [
			{
				source: "~/.gitconfig",
				target: "/home/devuser/.gitconfig",
				readonly: true,
			},
			{
				source: "~/.gitignore_global",
				target: "/home/devuser/.gitignore_global",
				readonly: true,
			},
		],
		description: "Git configuration and global ignore files",
	},

	ssh: {
		files: [{ source: "~/.ssh", target: "/home/devuser/.ssh", readonly: true }],
		description: "SSH keys and configuration",
	},

	aws: {
		files: [{ source: "~/.aws", target: "/home/devuser/.aws", readonly: true }],
		description: "AWS CLI credentials and configuration",
	},

	docker: {
		files: [
			{
				source: "/var/run/docker.sock",
				target: "/var/run/docker.sock",
				readonly: false,
			},
		],
		description: "Docker socket for Docker-in-Docker",
	},

	npm: {
		files: [
			{ source: "~/.npmrc", target: "/home/devuser/.npmrc", readonly: true },
		],
		description: "NPM configuration and registry settings",
	},

	claude: {
		files: [
			{
				source: "~/.config/claude",
				target: "/home/devuser/.config/claude",
				readonly: true,
			},
			{
				source: "~/.claude.json",
				target: "/home/devuser/.claude.json",
				readonly: false,
			},
			{ source: "~/.claude", target: "/home/devuser/.claude", readonly: false },
		],
		description:
			"Claude Code configuration, API keys, credentials, and project settings",
	},

	gemini: {
		files: [
			{ source: "~/.gemini", target: "/home/devuser/.gemini" },
			{
				source: "~/.config/gcloud",
				target: "/home/devuser/.config/gcloud",
				readonly: true,
			},
		],
		description: "Gemini CLI and Google Cloud authentication settings",
	},
};

class MountUtils {
	static parseCustomMount(mountSpec) {
		const parts = mountSpec.split(":");
		if (parts.length < 2 || parts.length > 3) {
			throw new Error("Mount format: source:target[:readonly]");
		}

		return {
			source: parts[0],
			target: parts[1],
			readonly: parts.length === 3 && parts[2] === "readonly",
		};
	}

	static validateMounts(mountPresets, customMounts) {
		// Validate mount presets
		for (const preset of mountPresets) {
			if (!MOUNT_PRESETS[preset]) {
				throw new Error(
					`Unknown mount preset: ${preset}. Available: ${Object.keys(MOUNT_PRESETS).join(", ")}`,
				);
			}
		}

		// Validate preset mounts
		for (const presetName of mountPresets) {
			const preset = MOUNT_PRESETS[presetName];
			if (preset) {
				for (const mount of preset.files) {
					MountUtils.validateMountSecurity(mount.source, mount.target);
				}
			}
		}

		// Validate custom mounts
		for (const mount of customMounts) {
			MountUtils.validateMountSecurity(mount.source, mount.target);
		}
	}

	static validateMountSecurity(source, target) {
		const expandedSource = source.replace("~", os.homedir());
		const resolvedSource = path.resolve(expandedSource);

		const dangerousPaths = [
			"/etc",
			"/var/run/docker.sock",
			"/proc",
			"/sys",
			"/dev",
		];

		const isDangerous = dangerousPaths.some((dangerousPath) => {
			return (
				resolvedSource === dangerousPath ||
				resolvedSource.startsWith(dangerousPath + "/")
			);
		});

		if (isDangerous) {
			console.warn(
				`!  Warning: Mounting potentially sensitive path: ${source}`,
			);
			console.warn("   This could expose system resources to the container.");
		}

		if (!fs.existsSync(resolvedSource)) {
			console.warn(`!  Warning: Mount source does not exist: ${source}`);
		}

		if (!target.startsWith("/")) {
			throw new Error(`Mount target must be absolute path: ${target}`);
		}
	}

	static getMountArguments(mountPresets, customMounts) {
		const mounts = [];

		// Add preset mounts
		for (const presetName of mountPresets) {
			const preset = MOUNT_PRESETS[presetName];
			if (preset) {
				for (const mount of preset.files) {
					const expandedSource = mount.source.replace("~", os.homedir());
					if (fs.existsSync(expandedSource)) {
						const readonly = mount.readonly ? ":ro" : "";
						mounts.push("-v", `${expandedSource}:${mount.target}${readonly}`);
					} else {
						console.warn(`!  Skipping missing mount: ${mount.source}`);
					}
				}
			}
		}

		// Add custom mounts
		for (const mount of customMounts) {
			const expandedSource = mount.source.replace("~", os.homedir());
			if (fs.existsSync(expandedSource)) {
				const readonly = mount.readonly ? ":ro" : "";
				mounts.push("-v", `${expandedSource}:${mount.target}${readonly}`);
			} else {
				console.warn(`!  Skipping missing custom mount: ${mount.source}`);
			}
		}

		return mounts;
	}

	static showMountInfo(mountArgs) {
		if (mountArgs.length > 0) {
			console.log("📁 Configured mounts:");
			for (let i = 0; i < mountArgs.length; i += 2) {
				if (mountArgs[i] === "-v") {
					const mountSpec = mountArgs[i + 1];
					const [source, target] = mountSpec.split(":");
					const readonly = mountSpec.endsWith(":ro") ? " (readonly)" : "";
					console.log(`   ${source} → ${target}${readonly}`);
				}
			}
			console.log("");
		}
	}

	static getPresets() {
		return MOUNT_PRESETS;
	}
}

module.exports = MountUtils;
