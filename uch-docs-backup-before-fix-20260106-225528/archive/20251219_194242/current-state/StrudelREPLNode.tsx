// 🚀 UPDATED: НОВАЯ ВЕРСИЯ С Scheduler из @strudel/webaudio
declare global {
  interface Window {
    __strudelLoaded?: boolean;
    __strudelCustomBundleLoaded?: boolean;
    strudel: any;
    note: any;
    initStrudel?: () => Promise<void>;
    // Ключевые функции из обновленного бандла
    repl: any;
    webaudioOutput: any;
    initAudioOnFirstClick: () => void;
    getAudioContext: () => AudioContext;
  }
}

import React, { useEffect, useRef, useState } from 'react';

interface StrudelREPLNodeProps {
  nodeId: string;
}

export const StrudelREPLNode: React.FC<StrudelREPLNodeProps> = ({ nodeId }) => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [isInitialized, setIsInitialized] = useState(false);
  const [code, setCode] = useState('note("c4 e4 g4")');
  
  // Refs для хранения аудио-контекста и планировщика
  const audioContextRef = useRef<AudioContext | null>(null);
  const schedulerRef = useRef<any>(null);
  const strudelLoadedRef = useRef(false);

  // 1. ИНИЦИАЛИЗАЦИЯ STRUDEL И АУДИО-СИСТЕМЫ
  useEffect(() => {
    const initializeStrudel = async () => {
      if (strudelLoadedRef.current) return;

      try {
        console.log('🔄 StrudelREPLNode: Инициализация с новым бандлом...');
        
        // Загружаем бандл, если ещё не загружен
        if (!window.strudel && !window.__strudelCustomBundleLoaded) {
          await new Promise<void>((resolve, reject) => {
            const script = document.createElement('script');
            script.src = '/strudel-bundle.umd.cjs?cache=' + Date.now() + Math.random();
            script.id = 'uch-strudel-custom-bundle';
            
            script.onload = async () => {
              console.log('✅ Кастомный Strudel бандл загружен');
              window.__strudelCustomBundleLoaded = true;
              
              if (window.initStrudel) {
                try {
                  await window.initStrudel();
                  console.log('✅ Кастомный Strudel инициализирован');
                  resolve();
                } catch (initError) {
                  console.error('❌ Ошибка инициализации:', initError);
                  reject(initError);
                }
              } else {
                resolve(); // Если нет initStrudel, просто продолжаем
              }
            };
            
            script.onerror = reject;
            document.head.appendChild(script);
          });
        }

        // Теперь инициализируем аудио-систему согласно документации @strudel/webaudio
        console.log('🎵 Настройка аудио-системы Strudel...');
        
        // Вариант A: Инициализация по первому клику (рекомендуется для autoplay policy)
        if (window.initAudioOnFirstClick) {
          window.initAudioOnFirstClick();
          console.log('✅ initAudioOnFirstClick вызван');
        }
        
        // Получаем AudioContext
        const ctx = window.getAudioContext ? window.getAudioContext() : new AudioContext();
        audioContextRef.current = ctx;
        console.log('✅ AudioContext получен, состояние:', ctx.state);
        
        // Создаем REPL среду с webaudioOutput как обработчиком звука
        if (window.repl && window.webaudioOutput) {
          console.log('🎛️ Создание REPL среды с webaudioOutput...');
          const { scheduler } = window.repl({
            defaultOutput: window.webaudioOutput,
            getTime: () => ctx.currentTime
          });
          
          schedulerRef.current = scheduler;
          console.log('✅ Scheduler создан и готов к работе');
        } else {
          console.error('❌ Не удалось создать scheduler: repl или webaudioOutput недоступны');
        }
        
        window.__strudelLoaded = true;
        strudelLoadedRef.current = true;
        setIsInitialized(true);
        
        console.log('✅ StrudelREPLNode полностью инициализирован со scheduler');
        
      } catch (error) {
        console.error('❌ Критическая ошибка инициализации Strudel:', error);
      }
    };

    initializeStrudel();

    return () => {
      // Очистка: останавливаем scheduler и закрываем AudioContext
      if (schedulerRef.current) {
        schedulerRef.current.stop();
      }
      if (audioContextRef.current && audioContextRef.current.state !== 'closed') {
        audioContextRef.current.close();
      }
    };
  }, []);

  // 2. PLAY - Запускаем паттерн через scheduler
  const handlePlay = async () => {
    if (!window.strudel || !schedulerRef.current) {
      console.error('❌ Strudel или scheduler не инициализирован');
      return;
    }

    try {
      console.log('▶️ Воспроизведение паттерна...');
      
      // Активируем AudioContext если он приостановлен (autoplay policy)
      const ctx = audioContextRef.current;
      if (ctx && ctx.state === 'suspended') {
        console.log('🔄 Активация AudioContext...');
        await ctx.resume();
        console.log('✅ AudioContext активирован, состояние:', ctx.state);
      }
      
      // Создаем паттерн из кода пользователя
      const result = await window.strudel.evaluate(code);
      const pattern = result.pattern;
      
      // Передаем паттерн планировщику и запускаем воспроизведение
      schedulerRef.current.setPattern(pattern);
      schedulerRef.current.start();
      
      setIsPlaying(true);
      console.log('✅ Паттерн передан в scheduler, воспроизведение запущено');
      
    } catch (error) {
      console.error('❌ Ошибка при запуске воспроизведения:', error);
      setIsPlaying(false);
    }
  };

  // 3. STOP - Останавливаем scheduler
  const handleStop = async () => {
    if (!schedulerRef.current) return;

    try {
      console.log('⏹️ Остановка scheduler...');
      schedulerRef.current.stop();
      setIsPlaying(false);
      console.log('✅ Scheduler остановлен');
    } catch (error) {
      console.error('❌ Ошибка при остановке:', error);
    }
  };

  // 4. TEST MIDI (опционально, оставляем для обратной совместимости)
  const testMidi = async () => {
    if (!window.strudel || !window.note) {
      console.error('❌ Strudel не инициализирован');
      return;
    }

    try {
      console.log('🎵 Тестирование MIDI...');
      const pattern = window.note("c4 e4 g4");
      
      if (pattern.midi && typeof pattern.midi === 'function') {
        pattern.midi({ channel: 1 });
        console.log('✅ MIDI сообщение отправлено');
      }
    } catch (error) {
      console.error('❌ Ошибка при тестировании MIDI:', error);
    }
  };

  // 5. ПРОВЕРКА СИСТЕМЫ
  const checkSystem = () => {
    console.log('🔍 Диагностика системы:', {
      strudel: !!window.strudel,
      repl: !!window.repl,
      webaudioOutput: !!window.webaudioOutput,
      scheduler: !!schedulerRef.current,
      audioContext: audioContextRef.current?.state,
      isInitialized,
      isPlaying
    });
  };

  return (
    <div className="strudel-repl-node" style={{ padding: '1rem', border: '1px solid #ccc', borderRadius: '8px' }}>
      <h3>Strudel REPL Node (с Scheduler)</h3>
      <p>Node ID: {nodeId}</p>
      <p>Статус: {isInitialized ? '✅ Инициализирован' : '⏳ Загрузка...'}</p>
      
      <div style={{ marginBottom: '1rem' }}>
        <textarea 
          value={code}
          onChange={(e) => setCode(e.target.value)}
          rows={3}
          style={{ width: '100%', padding: '0.5rem' }}
          placeholder="Введите Strudel код (например: note('c4 e4 g4').s('sine'))"
        />
      </div>

      <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1rem', flexWrap: 'wrap' }}>
        <button 
          onClick={handlePlay} 
          disabled={!isInitialized || isPlaying}
          style={{ padding: '0.5rem 1rem', backgroundColor: isPlaying ? '#ccc' : '#4CAF50', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          {isPlaying ? 'Играет...' : '▶️ Play'}
        </button>
        
        <button 
          onClick={handleStop}
          disabled={!isPlaying}
          style={{ padding: '0.5rem 1rem', backgroundColor: '#f44336', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          ⏹️ Stop
        </button>

        <button 
          onClick={testMidi}
          disabled={!isInitialized}
          style={{ padding: '0.5rem 1rem', backgroundColor: '#2196F3', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          🎵 Test MIDI
        </button>

        <button 
          onClick={checkSystem}
          style={{ padding: '0.5rem 1rem', backgroundColor: '#9C27B0', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          🔍 Check System
        </button>
      </div>

      <div style={{ fontSize: '0.9rem', color: '#666' }}>
        <p>AudioContext: {audioContextRef.current?.state || 'не создан'}</p>
        <p>Scheduler: {schedulerRef.current ? '✅ Создан' : '❌ Не создан'}</p>
        <p>Бандл: {window.__strudelCustomBundleLoaded ? '✅ Кастомный' : '⚠️ Загрузка...'}</p>
      </div>
    </div>
  );
};
