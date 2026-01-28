// ==UserScript==
// @name         DeepSeek Chat Saver - Exact Format
// @namespace    Violentmonkey Scripts
// @version      4.0
// @description  Save DeepSeek chats preserving exact formatting
// @author       Kirill
// @match        https://chat.deepseek.com/*
// @grant        GM_getValue
// @grant        GM_setValue
// @run-at       document-end
// ==/UserScript==

(function() {
	'use strict';
	
	console.log('=== DeepSeek Exact Format Saver LOADED ===');
	
	setTimeout(init, 1500);
	
	function init() {
			const oldBtn = document.getElementById('deepseek-save-btn');
			if (oldBtn) oldBtn.remove();
			
			const btn = document.createElement('button');
			btn.id = 'deepseek-save-btn';
			btn.innerHTML = '💾 Save Chat';
			
			btn.style.cssText = `
					position: fixed;
					bottom: 25px;
					right: 25px;
					z-index: 9999;
					padding: 14px 24px;
					background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
					color: white;
					border: none;
					border-radius: 12px;
					cursor: pointer;
					font-weight: 600;
					font-size: 15px;
					font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
					box-shadow: 0 6px 25px rgba(102, 126, 234, 0.4);
					transition: all 0.3s ease;
			`;
			
			btn.addEventListener('mouseenter', () => {
					btn.style.transform = 'translateY(-3px) scale(1.05)';
					btn.style.boxShadow = '0 12px 35px rgba(102, 126, 234, 0.6)';
			});
			
			btn.addEventListener('mouseleave', () => {
					btn.style.transform = 'translateY(0) scale(1)';
					btn.style.boxShadow = '0 6px 25px rgba(102, 126, 234, 0.4)';
			});
			
			document.body.appendChild(btn);
			btn.addEventListener('click', saveChatExactFormat);
			
			document.addEventListener('keydown', (e) => {
					if ((e.ctrlKey || e.metaKey) && e.altKey && e.key === 's') {
							e.preventDefault();
							saveChatExactFormat();
					}
			});
	}
	
	function saveChatExactFormat() {
			const btn = document.getElementById('deepseek-save-btn');
			const originalText = btn.innerHTML;
			
			try {
					btn.innerHTML = '⏳ Сохранение...';
					btn.style.opacity = '0.8';
					btn.style.cursor = 'wait';
					
					let counter = GM_getValue('deepseek_counter', 1);
					const filename = `DeepSeek${counter}.md`;
					
					const messageContainers = [];
					const allElements = document.querySelectorAll('*');
					
					allElements.forEach(el => {
							const classNames = el.className?.toString() || '';
							const isMessageContainer = 
									classNames.includes('message') ||
									classNames.includes('Message') ||
									classNames.includes('chat-message') ||
									classNames.includes('prose') ||
									classNames.includes('markdown');
							
							if (isMessageContainer && el.textContent && el.textContent.trim().length > 10) {
									const hasMessageParent = el.closest('[class*="message"], [class*="Message"]');
									if (!hasMessageParent || hasMessageParent === el) {
											messageContainers.push(el);
									}
							}
					});
					
					if (messageContainers.length === 0) {
							document.querySelectorAll('div').forEach(div => {
									const text = div.textContent?.trim() || '';
									if (text.length > 30 && text.length < 10000) {
											if (!text.includes('©') && 
													!text.includes('Политика') && 
													!text.includes('Terms') &&
													!text.includes('пользовательского соглашения')) {
													messageContainers.push(div);
											}
									}
							});
					}
					
					let mdContent = `# DeepSeek Chat #${counter}\n\n`;
					mdContent += `**Дата сохранения:** ${new Date().toLocaleString('ru-RU')}\n`;
					mdContent += `**URL:** ${window.location.href}\n\n`;
					mdContent += `---\n\n`;
					
					messageContainers.sort((a, b) => {
							return a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1;
					});
					
					messageContainers.forEach((container, index) => {
							const htmlContent = container.innerHTML;
							const markdown = convertHTMLtoMarkdown(htmlContent);
							
							mdContent += `## Сообщение ${index + 1}\n\n`;
							mdContent += `${markdown}\n\n`;
							mdContent += `---\n\n`;
					});
					
					const blob = new Blob([mdContent], {type: 'text/markdown;charset=utf-8'});
					const url = URL.createObjectURL(blob);
					const link = document.createElement('a');
					link.href = url;
					link.download = filename;
					document.body.appendChild(link);
					link.click();
					document.body.removeChild(link);
					URL.revokeObjectURL(url);
					
					GM_setValue('deepseek_counter', counter + 1);
					showNotificationWithPath(filename, messageContainers.length);
					
					console.log(`Saved: ${filename}, messages: ${messageContainers.length}`);
					
			} catch (error) {
					console.error('Save error:', error);
					showSimpleNotification(`❌ Ошибка: ${error.message}`, 'error');
			} finally {
					btn.innerHTML = originalText;
					btn.style.opacity = '1';
					btn.style.cursor = 'pointer';
			}
	}
	
	function convertHTMLtoMarkdown(html) {
			const tempDiv = document.createElement('div');
			tempDiv.innerHTML = html;
			
			function processElement(element, depth = 0) {
					let result = '';
					
					for (const node of element.childNodes) {
							if (node.nodeType === Node.TEXT_NODE) {
									result += node.textContent;
							} else if (node.nodeType === Node.ELEMENT_NODE) {
									const tagName = node.tagName.toLowerCase();
									const childContent = processElement(node, depth + 1);
									
									switch (tagName) {
											case 'p':
													result += childContent + '\n\n';
													break;
											case 'br':
													result += '\n';
													break;
											case 'div':
													result += childContent + (depth === 0 ? '\n' : '');
													break;
											case 'ul':
													const listItems = node.querySelectorAll('li');
													listItems.forEach(li => {
															const liContent = processElement(li, depth + 1);
															result += '- ' + liContent.trim() + '\n';
													});
													result += '\n';
													break;
											case 'ol':
													const olItems = node.querySelectorAll('li');
													olItems.forEach((li, index) => {
															const liContent = processElement(li, depth + 1);
															result += (index + 1) + '. ' + liContent.trim() + '\n';
													});
													result += '\n';
													break;
											case 'li':
													result += processElement(node, depth + 1);
													break;
											case 'strong':
											case 'b':
													result += '**' + childContent + '**';
													break;
											case 'em':
											case 'i':
													result += '*' + childContent + '*';
													break;
											case 'code':
													if (node.className?.includes('language-')) {
															result += '```' + node.className.replace('language-', '') + '\n' + childContent + '\n```\n';
													} else {
															result += '`' + childContent + '`';
													}
													break;
											case 'pre':
													result += '```\n' + childContent + '\n```\n';
													break;
											case 'h1':
													result += '# ' + childContent + '\n\n';
													break;
											case 'h2':
													result += '## ' + childContent + '\n\n';
													break;
											case 'h3':
													result += '### ' + childContent + '\n\n';
													break;
											case 'a':
													const href = node.getAttribute('href');
													result += '[' + childContent + '](' + href + ')';
													break;
											case 'blockquote':
													const lines = childContent.split('\n');
													result += lines.map(line => '> ' + line).join('\n') + '\n\n';
													break;
											default:
													result += childContent;
									}
							}
					}
					
					return result;
			}
			
			let markdown = processElement(tempDiv);
			markdown = markdown.replace(/\n{3,}/g, '\n\n');
			return markdown.trim();
	}
	
	function showNotificationWithPath(filename, messageCount) {
			const obsidianPath = '/Users/kirillkravcov/obsidian/my-digital-garden-content/Clippings/';
			
			const notification = document.createElement('div');
			notification.innerHTML = `
					<div style="
							position: fixed;
							top: 25px;
							right: 25px;
							background: linear-gradient(135deg, #10a37f 0%, #0d8f6c 100%);
							color: white;
							padding: 20px;
							border-radius: 12px;
							z-index: 10000;
							max-width: 450px;
							box-shadow: 0 8px 30px rgba(16, 163, 127, 0.3);
							font-family: -apple-system, system-ui, sans-serif;
							animation: slideIn 0.3s ease-out;
					">
							<div style="font-weight: 600; margin-bottom: 8px; font-size: 16px;">
									✅ Чат сохранен
							</div>
							<div style="margin-bottom: 12px; font-size: 14px; line-height: 1.4;">
									<strong>Файл:</strong> ${filename}<br>
									<strong>Сообщений:</strong> ${messageCount}<br>
									<strong>Сохранен в:</strong> Загрузки (~/Downloads)
							</div>
							<div style="
									background: rgba(255,255,255,0.15); 
									padding: 12px; 
									border-radius: 6px; 
									margin-bottom: 15px; 
									font-family: 'Monaco', 'Menlo', monospace; 
									font-size: 13px;
									line-height: 1.4;
							">
									# Переместите в Obsidian:<br>
									mv ~/Downloads/${filename} "${obsidianPath}"
							</div>
							<div style="display: flex; gap: 10px;">
									<button id="copyCmdBtn" style="
											padding: 8px 16px; 
											background: white; 
											color: #10a37f; 
											border: none; 
											border-radius: 6px; 
											cursor: pointer; 
											font-weight: 500; 
											flex: 1;
											font-size: 13px;
									">
											📋 Копировать команду
									</button>
									<button id="closeNotifBtn" style="
											padding: 8px 16px; 
											background: transparent; 
											color: white; 
											border: 1px solid rgba(255,255,255,0.3); 
											border-radius: 6px; 
											cursor: pointer; 
											flex: 1;
											font-size: 13px;
									">
											Закрыть
									</button>
							</div>
					</div>
			`;
			
			document.body.appendChild(notification);
			
			notification.querySelector('#copyCmdBtn').addEventListener('click', () => {
					const command = `mv ~/Downloads/${filename} "${obsidianPath}"`;
					navigator.clipboard.writeText(command).then(() => {
							const btn = notification.querySelector('#copyCmdBtn');
							btn.textContent = '✅ Скопировано!';
							btn.style.background = '#4CAF50';
							btn.style.color = 'white';
							setTimeout(() => {
									btn.textContent = '📋 Копировать команду';
									btn.style.background = 'white';
									btn.style.color = '#10a37f';
							}, 2000);
					});
			});
			
			notification.querySelector('#closeNotifBtn').addEventListener('click', () => {
					notification.style.animation = 'slideOut 0.3s ease-out forwards';
					setTimeout(() => notification.remove(), 300);
			});
			
			const style = document.createElement('style');
			style.textContent = `
					@keyframes slideIn {
							from { opacity: 0; transform: translateY(-20px) translateX(20px); }
							to { opacity: 1; transform: translateY(0) translateX(0); }
					}
					@keyframes slideOut {
							from { opacity: 1; transform: translateY(0) translateX(0); }
							to { opacity: 0; transform: translateY(-20px) translateX(20px); }
					}
			`;
			document.head.appendChild(style);
			
			setTimeout(() => {
					if (notification.parentNode) {
							notification.style.animation = 'slideOut 0.3s ease-out forwards';
							setTimeout(() => notification.remove(), 300);
					}
			}, 15000);
	}
	
	function showSimpleNotification(message, type = 'success') {
			const notification = document.createElement('div');
			notification.textContent = message;
			notification.style.cssText = `
					position: fixed;
					top: 25px;
					right: 25px;
					background: ${type === 'error' ? '#ff6b6b' : '#10a37f'};
					color: white;
					padding: 15px 20px;
					border-radius: 8px;
					z-index: 10000;
					font-family: system-ui, sans-serif;
					font-size: 14px;
					font-weight: 500;
					box-shadow: 0 4px 12px rgba(0,0,0,0.15);
			`;
			document.body.appendChild(notification);
			setTimeout(() => notification.remove(), 4000);
	}
	
	if (document.readyState === 'loading') {
			document.addEventListener('DOMContentLoaded', init);
	} else {
			init();
	}
	
})();