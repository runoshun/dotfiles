(function () {
	// Wait for document to be fully loaded
	document.addEventListener("DOMContentLoaded", function () {
		const webviewWidth = "250px"; // Adjust this value as needed
		let isWebviewVisible = true;
		let webview = undefined;
		let styleElement = undefined;

		function initWebview() {
			// Create webview element
			webview = document.createElement("webview");
			webview.setAttribute(
				"src",
				"chrome-extension://chejfhdknideagdnddjpgamkchefjhoi/sidepanel.html",
			);
			webview.id = "vivaldi-sidebar-webview";
			webview.style.height = "calc(100% - 50px)";
			webview.style.marginTop = "40px";
			webview.style.width = webviewWidth;

			// Create a style element for CSS rules
			styleElement = document.createElement("style");
			styleElement.id = "vivaldi-webview-styles";
			document.head.appendChild(styleElement);

			const fixedStyle = document.createElement("style");
			fixedStyle.textContent = `
      #main > div.mainbar > div > div[role="toolbar"] {
        min-height: 42px !important;
      }`;
			document.head.appendChild(fixedStyle);

			document.body.prepend(webview);
			updateWebviewVisibility(true);
		}

		// Function to update webview and app styles based on visibility
		function updateWebviewVisibility(visible) {
			isWebviewVisible = visible;

			if (visible) {
				webview.style.width = webviewWidth;
				webview.style.display = "block";
				styleElement.textContent = `
          #app {
            margin-left: ${webviewWidth} !important;
            transition: margin-left 0.3s ease;
          }
        `;
			} else {
				webview.style.width = "0px";
				webview.style.display = "none";
				styleElement.textContent = `
          #app {
            margin-left: 0px !important;
            transition: margin-left 0.3s ease;
          }
        `;
			}
		}

		// Monitor #panels-container width changes
		function setupPanelsContainerObserver() {
			// Try to find the panels container
			let panelFound = false;

			const findPanelsContainer = setInterval(() => {
				const panelsContainer = document.getElementById("panels-container");
				if (panelsContainer) {
					clearInterval(findPanelsContainer);
					console.log("Found #panels-container, setting up observer");
					panelFound = true;
					initWebview();

					// Function to check panels container width and update webview accordingly
					function checkPanelsWidth() {
						const width = parseInt(panelsContainer.style.width) || 0;
						console.log("panel Width: ", width, panelsContainer.style.width);
						const isVisible =
							panelsContainer.style.display !== "none" && width > 1;

						// If panels not visible or width is 0, hide webview
						if (!isVisible || width === 0) {
							if (isWebviewVisible) {
								updateWebviewVisibility(false);
								console.log(
									"Panels container hidden or width is 0, hiding webview",
								);
							}
						} else {
							// If panels become visible again, show webview
							if (!isWebviewVisible) {
								updateWebviewVisibility(true);
								console.log("Panels container visible, showing webview");
							}
						}
					}

					// Initial check
					checkPanelsWidth();

					// Set up a MutationObserver to watch for style changes
					const observer = new MutationObserver((mutations) => {
						mutations.forEach((mutation) => {
							if (mutation.attributeName === "style") {
								checkPanelsWidth();
							}
						});
					});

					// Start observing style and class changes
					observer.observe(panelsContainer, {
						attributes: true,
						attributeFilter: ["style", "class"],
					});

					// Also observe visibility changes on the parent element
					const panelsContainerParent = panelsContainer.parentElement;
					if (panelsContainerParent) {
						observer.observe(panelsContainerParent, {
							attributes: true,
							attributeFilter: ["style", "class"],
						});
					}
				}
			}, 500); // Check every 500ms

			// Stop checking after 30 seconds if not found
			setTimeout(() => {
				if (findPanelsContainer) {
					clearInterval(findPanelsContainer);
					if (!panelFound) {
						console.log("Could not find #panels-container within timeout");
					}
				}
			}, 30000);
		}

		// Start monitoring panels container
		setupPanelsContainerObserver();
		console.log("Vivaldi mod: side-webview loaded");
	});
})();
