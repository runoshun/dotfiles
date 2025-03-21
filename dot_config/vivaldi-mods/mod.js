(function () {
	// スタイル定数
	const STYLES = {
		WEBVIEW: {
			DEFAULT_WIDTH: "250px",
			HEIGHT: "calc(100% - 40px)",
			MARGIN_TOP: "40px",
		},
		RESIZER: {
			WIDTH: "5px",
			CURSOR: "col-resize",
			Z_INDEX: "1000",
		},
		TRANSITIONS: {
			MARGIN: "margin-left 0.3s ease",
		},
	};

	// ユーティリティ関数
	const createElementWithStyles = (tag, id, styles) => {
		const element = document.createElement(tag);
		element.id = id;
		Object.assign(element.style, styles);
		return element;
	};

	const setWebviewVisibilityStyles = (visible, width) => {
		return {
			webviewStyles: {
				width: visible ? width : "0px",
				display: visible ? "block" : "none",
			},
			appStyles: `
        #app {
          margin-left: ${visible ? width : "0px"} !important;
          transition: ${STYLES.TRANSITIONS.MARGIN};
        }
      `,
		};
	};

	document.addEventListener("DOMContentLoaded", function () {
		let isWebviewVisible = true;
		let webview, styleElement, resizer;
		let isResizing = false;

		function initWebview() {
			// Webview作成
			webview = createElementWithStyles("webview", "vivaldi-sidebar-webview", {
				height: STYLES.WEBVIEW.HEIGHT,
				marginTop: STYLES.WEBVIEW.MARGIN_TOP,
				width: STYLES.WEBVIEW.DEFAULT_WIDTH,
			});
			webview.setAttribute(
				"src",
				//"chrome-extension://kcoaboamaljjopcppblpdnhcmaddanig/sidepanel.html",
				"chrome-extension://chejfhdknideagdnddjpgamkchefjhoi/sidepanel.html",
			);

			// スタイル要素作成
			styleElement = document.createElement("style");
			styleElement.id = "vivaldi-webview-styles";

			// 固定スタイル追加
			const fixedStyle = document.createElement("style");
			fixedStyle.textContent = `
        #main > div.mainbar > div > div[role="toolbar"] {
          min-height: 42px !important;
        }
      `;

			// Resizer作成
			resizer = createElementWithStyles("div", "vivaldi-webview-resizer", {
				width: STYLES.RESIZER.WIDTH,
				cursor: STYLES.RESIZER.CURSOR,
				position: "absolute",
				top: "0",
				left: STYLES.WEBVIEW.DEFAULT_WIDTH,
				bottom: "0",
				zIndex: STYLES.RESIZER.Z_INDEX,
			});

			// DOM追加
			document.head.appendChild(styleElement);
			document.head.appendChild(fixedStyle);
			document.body.prepend(webview);
			document.body.appendChild(resizer);

			setupResizeHandlers();
			updateWebviewVisibility(true);
		}

		function setupResizeHandlers() {
			let startX = 0;
			let startWidth = 0;

			const handlePointerDown = (e) => {
				e.preventDefault();
				isResizing = true;
				startX = e.clientX;
				startWidth = parseInt(
					document.defaultView.getComputedStyle(webview).width,
					10,
				);

				// ポインタをキャプチャ
				resizer.setPointerCapture(e.pointerId);
			};

			const handlePointerMove = (e) => {
				if (!isResizing) return;
				e.preventDefault();
				const width = `${startWidth + e.clientX - startX}px`;
				updateElementsOnResize(width);
			};

			const handlePointerUp = (e) => {
				if (!isResizing) return;
				isResizing = false;

				// ポインタキャプチャを解放
				resizer.releasePointerCapture(e.pointerId);
			};

			// スタイル
			Object.assign(resizer.style, {
				zIndex: "9999",
				pointerEvents: "all",
				position: "fixed",
				touchAction: "none", // タッチデバイス用
			});

			resizer.addEventListener("pointerdown", handlePointerDown);
			resizer.addEventListener("pointermove", handlePointerMove);
			resizer.addEventListener("pointerup", handlePointerUp);
			resizer.addEventListener("pointercancel", handlePointerUp);
		}

		function updateElementsOnResize(width) {
			webview.style.width = width;
			styleElement.textContent = `
        #app {
          margin-left: calc(${width} + 2px) !important;
          transition: none;
        }
      `;
			resizer.style.left = width;
		}

		function updateWebviewVisibility(visible) {
			isWebviewVisible = visible;
			const { webviewStyles, appStyles } = setWebviewVisibilityStyles(
				visible,
				STYLES.WEBVIEW.DEFAULT_WIDTH,
			);
			Object.assign(webview.style, webviewStyles);
			styleElement.textContent = appStyles;
		}

		function setupPanelsContainerObserver() {
			let panelFound = false;

			const checkPanelsWidth = (panelsContainer) => {
				const width = parseInt(panelsContainer.style.width) || 0;
				const isVisible = panelsContainer.style.display !== "none" && width > 1;

				if ((!isVisible || width === 0) && isWebviewVisible) {
					updateWebviewVisibility(false);
				} else if (isVisible && !isWebviewVisible) {
					updateWebviewVisibility(true);
				}
			};

			const findPanelsContainer = setInterval(() => {
				const panelsContainer = document.getElementById("panels-container");
				if (!panelsContainer) return;

				clearInterval(findPanelsContainer);
				panelFound = true;
				initWebview();

				checkPanelsWidth(panelsContainer);

				const observer = new MutationObserver((mutations) => {
					mutations.forEach((mutation) => {
						if (mutation.attributeName === "style") {
							checkPanelsWidth(panelsContainer);
						}
					});
				});

				const observerConfig = {
					attributes: true,
					attributeFilter: ["style", "class"],
				};

				observer.observe(panelsContainer, observerConfig);
				if (panelsContainer.parentElement) {
					observer.observe(panelsContainer.parentElement, observerConfig);
				}
			}, 500);

			setTimeout(() => {
				if (findPanelsContainer) {
					clearInterval(findPanelsContainer);
					if (!panelFound) {
						console.log("Could not find #panels-container within timeout");
					}
				}
			}, 30000);
		}

		setupPanelsContainerObserver();
		console.log("Vivaldi mod: side-webview loaded");
	});
})();
