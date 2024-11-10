/**
 * Docker container detector that finds containers with specific labels
 */

export interface ContainerInfo {
    id: string;
    name: string;
    labels: Record<string, string>;
}

export class DockerDetector {
    private containers: Map<string, ContainerInfo> = new Map();
    private intervalId?: number;

    constructor(
        private readonly labelSelector: string,
        private readonly onContainerStart: (container: ContainerInfo) => void,
        private readonly onContainerStop: (container: ContainerInfo) => void,
        private readonly interval: number = 1000
    ) {}

    /**
     * Parse docker ps output to get container information
     */
    private async getContainers(): Promise<ContainerInfo[]> {
        const cmd = new Deno.Command("docker", {
            args: [
                "ps",
                "--format", 
                '{{.ID}}\t{{.Names}}\t{{.Label "' + this.labelSelector + '"}}'
            ]
        });

        const output = await cmd.output();
        const lines = new TextDecoder().decode(output.stdout).trim().split("\n");
        
        return lines
            .filter(line => line.trim() !== "")
            .map(line => {
                const [id, name, labelValue] = line.split("\t");
                return {
                    id,
                    name,
                    labels: {
                        [this.labelSelector]: labelValue
                    }
                };
            })
            .filter(container => container.labels[this.labelSelector] !== "");
    }

    /**
     * Check for container changes
     */
    private async checkContainers() {
        const currentContainers = await this.getContainers();
        const currentIds = new Set(currentContainers.map(c => c.id));
        
        // Check for new containers
        for (const container of currentContainers) {
            if (!this.containers.has(container.id)) {
                this.containers.set(container.id, container);
                this.onContainerStart(container);
            }
        }

        // Check for stopped containers
        for (const [id, container] of this.containers) {
            if (!currentIds.has(id)) {
                this.containers.delete(id);
                this.onContainerStop(container);
            }
        }
    }

    /**
     * Start watching for containers
     */
    start() {
        if (this.intervalId) return;

        // Initial check
        this.checkContainers();

        // Start periodic checks
        this.intervalId = setInterval(() => {
            this.checkContainers();
        }, this.interval);
    }

    /**
     * Stop watching
     */
    stop() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = undefined;
        }
    }
}
