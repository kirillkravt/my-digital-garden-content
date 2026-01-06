console.log('=== ПОЛНАЯ ДЕМО-ВЕРСИЯ STRUDELREPLNODE С РЕДАКТОРОМ ===');

// 1. Основной класс управления Strudel (уже протестирован)
class StrudelREPLManager {
    constructor() {
        this.isInitialized = false;
        this.isPlaying = false;
        this.audioContext = null;
        this.currentCode = 'note("c4 e4 g4")';
        this.error = null;
    }
    
    async initialize() {
        console.log('Инициализация StrudelREPL...');
        
        if (typeof initStrudel !== 'function') {
            throw new Error('Strudel не загружен');
        }
        
        try {
            initStrudel();
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            if (!window.strudel) throw new Error('window.strudel не создан');
            if (!window.strudel.getAudioContext) throw new Error('getAudioContext не доступен');
            
            this.audioContext = window.strudel.getAudioContext();
            this.isInitialized = true;
            this.error = null;
            
            console.log('✅ StrudelREPL инициализирован');
            return true;
        } catch (err) {
            this.error = err.message;
            console.error('❌ Ошибка инициализации:', err);
            throw err;
        }
    }
    
    async play(code = this.currentCode) {
        if (!this.isInitialized) {
            throw new Error('Сначала инициализируйте Strudel');
        }
        
        this.currentCode = code;
        this.error = null;
        
        // Проверяем AudioContext
        if (this.audioContext.state === 'closed') {
            throw new Error('AudioContext закрыт. Обновите страницу.');
        }
        
        if (this.audioContext.state === 'suspended') {
            await this.audioContext.resume();
        }
        
        // Выполняем код
        try {
            window.strudel.evaluate(code);
            this.isPlaying = true;
            console.log('✅ Код выполнен:', code);
            return true;
        } catch (err) {
            this.error = err.message;
            this.isPlaying = false;
            console.error('❌ Ошибка выполнения:', err);
            throw err;
        }
    }
    
    async stop() {
        if (!this.isInitialized || !this.isPlaying) return true;
        
        try {
            if (this.audioContext.state === 'running') {
                await this.audioContext.suspend();
            }
            this.isPlaying = false;
            console.log('✅ Воспроизведение остановлено');
            return true;
        } catch (err) {
            this.error = err.message;
            console.error('❌ Ошибка остановки:', err);
            throw err;
        }
    }
    
    getStatus() {
        return {
            initialized: this.isInitialized,
            playing: this.isPlaying,
            audioContextState: this.audioContext ? this.audioContext.state : 'нет',
            error: this.error,
            currentCode: this.currentCode
        };
    }
}

// 2. Создаём полноценный редактор с интерфейсом
function createFullStrudelEditor() {
    console.log('Создание полноценного Strudel редактора...');
    
    // Удаляем старые панели если есть
    document.querySelectorAll('.strudel-editor-panel').forEach(el => el.remove());
    
    const editorPanel = document.createElement('div');
    editorPanel.className = 'strudel-editor-panel';
    editorPanel.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 10000;
        background: white;
        padding: 20px;
        border-radius: 12px;
        border: 3px solid #4CAF50;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        width: 600px;
        max-width: 90vw;
        max-height: 90vh;
        overflow-y: auto;
    `;
    
    // Примеры паттернов Strudel
    const examplePatterns = [
        { name: 'Простая мелодия', code: 'note("c4 e4 g4 c5")' },
        { name: 'Аккорд', code: 'note(["c4", "e4", "g4"])' },
        { name: 'Ритм', code: 's("bd hh hh bd")' },
        { name: 'Полиритм', code: 'stack(note("c4 e4 g4"), s("bd hh"))' },
        { name: 'Случайные ноты', code: 'note("c4 e4 g4").sometimes(rev)' },
        { name: 'TidalCycles синтаксис', code: 'd1 $ s "bd hh hh bd"' }
    ];
    
    editorPanel.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px;">
            <h2 style="margin: 0; color: #2c3e50;">🎵 StrudelREPL Editor</h2>
            <div style="font-size: 12px; color: #7f8c8d;">Демо-версия для интеграции</div>
        </div>
        
        <div style="margin-bottom: 15px;">
            <div style="font-weight: bold; margin-bottom: 8px; color: #34495e;">Редактор кода:</div>
            <textarea 
                id="strudel-code-editor" 
                style="width: 100%; height: 150px; padding: 12px; border: 2px solid #ddd; border-radius: 6px; font-family: 'Monaco', 'Consolas', monospace; font-size: 14px; resize: vertical;"
                placeholder="Введите код Strudel/TidalCycles здесь..."
            >note("c4 e4 g4")</textarea>
        </div>
        
        <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px;">
            <button id="strudel-init-btn" style="padding: 10px 16px; background: #2ecc71; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; flex: 1;">
                🎵 Инициализировать Strudel
            </button>
            <button id="strudel-play-btn" style="padding: 10px 16px; background: #3498db; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; flex: 1;">
                ▶️ Воспроизвести код
            </button>
            <button id="strudel-stop-btn" style="padding: 10px 16px; background: #e74c3c; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; flex: 1;">
                ⏹️ Остановить
            </button>
        </div>
        
        <div style="margin-bottom: 20px;">
            <div style="font-weight: bold; margin-bottom: 8px; color: #34495e;">Примеры паттернов:</div>
            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px;">
                ${examplePatterns.map((pattern, i) => `
                    <button 
                        class="example-pattern-btn" 
                        data-code="${pattern.code.replace(/"/g, '&quot;')}"
                        style="padding: 8px 12px; background: #ecf0f1; border: 1px solid #bdc3c7; border-radius: 4px; cursor: pointer; text-align: left; font-size: 12px;"
                    >
                        <div style="font-weight: bold; color: #2c3e50;">${pattern.name}</div>
                        <div style="color: #7f8c8d; font-family: monospace; font-size: 10px; overflow: hidden; text-overflow: ellipsis;">${pattern.code}</div>
                    </button>
                `).join('')}
            </div>
        </div>
        
        <div style="background: #f8f9fa; border-radius: 8px; padding: 15px; border-left: 4px solid #3498db;">
            <div style="font-weight: bold; margin-bottom: 8px; color: #2c3e50;">📊 Статус системы:</div>
            <div id="strudel-status-display" style="font-family: monospace; font-size: 12px; color: #2c3e50;">
                <div>Strudel: <span id="status-strudel" style="color: #e74c3c;">Не инициализирован</span></div>
                <div>AudioContext: <span id="status-audiocontext" style="color: #e74c3c;">Не доступен</span></div>
                <div>Воспроизведение: <span id="status-playing" style="color: #e74c3c;">Остановлено</span></div>
                <div>Ошибки: <span id="status-error" style="color: #2ecc71;">Нет</span></div>
            </div>
        </div>
        
        <div style="margin-top: 20px; padding: 12px; background: #fffde7; border-radius: 6px; border: 1px solid #ffeb3b;">
            <div style="font-weight: bold; color: #f57c00; margin-bottom: 5px;">ℹ️ Как использовать:</div>
            <ol style="margin: 0; padding-left: 20px; font-size: 12px; color: #5d4037;">
                <li>Нажмите "Инициализировать Strudel" (зелёная кнопка)</li>
                <li>Отредактируйте код в текстовом поле или выберите пример</li>
                <li>Нажмите "Воспроизвести код" (синяя кнопка)</li>
                <li>Для остановки - "Остановить" (красная кнопка)</li>
                <li>В реальном StrudelREPLNode будет подсветка синтаксиса и больше функций</li>
            </ol>
        </div>
        
        <div style="margin-top: 20px; text-align: center; font-size: 11px; color: #95a5a6; border-top: 1px solid #ecf0f1; padding-top: 10px;">
            Это демо-версия для интеграции в Universal Creative Hub v0.3
        </div>
    `;
    
    document.body.appendChild(editorPanel);
    
    // Создаём менеджер
    const manager = new StrudelREPLManager();
    
    // Функция обновления статуса
    function updateStatusDisplay() {
        const status = manager.getStatus();
        
        document.getElementById('status-strudel').textContent = 
            status.initialized ? '✅ Инициализирован' : '❌ Не инициализирован';
        document.getElementById('status-strudel').style.color = 
            status.initialized ? '#2ecc71' : '#e74c3c';
            
        document.getElementById('status-audiocontext').textContent = 
            status.audioContextState;
        document.getElementById('status-audiocontext').style.color = 
            status.audioContextState === 'running' ? '#2ecc71' : 
            status.audioContextState === 'suspended' ? '#f39c12' : '#e74c3c';
            
        document.getElementById('status-playing').textContent = 
            status.playing ? '▶️ Воспроизводится' : '⏹️ Остановлено';
        document.getElementById('status-playing').style.color = 
            status.playing ? '#2ecc71' : '#e74c3c';
            
        document.getElementById('status-error').textContent = 
            status.error || 'Нет';
        document.getElementById('status-error').style.color = 
            status.error ? '#e74c3c' : '#2ecc71';
    }
    
    // Обработчики кнопок
    document.getElementById('strudel-init-btn').onclick = async () => {
        try {
            document.getElementById('strudel-init-btn').disabled = true;
            document.getElementById('strudel-init-btn').innerHTML = '⏳ Инициализация...';
            
            await manager.initialize();
            
            document.getElementById('strudel-init-btn').innerHTML = '✅ Инициализирован';
            document.getElementById('strudel-init-btn').style.background = '#27ae60';
            
            updateStatusDisplay();
        } catch (error) {
            document.getElementById('strudel-init-btn').innerHTML = '❌ Ошибка';
            document.getElementById('strudel-init-btn').style.background = '#c0392b';
            setTimeout(() => {
                document.getElementById('strudel-init-btn').disabled = false;
                document.getElementById('strudel-init-btn').innerHTML = '🎵 Инициализировать Strudel';
                document.getElementById('strudel-init-btn').style.background = '#2ecc71';
            }, 2000);
            updateStatusDisplay();
        }
    };
    
    document.getElementById('strudel-play-btn').onclick = async () => {
        const code = document.getElementById('strudel-code-editor').value;
        
        try {
            document.getElementById('strudel-play-btn').disabled = true;
            document.getElementById('strudel-play-btn').innerHTML = '⏳ Запуск...';
            
            await manager.play(code);
            
            document.getElementById('strudel-play-btn').innerHTML = '✅ Воспроизводится';
            document.getElementById('strudel-play-btn').style.background = '#2980b9';
            
            updateStatusDisplay();
        } catch (error) {
            document.getElementById('strudel-play-btn').innerHTML = '❌ Ошибка';
            document.getElementById('strudel-play-btn').style.background = '#c0392b';
            updateStatusDisplay();
        } finally {
            setTimeout(() => {
                document.getElementById('strudel-play-btn').disabled = false;
                document.getElementById('strudel-play-btn').innerHTML = '▶️ Воспроизвести код';
                document.getElementById('strudel-play-btn').style.background = '#3498db';
            }, 2000);
        }
    };
    
    document.getElementById('strudel-stop-btn').onclick = async () => {
        try {
            document.getElementById('strudel-stop-btn').disabled = true;
            document.getElementById('strudel-stop-btn').innerHTML = '⏳ Остановка...';
            
            await manager.stop();
            
            document.getElementById('strudel-stop-btn').innerHTML = '✅ Остановлено';
            document.getElementById('strudel-stop-btn').style.background = '#c0392b';
            
            updateStatusDisplay();
        } catch (error) {
            document.getElementById('strudel-stop-btn').innerHTML = '❌ Ошибка';
            updateStatusDisplay();
        } finally {
            setTimeout(() => {
                document.getElementById('strudel-stop-btn').disabled = false;
                document.getElementById('strudel-stop-btn').innerHTML = '⏹️ Остановить';
                document.getElementById('strudel-stop-btn').style.background = '#e74c3c';
            }, 2000);
        }
    };
    
    // Обработчики примеров паттернов
    document.querySelectorAll('.example-pattern-btn').forEach(button => {
        button.onclick = () => {
            const code = button.getAttribute('data-code');
            document.getElementById('strudel-code-editor').value = code;
            
            // Подсветка выбранного примера
            document.querySelectorAll('.example-pattern-btn').forEach(btn => {
                btn.style.background = '#ecf0f1';
                btn.style.borderColor = '#bdc3c7';
            });
            button.style.background = '#d5f4e6';
            button.style.borderColor = '#2ecc71';
        };
    });
    
    // Обновляем статус каждую секунду
    setInterval(updateStatusDisplay, 1000);
    
    console.log('✅ Полноценный Strudel редактор создан!');
    console.log('Теперь можно:');
    console.log('1. Редактировать код в текстовом поле');
    console.log('2. Выбирать примеры паттернов');
    console.log('3. Инициализировать, воспроизводить и останавливать');
    
    return { manager, updateStatusDisplay };
}

// 3. Запускаем создание редактора
console.log('\nЗапуск создания полноценного редактора...');
const { manager } = createFullStrudelEditor();

// 4. Экспортируем для тестирования
window.strudelDemo = {
    manager,
    getCode: () => document.getElementById('strudel-code-editor').value,
    setCode: (code) => document.getElementById('strudel-code-editor').value = code,
    play: () => manager.play(document.getElementById('strudel-code-editor').value),
    stop: () => manager.stop()
};

console.log('\n=== ЧТО МОЖНО ДЕЛАТЬ ===');
console.log('1. Редактировать код в текстовом поле редактора');
console.log('2. Выбирать примеры паттернов из списка');
console.log('3. Инициализировать Strudel (зелёная кнопка)');
console.log('4. Воспроизводить код (синяя кнопка)');
console.log('5. Останавливать (красная кнопка)');
console.log('6. Следить за статусом в панели статуса');
console.log('\n✅ Это ДЕМО полноценного StrudelREPLNode!');
console.log('В реальном компоненте будет:');
console.log('- Подсветка синтаксиса');
console.log('- Автодополнение кода');
console.log('- Сохранение паттернов');
console.log('- Интеграция с другими нодами студии');