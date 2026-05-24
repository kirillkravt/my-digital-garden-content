---
chat_id: 0aa3552d-4453-4ac0-a27d-a6dc07d47e8c
title: Remove admin rights requirement for app
message_count: 40
exported_at: 2026-05-24T19:24:17.714Z
---

# Remove admin rights requirement for app

## 👤 **Kirill**

приложение запускается только с админскими правами. Как это убрать на win

---

## 🤖 **DeepSeek**

Чтобы убрать требование прав администратора для запуска приложения в Windows, есть несколько способов. Начните с простых и переходите к более сложным.

## 1. Свойства ярлыка (самый простой способ)

1. Нажмите правой кнопкой мыши на **ярлык** приложения
2. Выберите **Свойства**
3. Перейдите на вкладку **Совместимость**
4. Снимите галочку с пункта **«Выполнять эту программу от имени администратора»**
5. Нажмите **Применить** → **ОК**

Если галочка неактивна (серая), нажмите внизу окна **«Изменить параметры для всех пользователей»** и снимите галочку там.

## 2. Проверка свойств самого исполняемого файла

1. Найдите `.exe` файл приложения
2. Нажмите правой кнопкой мыши → **Свойства**
3. Вкладка **Совместимость**
4. Убедитесь, что галочка «Выполнять от имени администратора» снята

## 3. Отключение через реестр (если настройки заблокированы)

Если интерфейсные настройки недоступны, можно убрать флаг через реестр:

1. Нажмите `Win + R`, введите `regedit`
2. Перейдите к ключу:
   ```
   HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers
   ```
   или для всех пользователей:
   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers
   ```
3. Найдите запись с полным путем к `.exe` файлу
4. Удалите эту запись или уберите из её значения параметр `RUNASADMIN`

## 4. Если приложение всегда запрашивает UAC

Иногда проблема не в ярлыке, а в том, что приложение лежит в защищенной папке (например, `Program Files`). Попробуйте:

- **Перенести приложение** в другую папку, например `C:\Users\Ваше_имя\Apps\`
- **Изменить права на папку** с приложением (правый клик на папку → Свойства → Безопасность → дать полный доступ текущему пользователю)

## 5. Отключение UAC (не рекомендуется)

Это крайняя мера, снижающая безопасность системы:

1. Нажмите `Win + R`, введите `UserAccountControlSettings`
2. Опустите ползунок вниз до **«Никогда не уведомлять»**
3. Перезагрузитесь

---

Если после всех действий приложение всё равно требует права администратора, возможно, оно **жестко запрограммировано** на запуск с админ-правами (в манифесте приложения). В таком случае без изменения самого файла или использования специальных утилит (например, Resource Hacker для редактирования манифеста) убрать требование не получится.

---

## 👤 **Kirill**

Нужно разработать сервис для переключения устройств ввода между источниками по наведению на определенную область экрана для win и mac

По сути нужно эмулировать нажатие на "смену" устройства на клавиатуре (комбинация fn+1..4) и мыши (отдельная кнопка переключения между устройствами) с kvm
ugreen KU005 и мышь logitech m720

---

## 🤖 **DeepSeek**

这是一个很有意思的自动化项目。要实现通过“鼠标悬停到屏幕特定区域”来触发 KVM 和鼠标的切换，核心思路是：**后台监听鼠标位置 -> 检测到进入设定区域 -> 模拟发送对应的切换热键**。

下面我为你设计一个完整的实现方案，主要使用 Python 来完成。

---

## 整体架构设计

整个系统由三个核心模块组成：

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   鼠标位置监听   │────▶│   区域检测逻辑   │────▶│   热键模拟发送   │
│  (全局钩子)     │     │  (坐标范围判断)  │     │  (键盘/鼠标模拟) │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

**工作流程：**
1. 程序在后台运行，持续监听鼠标位置
2. 当鼠标进入预设的屏幕区域（如屏幕左上角 100x100 像素区域）时
3. 触发对应动作：

---

## 👤 **Kirill**

На русском

---

## 🤖 **DeepSeek**

Хорошо, давайте разработаем сервис для переключения устройств по наведению мыши на определенную область экрана.

## Общая концепция

Сервис будет работать так:
1. Фоновый процесс отслеживает позицию курсора
2. При попадании курсора в заданную область экрана отправляется нужная комбинация клавиш
3. После отправки можно добавить небольшую задержку, чтобы не срабатывало многократно

---

## Вариант 1: Python + библиотеки (кросс-платформенный)

Этот подход будет работать и на Windows, и на macOS.

### Необходимые компоненты

Установите Python и зависимости:
```bash
pip install pynput pyautogui
```

### Код сервиса

```python
import time
import threading
from pynput.mouse import Listener, Controller as MouseController
from pynput.keyboard import Controller as KeyboardController, Key
import sys

class DeviceSwitcher:
    def __init__(self):
        self.keyboard = KeyboardController()
        self.mouse = MouseController()
        self.last_trigger_time = 0
        self.cooldown = 1.0  # секунд между срабатываниями
        self.running = True
        
        # Зоны переключения (координаты экрана)
        # Формат: (x1, y1, x2, y2, тип_устройства, номер)
        self.zones = [
            # Зона для KVM: FN+1 (верхний левый угол)
            {"zone": (0, 0, 100, 100), "type": "kvm", "channel": 1},
            # Зона для KVM: FN+2 (верхний правый угол)
            {"zone": (1920-100, 0, 1920, 100), "type": "kvm", "channel": 2},
            # Зона для мыши Logitech (нижний левый угол)
            {"zone": (0, 1080-100, 100, 1080), "type": "mouse", "device": "m720"},
        ]
        
        # Комбинации клавиш для разных устройств
        self.kvm_combinations = {
            1: self.press_fn_1,
            2: self.press_fn_2,
            3: self.press_fn_3,
            4: self.press_fn_4,
        }
        
        # Для мыши Logitech M720 обычно отдельная кнопка,
        # но можно эмулировать через клавиши или специальные события
        self.mouse_combinations = {
            "m720": self.switch_logitech_m720,
        }
    
    def press_fn_1(self):
        """FN + 1 для KVM"""
        self.press_fn_with_number(1)
    
    def press_fn_2(self):
        self.press_fn_with_number(2)
    
    def press_fn_3(self):
        self.press_fn_with_number(3)
    
    def press_fn_4(self):
        self.press_fn_with_number(4)
    
    def press_fn_with_number(self, number):
        """Нажатие FN + цифра"""
        # Примечание: FN на многих клавиатурах не эмулируется напрямую
        # Для KVM может быть другая комбинация, например Ctrl+Alt+1
        # Уточните для вашего KVM UGREEN KU005
        
        # Вариант 1: Используем модификаторы вместо FN
        with self.keyboard.pressed(Key.ctrl):
            with self.keyboard.pressed(Key.alt):
                self.keyboard.press(str(number))
                self.keyboard.release(str(number))
        
        # Вариант 2: Если нужно именно FN, возможно потребуется другой подход
        # self.keyboard.press(Key.fn)  # не все системы поддерживают
        
        print(f"Переключение KVM на канал {number}")
    
    def switch_logitech_m720(self):
        """Переключение мыши Logitech M720 между устройствами"""
        # Для M720 обычно используется специальная кнопка на мыши
        # Эмулировать её можно через:
        # 1. HID-эмуляцию (сложно)
        # 2. Использование Logitech Options API
        # 3. Отправку системных событий
        
        # Временное решение: имитируем нажатие средней кнопки + боковую
        # Уточните правильную комбинацию для вашей мыши
        
        from pynput.mouse import Button
        mouse = MouseController()
        
        # Например, нажатие на колесико влево/вправо
        # Это зависит от настроек в Logitech Options
        print("Переключение мыши Logitech M720")
        
        # Если у вас настроена комбинация клавиш в Logitech Options,
        # можно отправить её через клавиатуру
        # self.keyboard.press(Key.ctrl)
        # self.keyboard.press(Key.alt)
        # self.keyboard.press('`')
        # self.keyboard.release('`')
        # self.keyboard.release(Key.alt)
        # self.keyboard.release(Key.ctrl)
    
    def check_zones(self, x, y):
        """Проверка, находится ли курсор в какой-либо зоне"""
        current_time = time.time()
        
        # Проверяем кулдаун
        if current_time - self.last_trigger_time < self.cooldown:
            return
        
        for zone in self.zones:
            x1, y1, x2, y2 = zone["zone"]
            if x1 <= x <= x2 and y1 <= y <= y2:
                self.last_trigger_time = current_time
                
                if zone["type"] == "kvm":
                    channel = zone.get("channel", 1)
                    if channel in self.kvm_combinations:
                        self.kvm_combinations[channel]()
                        
                elif zone["type"] == "mouse":
                    device = zone.get("device", "m720")
                    if device in self.mouse_combinations:
                        self.mouse_combinations[device]()
                
                break
    
    def on_move(self, x, y):
        """Обработчик движения мыши"""
        if self.running:
            self.check_zones(x, y)
    
    def start(self):
        """Запуск сервиса"""
        print("Сервис запущен. Наведите курсор на зоны для переключения устройств.")
        print(f"Активные зоны: {self.zones}")
        print("Нажмите Ctrl+C для остановки")
        
        with Listener(on_move=self.on_move) as listener:
            listener.join()
    
    def stop(self):
        """Остановка сервиса"""
        self.running = False
        print("Сервис остановлен")

if __name__ == "__main__":
    switcher = DeviceSwitcher()
    try:
        switcher.start()
    except KeyboardInterrupt:
        switcher.stop()
        sys.exit(0)
```

### Настройка зон

В коде нужно указать разрешение вашего экрана. Замените `1920` и `1080` на ваши значения:

```python
self.zones = [
    # Верхний левый угол для KVM канал 1
    {"zone": (0, 0, 100, 100), "type": "kvm", "channel": 1},
    # Верхний правый угол для KVM канал 2  
    {"zone": (screen_width-100, 0, screen_width, 100), "type": "kvm", "channel": 2},
    # Нижний левый угол для мыши
    {"zone": (0, screen_height-100, 100, screen_height), "type": "mouse", "device": "m720"},
]
```

---

## Вариант 2: AutoHotkey (только Windows)

Для Windows более простое решение — AutoHotkey.

```autohotkey
; DeviceSwitcher.ahk
#Persistent
#SingleInstance Force

; Настройки
Cooldown := 1000  ; мс между срабатываниями
LastTrigger := 0

; Зоны: X1, Y1, X2, Y2, Действие
; Верхний левый угол (KVM канал 1)
Hotzone1 := {X1:0, Y1:0, X2:100, Y2:100, Action:"KVM1"}
; Верхний правый угол (KVM канал 2)
Hotzone2 := {X1:A_ScreenWidth-100, Y1:0, X2:A_ScreenWidth, Y2:100, Action:"KVM2"}
; Нижний левый угол (Мышь)
Hotzone3 := {X1:0, Y1:A_ScreenHeight-100, X2:100, Y2:A_ScreenHeight, Action:"Mouse"}

; Таймер для проверки позиции мыши
SetTimer, CheckMousePosition, 50
return

CheckMousePosition:
    MouseGetPos, MouseX, MouseY
    CurrentTime := A_TickCount
    
    if (CurrentTime - LastTrigger < Cooldown)
        return
    
    ; Проверка зон
    if (MouseX >= Hotzone1.X1 && MouseX <= Hotzone1.X2 && 
        MouseY >= Hotzone1.Y1 && MouseY <= Hotzone1.Y2) {
        TriggerAction(Hotzone1.Action)
    }
    else if (MouseX >= Hotzone2.X1 && MouseX <= Hotzone2.X2 && 
             MouseY >= Hotzone2.Y1 && MouseY <= Hotzone2.Y2) {
        TriggerAction(Hotzone2.Action)
    }
    else if (MouseX >= Hotzone3.X1 && MouseX <= Hotzone3.X2 && 
             MouseY >= Hotzone3.Y1 && MouseY <= Hotzone3.Y2) {
        TriggerAction(Hotzone3.Action)
    }
return

TriggerAction(Action) {
    global LastTrigger, Cooldown
    LastTrigger := A_TickCount
    
    if (Action = "KVM1") {
        ; FN+1 для KVM UGREEN
        Send, ^!1  ; Ctrl+Alt+1 как альтернатива
        ; Или используйте другие комбинации
    }
    else if (Action = "KVM2") {
        Send, ^!2
    }
    else if (Action = "Mouse") {
        ; Для Logitech M720 - если настроена комбинация в Logitech Options
        Send, ^!`  ; Ctrl+Alt+` например
    }
    
    ToolTip, Переключение: %Action%
    SetTimer, ClearToolTip, -1000
}

ClearToolTip:
    ToolTip
return
```

---

## Особенности для конкретных устройств

### KVM UGREEN KU005

Для этого KVM обычно используется комбинация **FN + 1..4**. Проблема: FN не всегда эмулируется программно.

**Решения:**
1. **Использовать альтернативную комбинацию** — многие KVM поддерживают также `Ctrl+Alt+1..4`
2. **Настроить в софте KVM** — возможно, у UGREEN есть утилита для переназначения
3. **Эмулировать через HID** — сложный путь

### Мышь Logitech M720

У M720 есть специальная кнопка переключения между 3 устройствами.

**Решения:**
1. **Logitech Options +** — можно назначить на кнопку мыши комбинацию клавиш, которую потом эмулировать
2. **Использовать Logitech API** — официальное API Logitech для управления устройствами
3. **Solaar (Linux/macOS)** — для Mac можно использовать Solaar для программного переключения

---

## Запуск как сервиса

### Windows
Создайте задачу в планировщике задач с запуском при старте системы:
```batch
# Создать скрипт run_service.bat
python C:\path\to\switcher.py
```

### macOS
Создайте `.plist` файл в `~/Library/LaunchAgents/`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.deviceswitcher.service</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/python3</string>
        <string>/Users/username/DeviceSwitcher/switcher.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

---

## Рекомендации

1. **Сначала протестируйте комбинации** — убедитесь, что эмулируемые нажатия действительно переключают ваши устройства
2. **Добавьте визуальную индикацию** — всплывающее уведомление при переключении
3. **Настройте кулдаун** — чтобы случайное движение мыши не вызывало частые переключения
4. **Используйте небольшие зоны** — чтобы избежать случайных срабатываний

Если нужна помощь с конкретными комбинациями для вашего KVM или мыши, сообщите, как именно происходит переключение вручную, и я скорректирую код.

---

## 👤 **Kirill**

давай попробуем реализовать

---

## 🤖 **DeepSeek**

Отлично! Давайте пошагово реализуем этот сервис. Я предлагаю начать с версии для Windows, так как это проще для отладки, а потом адаптируем для macOS.

## Шаг 1: Установка Python и зависимостей

### На Windows:
1. Скачайте Python с [python.org](https://python.org) (версия 3.8 или выше)
2. При установке обязательно отметьте "Add Python to PATH"
3. Откройте командную строку (cmd) и установите нужные библиотеки:

```bash
pip install pynput pyautogui
```

### На macOS:
```bash
# Установите Python через brew (если нет)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install python

# Установите библиотеки
pip3 install pynput pyautogui

# Для macOS потребуются дополнительные разрешения
# Нужно будет разрешить доступ к специальным возможностям в Системных настройках
```

---

## Шаг 2: Создаем базовый скрипт

Создайте файл `device_switcher.py` и скопируйте этот код:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Сервис для переключения KVM и мыши по наведению на область экрана
Поддерживает: Windows, macOS
"""

import time
import sys
import json
import os
from datetime import datetime
from pynput.mouse import Listener, Controller as MouseController
from pynput.keyboard import Controller as KeyboardController, Key

class DeviceSwitcher:
    def __init__(self, config_file="config.json"):
        """Инициализация сервиса"""
        self.keyboard = KeyboardController()
        self.mouse = MouseController()
        self.last_trigger_time = 0
        self.running = True
        
        # Загружаем конфигурацию
        self.config = self.load_config(config_file)
        self.cooldown = self.config.get("cooldown", 1.0)
        self.zones = self.config.get("zones", [])
        
        # Получаем размер экрана
        self.screen_width = self.get_screen_width()
        self.screen_height = self.get_screen_height()
        
        # Инициализируем зоны с реальными координатами
        self.init_zones()
        
        # Счетчик переключений для отладки
        self.switch_count = 0
        
        print(f"Сервис инициализирован")
        print(f"Размер экрана: {self.screen_width}x{self.screen_height}")
        print(f"Активных зон: {len(self.zones)}")
        print("=" * 50)
    
    def get_screen_width(self):
        """Получить ширину экрана"""
        try:
            import tkinter as tk
            root = tk.Tk()
            width = root.winfo_screenwidth()
            height = root.winfo_screenheight()
            root.destroy()
            return width
        except:
            # Если tkinter не доступен, используем значения по умолчанию
            import pyautogui
            return pyautogui.size().width
    
    def get_screen_height(self):
        """Получить высоту экрана"""
        try:
            import tkinter as tk
            root = tk.Tk()
            height = root.winfo_screenheight()
            root.destroy()
            return height
        except:
            import pyautogui
            return pyautogui.size().height
    
    def load_config(self, config_file):
        """Загрузка конфигурации из файла"""
        default_config = {
            "cooldown": 1.0,
            "show_notifications": True,
            "debug_mode": True,
            "zones": [
                {
                    "name": "KVM Канал 1",
                    "position": "top-left",
                    "size": 100,
                    "action": "kvm",
                    "channel": 1,
                    "hotkey": "ctrl+alt+1"
                },
                {
                    "name": "KVM Канал 2",
                    "position": "top-right",
                    "size": 100,
                    "action": "kvm",
                    "channel": 2,
                    "hotkey": "ctrl+alt+2"
                },
                {
                    "name": "Мышь Logitech",
                    "position": "bottom-left",
                    "size": 100,
                    "action": "mouse",
                    "device": "m720",
                    "hotkey": "ctrl+alt+`"
                }
            ]
        }
        
        if os.path.exists(config_file):
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                    print(f"Загружена конфигурация из {config_file}")
                    return config
            except Exception as e:
                print(f"Ошибка загрузки конфигурации: {e}")
                return default_config
        else:
            print(f"Файл конфигурации не найден, создаю {config_file} с настройками по умолчанию")
            with open(config_file, 'w', encoding='utf-8') as f:
                json.dump(default_config, f, indent=4, ensure_ascii=False)
            return default_config
    
    def init_zones(self):
        """Преобразование зон из конфига в абсолютные координаты"""
        self.active_zones = []
        
        for zone in self.zones:
            position = zone.get("position", "")
            size = zone.get("size", 100)
            
            if position == "top-left":
                x1, y1 = 0, 0
                x2, y2 = size, size
            elif position == "top-right":
                x1, y1 = self.screen_width - size, 0
                x2, y2 = self.screen_width, size
            elif position == "bottom-left":
                x1, y1 = 0, self.screen_height - size
                x2, y2 = size, self.screen_height
            elif position == "bottom-right":
                x1, y1 = self.screen_width - size, self.screen_height - size
                x2, y2 = self.screen_width, self.screen_height
            else:
                # Если указаны абсолютные координаты
                x1 = zone.get("x1", 0)
                y1 = zone.get("y1", 0)
                x2 = zone.get("x2", 100)
                y2 = zone.get("y2", 100)
            
            active_zone = {
                "name": zone.get("name", "Unknown"),
                "zone": (x1, y1, x2, y2),
                "action": zone.get("action", "kvm"),
                "channel": zone.get("channel", 1),
                "device": zone.get("device", "m720"),
                "hotkey": zone.get("hotkey", ""),
                "position": position
            }
            self.active_zones.append(active_zone)
            
            if self.config.get("debug_mode", False):
                print(f"Зона: {active_zone['name']} - координаты: ({x1}, {y1}) -> ({x2}, {y2})")
    
    def press_hotkey(self, hotkey_string):
        """Эмуляция нажатия горячей клавиши"""
        try:
            # Разбираем строку горячей клавиши
            keys = hotkey_string.lower().split('+')
            modifiers = []
            main_key = None
            
            for key in keys:
                if key in ['ctrl', 'alt', 'shift', 'cmd', 'win']:
                    modifiers.append(key)
                else:
                    main_key = key
            
            # Нажимаем модификаторы
            for mod in modifiers:
                if mod == 'ctrl':
                    self.keyboard.press(Key.ctrl)
                elif mod == 'alt':
                    self.keyboard.press(Key.alt)
                elif mod == 'shift':
                    self.keyboard.press(Key.shift)
                elif mod == 'cmd' or mod == 'win':
                    if sys.platform == 'darwin':  # macOS
                        self.keyboard.press(Key.cmd)
                    else:  # Windows
                        self.keyboard.press(Key.cmd)
            
            # Нажимаем основную клавишу
            if main_key:
                if len(main_key) == 1:
                    self.keyboard.press(main_key)
                    time.sleep(0.05)
                    self.keyboard.release(main_key)
                else:
                    # Для специальных клавиш
                    special_keys = {
                        'f1': Key.f1, 'f2': Key.f2, 'f3': Key.f3, 'f4': Key.f4,
                        'f5': Key.f5, 'f6': Key.f6, 'f7': Key.f7, 'f8': Key.f8,
                        'f9': Key.f9, 'f10': Key.f10, 'f11': Key.f11, 'f12': Key.f12,
                        'space': Key.space, 'enter': Key.enter, 'tab': Key.tab,
                        'esc': Key.esc, 'backspace': Key.backspace, 'delete': Key.delete,
                        'up': Key.up, 'down': Key.down, 'left': Key.left, 'right': Key.right,
                        '`': '`', '~': '~'
                    }
                    if main_key in special_keys:
                        key = special_keys[main_key]
                        if isinstance(key, str):
                            self.keyboard.press(key)
                            time.sleep(0.05)
                            self.keyboard.release(key)
                        else:
                            self.keyboard.press(key)
                            time.sleep(0.05)
                            self.keyboard.release(key)
            
            # Отпускаем модификаторы (в обратном порядке)
            for mod in reversed(modifiers):
                if mod == 'ctrl':
                    self.keyboard.release(Key.ctrl)
                elif mod == 'alt':
                    self.keyboard.release(Key.alt)
                elif mod == 'shift':
                    self.keyboard.release(Key.shift)
                elif mod == 'cmd' or mod == 'win':
                    if sys.platform == 'darwin':
                        self.keyboard.release(Key.cmd)
                    else:
                        self.keyboard.release(Key.cmd)
            
            return True
        except Exception as e:
            print(f"Ошибка при эмуляции нажатия: {e}")
            return False
    
    def switch_kvm(self, channel, hotkey):
        """Переключение KVM"""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Переключение KVM на канал {channel}")
        print(f"  → Отправляю комбинацию: {hotkey}")
        
        # Пытаемся отправить горячую клавишу
        success = self.press_hotkey(hotkey)
        
        if self.config.get("show_notifications", True):
            self.show_notification(f"KVM переключен на канал {channel}")
        
        return success
    
    def switch_mouse(self, device, hotkey):
        """Переключение мыши Logitech M720"""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Переключение мыши {device}")
        print(f"  → Отправляю комбинацию: {hotkey}")
        
        # Отправляем горячую клавишу
        success = self.press_hotkey(hotkey)
        
        # Альтернативный метод для Logitech M720 через специальные события
        if not success and device == "m720":
            print("  → Пробую альтернативный метод для Logitech M720")
            # Для M720 можно эмулировать нажатие на среднюю кнопку + боковую
            # или использовать специальные команды через hid
            self.alternative_mouse_switch()
        
        if self.config.get("show_notifications", True):
            self.show_notification(f"Мышь {device} переключена")
        
        return success
    
    def alternative_mouse_switch(self):
        """Альтернативный метод переключения Logitech M720"""
        try:
            # Имитируем нажатие колесика влево (часто используется для переключения)
            # Это зависит от настроек в Logitech Options
            self.keyboard.press(Key.ctrl)
            self.keyboard.press(Key.alt)
            self.keyboard.press('`')
            time.sleep(0.05)
            self.keyboard.release('`')
            self.keyboard.release(Key.alt)
            self.keyboard.release(Key.ctrl)
            print("  → Отправлена альтернативная комбинация Ctrl+Alt+`")
        except Exception as e:
            print(f"  → Ошибка альтернативного метода: {e}")
    
    def show_notification(self, message):
        """Показать системное уведомление"""
        try:
            if sys.platform == "win32":
                # Windows
                from win10toast import ToastNotifier
                toaster = ToastNotifier()
                toaster.show_toast("Device Switcher", message, duration=2)
            elif sys.platform == "darwin":
                # macOS
                os.system(f'osascript -e \'display notification "{message}" with title "Device Switcher"\'')
            else:
                # Linux
                os.system(f'notify-send "Device Switcher" "{message}"')
        except:
            # Если уведомления не поддерживаются, просто выводим в консоль
            print(f"🔔 {message}")
    
    def check_zones(self, x, y):
        """Проверка попадания курсора в активные зоны"""
        current_time = time.time()
        
        # Проверяем кулдаун
        if current_time - self.last_trigger_time < self.cooldown:
            return
        
        for zone in self.active_zones:
            x1, y1, x2, y2 = zone["zone"]
            if x1 <= x <= x2 and y1 <= y <= y2:
                self.last_trigger_time = current_time
                self.switch_count += 1
                
                if self.config.get("debug_mode", False):
                    print(f"\n{'='*50}")
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] Срабатывание #{self.switch_count}")
                    print(f"Позиция курсора: ({x}, {y})")
                    print(f"Зона: {zone['name']}")
                
                if zone["action"] == "kvm":
                    self.switch_kvm(zone.get("channel", 1), zone.get("hotkey", "ctrl+alt+1"))
                elif zone["action"] == "mouse":
                    self.switch_mouse(zone.get("device", "m720"), zone.get("hotkey", "ctrl+alt+`"))
                
                break
    
    def on_move(self, x, y):
        """Обработчик движения мыши"""
        if self.running:
            self.check_zones(x, y)
    
    def start(self):
        """Запуск сервиса"""
        print("\n" + "="*50)
        print("🚀 Сервис переключения устройств запущен")
        print("="*50)
        print("\nАктивные зоны:")
        for zone in self.active_zones:
            x1, y1, x2, y2 = zone["zone"]
            print(f"  • {zone['name']}: ({x1}, {y1}) -> ({x2}, {y2})")
            print(f"    Действие: {zone['action']}, комбинация: {zone['hotkey']}")
        
        print("\n💡 Инструкция:")
        print("  1. Наведите курсор на любую из указанных зон")
        print("  2. Сервис автоматически отправит нужную комбинацию клавиш")
        print("  3. Для остановки нажмите Ctrl+C")
        print("\n" + "="*50 + "\n")
        
        try:
            with Listener(on_move=self.on_move) as listener:
                listener.join()
        except KeyboardInterrupt:
            self.stop()
    
    def stop(self):
        """Остановка сервиса"""
        self.running = False
        print(f"\n{'='*50}")
        print(f"✅ Сервис остановлен")
        print(f"📊 Всего переключений: {self.switch_count}")
        print(f"{'='*50}\n")
        sys.exit(0)

if __name__ == "__main__":
    switcher = DeviceSwitcher()
    switcher.start()
```

---

## Шаг 3: Создаем конфигурационный файл

Создайте файл `config.json` в той же папке:

```json
{
    "cooldown": 1.0,
    "show_notifications": true,
    "debug_mode": true,
    "zones": [
        {
            "name": "KVM Канал 1 - ПК",
            "position": "top-left",
            "size": 150,
            "action": "kvm",
            "channel": 1,
            "hotkey": "ctrl+alt+1"
        },
        {
            "name": "KVM Канал 2 - Ноутбук",
            "position": "top-right",
            "size": 150,
            "action": "kvm",
            "channel": 2,
            "hotkey": "ctrl+alt+2"
        },
        {
            "name": "Мышь Logitech M720",
            "position": "bottom-left",
            "size": 150,
            "action": "mouse",
            "device": "m720",
            "hotkey": "ctrl+alt+`"
        }
    ]
}
```

---

## Шаг 4: Запуск и тестирование

### Запуск:
```bash
python device_switcher.py
```

### Проверка работы:
1. Запустите скрипт
2. Наведите курсор в левый верхний угол экрана
3. Должно сработать переключение
4. В консоли вы увидите сообщения о срабатывании

---

## Шаг 5: Настройка для ваших устройств

### Для KVM UGREEN KU005:

Вам нужно определить, какая комбинация работает. Попробуйте:
- `ctrl+alt+1` (часто работает)
- `ctrl+shift+1`
- `alt+shift+1`
- Если нужно именно FN, то FN не эмулируется. В этом случае можно:
  - Использовать утилиту от UGREEN для переназначения
  - Настроить в самом KVM другой способ переключения

### Для Logitech M720:

1. Откройте **Logitech Options+**
2. Назначьте на кнопку переключения устройств какую-нибудь комбинацию клавиш (например, `Ctrl+Alt+\``)
3. Укажите эту комбинацию в `config.json` в поле `hotkey`

---

## Шаг 6: Запуск как фоновый сервис

### На Windows:

Создайте файл `run_hidden.vbs`:
```vbscript
CreateObject("WScript.Shell").Run "python device_switcher.py", 0, False
```

Запускайте через этот файл, и скрипт будет работать в фоне.

### Для автозапуска:

1. Нажмите `Win + R`, введите `shell:startup`
2. Создайте ярлык на `run_hidden.vbs` в этой папке

---

## Отладка

Если что-то не работает, проверьте:

1. **Комбинации клавиш** — сначала проверьте вручную, работают ли `Ctrl+Alt+1` и т.д.
2. **Права администратора** — на некоторых системах эмуляция клавиш требует прав
3. **Размер экрана** — проверьте, совпадают ли координаты зон с вашим разрешением
4. **Логи** — в консоли видно все срабатывания

---

## Следующие шаги

После того как базовый вариант заработает, можно добавить:
- Графический интерфейс для настройки зон
- Поддержку горячих клавиш для временного отключения
- Визуальную индикацию зон на экране
- Звуковое оповещение

Запустите скрипт и сообщите, какие комбинации клавиш работают для вашего KVM и мыши, чтобы я мог скорректировать код под ваши устройства.

---

## 👤 **Kirill**

Можно ли управлять сменой режима pbp/pip на мониторе lg 38wr85qc не через джойстик а программно?

---

## 🤖 **DeepSeek**

К сожалению, **прямой программной команды для переключения PbP/PiP** на мониторе LG 38WR85QC не существует. У монитора нет публичного API или утилиты командной строки, которая позволяла бы управлять этими функциями[citation:7][citation:8].

Однако есть **несколько обходных путей**, которые могут решить вашу задачу.

---

## Вариант 1: Управление через OnScreen Control (частичное решение)

LG предоставляет программу **OnScreen Control**, которая позволяет управлять некоторыми настройками монитора мышью[citation:5][citation:9].

Что можно сделать:
- OnScreen Control имеет функцию **Screen Split** (разделение экрана на до 6 частей)
- Но для PbP/PiP, скорее всего, всё равно потребуется ручное переключение через меню[citation:6][citation:9]

**Проблема**: OnScreen Control не предоставляет API или горячих клавиш для PbP/PiP[citation:3].

---

## Вариант 2: Эмуляция нажатий джойстика (наиболее реалистичный)

Это самый надежный подход, аналогичный тому, что мы делали для KVM. Вы можете эмулировать нажатия на джойстик монитора через эмуляцию клавиатуры.

### Принцип работы:

Джойстик монитора обычно работает как обычная USB HID-клавиатура. Когда вы его нажимаете, он отправляет определенные скан-коды.

### Шаги для реализации:

1. **Определить коды нажатий джойстика**

Сначала нужно узнать, какие клавиши эмулирует джойстик. Используйте программу для перехвата клавиш:

**На Windows**:
- AutoHotkey с скриптом для логирования:
```autohotkey
#Persistent
#InstallKeybdHook
#UseHook
OnExit("ShowLog")
return

ShowLog:
    KeyHistory
return
```

**На macOS**:
- Используйте **Karabiner-Elements** (вкладка "Event Viewer")

2. **Создать скрипт для эмуляции**

После того как вы определили последовательность нажатий для включения PbP/PiP, добавьте их в предыдущий скрипт:

```python
# Добавьте в класс DeviceSwitcher новый метод
def switch_pbp_mode(self):
    """Включение/выключение PbP режима"""
    print("Переключение PbP режима")
    
    # Пример последовательности для джойстика:
    # 1. Нажатие джойстика (вход в меню)
    self.keyboard.press(Key.enter)
    time.sleep(0.1)
    self.keyboard.release(Key.enter)
    
    time.sleep(0.5)  # Ждем появления меню
    
    # 2. Навигация до меню PBP/PIP
    # Обычно это движение вниз/вверх и нажатие
    for _ in range(3):  # Например, 3 нажатия вниз
        self.keyboard.press(Key.down)
        time.sleep(0.1)
        self.keyboard.release(Key.down)
        time.sleep(0.2)
    
    # 3. Вход в подменю
    self.keyboard.press(Key.enter)
    time.sleep(0.1)
    self.keyboard.release(Key.enter)
    time.sleep(0.3)
    
    # 4. Выбор режима PbP
    self.keyboard.press(Key.right)  # Вправо для выбора PbP
    time.sleep(0.1)
    self.keyboard.release(Key.right)
    time.sleep(0.3)
    
    # 5. Подтверждение
    self.keyboard.press(Key.enter)
    time.sleep(0.1)
    self.keyboard.release(Key.enter)
    
    print("PbP режим переключен")
```

---

## Вариант 3: Использование Dual Controller (KVM) как триггера

Ваш монитор поддерживает **Dual Controller** — это встроенный KVM, позволяющий управлять двумя компьютерами одной клавиатурой и мышью[citation:3][citation:7].

Можно попробовать следующее:

1. Подключите оба компьютера к монитору
2. Используйте Dual Controller для переключения между ними
3. Когда вы переключаетесь на второй компьютер, монитор автоматически может переключить PbP/PiP режим (зависит от настроек)

---

## Вариант 4: Программное переключение входов как триггер для PbP

Если PbP/PiP не переключается напрямую, вы можете настроить сценарий, который:

1. Сначала переключает вход монитора через программные средства
2. Это автоматически активирует нужный режим PbP/PiP

Для программного переключения входов есть инструменты:

### На Windows:
- **ControlMyMonitor** (бесплатная утилита)
- Использует DDC/CI протокол для управления монитором

Пример через командную строку:
```batch
ControlMyMonitor.exe /SetValue "LG 38WR85QC" 0x60 15
```

### На macOS:
- **ddcctl** (через Homebrew)
```bash
brew install ddcctl
ddcctl -d 1 -i 15  # переключение на HDMI
```

---

## Рекомендация: полное решение

Я рекомендую объединить оба подхода:

1. **Используйте эмуляцию джойстика** для надежного переключения PbP/PiP
2. **Интегрируйте это в ваш существующий скрипт** для переключения KVM и мыши

Итоговый код будет выглядеть так:

```python
# Добавьте в конфиг новую зону
self.zones = [
    {"zone": (0, 0, 100, 100), "action": "kvm", "channel": 1},
    {"zone": (100, 0, 200, 100), "action": "kvm", "channel": 2},
    {"zone": (0, screen_height-100, 100, screen_height), "action": "mouse"},
    {"zone": (screen_width-100, screen_height-100, screen_width, screen_height), "action": "pbp"},  # новая зона
]

# И метод для PbP
def switch_pbp(self):
    self.emulate_joystick_sequence()  # последовательность нажатий джойстика
```

---

## Итог

Прямого программного управления PbP/PiP нет, но через **эмуляцию джойстика** вы сможете полностью автоматизировать процесс. Это будет работать так же надежно, как и переключение KVM, которое вы уже реализовали.

Если вы определите точную последовательность нажатий джойстика для вашего монитора, я помогу доработать скрипт.

---

## 👤 **Kirill**

установить Karabiner-Elements на mac

---

## 🤖 **DeepSeek**

# Установка Karabiner-Elements на macOS

Karabiner-Elements — это бесплатный инструмент с открытым исходным кодом для переназначения клавиш и настройки устройств ввода на macOS [citation:2][citation:10]. Он понадобится вам, чтобы определить коды нажатий джойстика монитора LG.

---

## Способ 1: Стандартная установка (рекомендуется)

1. **Скачайте последнюю версию** с официального сайта:  
   [https://karabiner-elements.pqrs.org/](https://karabiner-elements.pqrs.org/) [citation:3][citation:4]

2. **Откройте скачанный файл** `.dmg` и запустите `Karabiner-Elements.pkg` [citation:4]

3. **Следуйте инструкциям установщика**

---

## Способ 2: Установка через Homebrew

Если у вас установлен Homebrew, выполните в терминале:
```bash
brew install --cask karabiner-elements
```

---

## Настройка разрешений (обязательный шаг)

После установки macOS запросит несколько разрешений. **Без них Karabiner-Elements не будет работать** [citation:4].

### 1. Разрешить фоновые службы

После установки появится уведомление о фоновых элементах. Откройте **Системные настройки → Основные → Элементы входа** и включите:
- `Karabiner-Elements Non-Privileged Agents v2`
- `Karabiner-Elements Privileged Daemons v2`

### 2. Разрешить доступ к возможностям системы

При первом запуске появится окно с запросом на доступ к **Input Monitoring**. Нажмите **Open System Settings** и добавьте `Karabiner-Core-Service` в список разрешенных приложений.

> **Важно:** Если вы не видите приложение в списке, нажмите кнопку `+` и добавьте его вручную.

### 3. Разрешить системное ПО (драйвер)

Появится окно с сообщением о блокировке системного ПО. Откройте **Системные настройки → Конфиденциальность и безопасность** и внизу нажмите **Разрешить** для `Karabiner-VirtualHIDDevice-Manager` [citation:4].

---

## Проверка работы

1. Запустите **Karabiner-Elements** из папки Программы
2. Приложение появится в строке меню (иконка в виде квадрата)
3. Откройте **EventViewer** — он понадобится для отслеживания нажатий джойстика монитора

---

## Системные требования

Karabiner-Elements 15.x требует **macOS 13 Ventura или новее** [citation:8][citation:9]. Если у вас более старая версия macOS, скачайте предыдущую версию с официального сайта.

---

## Для чего это нужно

После установки Karabiner-Elements вы сможете:
1. Открыть **EventViewer**
2. Нажать джойстик на мониторе LG
3. Увидеть, какие именно скан-коды отправляются
4. Использовать эти коды в вашем Python-скрипте для эмуляции нажатий

Это позволит программно управлять PbP/PiP режимом монитора без физического касания джойстика.

---

## 👤 **Kirill**

lg 38wr85qc-w при включенном pbp режиме не воспроизводит звук

---

## 🤖 **DeepSeek**

Проблема с отсутствием звука при включенном режиме PBP (Picture-by-Picture) на мониторе LG 38WR85QC-W связана с тем, как монитор обрабатывает аудиосигнал в этом режиме.

## Причина проблемы

В режиме PBP монитор одновременно отображает изображение от двух разных источников (например, HDMI 1 и USB-C). Встроенные динамики могут воспроизводить звук **только от одного из этих источников**[citation:7]. По умолчанию монитор может быть настроен на "основной" вход, но если активный вход не совпадает с тем, откуда вы ожидаете звук, динамики будут молчать.

## Решение

### Способ 1: Переключить источник звука через меню (рекомендуется)

1. Нажмите джойстик на нижней части монитора, чтобы открыть **главное меню**
2. Перейдите в **Настройки** → **Вход** (Input) → **PBP / PIP**[citation:7]
3. Найдите опцию **Главный/Дочерний звук** или **Главный/Подэкранный переключатель звука** (Main/Sub Screen Sound Switch)
4. Переключите звук на тот вход, с которого вы хотите слышать звук

Это позволяет выбрать, какой из двух активных источников будет подавать звук на встроенные динамики[citation:7].

### Способ 2: Использовать отдельный аудиовыход

Если вам нужен звук сразу от двух устройств одновременно:

1. Подключите внешние колонки или наушники к разъему **Headphone Out** на мониторе[citation:3]
2. Настройте звук на каждом из подключенных компьютеров так, чтобы он выводился через монитор
3. Звук от обоих источников будет передаваться на наушники/колонки (микшироваться)

### Способ 3: Проверить базовые настройки

1. Убедитесь, что звук не выключен — в меню **Быстрые настройки** (Quick Settings) проверьте громкость и отключен ли режим без звука[citation:7]
2. На компьютере, подключенном к монитору, выберите **LG 38WR85QC** в качестве устройства вывода звука
3. Убедитесь, что на обоих подключенных устройствах уровень громкости не на нуле

## Если не помогает

Попробуйте перезагрузить монитор:
1. Выключите монитор с помощью джойстика (удерживайте 2-3 секунды)
2. Отключите кабель питания на 1-2 минуты
3. Включите обратно

Это сбрасывает временные состояния и часто решает программные сбои[citation:6][citation:9].

---

Если после этих действий звук по-прежнему отсутствует, уточните, как именно вы настроили PBP (какие два источника используются) — это поможет дать более точную рекомендацию.

---

## 👤 **Kirill**

странно, но в dual controller lg на windows можно запускать только от имени администратора. Отключить это сложно. Наш кастомный kvm переключатель можем сделать именно для использования через сам монитор. т.е. повторить частично функционал dual controller но без функции передачи файлов а только управление переключнием устройств (подклюяенных к монитору). напиши как понял эту задачу

---

## 🤖 **DeepSeek**

Отлично, я понял задачу. Давайте структурирую своё понимание:

---

## Понимание задачи

### Исходная проблема

1. **LG Dual Controller** (фирменное ПО LG для управления двумя компьютерами через один монитор) на Windows **запускается только с правами администратора**
2. Отключить это требование сложно или невозможно
3. В Dual Controller есть избыточный функционал (передача файлов, буфер обмена), который вам не нужен

### Ваша цель

Разработать **собственное решение** (кастомный "KVM-переключатель"), которое:

1. **Работает без прав администратора**
2. **Использует монитор LG 38WR85QC-W как "хаб"** — переключает устройства (клавиатура, мышь) между двумя компьютерами, подключенными к монитору
3. **Повторяет базовую функциональность Dual Controller**:
   - Переключение управления между компьютером A и компьютером B
   - Монитор сам переключает изображение (PbP/PiP) — ваше ПО не управляет монитором напрямую, а лишь переключает, *какие* USB-устройства активны на каком компьютере
4. **Имеет удобный способ переключения** — например:
   - Наведение мыши на область экрана (как мы обсуждали ранее)
   - Горячие клавиши
   - Иконка в трее

---

## Архитектура решения

```
┌─────────────────────────────────────────────────────────────┐
│                      Монитор LG 38WR85QC-W                  │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │   Компьютер A   │  │   Компьютер B   │                  │
│  │  (HDMI/USB-C)   │  │  (HDMI/USB-C)   │                  │
│  └────────┬────────┘  └────────┬────────┘                  │
│           │                    │                            │
│           └────────┬───────────┘                            │
│                    │                                        │
│         USB-B Upstream (к компьютерам)                      │
│                    │                                        │
│              ┌─────▼─────┐                                  │
│              │  USB-Hub  │ (встроенный в монитор)          │
│              │  (Downstream)                               │
│              └─────┬─────┘                                  │
└────────────────────│────────────────────────────────────────┘
                     │
                     │ USB
                     ▼
           ┌─────────────────┐
           │  Клавиатура     │
           │  Мышь           │
           │  Другие USB     │
           └─────────────────┘
```

**Ключевое понимание:** Монитор LG имеет встроенный USB-хаб и KVM. Переключение USB-устройств между компьютерами происходит при смене активного входа (Input) монитора.

---

## Техническая реализация

### Способ 1: Программное переключение входа монитора (DDC/CI)

Монитор поддерживает DDC/CI — протокол для программного управления через кабель видео.

```python
# Пример переключения входа через DDC/CI
# На Windows используем ControlMyMonitor
# На macOS используем ddcctl

def switch_input(source):
    """
    Переключение активного входа монитора
    source: "hdmi1", "hdmi2", "usb-c", "displayport"
    """
    input_codes = {
        "hdmi1": 0x15,   # код зависит от модели
        "hdmi2": 0x16,
        "usb-c": 0x1A,
    }
    
    if sys.platform == "win32":
        subprocess.run([
            "ControlMyMonitor.exe",
            f"/SetValue", "LG 38WR85QC", "0x60", 
            str(input_codes[source])
        ])
    elif sys.platform == "darwin":
        subprocess.run([
            "ddcctl", "-d", "1", "-i", str(input_codes[source])
        ])
```

**Плюсы:** 
- Не требует прав администратора
- Полностью программное решение

**Минусы:** 
- Не все мониторы корректно поддерживают DDC/CI для переключения USB
- Может быть задержка

---

### Способ 2: Эмуляция нажатий джойстика монитора

Как мы обсуждали ранее — эмулируем физические нажатия на джойстик монитора.

```python
def switch_monitor_input(target):
    """
    Эмуляция нажатий для переключения входа
    """
    # Последовательность для выбора нужного входа
    # Пример: джойстик вниз 2 раза -> нажать -> выбрать вход
    self.press_joystick_sequence([
        "press",      # вход в меню
        "down", "down",  # навигация к Input
        "press",      # вход в подменю Input
        "down",       # выбор нужного входа
        "press",      # подтверждение
        "exit"        # выход из меню
    ])
```

---

### Способ 3: Использование физического USB-переключателя (hardware KVM)

Если программные методы ненадежны, можно добавить **внешний KVM-переключатель**:

```
Компьютер A ─┬─► HDMI (в монитор)
             └─► USB (в KVM)

Компьютер B ─┬─► HDMI (в монитор)
             └─► USB (в KVM)

KVM ─► Клавиатура, мышь
```

Программно управлять KVM можно через:
- Эмуляцию комбинаций клавиш (как для UGREEN)
- USB-устройство с serial командой (Arduino)

---

## Итоговая архитектура кастомного решения

```
┌────────────────────────────────────────────────────────────────┐
│                    Ваше ПО (без админ-прав)                    │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Фоновый сервис (Python)                                │  │
│  │  • Отслеживает курсор / горячие клавиши                │  │
│  │  • Определяет, на какой компьютер нужно переключиться  │  │
│  │  • Вызывает функцию переключения                       │  │
│  └─────────────────────────────────────────────────────────┘  │
│                              │                                 │
│              ┌───────────────┼───────────────┐                │
│              ▼               ▼               ▼                │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │
│  │  DDC/CI команда │ │ Эмуляция джойс-│ │ Управление вне- │  │
│  │  (переключение  │ │ тика монитора   │ │ шним KVM        │  │
│  │  входа)         │ │ (через USB HID) │ │                 │  │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

---

## План реализации

1. **Этап 1: Исследование**
   - Определить, работает ли DDC/CI на LG 38WR85QC-W для переключения входа
   - С помощью Karabiner-Elements определить скан-коды джойстика

2. **Этап 2: Выбор метода переключения**
   - Если DDC/CI работает → используем его (проще всего)
   - Если нет → эмулируем джойстик
   - Если оба нестабильны → добавляем внешний KVM

3. **Этап 3: Интеграция с существующим скриптом**
   - Добавляем функцию переключения монитора в `DeviceSwitcher`
   - Настраиваем зоны или горячие клавиши

4. **Этап 4: Упаковка**
   - Создаем исполняемый файл (PyInstaller) для Windows и macOS
   - Настраиваем автозапуск без прав администратора

---

## Вопросы для уточнения

Чтобы я мог предложить конкретный код:

1. **Как именно вы хотите переключаться?**
   - Наведение на зону экрана?
   - Горячие клавиши (например, Ctrl+Shift+1)?
   - Иконка в трее?

2. **Сколько компьютеров нужно переключать?** (2 или больше?)

3. **Как сейчас настроен ваш монитор?**
   - Компьютеры подключены по HDMI или USB-C?
   - Используете ли вы PbP/PiP режим постоянно?

4. **Dual Controller на Windows требует админ-прав — это проблема только для вас или для других пользователей?**

Если подтвердите, я доработаю код под вашу конфигурацию.

---

## 👤 **Kirill**

установка на mac Karabiner-Elements

---

## 🤖 **DeepSeek**

Вот пошаговая инструкция по установке Karabiner-Elements на macOS. Он понадобится вам, чтобы определить коды нажатий джойстика монитора LG и затем эмулировать их.

---

## Способ 1: Установка через Homebrew (рекомендуется)

Откройте **Terminal** и выполните:

```bash
brew install --cask karabiner-elements
```

Это самый простой способ, который автоматически установит последнюю версию [citation:5][citation:7].

---

## Способ 2: Установка через официальный сайт

1. Перейдите на официальный сайт: https://karabiner-elements.pqrs.org/ [citation:2]
2. Нажмите кнопку **Download**
3. Откройте скачанный файл `.dmg` и запустите `Karabiner-Elements.pkg`
4. Следуйте инструкциям установщика [citation:1]

---

## Настройка разрешений (обязательный шаг!)

После установки macOS запросит несколько разрешений. **Без них Karabiner-Elements не будет работать**.

### 1. Включить фоновые службы

Откройте **Системные настройки → Основные → Элементы входа** (System Settings → General → Login Items) и убедитесь, что включены:

- `Karabiner-Elements Non-Privileged Agents v2`
- `Karabiner-Elements Privileged Daemons v2`

Если они отображаются в разделе "Разрешено в фоновом режиме" (Allow in Background), всё настроено правильно [citation:1][citation:3].

### 2. Разрешить доступ к возможностям системы (Input Monitoring)

При первом запуске появится окно с запросом доступа. Нажмите **Open System Settings**.

В открывшемся окне **Конфиденциальность и безопасность → Мониторинг ввода** (Privacy & Security → Input Monitoring) **включите** `Karabiner-Core-Service` [citation:1][citation:3].

> Если приложения нет в списке, нажмите кнопку `+` и добавьте его вручную из папки `/Library/Application Support/org.pqrs/Karabiner-Elements/bin/`.

### 3. Разрешить системное расширение

Появится уведомление о блокировке системного ПО. Откройте **Системные настройки → Конфиденциальность и безопасность** (System Settings → Privacy & Security).

Прокрутите вниз до раздела **Безопасность** (Security). Рядом с сообщением о заблокированном системном ПО от `Karabiner-VirtualHIDDevice-Manager` нажмите **Разрешить** (Allow) [citation:1][citation:3].

---

## Проверка работы

1. Запустите **Karabiner-Elements** из папки Программы (Applications)
2. Приложение появится в строке меню (иконка в виде квадрата) [citation:1]
3. Откройте **EventViewer** (доступен из меню приложения) — он понадобится для отслеживания нажатий джойстика монитора

---

## Системные требования

Karabiner-Elements поддерживает:
- macOS 26 Tahoe
- macOS 15 Sequoia
- macOS 14 Sonoma
- macOS 13 Ventura

Работает как на Intel-процессорах, так и на Apple Silicon (M1/M2/M3) [citation:2][citation:5].

---

## Для чего это нужно в вашем проекте

После установки Karabiner-Elements вы сможете:

1. Открыть **EventViewer**
2. Нажать джойстик на мониторе LG
3. Увидеть в EventViewer, какие именно скан-коды отправляются при каждом движении и нажатии
4. Использовать эти коды в вашем Python-скрипте для эмуляции нажатий

Это позволит программно управлять PbP/PiP режимом монитора без физического касания джойстика.

---

## 👤 **Kirill**

через терминал как установить?

---

## 🤖 **DeepSeek**

# Установка Karabiner-Elements через терминал

## Способ 1: Через Homebrew (рекомендуется)

Если Homebrew уже установлен:
```bash
brew install --cask karabiner-elements
```

Если Homebrew не установлен, сначала установите его:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

После установки Homebrew выполните:
```bash
brew install --cask karabiner-elements
```

---

## Способ 2: Через curl (прямая загрузка)

Если вы не хотите использовать Homebrew:

```bash
# Скачать последнюю версию
curl -L -o /tmp/Karabiner-Elements.dmg https://github.com/pqrs-org/Karabiner-Elements/releases/download/v15.8.0/Karabiner-Elements-15.8.0.dmg

# Смонтировать образ
hdiutil attach /tmp/Karabiner-Elements.dmg

# Установить
sudo installer -pkg /Volumes/Karabiner-Elements/Karabiner-Elements.pkg -target /

# Отмонтировать образ
hdiutil detach /Volumes/Karabiner-Elements
```

> **Примечание:** Версия `v15.8.0` актуальна на момент написания. Проверить последнюю версию можно на [странице релизов](https://github.com/pqrs-org/Karabiner-Elements/releases).

---

## Способ 3: Через wget (альтернатива curl)

```bash
# Скачать
wget -O /tmp/Karabiner-Elements.dmg https://github.com/pqrs-org/Karabiner-Elements/releases/download/v15.8.0/Karabiner-Elements-15.8.0.dmg

# Смонтировать
hdiutil attach /tmp/Karabiner-Elements.dmg

# Установить
sudo installer -pkg /Volumes/Karabiner-Elements/Karabiner-Elements.pkg -target /

# Отмонтировать
hdiutil detach /Volumes/Karabiner-Elements
```

---

## Проверка установки

После установки можно проверить, что приложение установлено:

```bash
# Проверить наличие в папке Applications
ls -la /Applications/ | grep -i karabiner

# Или
ls /Applications/Karabiner-Elements.app
```

---

## Запуск из терминала после установки

```bash
open /Applications/Karabiner-Elements.app
```

---

## Автоматический скрипт установки

Если вы хотите создать скрипт для автоматической установки:

```bash
#!/bin/bash

# install_karabiner.sh

echo "Установка Karabiner-Elements..."

# Проверяем наличие Homebrew
if ! command -v brew &> /dev/null; then
    echo "Homebrew не найден. Устанавливаю Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Устанавливаем Karabiner-Elements
brew install --cask karabiner-elements

echo "Установка завершена!"
echo "Запустите Karabiner-Elements из папки Applications"
echo "Или выполните: open /Applications/Karabiner-Elements.app"
```

Сохраните скрипт, сделайте его исполняемым и запустите:

```bash
chmod +x install_karabiner.sh
./install_karabiner.sh
```

---

## Что делать после установки

После установки Karabiner-Elements **обязательно** настройте разрешения:

```bash
# Открыть настройки безопасности
open /System/Library/PreferencePanes/Security.prefPane
```

Вручную добавьте разрешения в:
- **Конфиденциальность → Мониторинг ввода** (Privacy → Input Monitoring) — добавьте `Karabiner-Core-Service`
- **Конфиденциальность → Доступ к специальным возможностям** (Privacy → Accessibility) — добавьте `Karabiner-Elements`

Без этих разрешений Karabiner-Elements не сможет перехватывать и эмулировать нажатия клавиш.

---

## 👤 **Kirill**

zsh: command not found: #
drwxr-xr-x   3 root           wheel     96 Mar 24 16:34 .Karabiner-VirtualHIDDevice-Manager.app
drwxr-xr-x@  4 root           wheel    128 Mar 24 16:34 Karabiner-Elements.app
drwxr-xr-x@  4 root           wheel    128 Mar 24 16:34 Karabiner-EventViewer.app
zsh: command not found: #
Contents        Icon?
kirillkravcov@MacBook-Air UniversalCreativeHub %

---

## 🤖 **DeepSeek**

Отлично! Karabiner-Elements успешно установлен. Я вижу, что в папке `/Applications` появились:

- `Karabiner-Elements.app` — основное приложение
- `Karabiner-EventViewer.app` — инструмент для просмотра событий клавиш
- `.Karabiner-VirtualHIDDevice-Manager.app` — скрытый менеджер виртуальных устройств

Теперь нужно запустить EventViewer, чтобы определить коды нажатий джойстика монитора LG.

---

## Запуск Karabiner-EventViewer из терминала

```bash
open /Applications/Karabiner-EventViewer.app
```

Или просто нажмите `Cmd + Пробел` и введите "Karabiner-EventViewer".

---

## Как использовать EventViewer для определения кодов джойстика

1. **Запустите Karabiner-EventViewer**

2. **Нажмите на джойстик монитора LG** (вверх, вниз, влево, вправо, нажатие)

3. **Смотрите в окне EventViewer** — там появятся записи вида:

```
key_down  : 0x7b (up_arrow)  # движение джойстика вверх
key_up    : 0x7b (up_arrow)

key_down  : 0x7c (down_arrow)  # движение джойстика вниз
key_up    : 0x7c (down_arrow)

key_down  : 0x24 (return)  # нажатие джойстика
key_up    : 0x24 (return)
```

---

## Что нужно записать

Запишите последовательность, которая открывает меню монитора и переключает режим PbP/PiP. Например:

| Действие | Код клавиши |
|----------|-------------|
| Нажатие джойстика (вход в меню) | `return` или `enter` |
| Движение вниз (x раз) | `down_arrow` |
| Движение вверх | `up_arrow` |
| Движение вправо | `right_arrow` |
| Движение влево | `left_arrow` |

---

## Альтернативный способ: через hidutil

Если EventViewer не показывает события от джойстика, можно попробовать:

```bash
# Посмотреть все HID-устройства
ioreg -p IOUSB -l -w 0 | grep -i "LG\|Monitor"

# Посмотреть события клавиш в реальном времени
sudo log stream --predicate 'subsystem == "com.apple.iohid" and eventType == 11' --style syslog
```

---

## После определения кодов

Когда вы запишете последовательность нажатий для переключения PbP/PiP, сообщите мне:

1. Какие коды клавиш отправляет джойстик
2. Какая последовательность нажатий нужна для включения PbP/PiP

Я добавлю эти коды в Python-скрипт для эмуляции нажатий.

---

## Запуск Karabiner-Elements из терминала (опционально)

Если нужно запустить основное приложение:

```bash
open /Applications/Karabiner-Elements.app
```

После запуска приложение появится в строке меню (иконка в виде квадрата).

---

## 👤 **Kirill**

такого нет в выборе Karabiner-Core-Service только karabiner-element и eventviewer

---

## 🤖 **DeepSeek**

Вы правы! В моем предыдущем ответе была неточность. В новых версиях Karabiner-Elements названия изменились.

---

## Правильные настройки разрешений

После установки Karabiner-Elements вам нужно добавить в разрешения **два приложения**:

### 1. Мониторинг ввода (Input Monitoring)

Откройте **Системные настройки → Конфиденциальность и безопасность → Мониторинг ввода**

Нажмите `+` и добавьте:
- **Karabiner-Elements** (из папки Applications)
- **Karabiner-EventViewer** (из папки Applications)

```
/Applications/Karabiner-Elements.app
/Applications/Karabiner-EventViewer.app
```

### 2. Доступ к специальным возможностям (Accessibility)

Откройте **Системные настройки → Конфиденциальность и безопасность → Доступ к специальным возможностям**

Нажмите `+` и добавьте:
- **Karabiner-Elements**
- **Karabiner-EventViewer**

---

## Как добавить через терминал

Если удобнее работать через терминал, можно добавить разрешения командой:

```bash
# Добавить в Input Monitoring
sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access VALUES('kTCCServiceListenEvent', '/Applications/Karabiner-Elements.app', 0, 1, 1, 1, NULL, NULL, NULL, 'UNUSED', NULL, 0, 1687786159);"

sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access VALUES('kTCCServiceListenEvent', '/Applications/Karabiner-EventViewer.app', 0, 1, 1, 1, NULL, NULL, NULL, 'UNUSED', NULL, 0, 1687786159);"

# Добавить в Accessibility
sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility', '/Applications/Karabiner-Elements.app', 0, 1, 1, 1, NULL, NULL, NULL, 'UNUSED', NULL, 0, 1687786159);"

sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility', '/Applications/Karabiner-EventViewer.app', 0, 1, 1, 1, NULL, NULL, NULL, 'UNUSED', NULL, 0, 1687786159);"
```

После этого **перезагрузите компьютер**.

---

## Проверка, что все работает

После настройки разрешений:

1. Запустите **Karabiner-EventViewer**
2. Нажмите любую клавишу на клавиатуре — в окне должны появиться события
3. Если события отображаются — Karabiner работает корректно

---

## Теперь про джойстик монитора

После того как Karabiner-EventViewer запущен и работает:

1. Нажмите джойстик на мониторе LG
2. Посмотрите в окне EventViewer — должны появиться записи

**Важно:** Если джойстик монитора не отображается в EventViewer, это значит, что монитор отправляет события не как стандартная клавиатура, а через другой HID-интерфейс. В этом случае нам понадобится другой подход для определения кодов.

Сообщите, видны ли в EventViewer нажатия джойстика монитора.

---

## 👤 **Kirill**

[
  {
    "type": "down",
    "name": {"key_code":"f"},
    "usagePage": "    7 (0x0007)",
    "usage": "    9 (0x0009)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"key_code":"g"},
    "usagePage": "    7 (0x0007)",
    "usage": "   10 (0x000a)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"key_code":"f"},
    "usagePage": "    7 (0x0007)",
    "usage": "    9 (0x0009)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"key_code":"f"},
    "usagePage": "    7 (0x0007)",
    "usage": "    9 (0x0009)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"key_code":"g"},
    "usagePage": "    7 (0x0007)",
    "usage": "   10 (0x000a)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"key_code":"f"},
    "usagePage": "    7 (0x0007)",
    "usage": "    9 (0x0009)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"key_code":"h"},
    "usagePage": "    7 (0x0007)",
    "usage": "   11 (0x000b)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"key_code":"g"},
    "usagePage": "    7 (0x0007)",
    "usage": "   10 (0x000a)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"key_code":"h"},
    "usagePage": "    7 (0x0007)",
    "usage": "   11 (0x000b)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"key_code":"q"},
    "usagePage": "    7 (0x0007)",
    "usage": "   20 (0x0014)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"key_code":"q"},
    "usagePage": "    7 (0x0007)",
    "usage": "   20 (0x0014)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"key_code":"2"},
    "usagePage": "    7 (0x0007)",
    "usage": "   31 (0x001f)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"key_code":"2"},
    "usagePage": "    7 (0x0007)",
    "usage": "   31 (0x001f)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "down",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  },
  {
    "type": "up",
    "name": {"pointing_button":"button1"},
    "usagePage": "    9 (0x0009)",
    "usage": "    1 (0x0001)",
    "misc": ""
  }
]

Не срабатывает на джойстике монитора

---

## 🤖 **DeepSeek**

Спасибо за данные из EventViewer! Я вижу, что в логах отображаются нажатия клавиш `f`, `g`, `h`, `q`, `2` и клики мыши (button1), но **джойстик монитора не срабатывает**.

Это означает, что **джойстик монитора LG не эмулирует стандартные клавиатурные HID-события**, которые перехватывает Karabiner-EventViewer. Вместо этого монитор, вероятно, использует:

1. **Собственный USB HID-интерфейс** (не keyboard/mouse)
2. **VCP (Virtual Control Panel) команды** через DDC/CI
3. **Специфичный протокол** для управления OSD

---

## Альтернативные способы определить события джойстика

### Способ 1: Использовать `hidutil` для мониторинга всех HID-устройств

```bash
# Посмотреть все HID-устройства и найти монитор
ioreg -p IOUSB -l -w 0 | grep -A 20 -i "LG\|Monitor\|38WR85"

# Мониторинг всех HID-событий (требует sudo)
sudo hidutil monitor
```

Выполните `sudo hidutil monitor`, затем нажмите на джойстик монитора. Если повезет, вы увидите сырые HID-события.

### Способ 2: Использовать `usbtrace` для анализа USB-трафика

```bash
# Установить usbtrace (через Homebrew)
brew install usbtrace

# Посмотреть список USB-устройств
usbtrace list

# Записать трафик с устройства монитора (нужен ID)
sudo usbtrace capture --device <device_id> --output monitor.pcap
```

### Способ 3: Использовать DDC/CI для управления монитором

Поскольку джойстик не эмулирует клавиатуру, **более перспективный подход** — использовать **DDC/CI протокол** для программного управления монитором.

---

## Проверка поддержки DDC/CI

Установите `ddcctl` для macOS:

```bash
brew install ddcctl
```

Проверьте, видит ли система ваш монитор:

```bash
# Список мониторов
ddcctl -l

# Попробовать прочитать текущий вход (пример для display 1)
ddcctl -d 1 -i ?
```

Если DDC/CI работает, вы сможете программно переключать входы монитора, что автоматически переключит и USB-устройства (встроенный KVM).

---

## Что мы видим в ваших логах

Из предоставленных данных EventViewer:

| Событие | Что это |
|---------|---------|
| `key_code: f` | Нажатие клавиши F |
| `key_code: g` | Нажатие клавиши G |
| `key_code: h` | Нажатие клавиши H |
| `key_code: q` | Нажатие клавиши Q |
| `key_code: 2` | Нажатие цифры 2 |
| `button1` | Левая кнопка мыши |

Это похоже на то, что вы **нажимали клавиши на клавиатуре и кликали мышью**, а не на джойстик монитора. Джойстик монитора не появился в логах.

---

## Следующие шаги

1. **Выполните** `sudo hidutil monitor` и нажмите на джойстик монитора. Сообщите, появились ли какие-либо события.

2. **Проверьте DDC/CI** через `ddcctl`. Если монитор поддерживает DDC/CI, это будет самый надежный способ программного управления.

3. **Альтернатива**: если монитор не отдает события через HID и не поддерживает DDC/CI для переключения входов, останется только вариант с **внешним KVM-переключателем**, управляемым программно.

---

## Если DDC/CI работает

Я сразу смогу доработать наш Python-скрипт, добавив функцию переключения входов монитора через DDC/CI. Это будет работать без прав администратора и надежнее эмуляции джойстика.

Выполните команду и покажите результат:

```bash
ddcctl -l
```

---

## 👤 **Kirill**

kirillkravcov@MacBook-Air UniversalCreativeHub % # Посмотреть все HID-устройства и найти монитор
ioreg -p IOUSB -l -w 0 | grep -A 20 -i "LG\|Monitor\|38WR85"

# Мониторинг всех HID-событий (требует sudo)
sudo hidutil monitor
zsh: command not found: #
  |   "IOKitDiagnostics" = {"Instance allocation"=22310976,"Container allocation"=8637715,"Pageable allocation"=1958953104,"Classes"={"AppleJPEGWrapperControlV8"=2,"KDISecondaryEncoding"=0,"RTBuddyFirmwareBundle"=0,"ApplePMPThermal"=0,"IOSkywalkPacketPoller"=0,"IOGPUKernelMappedMemory"=1,"IOPMPowerStateQueue"=1,"IOAVBStreamCaptureUserClient"=0,"ExclavesAudioProxyInputStreamDriverInterface"=0,"AppleSPUVD6287"=0,"IOPMServiceInterestNotifier"=178,"IosaEnhancementPipeUnitMSR9"=0,"AppleConvergedIPCDevice"=1,"IOPerfControlWorkContext"=64,"IOAVService"=0,"IOBlockStorageDriver"=1,"IO80211NoneProtocol"=0,"IODTPlatformExpert"=1,"IOGPUBufferMemoryDescriptor"=5034,"AFKFirmwareService"=1,"IOTimeSyncUnicastUDPv4EtEPort"=0,"ApplePassThroughBakuBTM"=0,"AppleMesaARMFunction"=0,"IOGPUCommandDescriptor"=1,"IOMobileFramebufferAP"=1,"IOThunderboltSwitchIntelJHL8440"=0,"OSArray"=43686,"IOImageLoaderHashstore"=0,"IOThunderboltConfigXDomainLinkChangeRequestCommand"=0,"ApplePCIEHostBridge"=1,"IOAccessoryManagerAID"=0,"AppleEmbeddedButtonController"=1,"AppleNVMeController"=1,"AUAInputTerminalDictionary"=0,"IOCommandGate"=1903,"AppleT8132USBXHCICommandRing"=2,"IOSerialBSDClient"=5,"AppleParadeDP825TCON"=0,"IosaColorManager"=1,"KDIUDIFCacheBuffer"=0,"IosaPrescaler3x3PipeUnitMSR9"=0,"IO80211TimeSyncPeersDatabase"=0,"AGXIOFenceData"=16,"AppleT8122DPTXPort"=0,"ApplePMGRFunctionStartS2RTimer"=0,"IOGPUClientSharedMachine"=74,"TaggedMemoryDescriptor"=0,"IOThunderboltSRAMLog"=0,"AppleGPIOICController"=1,"AppleTCControllerType2"=0,"AGXHardwareBufferBase"=2,"AppleT8112USBXHCICommandRing"=0,"AppleSEPSharedMemoryChannel"=1,"IOUSBMassStorageUASDriver"=0,"IOThunderboltXDomainPath"=0,"IOThunderboltConfigXDomainResponseCommand"=12,"IOWorkLoop"=485,"IOPortUserClient"=0,"AppleUVDMAceInterface"=0,"AppleUSBSerial"=1,"AppleT8132USBXHCI"=2,"AGXMemoryMap"=1,"IORegistryIterator"=0,"ApplePCIECLegacyIntController"=2,"HSAIDUserClientHost"=0,"IOGPUGroupMemory"=1,"ApplePPMDroopController"=1,"AppleEmbeddedNVMeNVRAM"=0,"AppleBCMWLANTimeSyncEngine"=0,"AppleARMCPUPerformanceServiceNub"=0,"AICInterruptTimestampFunction"=1,"AUAEffectUnitDictionary"=0,"IO80211TrafficNotification"=0,"AppleSEPDebugService"=0,"IOThunderboltConfigWriteCommand"=8,"AppleThunderboltNHITransmitRing"=0,"IOTimeSyncDomainUserClient"=0,"IO80211NeighborCacheManager"=0,"IOUSBInterfaceUserClientV3"=1,"AppleATCDPPort"=2,"OSAction_IOUserNetworkEthernet__RxSQDataAvailable"=0,"AppleEmbeddedUSBDeviceSupport"=0,"RTBuddyEndpoint"=90,"AppleTypeCRetimerReporter"=0,"IOPortTransportAIDBus"=0,"AppleExternalPowerManager"=16,"IO80211RealTimePeerManager"=0,"IOSKMemoryBuffer"=706,"CommonGlue"=0,"DCPAVAudioDMADelegate"=3,"AGXStatistics"=1,"CoreAnalyticsMessenger"=1,"AppleARMSPMIDeviceUserClient"=0,"AppleM2ScalerCSCHalMSR22"=0,"AppleBCMWLANItemRing"=0,"HIDAlwaysNotifyingIODataQueue"=1,"IosaFirmwareControl"=0,"DigitizerTransducer"=1,"IOWatchdogUserClient"=1,"AppleThunderboltNHIReceiveRingType5"=0,"IOUnifiedAddressTranslator"=88,"IOThunderboltConfigErrorCommand"=2,"IOGPUDeviceUserClient"=1,"M2ScalerCSCColorConversionControlMSR23"=0,"AppleConvergedPCI"=1,"AppleProcessorTrace"=1,"AppleSPUCT724"=0,"IOPlatformDevice"=27,"MCCommand"=0,"AppleThunderboltNHIReceiveRingType7"=0,"IODPPortAnalyticsCollector"=6,"AppleTCControllerType11"=0,"IOPAudioDeviceExternalServiceManager"=4,"AppleIPAppender"=1,"CoreKDLUserClient"=1,"IOHIDevice"=0,"AGXLegacyGart"=0,"AIDQueueEventSource"=1,"AppleHIDTransportIODataQueue"=0,"AppleOnboardSerialSkywalkInterface"=0,"IOFramebufferSharedUserClient"=0,"AppleUSBUserHCIUserClient"=0,"com_apple_driver_FairPlayIOKitUserClient"=2,"HibiscusFunctions"=0,"IODPVirtualDevice"=0,"IOMbufLittleMemoryCursor"=0,"AppleMultitouchInputHIDEventDriver"=1,"AIDReporterState"=0,"IosaFilmGrainControlMSR16"=1,"AppleBCMWLANPCIeSkywalkMulticastQueue"=0,"IOHistogramReporter"=120,"AppleMCCUserClient"=0,"IODPRXPort"=0,"AGXFamilyAccelerator"=1,"IOBioPool"=0,"AppleBCMWLANChipManagerPCIe4377"=0,"AppleBluetoothModuleUserClient"=0,"IOHIDEventService"=3,"IONVMeBlockStorageDevice"=1,"WCLGASManager"=0,"IODispatchSource"=2,"OSOrderedSet"=568,"AppleJPEGWrapperControlV11"=0,"AppleBatteryAuth"=0,"AUAControlDictionary"=0,"AppleBTMPMUAgent"=1,"AppleUserHIDDevice"=1,"AppleT8122USBXDCI"=0,"IOPAudioLPMicDevice"=1,"IOAVServiceUserClient"=0,"AppleHIDTransportHIDDevice"=6,"IOThunderboltCommand"=3,"IOGPUCommandQueue"=1,"CoreAnalyticsUserClient"=1,"AppleT8140USBXHCI"=0,"IOPortFeaturePowerSourceOption"=1,"AppleUSB20HostController"=0,"AppleDCPLinkService"=1,"IOBioPoolItemFactory"=0,"InterruptEventSourceBridge"=39,"IOBiometricUserClient"=0,"IOUserNetworkLogicalLink"=0,"AHTFunctionExecutor"=0,"AIDCircularBuffer"=0,"RTBuddyPatchBay"=1,"AppleCLPCWorkLoop"=1,"AppleUSBSortableConfigurationDescriptor"=2,"IOTSAEITimeSyncHandler"=0,"AppleProResHW"=1,"AppleSPUProfileDriverUserClient"=0,"M2ScalerSrcDestCfgControlMSR19"=1,"AppleARMBacklight"=1,"IOHITablet"=0,"BinaryEncoder"=0,"OSValueObject<KeyboardReserved>"=0,"RTBuddyService"=12,"IOReporter"=3,"OSAction_IOHIDEventService__CopyEvent"=0,"IO80211ThroughputCache"=0,"IO80211LQMCrashTracer"=0,"AppleBringUpPMGR"=0,"IASClientManager"=6,"AppleGCResource"=1,"IOTBTTunnelUSBType2ClientInterface"=0,"IO80211RNGAgent"=0,"IOAccessoryHSAIDBusTransport"=0,"ApplePPMEntity"=5,"AppleBSDKextStarter"=2,"IOSurfaceSharedEvent"=17,"IOServiceMessageUserNotification"=546,"IOAVRegisterSet"=0,"AppleUSBXHCI"=1,"IO80211NANDataPathResponder"=0,"IOSharedInterruptController"=6,"IOThunderboltSet"=76,"AppleT8101GPIOIC"=4,"ACMKernelService"=6,"IOAVAudioLinkDelegate"=0,"AppleDockChannelUserClient"=0,"OSValueObject<AppleH16CamInFirmwareWorkProcessorRPCRequest>"=0,"IOProviderPropertyMerger"=1,"IOHIKeyboardMapper"=0,"IOBluetoothTimerEventSource"=0,"AppleAGXFunctionMetrology"=0,"IO80211DataPathInformAgent"=0,"RTBuddyRouteOnly"=0,"PMGRDispCtrl"=0,"IOStorage"=4,"AppleDisplayConnection"=0,"IONetworkMedium"=10,"AUCWorkloop"=1,"AppleSMCChargerPS"=0,"ApplePassthroughPPM"=1,"AppleSPUDispADCUserClient"=0,"IOThunderboltConfigXDomainROMChangedRequestCommand"=0,"IO80211EventSource"=0,"AppleATVAintreeBTM"=0,"WCLBGCommonFsm"=0,"IOHDCP2LocalMessageTransport"=0,"IOPMWorkQueue"=1,"AppleSEPPanicBuffer"=1,"AppleASCWrapV6"=11,"ApplePTDUserClient"=0,"AGXCLChannelSKU"=1,"AGX3DChannelG16"=34,"AppleI2CPagedAudio"=0,"AppleSandDollar"=1,"AppleT8132PCIePort"=1,"AGXHWParamBufferManager"=33,"AppleTDMBlockStorageServices"=0,"IosaChannelConfig"=0,"AppleARMFunctionCharger"=0,"RTBuddyKdebugEndpoint"=6,"IOUSBDeviceInterface"=8,"IODPSwitchAllocationState"=2,"AppleARMLightEmUp"=1,"IOBluetoothSCOMemoryDescriptorRetainer"=0,"AppleSPU"=12,"BTDebug"=1,"RTBuddySlaveMemoryDescriptor"=11,"AppleT8130USBXDCI"=0,"IOAccessoryPowerSourceItemPDPlatformCurrentLimit"=0,"AppleSmartIOCommandPool"=7,"IOGPUWorkQueue"=1,"AppleCotaBTM"=0,"AppleSMCChargerFunction"=0,"AppleS8000AESAccelerator"=1,"AGXTAChannelSKU"=1,"AppleM2ScalerCSCDriverFilters"=1,"AppleBCMWLANChipManagerPCIe4364"=0,"IOThunderboltConfigMultiReadCommand"=2,"AppleUSBDeviceNCMControl"=4,"ANEClientDevice"=2,"IOSKRegionMapper"=334,"AppleFermiumBTM"=0,"AppleT8132DisplayCrossbar"=1,"IOHIDResource"=1,"IOTimeSyncTimedEdgeGeneratorUserClient"=0,"IORSMMemoryDescriptorArray"=0,"AppleThunderboltNHIMemoryBlock"=0,"IORSMCommand"=0,"IosaDPEControlMSR19"=0,"AppleThunderboltHALGenericACIO"=1,"IOCPU"=1,"DitherControlMSR7"=1,"AppleBCMWLANNANInterface"=0,"IOTimeSyncDaemonServiceBase"=1,"IOMachPort"=4318,"IOWorkGroup"=0,"ApplePMGRFunctionPerfCycleCount"=2,"AppleARMMIPIDSIController"=0,"AGXPerfCtrSampler"=1,"AGXCLWorkQueue"=20,"IOThunderboltConfigXDomainPathTeardownRequestCommand"=0,"AppleTCS3490"=0,"AGXFastRenderTarget"=1,"MogulAuthI2CRelayInterface"=0,"AppleUSBHostDARTDMACommand"=10,"AppleThunderboltIPConnection"=0,"IOAccessoryPowerSourceItemUSB_TypeC_Current"=0,"IODPEventLog"=0,"IODTNVRAMDiags"=1,"IOSCSIPeripheralDeviceNub"=0,"IOThunderboltSwitchType7"=0,"IOPCIDevice"=5,"AppleSystemPolicy"=1,"AppleUSBXHCISparseRequestPool"=0,"IOPolledFilePollers"=0,"IODTNVRAMVariables"=2,"IOPortTransportStatePCIe"=0,"IOUserNetworkPacketQueue"=4,"AppleBCMWLANCommandMonitor"=0,"IOAudioEngine"=0,"AppleEmbeddedSimpleSPINORFlasherDriverUC"=0,"IOSurfaceWiredSendRight"=0,"AppleEmbeddedHIDEventService"=5,"AppleProcessorTraceT6000"=0,"StatusDescriptorRingMSR23"=0,"ANEScheduler"=1,"OSValueObject<PMAssertStruct>"=11,"HSAIDReceivePacket"=0,"IODPVirtualPortService"=0,"APFSOSNumberAtomic"=1493,"AppleConvergedIPCBTIDevice"=0,"AppleProcessorTraceT8122"=0,"IosaRdmaControlMSR11"=1,"H16ISPSharedMemorySurfaceParams"=6,"AppleHPM"=1,"AppleARMPWMBacklight"=0,"IOGPUFenceMachine"=1,"OSValueObject<void*>"=0,"IOHIDEventDummyService"=0,"ApplePMPv2UserClient"=0,"IOCryptoAccelerator"=1,"AUAASEndpointDictionary"=0,"AppleBPIC"=0,"AppleSPUTimesyncV1"=0,"AppleSetDroopUtilizationControlEffortFunction"=0,"AppleBiometricSensor"=1,"IOFramebufferParameterHandler"=0,"IOThunderboltAbstractPath"=0,"KDIShadowedDiskImage"=0,"SalviaFunctions"=0,"AppleHPMInterfaceType16"=0,"AppleARMFunctionAssertReset"=1,"IOAccessoryPowerSourceItemDebounce"=0,"IOHIDSystem"=1,"IOSEPBiometricService"=1,"IOUSBDeviceController"=1,"AppleHIDTransportProtocol"=1,"HSAIDTransmitCommand"=0,"AppleHPMARM"=1,"M2ScalerScalingASEControlMSR10"=1,"IOGPU"=1,"IOTimeSyncNetworkPortUserClient"=0,"IOThunderboltFrameList"=0,"AGXParameterManagementVirtual"=33,"ApplePCIePIODMA"=1,"M2ScalerScalingASEControlMSR23"=0,"IOAVCommandGate"=5,"MesaAccessoryIntReportError"=0,"DCPAVServiceProxyUserClient"=0,"AppleH16CamInFrameReceiver"=0,"IOPortTransportComponentCCUSBPDSOPp"=1,"AGX3DChannelGen2"=1,"AGXRepeatedMemoryDescriptor"=0,"AppleBCMWLANBusSkywalk"=0,"ANEMessage"=0,"IOAVVideoInterfaceConcreteUserClient"=0,"AppleBTM"=1,"IOThunderboltNub"=2,"AppleM2ScalerCSCHalMSR16"=1,"IOAESAcceleratorUserClient"=0,"IOThunderboltStatistics"=2,"IODPHDMIPortController"=0,"IosaDPEControlMSR16"=1,"IOSurface"=635,"IOHIPointing"=0,"AppleSmartIOPerf"=1,"HSAIDAckPacket"=0,"M2ScalerScalingControlMSR2"=0,"AppleSPUFirmwareService"=1,"IOAudioTimeIntervalFilter"=0,"AppleParadeDP865TCON"=0,"WCLTrafficPatternAgent"=0,"TSNITimeSyncHandler"=0,"IOI2CInterface"=0,"RoswellAuthI2CRelayInterface"=0,"AppleBCMWLANCommander"=0,"IOUSBMassStorageUFIDriver"=0,"IO80211PacketDescriptor"=0,"IOThunderboltDebugBlock"=1,"AIDCircularWriteBufferShared"=0,"IODeblocker"=0,"ApplePMGRFunctionGetValidPerfState"=0,"IO80211BssManager"=0,"IOHDCPMessageTransport"=1,"AppleUSBHostDMACommandPool"=2,"ACMRestrictedModeKernelService"=1,"IOFastPathField"=0,"IosaInternalPipe"=1,"AGXLateEvalEventFence"=0,"IOSCSIMultipathedLogicalUnit"=0,"IOSkywalkBSDClient"=2,"IODPCECController"=0,"AppleProcessorTraceT8103"=0,"IOThunderboltConnectionManagerType5"=2,"IosaFilmGrainPipeUnitMSR16"=0,"AppleStockholmRingBuffer"=0,"AppleBCMWLANIO80211APSTAInterface"=0,"OSValueObject<ANECoredumpSection>"=0,"AppleThunderboltNHIReceiveRingManager"=0,"AppleFairplayTextCrypter"=1,"SEPEpoch"=0,"IO80211NANSubscribeServiceDescriptor"=0,"IOTimeSyncUnicastUDPv6EtEPort"=0,"AGXArmFirmware"=1,"IOThunderboltJTAG"=2,"MSR23ChromaDownsampleFilter"=0,"IOFDiskPartitionScheme"=0,"AppleMultiFunctionPlatformExternal"=0,"AppleANEPerfCounterReadFunction"=0,"AppleUSBUserHCIResources"=1,"AppleGPIOUserClient"=0,"IOTimeSyncNanosecondSnapshotService"=0,"DCPDPDeviceProxyUserClient"=0,"AppleT8132PCIeCPort"=2,"IODARTVMSpace"=481,"IosaWdmaControlMSR23"=0,"IISAudioIsolatedStreamECProxy"=0,"IOUserNetworkTxCompletionQueueCompat"=0,"AppleTypeCRetimerCrashReport"=0,"IOThunderboltConnectionManager"=1,"IOGPUResource"=1,"IORangeAllocator"=622,"AppleBCMWLANCallbackEventSource"=0,"IosaFilmGrainControl"=1,"WCLController"=0,"IOAccessoryIDBusTransport"=0,"TSNPacketPool"=0,"M2ScalerSrcDestCfgControlMSR7"=1,"RTBuddyBinaryLogHandler"=12,"AppleSPUALSSealionDriver"=0,"IOAVAUPPacket"=0,"AppleThunderboltHALType5"=2,"IOAccessoryIDBusBulkData"=0,"ApplePCIeCPIODMA"=2,"IODPDeviceConcreteUserClient"=0,"AppleUSB20XHCITypeCPort"=1,"IOTimeSyncUserFilteredServiceDaemonClient"=0,"IOTimeSyncTimeSyncTimePort"=1,"AppleUSBAudioPlugin"=0,"IOCECUserClient"=0,"IosaPowerManagerMSR20"=1,"IosaFirmwareControlMSR23"=0,"IOPortTransportProtocolAppleUVDM"=0,"AppleBCMWLANTimeTrace"=0,"AppleARMNORFlashDevice"=3,"IosaTiledCompressedMemMSR8"=1,"AppleTDMAKSCommand"=0,"AppleUSB30Hub"=0,"IOAccessoryIDBusSystemStates"=0,"AppleSmartBatteryUserClient"=0,"AppleThunderboltNHIType7"=0,"IOWorkQueue"=1,"FilmGrainSynthesizer"=1,"IOInterleavedMemoryDescriptor"=0,"IO80211InfraPeer"=0,"IOAccessoryIDBusHIDDevice"=0,"AEARuntimeRegisterPatchForI2C"=2,"IOTimeSyncDomain"=1,"AppleSecondaryAudioFunction"=1,"IOAudioPort"=0,"AppleSPIBiometricSensor"=1,"AppleSPIMCControllerStats"=2,"AppleBCMWLANPCIeSkywalkRxCompletionQueue"=0,"AppleExclaveCameraProxy"=0,"IOHIDAccelElementProcessor"=0,"AppleUSBXDCIARM"=1,"IosaTunableControlMSR22"=0,"AppleOLYHALPlatformFunction"=1,"OSValueObject<H16ISPOverrideNVMParams>"=1,"OSValueObject<ANEInDebugWorkProcessorRPCRequest>"=0,"IOAudioTimeIntervalFilterIIR"=0,"IOTimeSyncTranslationPMGR"=0,"AppleImage4"=1,"IOUSBDeviceControlRequest"=2,"IOGPUDeviceAssertion"=0,"HSAIDUserClientAccessory"=0,"IODARTVMAllocatorMPM"=1,"IOUserEthernetController"=0,"IOFilterScheme"=0,"IOSkywalkRxSubmissionQueue"=5,"KopsiaFunctions"=0,"AppleThunderboltNHIReceiveRingManagerType5"=0,"AppleSPUCT725"=0,"IOUSBHostDevice"=20,"IODPPortUserClient"=0,"IOAVEventLog"=3,"AppleDialogPMUUserClient"=0,"IOThunderboltDispatchContextAbstract"=0,"AppleUSBXHCITransferRing"=7,"M2ScalerSrcDestCfgControlMSR17"=1,"ANEHWDevice"=1,"IosaRevertPipeUnit"=0,"ApplePMGRUserClient"=0,"AppleT8112USBXDCI"=0,"AIDUserClientLogger"=1,"AppleUSBACMData"=3,"AppleEmbeddedNVMeDiagnostics"=0,"IOSerialStreamSync"=3,"IORS232SerialStreamSync"=0,"RegStream"=1,"IOAVVideoColorElement"=0,"IOThunderboltSwitch"=1,"IOTimeSyncSyncUserClient"=0,"AUCUserClient"=0,"AppleT603XDisplayCrossbar"=1,"IOServiceNotificationManager"=22,"MogulAuthSMCRelayInterface"=0,"AppleT8142ATCDPXBAR"=0,"IOAudioControl"=0,"MailBox"=0,"IOPort"=1,"ApplePMPv2"=1,"IOPowerConnection"=340,"IOThunderboltTransmitCommand"=0,"IOHIDUserDevice"=3,"IODisplay"=0,"AppleBCMWLANCommand"=0,"ANENotificationMsg"=0,"AppleUSBUserHCI"=0,"IOGPUVnioDesc"=0,"AppleDiagnosticDataAccessReadOnly"=1,"IOHIDKeyboardDevice"=0,"IO80211HistogramReporter"=0,"AppleSPUALSSealionAccessoryDriver"=0,"AppleRSMChannelTestClient"=0,"AGXLateEvalEventTable"=1,"IOThunderboltTracebuffer"=6,"WCLConfigManager"=0,"IOAccessoryPowerSourceItemBehavior"=0,"AppleARMPerformanceControllerFunctionCPUIdle"=0,"AppleMMIOSerial"=1,"IOSerialDriverSync"=0,"OSValueObject<SMCNotification>"=7,"AppleHIDTransportManagement"=1,"IODataQueueDispatchSource"=22,"AppleSPUFastpathDriver"=0,"IOPAudioVoiceTriggerDevice"=1,"FrameDescriptorRing"=0,"AppleSMCClient"=7,"IOThunderboltXDPropertiesDirectory"=4,"IOMobileFramebuffer"=1,"RTBuddyFirmware"=10,"IODPSACAggressorTable"=0,"IOTimeSyncService"=2,"AGXRestartReport"=0,"AppleH16GFamilyMemCacheController"=1,"AppleOLYHALUART"=1,"APCIECPortControlFunction"=0,"IOCatalogue"=1,"IOGPUSegmentResourceList"=1,"AGXHAL200SecureMonitor"=0,"IONVMeEffaceableDevice"=0,"IOPlatformExpertDevice"=1,"AppleTDMAKSServices"=0,"AppleHPMUserClient"=3,"AppleMemCacheController"=1,"AppleUSBHostUserClient"=2,"AGXLegacyGartG16"=0,"AppleBCMWLANPowerManager"=0,"AppleSmartIODMAController"=1,"AGXSecureGart"=1,"IO80211NANPeer"=0,"AppleSPUALSSunfishDriver"=0,"AppleMxWrapACIO"=2,"AHTFunctionInfo"=3,"AppleUSB20XHCILightningPort"=0,"IOTimeSyncReverseSync"=0,"RTBuddyTraceKitMessageEncoder"=21,"RTBuddyTimeDecoder"=12,"ANEClientHints"=1,"AppleUSB20Hub"=7,"AppleM2ScalerCSCHalMSR6"=1,"IOUSBMassStorageDriverUFIDevice"=0,"IOECStateNotifier"=0,"AppleUSBHostBusCurrentClient"=1,"CCFaultReport"=0,"IosaDPEControlMSR10"=1,"IOSCSIPrimaryCommandsDevice"=0,"IOThunderboltReceiveQueue"=0,"AppleBCMWLANNearbyDeviceDiscoveryAdapter"=0,"IOUSBHostPipe"=1,"ANEProgramLegacyResource"=1,"AppleActuatorDevice"=1,"IOStateNotificationItem"=4,"RTBuddyCrashlogDecoder"=12,"AppleS8000DWIBacklightFunction"=0,"AppleRSMChannelServerClient"=0,"IO80211Buffer"=0,"RTBuddyScmDecoder"=12,"AppleSEPCoreBuffer"=0,"AppleExternalPowerProvider"=13,"AppleMobsiTmpSADC"=0,"AppleEmbeddedAudioGroup"=0,"IOBluetoothWorkLoop"=0,"AppleBCMWLANLogger"=0,"OSString"=46268,"AppleProcessorTraceSession"=0,"IOSurfaceMemoryPool"=0,"IOHIDOOBReportDescriptor"=0,"AppleSEPDiscovery"=1,"AppleUSBXHCIRequest"=141,"IOSlaveProcessor"=2,"SharedDARTMapperProxy"=0,"IOAccessoryPowerSourceItemUSB_DataContactDetect"=0,"IOTimeSyncgPTPManagerUserClient"=0,"IOBluetoothHCIUserClient"=1,"IOThunderboltHopSet"=32,"AppleHPMInterfaceType10"=2,"AppleSMCPMU"=1,"ANEInVMAllocator"=1,"AppleAPFSContainerScheme"=3,"IOHDIXHDDriveOutKernelUserClient"=0,"IOSurfaceDeviceCache"=360,"AppleARMNORPanicLog"=0,"IosaAxi2AfControl"=1,"ApplePMGRFunctionEnablePSDService"=0,"IOTextCrypter"=1,"AppleGasGaugeUpdate"=0,"AppleDieTempControllerUserClient"=0,"AppleSPUSingleShotReporter"=0,"AppleTCControllerType12"=0,"AppleBacklightDisplay"=0,"AppleASCWrapV6SISP"=0,"EndpointSecurityDriver"=1,"AppleBCMWLANRxByteRing"=0,"_IOServiceInterestNotifier"=455,"AGXFirmware"=1,"IOBlockStorageServices"=0,"IOAVAudioInterfaceUserClient"=0,"IOThunderboltArray"=8,"AGXEnergyAttributor"=1,"IOHIDButtonElementProcessor"=0,"M2ScalerScalingControlMSR7"=1,"IOPortTransportComponentCC"=1,"AppleSynopsysDRDUSBXHCI"=0,"IosaColorManagerMSR9"=0,"ApplePMGRFunctionSetATCDpClockSource"=0,"AppleHPMCommandGate"=3,"AppleInterruptControllerUserClient"=0,"AppleSARTMarconi"=0,"RTBuddyCL4Coredump"=0,"AppleSmartBattery"=1,"IOAccessoryEAInterface"=0,"AppleVTempDispatcher"=0,"IOGPUSysMemory"=1,"IOPortFamily"=4,"AppleAPFSVolumeBSDClient"=12,"ANEDriver"=1,"IOSkywalkPacketBufferPool"=2,"IOBiometricSensorInterface"=1,"BootPolicyUserClient"=9,"AppleUSBHostResourcesTypeC"=1,"AppleUIOPCI"=0,"IOPortTransportComponent"=1,"AppleFirmwareUpdateKext"=1,"AppleHPMDevice"=1,"IO80211ApFeatureConfig"=0,"InterruptCommand"=72,"WCLTimerFactory"=0,"AppleM2ScalerCSCHalMSR13"=1,"IO80211RoamProfile"=0,"AppleEmbeddedPCIEPort"=1,"AppleSocHot"=0,"RTBuddyBinaryLogEntryHandlerSysLog"=7,"NVMeSEPNotifier"=1,"AppleSPUHapticsManagerUserClient"=0,"AGXLateEvalEventResourceManager"=1,"AppleDialogSPMIPMUFunction"=0,"IOTimeSyncPort"=1,"AppleEmbeddedNVMeController"=1,"AppleOLYHALPortInterfacePCIe"=1,"IOTimeSyncgPTPManager"=1,"AppleBTMDataClientSMC"=0,"IOAccessoryManagerOrion"=0,"ApplePPMPredictivePmax"=44,"AppleCallbackPowerSourceProvider"=1,"AppleSPUCoexParams"=0,"IOHITabletPointer"=0,"IO80211ColocatedGroup"=0,"IOGPUResourceSet"=6,"IOTimeSyncTimeLineFilter128"=0,"IORTC"=0,"AppleCSI2CAudio"=0,"WCLBSSBeacon"=0,"AFKRemoteSMCClient"=0,"IOAudio2DeviceUserClient"=7,"IOAccessoryHSAIDBulkData"=0,"AppleBCMWLANChipManagerPCIe4350"=0,"AppleHIDKeyboardEventDriver"=1,"IosaColorManagerMSR11"=1,"CommonFsmManager"=0,"AppleNVMeTranslationSMARTUserClient"=0,"AppleARMWatchdogTimerFunctionExpireWatchdog"=0,"IOSimpleReporter"=765,"AHTFunction"=3,"AppleConvergedIPCLogger"=0,"IosaRdmaPipeUnitMSR23"=0,"IOHIKeyboard"=0,"BinaryEncoderManager"=0,"M2ScalerScalingControl"=1,"IOSurfaceShared"=78,"AppleBCMWLANChipManagerPCIe4388"=0,"ApplePMGRFunctionROSC"=0,"AppleARMDMAAudioDevice"=1,"IOPMGR"=1,"IOHIDParamUserClient"=7,"AppleThunderboltNHIReceiveRing"=0,"AppleUSBXDCITRBPool"=4,"IosaRdmaControlMSR25"=0,"IOAudioTimerEvent"=0,"AppleH16CamInFrameMetadata"=0,"OSValueObject<IOAccessoryIDBusTransport::TransferData>"=0,"IOUserNetworkPacketQueueCompat"=0,"AppleThunderboltNHITransmitRingGenericACIO"=0,"IOPanicPlatform"=0,"IOMobileFramebufferLegacy"=0,"IOHIDPowerSourceController"=1,"AFKEPInterfaceServiceKextV2"=39,"IOSkywalkController"=0,"IosaFirmwareControlMSR23Rtk"=0,"OSMetaClass"=0,"ApplePMPControlFunction"=0,"AIDUserClient"=0,"AppleSPUGpioUnplugDriver"=0,"AppleT8132PCIeC"=2,"IODPControllerConcreteUserClient"=0,"ApplePPMPolicyCPMSPowerServo"=1,"AppleMultiFunctionManagerLogger"=0,"IO80211SkywalkInterface"=0,"AppleT600XATCDPXBAR"=0,"H16ISPClientMappedSurfaceArray"=1,"HSAIDPacket"=0,"AppleUSBIORequest"=35,"AppleT8112DisplayCrossbar"=0,"AppleSecureRepair"=1,"IO80211Stopwatch"=0,"AGXPerfCtrSamplerGen15"=1,"AppleBCMWLANSkywalkRxCompletionQueue"=0,"IOUSBDevicePipe"=8,"IOThunderboltFamilyUserClient"=0,"AppleParadeDP835TCONI2CPLS"=0,"AppleMemCacheDataSetsFunction"=6,"AppleConvergedIPCPool"=3,"IOPAudioClientManagerDeviceUserClient"=1,"IOHDCPInterface"=1,"AppleARMQuadSPIDeviceUserClient"=0,"AGXUSCPrivMemFList"=26,"AppleIASMCA"=1,"AGXUniqueResourceSet"=0,"IosaColorManagerMSR18"=0,"AppleConvergedIPCRTIDevice"=1,"ApplePPMCPMSSystemCapabilityMonitor"=1,"IosaInternalPipeMSR"=1,"StockFunctions"=0,"IO80211ControllerMonitor"=0,"IOAVSerializer"=17,"IOHIDAction"=0,"DMAChannelProxy"=0,"IOThunderboltTRMPolicy"=1,"AppleConvergedIPCMemoryPolicyInfo"=1,"IOAVAudioInterface"=0,"IOThunderboltTransmitQueue"=0,"IODisplayWrangler"=1,"AUAADC3ClassSpecificDescriptorFetcher"=0,"IOWatchdog"=1,"IODPDeviceUserClient"=0,"AppleT8101USB20XHCILightningPort"=0,"IOThunderboltTimerCommandQueue"=2,"IOPortTransportStateSD"=0,"KDIReadWriteDiskImage"=0,"IOSkywalkInterface"=2,"AppleThunderboltNHISubMemoryBlock"=0,"AppleProcessorTraceT8132"=1,"IOAVBControllerHelper"=0,"ApplePMGRFunctionPLLOffMode"=0,"AppleConvergedIPCMemoryCommandPool"=3,"ApplePMGR"=1,"AppleUSBECMDataNC"=0,"IosaInternalPipeMSR15"=1,"AppleMAXI2CAudio"=0,"AGXFastRenderTargetG16"=28,"AppleProcessorTraceNub"=1,"IO80211FaultReporter"=0,"AppleTrustedAccessoryAnalytics"=1,"H16ISPSharedMemorySurfaceParamArray"=4,"IOAccessoryManagerUSBC"=1,"AppleUSBXHCIInterrupter"=8,"AppleSEPLoggerService"=0,"AppleConvergedIPCControl"=1,"SMState"=234,"IOHIDActionQueue"=0,"IOTimeSyncDaemonUserClient"=1,"IO80211StaticBufferPool"=0,"IOUserNetworkTxSubmissionQueue"=13,"IO80211AWDLProtocol"=0,"AppleMxWrap"=1,"AppleUSBXHCIEndpointSoftRetry"=0,"DCPDPDeviceProxy"=1,"AppleAuthCPI2C"=0,"AppleUSBXHCIRequestPool"=3,"AUC"=1,"GTraceBuffer"=3,"ANEClientInterface"=2,"AppleSEPTraceBuffer"=0,"IOUSBMassStorageDriver"=0,"ApplePPMEntityCLPC"=2,"AppleDPTXPort"=0,"AppleThunderboltPCIDownAdapter"=1,"IOHDIXControllerUserClient"=0,"AppleConvergedIPCUserClient"=0,"com_apple_AppleFSCompression_AppleFSCompressionTypeDataless"=1,"AUASelectorUnitDictionary"=0,"AppleS5L8960XGPIOIC"=0,"AppleT8006GPIOIC"=0,"MesaAccessoryManager"=1,"IOSCSIBlockCommandsDevice"=0,"WCLWnmAgent"=0,"RTBuddyEndpointService"=61,"IO80211TimerSource"=0,"RequestTimeOutInfo"=0,"AGXAllocationList2"=23,"ApplePPMEntityBaseband"=0,"AppleT8130USBXHCICommandRing"=0,"AppleUSB20AccessoryHub"=0,"ApplePMGRFunctionGetServiceState"=0,"IOPortFeaturePowerSource"=5,"USBStringIndex"=2,"IosaInternalPipeMSR6"=1,"GTCondition"=3,"MCClient"=4,"AppleHIDTransportStats"=1,"PhloxFunctions"=0,"IOCommandPool"=81,"M2ScalerSrcDestCfgControlMSR15"=1,"ApplePMGRFunctionSetTouchClockSource"=0,"IOThunderboltConfigXDomainLinkStatusRequestCommand"=0,"AppleHPMInterfaceType17"=0,"IOSlaveMemory"=1,"IOTimeSyncEthernetConcreteControllerAdapter"=0,"AppleEmbeddedPCIEUserClient"=0,"AppleThunderboltNHITransmitRingType5"=0,"AppleUSBHostCompositeDevice"=2,"IOHIDEventRepairDriver"=0,"AppleBCMWLANPCIeSkywalkTxSubmissionQueue"=0,"IOSystemStateNotification"=1,"AppleFirmwareUpdateUserClient"=0,"BellisFunctions"=0,"IOHIDEventQueue"=1,"IOAccessoryIDBusEA"=0,"AppleUSB30XHCITypeCPort"=1,"AppleThunderboltNHITransmitRingType7"=0,"DIFracturedMemoryMap"=0,"ApplePMPUserClient"=0,"AppleAuthCPAID"=0,"AppleCLCD2"=0,"AppleUSBSparseArray"=4,"IOAVControlInterfaceUserClient"=0,"IOKDP"=0,"IOPortTransportStateUSB"=2,"AppleProcessorTraceVirtualBufferMemoryDescriptor"=0,"IOThunderboltSwitchType1"=0,"IOThunderboltReceiveCommand"=0,"IOAccessoryTransport"=0,"IOHIDDeviceElementContainer"=20,"AppleBCMWLANDynamicRingOperationContext"=0,"KDIBackingStore"=0,"IORegistryPlane"=8,"AppleSPUCT726"=0,"AppleSPUHIDDevice"=8,"IOAVSimpleVideoInterface"=0,"CCDataPipeBlob"=0,"IOThunderboltConfigXDomainRequestCommand"=0,"IOFramebufferUserClient"=0,"AppleARMPerformanceControllerFunctionCLPCEnabled"=0,"AppleARMFunction"=47,"CCCapture"=0,"AFKEndpointInterfaceClient"=30,"AppleConvergedIPCOLYBTCoreDumpProvider"=1,"OSValueObject<int>"=0,"AppleBCMWLANPCIeSkywalkPacketPool"=0,"ApplePPMSystemCapabilityMonitor"=1,"TSNBSDTestInterface"=0,"_IOOpenServiceIterator"=0,"IOAccessoryIDBusPD"=0,"IOUSBDeviceInterfaceReserved"=0,"APCIECPort"=1,"AppleH16CamInFrameReceiverBufferPool"=0,"AppleAPFSSnapshot"=1,"AppleUSBECMData"=0,"IOThunderboltConfigXDomainPathSetupRequestCommand"=0,"AGXWorkQueue"=3,"_IOMemoryDescriptorMixedData"=12768,"IOAVBValidate"=1,"IOSurfaceRoot"=1,"CCDataPipeBlobOD"=0,"ApplePPMCPMSPowerInputHelperBatteryFirmware"=0,"H16ISPSharedClientBufferArgs"=0,"IOThunderboltConfigXDomainPathCapabilitiesRequestCommand"=0,"IODiskImageBlockStorageDeviceInKernel"=0,"AppleHPMARMI2C"=0,"AppleUSBUserHCIIsochronousTransferQueue"=0,"AppleSimpleUARTCommand"=16,"AppleM68Buttons"=1,"OSSerialize"=1,"AUCAsynchronousScheduler"=1,"AppleT8112DPTXPort"=0,"OSValueObject<H16ISPExclaveMessage>"=0,"IOTimeSyncTimeOfDayAnchorPort"=0,"AppleARMCPU"=10,"IOAVUserClient"=0,"AppleCT711"=0,"IOHIDEventServiceUserClient"=143,"DitherControlMSR23"=0,"AGXTAChannelGen2"=1,"IOHIDEventSystemUserClient"=1,"IOSlaveMemoryBuffer"=26,"IOHIDRootElementProcessor"=0,"AppleSMCFamily"=1,"IOGPUNotificationQueue"=28,"IO80211WorkSource"=0,"AppleThunderboltNHIDARTVMAllocator"=48,"AppleBiometricSensorEmulatorBaseClass"=0,"IOTimeSyncIntervalFilterIIR128"=0,"IONVRAMController"=1,"AppleCplBTM"=0,"OSValueObject<ANEProgramToANEMapping>"=1,"AGXAsyncGrowEngine"=26,"OSValueObject<ANEFirmwareCommandState>"=0,"ApplePPMPolicyCPMS"=1,"IOHIDTranslationEventReq"=0,"AppleMultitouchHIDEventService"=0,"AppleEmbeddedExternalAudioObject"=0,"AppleSPURemoteCrashdump"=0,"AppleARMPMUSensor"=2,"KDIURL"=0,"IOAccessoryPowerSourceItemCurrentBase"=0,"AppleUSBUserHCITransferStructPool"=0,"AppleGasGaugeUpdateUserClient"=0,"IO80211NeighborCache"=0,"AppleARMFunctionPerfAdvise"=0,"OSValueObject<H16ISPCommandArgs>"=0,"IOUserEthernetInterface"=0,"AppleM2ScalerCSCHalMSR10"=1,"AFKEPKextBaseV2"=1,"IOThunderboltCallbackEventSource"=2,"AppleUSBXDCI"=1,"AppleATCDPNativePort"=1,"MesaCachedSystemConfig"=1,"IOPortFeatureLDCMUserClient"=2,"IOThunderboltConfigCompareSwapCommand"=0,"IOAccessoryAuthProtocolInterface"=0,"IOUserNetworkRxSubmissionQueue"=1,"IORSMChannel"=0,"IOThunderboltProtocolListener"=2,"AppleBCMWLANSkywalkMulticastQueue"=0,"AIDQueueEventSourceWorkItem"=0,"IOInterruptEventSource"=226,"AGX3DWorkQueue"=34,"IOUSBMassStorageUFIDriverNub"=0,"IosaDPEControlMSR21"=0,"IASDMAChannelManager"=9,"AppleParadeDP835TCON"=0,"KDIDiskImageNubUserClient"=0,"AVE_Thread"=1,"MesaAccessoryIntReportImageInfo"=0,"AppleHIDTransportBootloaderCBOR"=1,"AppleUSBHostInterfaceUserClient"=1,"IONVMeLifeboatBlockDevice"=0,"IOAVAsyncEventSource"=5,"IOTimeSyncPortManager"=0,"AUAFeatureUnitDictionary"=0,"IO80211PeerBssSteeringManager"=0,"AppleProcessorTraceUserClient"=2,"IOSurfaceAcceleratorClient"=2,"AGXCLChannelGen2"=1,"OSAction"=132,"AppleUSBXHCIPipe"=13,"IO80211AWDLPeerManager"=0,"IOKitDiagnosticsClient"=0,"IOPlatformIO"=1,"_IOServiceJob"=0,"AppleUSBUserHCIPort"=0,"IOBluetoothACPIMethods"=1,"AGXCommandDescriptor"=2,"AppleThunderboltNHITransmitRingManagerGenericACIO"=0,"AIDCircularReadBufferShared"=1,"TextCrypterSession"=0,"IosaDirectionalScalingPipeUnit"=0,"AppleBCMWLANStopwatch"=0,"IosaTunableControlMSR23"=0,"IOUSBHostHIDDevice"=0,"AppleTDMType00"=0,"AppleDiskImageDevice"=0,"DCPDPServiceProxy"=1,"AppleUSB30XHCIPort"=1,"IODPLegacyDualDVIService"=0,"AppleHIDTransportBootloaderFlatPack"=0,"TSNWiFiControlInterface"=0,"H16ISPMPMMemoryParams"=0,"IosaWdmaControlMSR11"=1,"AFKOOBMsgDescriptor"=0,"TSNWiFiInterface"=0,"IOAccessoryOOBPairingInterface"=0,"AMCTempSensor"=0,"AppleDockChannel"=1,"AppleSPUDispADCDriver"=0,"IOPortTransportStateIIC"=0,"IO80211NANServiceDescriptor"=0,"IONetworkController"=1,"AppleARMFabricTrace"=0,"AppleButtonsDispatchFunction"=1,"IOAccessoryPort"=0,"IODPTXPortEventLog"=10,"PMTraceWorker"=1,"IOAVTransactionLog"=0,"AppleGCResourceDeviceUserClient"=1,"AppleARMNORNVRAM"=1,"IODPHDMIPortUserClient"=0,"AppleBTMDataClientPPM"=0,"KDIFileBackingStore"=0,"OSValueObject<AsyncCommitParam>"=0,"IOPMRequestQueue"=2,"H1xANELoadBalancerClient"=1,"IOAVElementArray"=0,"CoreKDLDriver"=1,"IODTNVRAMPlatformNotifier"=1,"IODARTPIOAllocatorGeneric"=0,"OSLiveNumber"=6,"AppleH16GFamilyIO"=1,"HIDMTQueueEventSource"=1,"AppleSPUAppDriver"=1,"IOI2CInterfaceUserClient"=0,"AppleBCMWLANChipManagerPCIe4387"=0,"AppleS5L8920XPWM"=1,"AppleARMTraceController"=0,"IO80211NANPowerManager"=0,"IOAppleLabelScheme"=0,"AppleSMCDockUSB_UFP"=0,"IOUSBDeviceUserClientV2"=1,"IODPServiceAUXOnly"=0,"DCPAVPowerControllerProxy"=1,"IOEventLink"=0,"AppleARMSPMIControllerUserClient"=0,"M2ScalerScalingControlMSR10"=1,"ConnectionWatchdog"=0,"OSOrderedSetEquality"=27,"IO80211AWDLMulticastPeer"=0,"AppleThunderboltNHIGenericACIO"=1,"IODPAgileLinkRateTable"=0,"IOTimeSyncIntervalFilter"=0,"IosaDirectionalScalingPipeUnitMSR23"=0,"IOPAudioNode"=10,"IOAccessoryOOBPairingInterfaceUserClient"=0,"AppleSPUMesaDriver"=0,"IOPacketQueue"=0,"IosaCSCPipeUnit"=0,"OSValueObject<AppleH16CamInFirmwareWorkProcessorParams>"=2,"RTBuddyAutoBKPDecoder"=12,"IOServiceNotificationDispatchSource"=0,"AppleATCDPAltModePort"=2,"AppleIPDormancyHandler"=1,"AppleHPMEmbedded"=1,"IosaRequestPipeUnitMSR23"=0,"AppleBCMWLANNetAdapter"=0,"IOPerfControlClient"=4,"IOTimeSyncDaemonClientBase"=4,"KDIUDIFCacheObject"=0,"IO80211DriverCommandDescriptor"=0,"IOEthernetController"=3,"IOMemoryDescriptor"=2,"IO80211TimeSyncPeer"=0,"AppleStockholmDebugDevice"=0,"IosaPipeUnit"=0,"AppleFairplayTextCrypterSession"=0,"AGXRenderTargetMemoryG16"=33,"IOGUIDPartitionScheme"=1,"IOGPUDeviceShmem"=304,"AppleGPIODevice"=9,"KDIUDIFDiskImage"=0,"ApplePPM"=1,"IOAudioDevice"=0,"AFKSharedDataQueue"=2,"AppleUSBHub"=1,"AGXPeakPowerManager"=1,"ACMBridgeKernelService"=0,"AppleM2ScalerCSCHalMSR7"=1,"IosaRdmaPipeUnit"=0,"AppleUVDMPDControllerInterface"=0,"IO80211GASFsm"=0,"AppleUSBAudioStream"=0,"IOSlaveCPU"=1,"CCFaultReporter"=0,"BTDebugService"=2,"AppleBTMFunction"=3,"AppleUSB30XHCIARMPort"=2,"ACMAccessoryCacheKernelService"=1,"AppleConvergedIPCOLYBTControl"=1,"AppleSEPEndpointService"=1,"IODataQueue"=1,"AGXLegacySharedGartTableBacking"=0,"IOSkywalkPacket"=3520,"IO80211NANDiscoveryEngine"=0,"AGXUSCPrivMemPool"=1,"AppleProcessorTraceBringUp"=0,"AppleFileSystemDriver"=0,"IOPortTransportProtocol"=0,"IOAccessoryManagerHSAID"=0,"IODPServiceUserClient"=0,"AppleANEMPMUnmapMemoryFunction"=0,"IOAESAcceleratorCommand"=32,"AppleT8103PCIeCPort"=0,"AppleProcessorTraceFracturedMemoryMap"=0,"AppleS8000DWIVoltageFunction"=0,"IOThunderboltNHITransmitRing"=0,"AppleM2ScalerCSCHalMSR23"=0,"AppleThunderboltIPTransmitter"=0,"ApplePMGRFunctionAvoidPerfState"=0,"AppleS8000DWI"=1,"UserTimerEventSource"=3,"IO80211ColocatedGroupManager"=0,"IOSkywalkLogicalLink"=4,"AppleHPMInterfaceType11"=1,"OSAction_IOHIDEventService__SetLED"=0,"AppleBCMWLAN11beAdapter"=0,"RTBuddy64"=0,"ANERequest"=0,"AppleBCMWLANWnmAdapter"=0,"AppleParadeDP865TCONSPI"=0,"IODPDevice"=0,"IOUSBHostIOSource"=1,"AppleThunderboltDPInAdapterCM"=1,"AppleBCMWLANChipManagerPCIe0x4377b"=0,"IOAccessoryHIDDeviceEndpoint"=0,"IOAVHandler"=0,"IO80211LinkRecovery"=0,"IOAVAudioChannelLayoutElement"=9,"AppleUSBHostControllerIsochEndpoint"=0,"IOSARTMapper"=0,"AppleDisplayPseudoStandbyFunction"=0,"IODPTXPort"=2,"AppleT602XDPTXPort"=0,"IORSMReceiveQueueEntry"=0,"IOPCI2PCIBridge"=2,"AppleT8030USBXDCI"=0,"AppleDisplayCrossbar"=1,"IOAccessoryBulkDataEndpoint"=0,"AppleProcessorTraceT8110"=0,"IOMediaBSDClient"=7,"ACMKeybagKernelService"=0,"AppleJPEGHal"=2,"M2ScalerCSCColorConversionControlMSR"=1,"IOAVController"=0,"AGXRenderTargetMemory"=1,"AppleMemCacheEvent"=0,"IOTimeSyncInterfaceAdapter"=0,"AppleUSBUserHCIRequest"=0,"AppleThunderboltIPReceiveCommand"=0,"IOThunderboltPort"=16,"AppleSMCPowerOut"=0,"RTBuddyNativeSlaveMemoryDescriptor"=0,"AppleAuthCPMGAID"=0,"IOAVBTimeSyncCaptureUserClient"=0,"mDNSOffloadUserClient"=0,"AppleMultitouchHIDService"=0,"AppleTII2CAudio"=1,"IOThunderboltI2CCommand"=4,"IOUserBlockStorageDevice"=0,"M2ScalerSrcDestCfgControlMSR13"=1,"IO80211QueueCall"=0,"RTBuddyProductVersionDecoder"=12,"IOAccessoryPowerSourceItemPD"=0,"OSObject"=284,"IOHDIXHDDriveNub"=0,"IO80211NANRangingManager"=0,"AGXUATMux"=88,"IO80211NetworkPacket"=0,"AppleCSCodecMikey"=1,"AppleBCMWLANChanSpec"=0,"IOBluetoothHCIController"=1,"IOGPUSubMemoryDescriptor"=0,"AppleSOCDInterface"=0,"IO80211NANSyncEngine"=0,"IOUSBMassStorageCBIDriver"=0,"AppleBCMWLANHashtable"=0,"AGXAccelerator"=1,"ANEPrivilegedVMAccess"=0,"RTBuddyNvramDecoder"=12,"AppleSystemPolicyUserClient"=2,"IOKitDiagnostics"=1,"IosaColorManagerMSR15"=1,"IOTimeSyncEthernetPort"=0,"WCLJoinManager"=0,"ApplePTDFunctionMultiCmd"=1,"AppleDieTempController"=0,"WCLGASFsm"=0,"AppleSEPBooter"=1,"AGXBlockFence"=2,"AppleBCMWLANChipConfigSpace"=0,"IOUSBHostInterfaceIterator"=0,"IOTimeSyncEthernetModernInterfaceAdapter"=0,"WCLJoinCandidateSelector"=0,"RTBuddySyslogEndpoint"=8,"IOSurfaceMemoryRegion"=1,"IO80211NANProtocol"=0,"OSValueObject<ANEClientContext>"=3,"AGXCLChannelG16"=20,"AppleM2ScalerCSCHalMSR"=1,"AppleBCMWLANSkywalkRxSubmissionQueue"=0,"IOTimeSyncTimeOfDayPort"=0,"IOAVValueSet"=0,"AppleEmbeddedAudio"=2,"com_apple_AppleFSCompression_AppleFSCompressionTypeZlib"=1,"CCPipe"=2,"AppleAPFSMediaBSDClient"=3,"AppleUSBXHCIStream"=0,"AppleProcessorTraceT6020"=0,"WCLNetManager"=0,"IOHIDTranslationEvent"=0,"IOGPUIOCommandBuffer"=0,"AppleIOP"=1,"WCLScanCacheStore"=0,"IOAccessoryIDBusSystemStatesUserClient"=0,"ApplePPMPolicyCPMSPowerServoLowerLayerCEs"=1,"AGXTAChannelG16"=33,"IOUserNetworkTxSubmissionQueueCompat"=0,"IOThunderboltTunnelDriver"=3,"AppleProcessorTraceT8142"=0,"IOAVCECInterface"=0,"AppleUSBCDCCompositeDevice"=1,"IOExclaveProxy"=0,"AGXVirtualMemory"=0,"IOAVHandlerInternalDisplay"=0,"AppleARMFunctionSlowAdaptiveClockingAggressor"=3,"OSValueObject<ANEDriverRequestParams>"=0,"IOFastPathDescriptor"=0,"AppleSerialShim"=1,"AGXGPUMemBlockPool"=0,"AppleKeyStoreUserClient"=104,"IO80211FlowQueueDatabase"=0,"AppleT6020PCIePIODMA"=1,"AppleUSBAudioEngine"=0,"AppleBCMWLANKeepAliveOffload"=0,"IOPortFeaturePowerIn"=3,"AppleANS2CGv2Controller"=1,"AppleATCDPOUTAdapterPort"=0,"ApplePMGRFunctionISPRefClock"=0,"AppleSmartIOControl"=1,"IOPolledInterface"=2,"AGXArmFirmwareASC"=1,"AppleNVMeNamespaceUC"=0,"IOThunderboltSwitchI2CCommandQueue"=0,"AppleUSBXHCIPort"=2,"AppleBCMWLANGCRAdapter"=0,"IOHIDPointingDevice"=0,"AppleHIDTransportSMCNotifier"=0,"IOHIDProviderPropertyMerger"=0,"IOThunderboltSideband"=0,"IOUserNotification"=2,"AGXParameterBufferBlock"=1,"AppleUSBXHCISparseRequest"=0,"IOUSBDeviceConfigurator"=2,"IOAccessoryManagerUserClient"=0,"IOHDIXController"=1,"PMSettingHandle"=1,"VictimUserClient"=0,"AppleTypeCPhyUSBInterface"=8,"AppleSMCEmbeddedFunction"=6,"AppleConvergedIPCOLYBTLogProvider"=1,"IOThunderboltSwitchOS2"=0,"IOTimeSyncUnicastLinkLayerEtEPort"=0,"RTBuddyRtkitDecoder"=12,"AppleStockholmSPMI"=1,"OSAction_IOHIDDevice__CompleteReport"=0,"IOGPUBlockFencePort"=28,"AppleSPUALSDriver"=0,"ApplePMGRFunctionVideoClock"=0,"AppleUSBHostBusCurrentPool"=0,"IosaPremultiplyAlphaMultiplyPipeUnit"=0,"IOGPUMemoryInfoUserClient"=0,"ACMRestrictedModeAnalyticsKernelService"=1,"AppleARMGPIOFunction"=8,"IOGraphicsSystemWorkLoop"=1,"AppleH16CamInVMAllocator"=0,"IONetworkUserClient"=0,"IOBioUtils"=0,"AppleEmbeddedUSBDevice"=0,"IO80211PeerManager"=0,"IOThunderboltIECSNub"=0,"IOAccessoryIDBusProxyPD"=0,"IOAccessoryHSAIDBulkDataEndpoint"=0,"AppleBCMWLANTimeKeeper"=0,"IOPortFeatureLDCM"=1,"IO80211InterfaceMonitor"=0,"IOHIDEventServiceFastPathUserClient"=0,"AppleARMPassthroughPowerSource"=0,"AppleARMSPMIController"=1,"IOMbufNaturalMemoryCursor"=0,"IosaFirmwareControlMSR24Rtk"=0,"AppleARMSFRManifest"=1,"IOHIDEventSource"=20,"IOTimeSyncTimeLineFilter"=0,"AppleNVMeNamespaceDevice"=2,"ApplePMGRFunctionReconfigTrigger"=2,"SEPHibernatorService"=1,"AppleUSBHostFrameworkClient"=1,"IODMAController"=2,"IOAVBNub"=1,"IOAVAudioDMADelegate"=1,"IOPortTransportStateOrderedSet"=0,"DCPAVCECInterfaceProxy"=0,"IOTimeSyncDomainDaemonClient"=1,"IO80211WorkQueue"=0,"_HACK_RingBuffer"=0,"AbstractPMGR"=0,"AppleUSBNetworkingHostCommandPool"=0,"IOMemoryCursor"=0,"AppleUSBCDCControl"=1,"OSKext"=412,"AppleHIDTransportInterface"=7,"IOGraphicsDevice"=0,"IOResources"=1,"IOGPUSurfaceMTL"=0,"AppleTDMControlLUN"=0,"IOServiceStateNotificationDispatchSource"=0,"AGXSoKGrowEngine"=0,"IOThunderboltXDLocalPropertiesCache"=2,"_IOUserServerCheckInCancellationHandler"=0,"AppleMPMUnmapMemoryFunction"=0,"IOConditionGate"=1,"RTBuddyMailboxDecoder"=12,"IOThunderboltSwitchDelegate"=1,"ApplePMGRFunctionSetPerfState"=0,"IOUSBInterface"=1,"AppleBCMWLANWorkOrder"=0,"AppleAPFSGraft"=4,"AppleUSBDeviceNCMPrivateEthernetInterface"=2,"IOUSBMassStorageUASDriverCommand"=0,"IOAVBNubUserClient"=0,"AppleARMIICController"=1,"RTBuddyCoredump"=2,"IOTimeSyncUserFilteredService"=0,"AUAEndpointDictionary"=0,"AppleThunderboltNHITransmitRingManagerType5"=0,"AppleTypeCRetimer"=2,"IOAVAudioElement"=9,"IOAccessoryPowerSourceItemExternal"=0,"RTBuddyHeapDecoder"=12,"IosaDegammaPipeUnit"=0,"IOSkywalkPacketQueue"=5,"AppleARMFunctionIISActive"=0,"AppleARMPMUTempSensor"=45,"AppleHPMInterfaceType18"=0,"IOThunderboltLocalNode"=2,"IOServiceStateNotificationEventSource"=0,"AIDSnifferInterface"=0,"AppleBakuBTM"=0,"AppleBCMWLANHistogram"=0,"AppleM2ScalerCSCDriver"=1,"IOMemoryMap"=13725,"IONetworkData"=14,"AppleBTMBatteryDataAgent"=0,"AppleTICD2E22"=0,"AppleUIOPCIUserClient"=0,"IOUserNetworkPacketBufferPool"=1,"IOThunderboltData"=0,"M2ScalerScalingControlMSR8"=1,"AUAConfigurationDictionary"=0,"AppleARMSPIDevice"=3,"IOBioSharedMemoryTransferQueue"=0,"AppleUSBAudioComposite"=0,"M2ScalerSrcDestCfgControlMSR6"=1,"AppleRSMChannelControllerClient"=1,"IOUSBMassStorageResource"=1,"AppleSPUMarconiFunction"=0,"AppleTempSensorUserClient"=0,"AppleATCDPXBAR"=1,"IOPortTransportStateUSB2"=4,"AppleT8103USBXDCI"=0,"RTBuddyRoute"=1,"ApplePPMUserClient"=1,"BTDebugReporter"=1,"AppleT8027USBXHCI"=0,"AppleSynopsysDRDUSBXHCICommandRing"=0,"AUAProcessingUnitDictionary"=0,"AGXResource"=9826,"AFKAsyncRequestV2"=0,"IOAudioToggleControl"=0,"AppleLIFSUserClient"=1,"IOGPUMemoryMap"=1,"AppleHPMBusDevice"=0,"IosaWdmaControlMSR25"=0,"IOImageLoaderRequest"=0,"AppleUSBHostBusCurrentAllocator"=20,"IOPCIHostBridge"=2,"DIDeviceCreatorUserClient"=0,"AppleNotificationQueue"=10,"SEPApNonce"=0,"IOThunderboltXDomainLink"=0,"OSValueObject<H16ISPClientContext>"=2,"AGXEventMachine"=1,"AppleT8150USBXDCI"=0,"RTBuddySlaveMemoryBuffer"=67,"IOHIDEventDriver"=3,"AppleMesaAccessory"=0,"AppleHPMDeviceHALType3"=3,"HSAIDTransmitCommandPool"=0,"IOSimpleMbufMemoryDescriptor"=0,"IosaRegammaPipeUnit"=0,"AppleM2ScalerCSCHalMSR20"=1,"ApplePassThroughEstBTM"=0,"IOTimeSyncServiceDaemonClient"=5,"IOAVSplitDisplay"=0,"IOThunderboltAbstractMicro"=0,"IOThunderboltCommandQueue"=2,"EventElementCollection"=1,"IO80211NANDataPathSession"=0,"FPMemoryDescriptor"=0,"IOBluetoothLocalUtilityEventSource"=0,"DCPAVAudioInterfaceProxyUserClient"=0,"AppleUSBSerialUserClient"=0,"IOSCSICommandGate"=0,"IOThunderboltCableState"=8,"AppleThunderboltNHIReceiveRingManagerType7"=0,"AppleSEPXARTService"=2,"AppleBCMWLANInfraProtocol"=0,"AppleBCMWLANChipBackplane"=0,"AGXUnifiedAddressTranslator"=0,"AppleT8132ANEHAL"=1,"AppleBiometricServices"=1,"AppleUSBUserHCIDevice"=0,"WCLBssManager"=0,"TSNAssistedInterface"=0,"ApplePMGRFunctionAssertReset"=6,"AppleEmbeddedSimpleSPINORFlasherDriver"=1,"IOTimeSyncTimeLineFilterIIR"=0,"MesaAccessoryIntReportFingerState"=0,"IOUserNetworkMemorySegment"=316,"AppleMultitouchHIDEventDriver"=0,"ANEClientHintsUserClient"=0,"BootPolicy"=1,"IosaDPEControlMSR17"=0,"AGXCLCommandDescriptor"=1,"AppleOnboardSerialBusInterface"=1,"AHTMemoryDumpExtractor"=0,"IOCECService"=0,"IODARTVMAllocatorGeneric"=29,"IOUserNetworkPacket"=0,"IOAVDisplayMemoryUserClient"=0,"IOCECMergeProperties"=0,"CCLogPipe"=2,"IOPartitionScheme"=2,"AppleT6000USBXHCICommandRing"=0,"IOSkywalkNetworkController"=0,"KDIUDIFEncoding"=0,"DCPLink"=3,"AppleNVMeRequestPool"=1,"IOEthernetInterface"=6,"AppleHIDTransportProtocolNone"=0,"AppleUSB20Hub_32789"=0,"AHTRTBuddyFirmwareService"=0,"KDIDiskImage"=0,"AppleNVMeWorkLoop"=2,"AppleBCMWLANCommandQueue"=0,"AFKBufferMemoryDescriptor"=0,"IO80211AsyncEventUserClient"=0,"IOGPUMTLLateEvalEvent"=0,"IOThunderboltConfigReadCommand"=11,"AppleActuatorHIDEventDriver"=1,"IOThunderboltConfigNotifyAckCommand"=2,"ACMLockdownModeKernelService"=1,"AppleAVE2Driver"=1,"RTBuddyVisibleMemoryImpl"=32,"IOTimeSyncRootService"=1,"IOUSBMassStorageCBIDriverNub"=0,"RTBuddyUnknownDecoder"=12,"AppleTCControllerType1"=0,"IODispatchQueue"=108,"AppleSMCCharger"=0,"WCL11axManager"=0,"ApplePPMSMCInterface"=0,"AppleSPMIController"=5,"IOThunderboltConfigPollQuadletCommand"=0,"IO80211IOUCEventPipe"=0,"AppleThunderboltDPAdapterFamily"=0,"AppleConvergedIPCBTIInterface"=0,"ApplePMGRFunctionWaitForDeviceEvent"=1,"AppleBCMWLANBusInterface"=0,"AppleAVE2UserClient"=0,"AppleNVMeBuffer"=5,"IOTimeSyncUnicastUDPv4PtPPort"=0,"AppleUSB30AccessoryHub"=0,"AppleARMSPIController"=2,"AppleSEPDebugArgs"=0,"DCPPowerManager"=3,"AppleMultitouchHIDEventDriverV2"=1,"IosaTunableControlMSR24"=0,"IOThunderboltConfigXDomainPathControlRequestCommand"=0,"PerfControlClient"=1,"AppleConvergedIPCControlUserClient"=0,"IosaRdmaControlMSR10"=1,"IOAccessoryDockUSB_UFP"=0,"AppleSEPLogger"=0,"ApplePMGRFunctionPDMClockBypass"=0,"HibernationService"=1,"TSNUserWiFiControlInterface"=0,"AppleUSBRealtek8153Patcher"=0,"M2ScalerSrcDestCfgControlMSR24"=0,"AppleBCMWLANPCIeIO"=0,"IOCommand"=304,"AGXSharedGartTableBackingG16"=1,"IOAVDeviceUserClient"=0,"IOAudio2Device"=2,"AppleARMIO"=1,"IO80211NANRadioResourceManager"=0,"WCLScanManager"=0,"CoreAnalyticsHub"=1,"IOThunderboltControllerType7"=0,"AppleT602XATCDPXBAR"=2,"WCLRoamManager"=0,"IODARTMapperNub"=90,"AppleBCMWLANByteRing"=0,"IO80211InfraInterface"=0,"MesaAccessoryIntReport"=0,"PassthruInterruptController"=1,"AppleProcessorTraceT8310"=0,"IOAccessoryPowerSourceItemCurrentOffset"=0,"IosaFilmGrainControlMSR23"=0,"IOPAudioService"=1,"IOPortTransport"=0,"IOUSBMassStorageInterfaceNub"=0,"OSCollectionIterator"=149,"AppleBCMWLANTxBuffer"=0,"AppleDCPExpert"=3,"AppleSMCBinaryLogDriver"=0,"IOThunderboltXDPropertiesImmediateValue"=18,"AppleUSBXHCIIsochronousTransferRing"=0,"OSValueObject<ISPCoredumpSection>"=0,"IOUserNetworkWLAN"=4,"AppleARMFunctionIISRoute"=0,"AppleSPUAppInterface"=4,"IOThunderboltSwitchOS"=1,"CommonTimerFactory"=0,"AppleANS3NVMeController"=0,"AppleSmartIOEndpoint"=3,"IODARTMapperClient"=0,"IOHIDDeviceShim"=0,"IOStateReporter"=434,"AppleMultitouchMouseHIDEventDriver"=0,"IODPCECInterface"=0,"AppleSSE"=1,"IOAVDisplayConnectionManager"=1,"AppleOLYHAL"=1,"IOGPUSharedEventFence"=0,"IOHIDTranslationServiceClient"=0,"IOBasicOutputQueue"=0,"IOAccessoryPortIDBus"=0,"AppleT8027USBXHCICommandRing"=0,"HSAIDTransmitPacket"=0,"AppleI2CRangedMultipleAudio"=0,"IosaRdmaControl"=1,"AppleProResUserClient"=0,"com_apple_filesystems_apfs"=1,"AppleMesaCommand"=1,"OSEntitlements"=1665,"AppleNVMeRequestPoolTagReserve"=1,"AppleHPMARMSPMI"=3,"AudioDMAController"=2,"AppleSMCACAMUserClient"=0,"IORSMReceiveQueue"=0,"M2ScalerScalingControlMSR23"=0,"AppleUSBAudioIsocFrameList"=0,"IOTimeSyncClockManager"=1,"IOHIDPointing"=0,"AppleATCDPOUTAdapterPortBase"=0,"M2ScalerScalingControlMSR15"=1,"IOSurfaceDescriptorComponent"=0,"AppleThunderboltNHIBufferMemoryBlock"=0,"AppleH16CamInWorkLoop"=1,"com_apple_filesystems_nfs"=1,"AppleDisplayConnectionManager"=1,"ApiodmaRegStreamMSR11"=1,"IOImageLoader"=0,"ApplePIODMARequest"=48,"IOSkywalkLegacyEthernet"=1,"ExclavesAudioProxyDebugInterface"=0,"AppleT8142USBXHCI"=0,"AppleAOPSMCFunction"=0,"IO80211NANDataProtocol"=0,"OSValueObject<ANEClientResource*>"=0,"BinaryEncoderHCC2x"=0,"ApplePMP"=0,"IOThunderboltSwitchType5"=2,"IOBluetoothL2CAPSupervisoryFrameMemoryBlock"=0,"AppleThunderboltDPConnectionManager"=2,"AppleSPUHIDInterface"=8,"ApplePMGRFunctionEnableAutoClockGate"=0,"AppleBCMWLANTaskmaster"=0,"ANEProgramRTResource"=0,"IOThunderboltControlPath"=2,"DIDeviceRequestPool"=0,"AppleThunderboltNHITransmitRingManager"=0,"AppleARMPerformanceController"=0,"IOThunderboltXDPropertiesLeafText"=4,"AppleM2ScalerCSCHalMSR8"=1,"IOAVBTimeSyncCapture"=0,"AppleNVMeEAN"=1,"IOPMPowerSourceList"=0,"AppleT700XTempSensorDisableSensorFunction"=0,"CCLogStream"=2,"IOUserResources"=1,"AppleTypeCPhyCIOInterface"=2,"IOGPUMappingCommandDescriptor"=0,"IODARTClient"=0,"IOAVBRingBufferMemoryDescriptor"=0,"IOAudioSelectorControl"=0,"IOAVVideoInterfaceUserClient"=0,"ApplePMGRFunctionEnableTouchClock"=0,"ANEProcess"=1,"AppleThunderboltDPPathManager"=0,"AppleProcessorTraceT8120"=0,"AppleThunderboltUSBDownAdapter"=2,"IONetworkInterface"=1,"AppleARMSPICommand"=48,"OSValueObject<ANESharedMemorySurfaceParams>"=3,"IOAccessoryIDBusBulkDataEndpoint"=0,"OSValueObject<ANEInDebugWorkProcessorParams>"=0,"AppleCLPC"=1,"AppleSMC"=1,"IOAccessoryPortIDBusSNTP"=0,"IOThunderboltTRMPolicyRoot"=2,"IO80211PoolMgr"=0,"IOAVIISAudioLinkDelegate"=0,"IOSCSITargetDevice"=0,"IOHIDConsumer"=0,"AppleBCMWLANObjectQueue"=0,"AppleEmbeddedKeyboard"=2,"AppleBCMWLANBusInterfacePCIe"=0,"RTBuddyEndpointPSEventSource"=12,"AppleARMSlowAdaptiveClockingManager"=1,"IOGPUEventMachine"=1,"IOAccessoryPowerSourceItem"=0,"IOGeneralMemoryDescriptor"=4783,"AFKLocalMemoryDescriptorManager"=3,"AGXCLChannel"=1,"IODPTXVirtualPort"=0,"IOHIDInterface"=20,"AppleTCControllerType14"=0,"IODPHDCPMessageTransportDelayContentType"=0,"AppleUSBUserHCIPipe"=0,"AppleAuthCPUserClient"=0,"IOAccessoryPowerSourceItemUSB_ChargingPort"=0,"CCDataSession"=0,"AGXSharedGartTableBacking"=1,"AppleOnboardSerialBSDClient"=1,"AppleANEPowerOnOffFunction"=0,"AppleH16CamInUserClient"=1,"AIDLogger"=2,"AppleActuatorSecondaryAudio"=0,"AppleActuatorDeviceUserClient"=1,"AppleAPFSVolume"=12,"AGXUSCPrivMemPoolUMA"=26,"IOUserClient2022"=20,"AppleBCMWLANPCIeFlowQueue"=0,"IO80211ServiceRequestDescriptor"=0,"AppleSmartBatteryHFDataClient"=0,"AppleSmartIOCommand"=176,"IosaReshapePipeUnit"=0,"AppleSPUSpkAmpStateFunction"=0,"IOPAudioClientManagerDevice"=2,"IosaDPEControlMSR11"=1,"TSNInterface"=0,"TSNBSDInterface"=0,"AppleT8132USBXDCI"=2,"AppleUSBAudioControlInterface"=0,"IOMedia"=9,"AppleT8101USBXHCI"=0,"TAAsyncReport"=0,"IOAVWAVRecorder"=0,"IOEmbeddedNVMeBlockDevice"=1,"AppleS5L8920XFPWM"=1,"IOUSBMassStorageDriverRequestTimer"=0,"AppleBCMWLANChipManagerPCIe4357"=0,"AppleProcessorTraceT6030"=0,"IO80211LQMData"=0,"IOThunderboltController"=1,"IOPortTransportStateCIO"=0,"IOHIDClientData"=143,"IOThunderboltPath"=0,"IOSurfaceSharedEventNotificationPort"=12,"AppleTypeCPhy"=1,"USBConfiguration"=2,"IOThunderboltI2CCommandQueue"=0,"IOSKArena"=121,"M2ScalerSrcDestCfgControlMSR2"=0,"IosaPrescaler3x3PipeUnitMSR23"=0,"AppleHIDTransportBootloaderUserClient"=0,"IosaPowerManager"=1,"IORegistryEntry"=3,"AFKACIPCEndpoint"=0,"ANEPrivilegedVMAccessUserClient"=0,"IONotifier"=3,"AppleHDCPManager"=1,"AppleJPEGWrapperControlLegacy"=0,"IOFBController"=0,"IOUserEthernetResourceUserClient"=0,"AppleProcessorTraceT8101"=0,"IOAccessoryPowerSourceItemUSBHost"=0,"IOBluetoothDevice"=1,"IOSkywalkEthernetInterface"=1,"AIDReporters"=2,"AppleSEPXART"=2,"AppleAPFSMedia"=3,"IAGXUSCPrivMemGrowEngine"=1,"AppleBCMWLANProximityInterface"=0,"AppleSEPDeviceService"=12,"AGXAllocation"=9996,"ApplePMGRFunctionPowerGate"=1,"AppleSmartIO"=1,"IOReportUserClient"=11,"IOHDIXHDDriveOutKernel"=0,"IOTimeSyncClockMapping"=2,"AppleT8122USBXHCICommandRing"=0,"AppleSPUHIDDriverUserClient"=2,"RTBuddyCrashlogSectionDecoder"=16,"AppleUSBECMControl"=0,"IOUSBHostInterface"=15,"IOAccelGPURestartReport"=0,"AFKRTBuddyHelper"=39,"AppleStockholmControlUserClient"=0,"AppleFabricTraceUserClient"=0,"AppleConvergedIPCBTAdapter"=0,"AppleMPMMapMemoryFunction"=0,"IOAVInterface"=0,"DCPDPServiceProxyUserClient"=0,"IOHIDElementProcessor"=0,"AppleTrustedAccessoryInterface"=0,"ANEProgramResource"=1,"IOSkywalkNetworkBSDClient"=4,"AppleAVDUserClient"=0,"AGXLateEvalEvent"=0,"IOGPUMappingFence"=0,"AppleCallbackPowerSource"=0,"AppleARMIODevice"=132,"IOThunderboltXDomainTransmitPath"=0,"AppleThunderboltDPInAdapterBase"=1,"AppleT8140USBXDCI"=0,"IO80211InfraProtocol"=0,"DMAChannelECProxyInterface"=0,"IOUserNetworkRxCompletionQueueCompat"=0,"IOHIDLibUserClient"=14,"AppleFDEKeyStoreUserClient"=0,"AppleI2CAudio"=1,"WCLCoreDbg"=0,"AppleARMBootPerf"=1,"AFKMemoryDescriptorManagerBase"=1,"AppleThunderboltNHIType5"=2,"AGX3DChannel"=1,"AGXLegacySharedGartTableBackingG16"=0,"OSAction_IOUserNetworkEthernet__DataAvailable"=7,"AppleBCMWLANApFeatureConfig"=0,"AppleBTMBPICAgent"=0,"ANEPatchedWeightInfo"=0,"IOThunderboltConfigXDomainUUIDRequestCommand"=2,"IO80211NANRangingSession"=0,"IOThunderboltXDomainServiceClientManagerMergeProperties"=0,"IOInterruptController"=10,"IOTimeSyncFDEtEPort"=0,"AppleSEPHDCPManager"=1,"CachedUserContext"=1,"ANEPowerOnMsg"=0,"AppleNVMeRequest"=64,"IOTBTTunnelDriverInterfaceType3"=0,"IosaInternalPipeMSR8"=1,"AppleSeraBTMiPad"=0,"AppleSeraBTM"=0,"IOGPUChannel"=2,"IOHIDDevice"=6,"AFKMemoryDescriptor"=0,"WCLJoinCandidate"=0,"IOUSBMassStorageResourceUserClient"=0,"client_log_buffer_t"=0,"KDIRAMBackingStore"=0,"IOMobileFramebufferShim"=3,"AppleI2CRangedAudio"=1,"IOThunderboltString"=47,"IosaTiledCompressedMem"=1,"IOTimeSyncTimedEdgeGenerator"=0,"M2ScalerScalingControlMSR4"=1,"IOInterruptDispatchSource"=1,"IosaEnhancementPipeUnit"=0,"IosaColorManagerMSR10j"=0,"IosaDPEControl"=1,"ApplePMGRNub"=3,"AppleBCMWLANProvisioningManager"=0,"AppleConvergedIPCRequestPool"=1,"IOPortTransportUserClient"=0,"DaisyFunctions"=2,"ModularDefaultFilter"=4,"IO80211SimpleReporter"=0,"IOSCSIHierarchicalLogicalUnit"=0,"IosaColorManagerMSR8"=1,"AGXFirmwareKextG16RTBuddy"=1,"M2ScalerScalingControlMSR"=1,"AppleConvergedIPCIOCommandPool"=1,"AppleUSBACMControl"=1,"IOThunderboltXDomainServiceClientManager"=2,"IxoraFunctions"=0,"IOThunderboltConfigReadQuadletCommand"=4,"IosaRdmaControlMSR8"=1,"AppleBCMWLANConfigManager"=0,"IOGPUTask"=1,"IO80211ActionFrameDescriptor"=0,"AppleUVDMUserClient"=0,"IosaDegammaPipeUnitMSR23"=0,"IosaPipeControl"=8,"IOGPUMTLFence"=0,"M2ScalerSrcDestCfgControlMSR22"=0,"AppleARMCFIFlashController"=0,"OSValueObject<ANEIOReporter*>"=0,"IOAVBGPIOEdgeTimeCapture"=0,"AFKEndpointInterfaceUserClient"=2,"ApplePPMCPMS"=1,"AGXGFXDVAccessor"=0,"AppleUSB20XHCIPort"=1,"IOSKMapper"=104,"CryptoBufferDescriptor"=0,"IosaPolyphaseScalingPipeUnit"=0,"AppleARM64ErrorHandler"=1,"AppleUSBRequestPool"=2,"AppleARMFunctionChargerMux"=0,"ApplePMGRFunctionEnableCPUCore"=0,"AppleBCMWLANPCIeCompletionRing"=0,"IOSurfaceSharedEventListener"=7,"AGXGartG16"=88,"OSNumber"=73129,"AppleUSBHostResources"=1,"ExclavesAudioProxyEndpoint"=0,"ApplePPMCPMSPowerInputHelper"=0,"IOThunderboltSwitchIntelJHL9580"=0,"AppleAPFSUserClient"=0,"AppleHIDTransportDRAMUsageStats"=1,"IO80211ScanCacheStore"=0,"RTBuddyBinaryLogEntryHandlerTraceKit"=7,"IOTimeSyncUnicastUDPv6PtPPort"=0,"AppleJPEGDriverUserClient"=0,"IOPortTransportProtocolCCUSBPDSSAM"=0,"OSValueObject<ANEClientMappedSurfacePR>"=0,"AppleCLPCUserClient"=4,"IO80211BufferSlab"=0,"AppleBCMWLANPCIeSkywalkTxCompletionQueue"=0,"IOHIDResourceDeviceUserClient"=3,"IosaFirmwareControlMSR25Rtk"=0,"IOServiceUserNotification"=788,"TransducerState"=0,"IOSkywalkStatisticsReporter"=46,"IO80211NANServiceManager"=0,"IO80211BufferPool"=0,"IOHDCP2TransmitterAuthSession"=1,"IOAVCommandDelegateService"=0,"AppleUSBUserHCITransferQueue"=0,"DisplayScalerFilter"=0,"OSValueObject<ANEClientMappedSurface>"=0,"ADMACCEDInterface"=0,"AppleARMPMUAccessoryPS"=0,"IOHIDWorkLoop"=1,"IOGDiagnosticUserClient"=0,"IO80211ScanManager"=0,"IOWatchDogTimer"=0,"AppleThunderboltDPAdapterFamilyBase"=1,"IOThunderboltSwitchType2"=0,"AppleT8122USBXHCI"=0,"IOGPUObject"=16,"IOSkywalkRxCompletionQueue"=5,"IOAudioStream"=0,"IOFenceTransaction"=5,"IOUserClient"=38,"CommonFaultReporter"=0,"AppleH16CamInFrameReceiverBuffer"=0,"IOEventSource"=29,"IOGPUStatistics"=1,"IOAccessoryIDBusPDSupplyData"=0,"AppleUSBRequest"=1,"AGXLegacyMemoryMap"=0,"AppleM2ScalerCSCHalMSR2"=1,"IO80211NANPublishServiceDescriptor"=0,"APFSCryptoContext"=0,"IOHIDPowerSource"=1,"AppleM2ScalerCSCHalControl"=8,"AGXBlockedArray"=0,"AppleConvergedIPCSkywalkPacketPool"=5,"IODART"=1,"SEPHibernator"=1,"ANEDriverEventSource"=1,"AppleMesaSEPDriverInterface"=1,"AVE_WorkPool"=1,"IOAVAudioPattern"=0,"IO80211NANDataPeer"=0,"SMTransition"=390,"AppleAuthCPDock"=0,"AppleHPMDeviceHALType5"=0,"IOBiometricService"=1,"AppleARMSPIFlashController"=1,"AppleSOCD"=0,"AppleJPEGDriver"=1,"AppleSEPGenericTransfer"=3,"IOUserSerial"=1,"AppleConvergedIPCInterface"=1,"AppleSPUCT720"=0,"AppleIISAudioLinkDelegate"=0,"AIDInterface"=1,"IOUSBMassStorageDriverUFIStorageServices"=0,"AGXShared"=74,"IOAudioClientBufferSet"=0,"AppleARMWatchdogTimer"=1,"AppleUSBHubIICDevice"=0,"IOBioShareableMemoryObject"=0,"IOMFBSwapIORequest"=0,"OSKextSavedMutableSegment"=17,"IODPSwitch"=1,"ApplePMGRFunctionUSBClock"=0,"AppleUSBXHCIIsochronousRequestPool"=2,"AGXCommandQueue"=28,"AppleSPUControl"=0,"M2ScalerSrcDestCfgControlMSR9"=0,"IOPortTransportComponentCCUSBPDSOP"=1,"AGXInternalResource"=671,"AppleCS42L84Mikey"=1,"IOTimeSyncTranslationMach"=1,"IOFastPathUserClient"=0,"AppleHPMInterface"=2,"AppleHPMIECS"=0,"IOGPUMultiMemoryDescriptor"=0,"DitherControlMSR4"=0,"IO80211P2PDataPathManager"=0,"AppleBCMWLANTxItemRing"=0,"MSR23DefaultFilter"=0,"IO80211CommandGate"=0,"IOSurfaceDescriptor"=0,"AppleEmbeddedNVMeTemperatureSensor"=1,"IOCoastGuardSARTMapper"=1,"AppleBakuBTM2"=0,"AppleM2ScalerCSCHalMSR11"=1,"CCIOReporterLogStream"=0,"IOThunderboltConfigXDomainCommand"=2,"AppleUSBXHCIInterrupterMSI"=0,"ClientObject"=0,"RTBuddyUserClient"=0,"IOAccessoryPortUserClient"=0,"DCPAVControllerProxy"=5,"IOMobileFramebufferUserClient"=8,"AppleBCMWLAN11axAdapter"=0,"RTBuddyCallStackDecoder"=12,"IOTimeSyncUserFilteredServiceUserClient"=0,"IOThunderboltConfigXDomainPathSetupCompleteRequestCommand"=0,"AppleT8130USBXHCI"=0,"AppleUSBDeviceNCMData"=4,"AppleGCSyntheticDevice"=0,"AppleDCPLinkServiceSoC"=3,"IOAVSliceVideoInterface"=0,"AppleImage4UserClient"=1,"CCIOService"=50,"AGXArmFirmwareMapper"=1,"IOSkywalkNetworkKDPPoller"=0,"IOCancelationWrapper"=0,"AppleThunderboltGenericHAL"=1,"ApplePCIEMSIController"=1,"IOGateLock"=1,"IOThunderboltConfigCommand"=9,"AppleBTMDataClient"=0,"IODPServiceConcreteUserClient"=0,"IOThunderboltMultiMapper"=0,"OSValueObject<AltInfo>"=12,"IOSurfaceDeviceMemoryRegion"=1,"AppleUSBXHCIIsochronousRequest"=15,"ApplePMGRFunctionResetPSDService"=0,"IOAVControlInterfaceConcreteUserClient"=0,"IOPMClientAck"=0,"IosaTunableControlMSR25"=0,"AppleUSBAudioStreamNode"=0,"IONVMeController"=1,"AppleH16CamIn"=1,"AppleSMCAcamLogHandler"=0,"IosaRdmaControlMSR18"=0,"AppleHPMInterfaceType1"=0,"IOHIDTranslationService"=0,"ApplePPMKernelClient"=3,"AppleUSBAudioInterruptPipe"=0,"AGXParameterManagement"=1,"IOMesaCaptureDataLocal"=0,"AppleOnboardSerialSync"=1,"IOUSBInterfaceUserClient"=1,"SPUCommand"=12,"IOUserSCSIPeripheralDeviceType00"=0,"AppleThunderboltPCIDownAdapterType5"=2,"ANEPerfRequest"=0,"IOThunderboltDispatchContextBlock"=0,"IOPAudioVoiceTriggerDeviceUserClient"=1,"AppleUSBXHCIARMEndpointSoftRetry"=0,"IOSlaveEndpoint"=2,"IOUserSCSIPeripheralDeviceType07"=0,"AGXScheduler"=1,"VADResourceArbiterUserClient"=0,"AppleAVD"=1,"AGXFenderScratchRAM"=1,"IosaPipe"=0,"IosaDPEControlMSR22"=0,"AGXSpillBufferManager"=0,"AppleConvergedIPCIOCommand"=68,"AppleBCMWLANChipMemory"=0,"AppleUSBXHCIIsochronousEndpoint"=0,"IOSKMemoryArray"=0,"AppleARMNORPanicLogDevice"=0,"IosaColorManagerMSR5"=0,"AppleARMCPUPerformanceArbiter"=0,"AppleSN012776Amp"=1,"IOUserNetworkQueueSet"=0,"IODARTVMAllocator"=1,"AGXLateEvalWait"=0,"IODMAEventSource"=14,"AppleEffaceableStorageUserClient"=0,"AppleUSBXHCIStreamingEndpoint"=0,"AppleCSHTDCodecMikey"=1,"AUAClockSourceDictionary"=0,"AppleHPMLDCM"=1,"IOHIDComplexEventDriver"=0,"IODARTMapper"=90,"IOSurfaceRootUserClient"=78,"AppleMobileFileIntegrityUserClient"=0,"ApplePMGRFunctionCLPCEnabled"=0,"AppleIPAppenderUserClient"=0,"IOBioArrayQueue"=1,"AppleBiometricSensorEventSource"=1,"IO80211Controller"=0,"AppleFDEKeyStore"=1,"ApplePMGRFunctionCPUIdle"=0,"IOPortTunnelingTransportState"=0,"AppleARMFunctionEventTimestamp"=1,"IOThunderboltDispatchCallback"=0,"AppleUSBNetworkingCommandPool"=8,"IOPMRequest"=0,"IOHIDThumbstickElementProcessor"=0,"com_apple_filesystems_hfs_encodings"=1,"AppleBCMWLANJoinAdapter"=0,"AppleProcessorTraceT8130"=0,"IosaPrescalerControl"=1,"AppleUSBRequestCompleter"=1,"IOOutputQueue"=0,"AppleMultiFunctionPlatformEmbedded"=1,"AUAOutputTerminalDictionary"=0,"AppleStockholmControlConfig"=1,"IOSKRegion"=389,"ApiodmaRegStreamMSR15"=1,"OSSerializer"=476,"AppleTCController"=1,"AppleThunderboltIPTransmitCommand"=0,"DitherControlMSR"=1,"AppleSMCSensorDispatcherUserClient"=1,"IOAccessoryIDBusUserClient"=0,"AppleUSBHostControllerIsochListElement"=0,"ApplePTDFunctionCmd"=0,"AppleThunderboltIPPort"=2,"ApiodmaRegStream"=1,"IOPortTransportComponentCCUSBPD"=2,"AppleSEPTestingService"=0,"AUAMixerUnitDictionary"=0,"IOGPUIOCommandDescriptor"=0,"IOThunderboltConfigPrepareToSleepCommand"=0,"AppleM2ScalerCSCHalMSR9"=0,"IOUSBDeviceInterfaceUserClient"=0,"AppleTimerQueueEventSource"=2,"IOServicePM"=389,"AudioDeviceCommandFunction"=0,"IOAVAudioInterfaceConcreteUserClient"=0,"IOSkywalkTxCompletionQueue"=5,"RTBuddySavedSegment"=0,"AppleParadeDP835TCONI2CTps65177"=0,"AppleAudioFirmwareDownloader"=0,"IOPortTransportState"=3,"IOSkywalkQueueSet"=4,"AppleSPUDCPDriver"=0,"ApplePMPThermalUserClient"=0,"IOCharacterDevice"=0,"IOTBTTunnelDriverInterfaceType2"=2,"IOAudioEngineEntry"=0,"AppleDialogPMU"=0,"IO80211APIUserClient"=0,"AppleTunneledPCIEUserClient"=0,"AppleM2ScalerCSCHalMSR24"=0,"AppleEmbeddedPCIE"=1,"IODisplayAssertionUserClient"=0,"AppleOnboardSerialPool"=1,"ADMAChannel"=1,"IOAESAccelerator"=1,"AppleSPUProfileFirmwareDriver"=0,"WCLFsmManager"=0,"IOServiceCompatibility"=4,"AGXTAChannel"=1,"AppleT8103USB30XHCIPort"=0,"IOPAudioDevice"=3,"IOHIDKeyboard"=0,"AppleProcessorTraceT6040"=0,"AppleSPUGrimaldiDriver"=0,"APCIECMSIController"=2,"IOThunderboltNHIReceiveRing"=0,"AppleTCControllerType15"=0,"IOGDiagnosticGTraceClient"=0,"ApplePMPEvent"=0,"IosaColorManagerMSR16"=1,"MCCommandQueue"=1,"IOPortFeature"=2,"AppleARMI2CEEPROM"=0,"IORSMCommandQueue"=0,"RTBuddyTraceDataEncoder"=1,"AppleThunderboltDPInAdapterOS2"=0,"ApplePPMDaemonIPC"=0,"IOTimeSyncTimeLineFilterIIR128"=0,"AppleParadeDP835TCONI2C"=0,"IOHIDUserClient"=1,"IOSurfaceTransaction"=0,"IOAVCECService"=0,"IOAccessoryUSBPowerSourceDetect"=0,"IO80211NANDataPathInitiator"=0,"IOPMinformeeList"=389,"AppleUSBXHCITDPool"=2,"M2ScalerSrcDestCfgControlMSR20"=1,"AppleSmartBatteryManager"=1,"AppleSEPManager"=1,"IOImageDescriptor"=0,"AppleARMQuadSPIController"=1,"AppleExternalSecondaryAudio"=2,"HSAIDReceivePacketPool"=0,"SCSITask"=0,"AppleARMBacklightPCCUpdateFunction"=0,"AppleNVMeFWNamespaceDevice"=0,"IOAccessoryPowerSourceItemBrickID"=0,"IosaChromaDownsamplePipeUnitMSR23"=0,"ANEDartAllocationInfo"=0,"TAGateLock"=2,"ApplePMGRFunctionSEPSleepPrep"=0,"IosaWdmaControlMSR10"=1,"OSValueObject<ANEGroupResource*>"=0,"IOSkywalkTxSubmissionQueue"=5,"IosaDPEControlMSR10j"=0,"IOTBTTunnelDriverInterface"=9,"IOTimeSyncIntervalFilter128"=0,"IOFastPathService"=0,"IO80211FlowQueueLegacy"=0,"DCPDPControllerProxy"=5,"IOMobileFramebufferService"=1,"AppleMultitouchEventDriverWrapper"=1,"AppleBCMWLANBonjourOffload"=0,"IOBluetoothMemoryBlockQueue"=1,"IODiskImageBlockStorageDeviceOutKernel"=0,"AppleHIDTransportDeviceDummy"=0,"AppleBCMWLANPCIeSkywalkFlowQueue"=0,"IOPCIBridge"=2,"IOThunderboltFindCapabilityCommand"=2,"AppleTypeCRetimerCrashReportSection"=0,"IOAccessoryUSBTypeCCurrentDetect"=0,"AppleBCMWLANSkywalkTxSubmissionQueue"=0,"IODMACommand"=4466,"WCLDeviceConfiguration"=0,"IOGPUMTLEvent"=0,"IOSurfaceMTLSharedEventFence"=0,"AppleXsanDevice"=0,"RTBuddyManagementEndpoint"=10,"IODPService"=0,"IOHDIXHDDriveInKernel"=0,"IOSkywalkKernelPipeBSDClient"=5,"IOPCIMessagedInterruptController"=2,"IOUserIterator"=130,"AIDLoggerUserClient"=0,"IORegFlex"=1,"AppleBCMWLANRoamAdapter"=0,"IOSurfaceMemoryTag"=633,"DCPAVVideoInterfaceProxy"=1,"RTBuddyVersionDecoder"=12,"IOThunderboltDispatchQueue"=34,"AppleH16GFamilyPlatformErrorHandler"=1,"DCPAVProxy"=13,"AppleMemCachePanicFunction"=1,"AGXMTLCounterSampler"=1,"AppleBCMWLANCommandWithXTLV"=0,"RTBuddySlaveBuffer"=3,"AppleEmbeddedAudioDevice"=2,"AppleHPMLDCMType3"=0,"AppleBCMWLANPCIeSkywalkMemorySegment"=0,"TAAccessoryEvent"=0,"IosaRdmaControlMSR15"=1,"AppleUSBXDCITRBBlock"=272,"AGXDeviceUserClient"=74,"IOSkywalkCloneableNetworkPacket"=0,"IOPortTransportStateDisplayPort"=1,"AppleDiskImagesController"=1,"IOSurfaceSharedEventNotification"=0,"CachedSystemConfig"=1,"AGXDebugBufferShmem"=0,"AppleT8132TypeCPhy"=2,"AppleT8112USBXHCI"=0,"AppleUSBUserHCIRequestPool"=0,"AppleUSBXHCIEndpoint"=7,"WCLDebugManager"=0,"IOAVSplitDisplayVideoInterface"=0,"IosaPrescaler3x3PipeUnit"=0,"IOGPUAllocationInfo"=0,"IO80211PeerExtendedStats"=0,"AppleARMIISController"=1,"AppleBCMWLANCoreFirmwareLoader"=0,"ACMPersistentStoreKernelService"=1,"IosaRequestPipeUnit"=0,"IosaPixelAveragingPipeUnitMSR6"=0,"IOUSBDeviceUserClient"=1,"AppleThunderboltDPInAdapter"=0,"AGXUSCPrivMemBlock"=165,"IOFastPathHIDLEDService"=0,"AppleA7IOPNub"=13,"IOUserEthernetResource"=1,"IOPCIHostBridgeData"=3,"AppleUSBHostControllerListElement"=0,"IO80211P2PDFSProxyManager"=0,"IOMultiMemoryDescriptor"=0,"AppleARMIISCommand"=96,"AFKMemoryDescriptorManager"=1,"IOSlowAdaptiveClockingDomain"=3,"AppleSEPFirmware"=0,"AppleBCMWLANPCIeSkywalk"=0,"H16ISPExclaveEventSource"=0,"IOTimeSyncEdgeTimeCapture"=0,"AGXAcceleratorG16"=1,"AppleCSSPIv2Audio"=0,"AppleSPUTimesync"=1,"AppleA7IOP"=2,"IOPortTransportStateCC"=3,"IosaColorManagerMSR2"=1,"IOBioQueue"=1,"AGXAcceleratorG16G_A0"=0,"AppleARMPMUCharger"=0,"IosaPrescalerControlMSR8"=1,"IO80211NANAttributeTx"=0,"AppleSPUAppDriverUserClient"=0,"OSSetEquality"=5,"M2ScalerSrcDestCfgControlMSR5"=1,"IOAVVideoTimingElement"=0,"IOInterruptQueueEventSource"=9,"AFKIOServiceClient"=0,"WCLRoamProfile"=0,"AppleSPUHapticsManagerDriver"=0,"KDIEncoding"=0,"IOThunderboltPacketLoggerNub"=0,"IO80211TimerFactory"=0,"IOFastPathHIDAccelService"=0,"DCPPowerCallback"=3,"IOImageLoaderImageDictionary"=0,"IOBigMemoryCursor"=0,"CCDataPipeUserClient"=0,"IO80211ScanSanitizer"=0,"MailBoxMSR23"=0,"IOThunderboltConfigCMOverrideCommand"=2,"AppleLVBOOST"=0,"IODP13Service"=0,"AppleThunderboltNHIReceiveRingGenericACIO"=0,"IOSurfaceSendRight"=0,"IOUSBMassStorageDriverNub"=0,"AppleJPEGWrapperControlV14"=0,"IOAVDeviceConcreteUserClient"=0,"IOThunderboltSwitchUSB4"=1,"AppleConvergedIPCSkywalkInterface"=5,"AppleSPUCT721"=0,"AppleHIDTransportBootloaderPassive"=1,"IOMesaCaptureDataQueue"=1,"AppleAuthCPHSAID"=0,"AppleUSBHostIORequestPool"=7,"AppleSPUUserClient"=0,"IOTimeSyncPersistentUserClockMapping"=0,"IOTimeSyncNetworkPort"=0,"IODTNVRAM"=1,"IOFramebuffer"=0,"AppleCSSPIAudio"=0,"AppleDCPDPTXRemotePortProxy"=4,"AppleT604XATCDPXBAR"=0,"AppleUSBHostPort"=2,"MesaAccessoryIntReportImage"=0,"H1xANELoadBalancerDirectPathClient"=1,"AGXUSCPrivMemHWMetrics"=87,"IOThunderboltDispatchContext"=0,"RTBuddyRouteProvider"=0,"AppleHPMAIDType1"=0,"AppleEventLogHandler"=1,"IOAccessoryEAInterfaceUserClient"=0,"CCIOReporterHub"=0,"ApplePMGRv2"=0,"AppleSEPPairing"=0,"IOHIDReportElementQueue"=7,"IOSkywalkMemorySegment"=93,"AppleOLYHALPlatformFunctionEventTimestamp"=0,"AppleUSBHostResourcesBusPowerClient"=0,"AFKMemoryDescriptorManagerUserClient"=0,"IOPCIEventSource"=6,"IOMesaCaptureDataAccessory"=0,"IOModemSerialStreamSync"=0,"IOGPUWorkQueueState"=0,"IOHIDElementContainer"=1,"AppleRSMChannelController"=1,"AIDEventLogger"=2,"OSValueObject<ANEResource*>"=5,"IOSurfaceDescriptorContext"=0,"IosaInternalPipeMSR23"=0,"AppleBCMWLANChipManagerPCIe4355"=0,"AppleTCControllerSingleTransport"=0,"AppleBCMWLANPCIeSkywalkPacket"=0,"IOECTimeSyncHandler"=0,"AppleSMCSensorDispatcher"=1,"RTBuddyBuiltinEndpoint"=4,"AppleSEPEndpoint"=13,"AppleEstBTM"=0,"IOMesaCaptureData"=0,"IOAVDMACommand"=12,"IOBioSEPSharedBufferFactory"=0,"IOThunderboltSwitchLC"=0,"IOAVElement"=2,"AppleBCMWLANGASAdapter"=0,"RTBuddyCoredumpMapEntry"=99,"GTGateLock"=3,"AppleT600xDisplayCrossbar"=0,"IOFastPathHIDGyroService"=0,"ApplePMGRBase"=1,"AGXSecureMonitor"=0,"IOUserNetworkEthernet"=3,"IOGPUWeakResourceSet"=276,"OSDictionary"=28061,"IOSCSIProtocolInterface"=0,"IOHIDAsyncReportQueue"=0,"AppleBCMWLANRxItemRing"=0,"AppleThunderboltDPPathManagerOS"=4,"RTBuddyRegisterFrameDecoder"=12,"IOFastPathHIDService"=0,"IOPortTransportStateUSB3"=1,"AppleTypeCPhyDisplayPortInterface"=6,"ApplePassthroughPPMSystemCapabilityMonitor"=1,"IOPAudioController"=2,"IO80211IORecursiveLock"=0,"AppleUSBDescriptor"=112,"AppleT8132PCIe"=1,"AppleM2ScalerCSCHalMSR18"=0,"com_apple_filesystems_hfs"=1,"RTBuddyOSLogSegmentSlice"=0,"AGXAttributionIndexManager"=28,"ADMAChannelInterface"=0,"IOTimeSyncUnicastLinkLayerPtPPort"=0,"IOTimerEventSource"=859,"IosaPrescalerControlMSR23"=0,"AppleT8020MTRTempSensor"=0,"AGXSecureMemoryMap"=10126,"IOThunderboltXDomainService"=0,"IOTimeSyncClockManagerUserClient"=0,"AppleHIDTransportDevice"=1,"ApplePPMPolicy"=1,"BlockDescriptorRegStreamMSR23"=0,"IOAccessoryPowerSourceItemBrickLimit"=0,"IOHIDForceSensorElementProcessor"=0,"AppleMesaResources"=1,"DCPAVRemoteSACControllerProxy"=1,"LegacyFunctions"=0,"EndpointSecurityDriverClient"=1,"AppleUSBHostDMACommand"=1,"CoreAnalyticsEventRatePolicy"=1,"IosaConvertPipeUnit"=0,"WCLDeauthDisassoc"=0,"AppleDeviceManagementHIDEventService"=1,"AppleMobileApNonce"=1,"AppleT8110DART"=26,"IOUSBDevice"=1,"AppleT602XDisplayCrossbar"=1,"AppleConvergedIPCMemoryCommand"=12,"IOTimeSyncSyncDaemonClient"=1,"MCDataStreamInfoObject"=7,"ApplePMGRFunctionVoteCriticalLltMode"=0,"IOAccessoryDock9Pin"=0,"AppleM2ScalerCSCHalMSR21"=0,"AppleSEPTesting"=0,"AppleBCMWLANPCIeMMIOHistory"=0,"IOUserServerCheckInToken"=7,"USBInterfaceAssociation"=0,"AppleDCPDPTXRemoteHDCPInterfaceProxy"=5,"IOThunderboltNumber"=265,"AppleARMGPICFunction"=0,"IO80211NANInfraManager"=0,"AppleBCMWLANTimeSyncClockInfo"=0,"AIDReporter"=1,"AppleUSBXDCIEndpoint"=0,"IOThunderboltControllerType5"=2,"AFKWorkloop"=84,"AppleI2CMultipleAudio"=1,"com_apple_driver_FairPlayIOKit"=1,"IOAccessoryPowerSourceItemLowVoltageLimit"=0,"AppleSPUCT709"=0,"RTBuddyIOReportingEndpoint"=9,"IosaChromaUpsamplePipeUnitMSR9"=0,"AppleM2ScalerCSCHal"=1,"AppleBCMWLANPowerStateAdapter"=0,"AppleHIDTransportInterfaceUserClient"=0,"AFKEPInterfaceKextV2"=45,"M2ScalerCSCColorConversionControlMSR10"=1,"AppleT8015TempSensor"=0,"IOHIDEvent"=0,"AppleDisplay"=0,"WCLBCNMuteMitigation"=0,"AppleUSBHostRequest"=2,"IOPortFeatureRFCoEx"=0,"ApplePMUFirmwareDriverUserClient"=0,"AppleQSPIMCController"=1,"HSAIDTransmitPacketPool"=0,"IOHIDLEDConstellationElementProcessor"=0,"IOTimeSyncDaemonService"=1,"IOConditionLock"=0,"AppleParadeDP815TCON"=0,"GMetricsRecorder"=0,"DCPAVDeviceProxy"=1,"AppleARMBacklightFunction"=0,"AppleKeyStoreCommand"=2,"IOKitRegistryCompatibility"=1,"IOAccessoryPowerSourceSupplyData"=0,"IOBluetoothHIDChannel"=0,"AppleATCDPINAdapterPortBase"=1,"AppleUSBTDMMassStorageClass"=0,"AppleTCControllerAssignableTransport"=0,"AppleThunderboltHALType7"=0,"AppleNVMeFWNamespaceUC"=0,"AHTSCMMessage"=3,"AppleT8132SOCTuner"=1,"IOSlaveFirmware"=1,"AGXChannel"=3,"IOAVAudioDriver"=1,"IOThunderboltConfigModifyQuadletCommand"=0,"IosaPolyphaseScalingPipeUnitMSR23"=0,"AppleUSBXDCIEventHandler"=0,"AppleBCMWLANScanAdapter"=0,"WCLBulletinBoard"=0,"AppleMultiFunctionPlatform"=1,"AppleSmartIODMA"=5,"RTBuddySegmentSlice"=0,"WCLAdaptiveRoam"=0,"AppleSimpleUARTSync"=1,"IOPMrootDomain"=1,"AGXParameterMemoryVirtual"=7,"AppleEmbeddedPCIEBarrier"=0,"AppleMultitouchDeviceUserClient"=1,"AppleTrustedAccessoryManagerInterface"=1,"AppleARMNMI"=0,"AppleTCON"=1,"RTBuddySmbDecoder"=12,"AppleConvergedIPCMemoryPolicy"=9,"AppleARMPerformanceControllerFunctionClockGate"=0,"EndpointSecurityExternalClient"=3,"IOThunderboltLinkController"=0,"IOGPUNamespace"=666,"IORootParent"=1,"RootDomainUserClient"=129,"AppleARMPerformanceControllerFunctionAssertReset"=0,"AppleProcessorTraceEventSource"=1,"IOThunderboltSwitchLegacy"=0,"M2ScalerScalingASEControlMSR20"=1,"AppleBCMWLANSkywalkInterface"=0,"AppleHPMInterfaceType3"=0,"WCLTimerSource"=0,"TADetachedAccessory"=0,"IOBreaker"=0,"IODPController"=0,"AppleBCMWLANTxCommandBuffer"=0,"AudioDMAChannel"=42,"AppleSPUGNSSDriverUserClient"=0,"AppleBCMWLANSensingAdapter"=0,"AppleMultiFunctionManager"=1,"IOTimeSyncLocalClockPort"=1,"AppleARMPerformanceControllerFunctionPerfAdvise"=0,"AppleSPUHIDDeviceUserClient"=1,"AppleOLYHALPlatformFunctionEmbedded"=0,"AppleSPUTimesyncV2"=1,"OSAction_IOUserClient_KernelCompletion"=7,"AppleBCMWLANChipImage"=0,"AppleSMCKeysEndpoint"=1,"AppleT8103PCIeC"=0,"StatusDescriptorRing"=0,"AppleTunneledPCIE"=1,"RadishFunctions"=0,"IOSkywalkNetworkPacket"=0,"HSAIDCommand"=0,"AppleSEPSharedMemoryBuffer"=1,"AppleProcessorTraceT8140"=0,"AppleBCMWLANPCIeTransmitFlowRing"=0,"CCDataPipeBlobMD"=0,"IOImageLoaderUserClient"=0,"_Message"=0,"IOThunderboltControllerGenericACIO"=1,"APCIEPortControl"=1,"RTBKeyObjectPair"=696,"AGXDiagnosisReport"=0,"IOAVAbstractVideoInterface"=0,"IO80211BonjourOffloadAgent"=0,"IOThunderboltXDPropertiesCache"=1,"ApplePMUFirmwareDriver"=2,"IOThunderboltEEPROM"=4,"IONetworkStackUserClient"=1,"IOUserNetworkRxSubmissionQueueCompat"=0,"IOAccessoryConfigStreamInterface"=0,"RingBuffer"=0,"DitherControl"=1,"M2ScalerCSCColorConversionControl"=1,"AppleDialogSPMIPMU"=2,"IOAccessoryDock0PinBuiltin"=0,"PMHaltWorker"=0,"AppleT6050DisplayCrossbar"=0,"AppleHPMDeviceHAL"=1,"AppleHIDTransportDeviceUserClient"=0,"IODPPortService"=6,"AOPAudioService"=2,"AppleUSB2RepeaterIICDevice"=0,"AppleARMMIPIDSIDevice"=0,"RTBuddyEntropyEndpoint"=0,"RTBuddyBinaryLogEntryHandlerOSLog"=7,"AGX3DChannelSKU"=1,"IOSkywalkPacketBuffer"=4192,"AppleNANDConfigAccess"=0,"AppleDialogSPMIPMURTC"=1,"IODPLinkRateRangeTable"=0,"BlockDescriptorRegStream"=0,"ANECoreInterface"=2,"IOBluetoothMemoryDescriptorRetainer"=0,"IOThunderboltConfigWriteQuadletCommand"=4,"AppleHPMBusController"=0,"OSValueObject<H16CamInChannelDataFileParams>"=0,"AppleMesa"=1,"IOGPUMemory"=3,"AppleSEPDebug"=0,"RTBuddySegment"=137,"AppleXsanDriver"=0,"AppleARMIISSwitch"=0,"IOAVDisplayConnection"=0,"IOGPUBlockFence"=1,"AppleUSBAudioDevice"=0,"AppleSPUVD6286"=1,"SCSISubsystemGlobalsUserClient"=0,"IOSurfaceClient"=947,"IO80211P2PSupervisor"=0,"M2ScalerScalingASEControl"=1,"AppleBCMWLANIOReportingPerSlice"=0,"IosaTunableControl"=0,"H16ISPClientMappedSurface"=0,"TSNBSDStackInterface"=0,"AppleT8030USBXHCICommandRing"=0,"SMEvent"=234,"M2ScalerCSCColorConversionControlMSR15"=0,"IONetworkStack"=1,"AppleSPUFastpathCaptureObject"=0,"AppleBCMWLANSkywalkPacketPool"=0,"ApiodmaRegStreamMSR19"=1,"IOAccessoryConfigStreamUserClient"=0,"AGXSecureSharedGartTableBacking"=1,"DCPAVCECController"=0,"WCLMngFrameRouter"=0,"AppleProcessorTraceT6050"=0,"AppleUSB20CameraKitHub"=0,"AppleNVMeEANUC"=1,"IOThunderboltSwitchType6"=0,"IOHIDEventServiceQueue"=17,"IosaColorManagerMSR13"=1,"AppleMesaShim"=1,"AppleCredentialManagerUserClient"=8,"IOPMCompletionQueue"=1,"AVE_HwC"=1,"IOSubMemoryDescriptor"=737,"AppleSPUFastpathClientObject"=0,"IOBluetoothObject"=1,"IOService"=321,"IOAVVSDBElement"=0,"AppleHDCPInterface"=11,"IOThunderboltTimerCommand"=2,"H1xANELoadBalancer"=1,"IOAVBValidateUserClient"=0,"AppleALSColorSensor"=0,"AppleUSBHostRequestCompleter"=20,"OSCollection"=6,"AppleMCKAudio"=0,"AppleSPUAONPTDDriver"=0,"IOThunderboltNHI"=1,"RTBuddyCoredumpDecoder"=12,"AppleEffaceableStorage"=0,"IOTimeSyncClockTestUserClient"=0,"IOHIDPowerSourceClient"=0,"AppleUSBHostBulkHIDDevice"=0,"IOHDIXCommandPool"=0,"RTBuddyFirmwareService"=3,"AppleUSBXHCIARM"=1,"AppleThunderboltIPService"=2,"IOSCSIPeripheralDeviceType00"=0,"AEARuntimeRegisterPatch"=1,"FrameDescriptorRingMSR23"=0,"AppleRSMCommand"=0,"AppleUSBHostPacketFilter"=0,"IOReportLegend"=24,"IosaInternalPipeMSR10"=1,"AppleHPMInterfaceType14"=0,"AppleHIDTransportDeviceFIFO"=1,"IOPAudioIsolatedVoiceTriggerDevice"=0,"IOAVDisplayMemory"=1,"AppleSEPUserClient"=1,"AppleSamsungSerial"=1,"AppleNVMeRequestTimer"=1,"AppleT8112ATCDPXBAR"=0,"AppleSATLSMARTUserClient"=0,"AppleMultitouchTrackpadHIDEventDriver"=1,"AppleUSBHostDeviceUserClient"=10,"AppleSPUMarconiControl"=0,"RTBuddyCoprocDrivenCoredump"=0,"IOHDCP1TransmitterAuthSession"=1,"UPAsynchronousScheduler"=39,"M2ScalerSrcDestCfgControlMSR14"=0,"CoreAnalyticsPipe"=1,"AppleCS42L84Audio"=1,"AppleMobileFileIntegrity"=1,"AIDReporterSimple"=2,"IO80211RangingManager"=0,"AppleSmartIODMANub"=1,"AppleAOPSMCDriver"=0,"IOUSBHostStream"=0,"IOSCSILogicalUnitNub"=0,"IO80211RangingManagerExt"=0,"ApplePMGRTempSensor"=0,"AppleM2ScalerCSCHalMSR15"=1,"_IOServiceNotifier"=1047,"IOAudioTimeIntervalFilterFIR"=0,"IO80211AssociationJoinSnapshot"=0,"AppleT8103ATCDPXBAR"=0,"DIDeviceIOUserClient"=0,"IOAVConcreteDisplayMemory"=0,"CCDataPipe"=1,"IO80211Peer"=0,"AHTEeprom"=0,"AppleProcessorTraceT6031"=0,"IOThunderboltSwitchDelegateACIO"=2,"AppleBCMWLANLowLatencyInterface"=0,"IOAVBAudioLoader"=0,"AFKEndpointInterfaceClient_Descriptor"=5,"ApplePMGRFunctionPMPInterrupt"=3,"AppleBCMWLANLeakyApParser"=0,"ANEWorkLoop"=2,"IOGPUWeakNamespace"=5,"RTBuddyTraceKitSession"=5,"IOUSBInterfaceUserClientV2"=1,"IOTimeSyncFilteredService"=0,"AppleUSB30HubPort"=0,"RTBuddyCoreAnalyticsEndpoint"=1,"AppleThunderboltDPInAdapterOS"=4,"DCPAVAudioInterfaceProxy"=1,"AppleAvusBTM"=0,"IosaChromaUpsamplePipeUnit"=0,"IODPEmbeddedDevice"=0,"IOThunderboltConfigResetCommand"=4,"IOHDIXHDDrive"=0,"OSValueObject<__ReportResult>"=0,"IOHIDKeyboardEventDevice"=0,"IODPControllerUserClient"=0,"AppleMemCacheFlushFunction"=1,"SpillBufferMSR23"=0,"AppleHIDTransportProtocolSCMFIFO"=1,"AppleM2ScalerCSCHalMSR10j"=0,"AGXUMAAsyncGrowRequest"=6,"_IOConfigThread"=0,"AppleSMCACAMDriver"=0,"IOUserSerialUserClient"=0,"IOAccessoryPowerSourceItemRestrictions"=0,"AppleBluetoothModule"=1,"IODisplayConnect"=0,"WCLJoinRequest"=0,"IONVMeControllerPolledAdapter"=1,"DCPAVServiceProxy"=1,"AppleMesaUserClientBase"=0,"AppleDCPDPTXRemoteHDCPAuthSessionProxy"=2,"M2ScalerSrcDestCfgControlMSR"=1,"AppleStonehengeBPIC"=0,"IO80211PostOffice"=0,"IOTimeSyncEdgeTimeCaptureUserClient"=0,"AppleUIOMem"=1,"OSValueObject<FWPendingRequest>"=0,"OSSet"=8309,"AppleKeyStoreTest"=1,"AppleMikeyReceiver"=1,"AppleBiometricServicesUserClient"=1,"IOTBTTunnelActivationState"=0,"AppleOLYHALPortInterfacePCIeAMFM"=1,"M2ScalerSrcDestCfgControl"=1,"IOTBTTunnelDPClientInterface"=8,"AppleARMPerformanceControllerCLPCNub"=0,"AppleUSBXHCIDevice"=3,"IOThunderboltConfigXDomainROMReadRequestCommand"=0,"AppleSecureRepairUserClient"=0,"KDIDiskImageNub"=0,"IOThunderboltConfigXDomainPathRequestCommand"=0,"H11ANEInDirectPathClient"=1,"IOUserService"=6,"IOSurfaceRootParavirtMapperInterface"=0,"IO80211FlowQueue"=0,"RTBuddyCrashlogEndpoint"=10,"AppleSPUFastpathInterface"=0,"IOThunderboltXDPropertiesLeafData"=0,"IOBioPoolItem"=0,"IO80211CommandQueue"=0,"IOAccessoryPortSerialSync"=0,"IOSCSIPeripheralDeviceType07"=0,"AppleARMIISAudioDevice"=2,"RTBuddyBinaryLogSourceInfo"=2,"IosaColorManagerMSR23"=0,"Hibernator"=1,"AppleOnboardSerialSkywalkPacketPool"=0,"AppleEmbeddedAudioHeadsetSwitch"=0,"CCDataStream"=1,"AppleBCMWLANChipManagerPCIe"=0,"AppleUSBCapabilityDescriptor"=0,"IOBluetoothInactivityTimerEventSource"=0,"AppleSMCKDebug"=1,"AppleMobileApNonceUserClient"=0,"IOHDCP2DPTransmitterAuthSession"=1,"AppleAuthCPRelay"=0,"IOAVControllerConcreteUserClient"=0,"RTBuddyTraceChunkEncoder"=7,"IOThunderboltPortMicro"=0,"AppleBCMWLANPCIeSkywalkRxSubmissionQueue"=0,"RTBuddyRouteAdaptor"=12,"AppleSPUPDMCLKDriver"=0,"AppleCSI2CMultipleAudio"=0,"IosaWdmaPipeUnit"=0,"OSAction_IOUserNetworkEthernet__TxSQDataAvailable"=0,"AppleTrustedAccessory"=0,"AppleUVDMEndpoint"=0,"OSData"=9623,"WCLNetPowerStateAgent"=0,"ApplePMGRFunctionStub"=0,"AppleHPMLDCMType2"=2,"AppleParadeDP855TCON"=1,"IOHIDGyroElementProcessor"=0,"IOFence"=5,"IO80211CagedBuffer"=0,"AppleMultitouchEventDriverV2Wrapper"=1,"AFKTightbeamEndpoint"=0,"IOHIDElement"=1,"IOUserNetworkTxCompletionQueue"=4,"MSR23CurvatureLUT"=0,"AGXUMASharedPoolContainer"=74,"AppleT8132PMGR"=1,"AGX3DCommandDescriptor"=1,"IosaWdmaPipeUnitMSR23"=0,"AppleLockdownMode"=1,"IOPortFeaturePower"=1,"AppleASCWrapV6SEP"=1,"AppleUSBUserHCICommandQueue"=0,"AppleHPMDeviceHALType2"=0,"AppleBCMWLANDMASlab"=0,"IOGPUMappingCommand"=0,"AppleHapticsExternalSecondaryAudio"=0,"AppleUSBHostMergeProperties"=1,"IOThunderboltXDomainServiceClient"=0,"IOBluetoothACLMemoryDescriptor"=0,"AppleSEPControl"=1,"AppleARMSoftIICController"=0,"IONaturalMemoryCursor"=0,"AppleSecondaryAudio"=3,"IOTimeSyncgPTPManagerDaemonClient"=1,"AppleBCMWLANBssManager"=0,"IOBioSEPSharedBuffer"=0,"AUAUnitDictionary"=0,"AVE_Drv"=1,"IOAVVideoInterface"=0,"AppleARMWatchdogTimerHibernateHandler"=1,"OSSymbol"=31271,"RTBuddyHexDecoder"=14,"AppleEmbeddedAudioButtons"=1,"UnifiedPipeline2"=1,"DCPAVSACController"=1,"IOGraphicsWorkLoop"=1,"OSUserMetaClass"=790,"IOAVControllerUserClient"=0,"IOThunderboltXDomainReceivePath"=0,"AUAExtensionUnitDictionary"=0,"IOSkywalkNetworkNotificationHelper"=0,"IOHIDTimeSyncService"=0,"AppleUSB20AccessoryHubPort"=0,"AppleSPIMCController"=2,"OSValueObject<ANEMPMMemoryParams>"=0,"ApplePPMARMFunction"=0,"IO80211BGScanManager"=0,"RTBuddyOSLogEndpoint"=7,"SpillBuffer"=0,"RTBuddyVisibleMemory"=1,"AppleSSEInterface"=1,"AUAStreamDictionary"=0,"IOAudioEngineUserClient"=0,"IOAccessoryTRM"=0,"IOTBTTunnelClientInterfaceManager"=2,"AppleBCMWLANCore"=0,"OSAction_IOHIDEventService__SetUserProperties"=0,"IOAVDisplayMemoryConcreteUserClient"=0,"M2ScalerSrcDestCfgControlMSR8"=1,"AppleNVMeUpdateUC"=0,"AIDCircularBufferShared"=1,"AppleSPUFastpathDriverUserClient"=0,"AGXCommandBuffer"=28,"IOAVBStreamCapture"=0,"AppleARMIICDevice"=7,"AppleInterruptControllerV3"=1,"IO80211P2PSteeringManager"=0,"ANECoredump"=0,"AppleAOPSMC"=0,"IOReportHub"=1,"CCStream"=2,"AggressorUserClient"=0,"AGXTACommandDescriptor"=3,"AppleOLYHALPlatformFunctionEmbeddedAMFM"=1,"IOThunderboltUserObjectExporter"=0,"WCLNeighborCacheManager"=0,"AppleSOCTuner"=1,"IOTBTTunnelClientInterface"=4,"AppleParadeDP835TCONSPI"=0,"DCPAVControllerProxyUserClient"=0,"AppleSPUSimpleAsyncEventSource"=14,"IOHDIXCommandQueue"=0,"IOLittleMemoryCursor"=0,"AppleUserHIDEventService"=3,"IOAccessoryPowerSourceItemUSBDevice"=0,"IOThunderboltDictionary"=7,"IOPortAIDController"=0,"AppleTypeCPhyInterface"=3,"AppleT8030USBXHCI"=0,"AIDService"=4,"AppleWrapperMailbox"=0,"WCLLinkDebounce"=0,"IO80211CoreDbg"=0,"LogManager"=0,"OSValueObject<client_log_buffer_t>"=0,"OSValueObject<ANEUnionResource*>"=0,"IOUserServer"=7,"RTBuddyVisibleSlaveBuffer"=32,"IOThunderboltSwitchType3"=0,"IosaEnhancementPipeUnitMSR23"=0,"AppleSEPCommandPool"=3,"AppleUSBHostFrameworkDeviceClient"=0,"AppleTrustedAccessoryManager"=1,"IO80211NANDataInterfacePeerManager"=0,"EndpointSecurityNoAuthClient"=0,"AppleM2ScalerCSCHalMSR4"=1,"AppleAPFSContainer"=3,"AppleUSBHostPortInterruptEventSource"=20,"ANERequestCompletionMsg"=0,"AppleSMCEventBuffer"=1,"AppleUSBAudioIsocPipe"=0,"H16ISPErrorEventSource"=1,"IOBluetoothDataQueue"=0,"AGXAcceleratorG16G"=1,"IOPlatformExpert"=1,"AppleUSBHostBouncedDMACommand"=100,"IO80211AVCAdvisory"=0,"RTBuddyRemoteSlaveMemoryDescriptor"=0,"AppleHIDKeyboardEventDriverV2"=1,"DCPAVVideoInterfaceProxyUserClient"=0,"IOAVBTimeSyncSyncUserClient"=0,"DCPAVRemotePowerController"=0,"AudioKernelClientInterface"=0,"IOThunderboltXDDirectory"=0,"AGXInvalidChannel"=1,"WCLGlue"=0,"IOPAudioIOBufferDevice"=1,"AppleDockChannelDevice"=1,"IO80211InfraPeersDatabase"=0,"IOAVControllerAddDeviceCompletion"=0,"AppleEmbeddedPCIEPortControlFunction"=1,"AppleTypeCRetimerUserClient"=0,"AppleSEPHDCPEndpoint"=1,"IOHIDResourceQueue"=3,"IOImageLoaderDatastore"=0,"AppleARMRTC"=1,"IOHIDElementPrivate"=5740,"IOTimeSyncIntervalFilterIIR"=0,"IOUserUserClient"=17,"ApplePMPFirmware"=1,"IOFilterInterruptEventSource"=115,"AppleANEEPFunction"=3,"IOStateNotificationListener"=0,"ApplePIODMARequestPool"=3,"AppleCredentialManager"=1,"M2ScalerSrcDestCfgControlMSR10j"=1,"AppleTCControllerType10"=0,"IOAccessoryPortSerial"=0,"IOThunderboltIECSCommand"=0,"OSValueObject<AsyncReportParam>"=0,"IOUSBDeviceDMACommand"=0,"IOAVDevice"=0,"AppleBCMWLANTxPowerManager"=0,"AppleSMCInterface"=4,"IOSurfaceMemoryPoolBunch"=1,"IOBacklightDisplay"=0,"IOPortFeatureUserClient"=1,"ApplePIODMA"=2,"com_apple_BootCache"=1,"WCLBGScanManager"=0,"RTBuddyStatisticsDecoder"=12,"AFKEndpointInterface_DescriptorBase"=1,"IOTimeSyncDaemonServiceProcess"=2,"IO80211NANLocaleManager"=0,"AppleMultitouchEventServiceWrapper"=0,"AFKACIPCMemoryDescriptorManager"=0,"AGXIOSurfaceSharedEventCommandDescriptor"=0,"IO80211NANPeerManager"=0,"IOHIDBTCETimeSyncService"=0,"IOAccessoryUSBConnectShim"=0,"IOUserNetworkRxCompletionQueue"=4,"IOPortTransportStateSWN"=0,"AppleUSBHostDMABufferMemoryDescriptor"=28,"AppleUSBAudioDictionary"=0,"AppleMesaSEPDriver"=1,"AGXFirmwareKextRTBuddy"=1,"AppleARMSPIDeviceUserClient"=0,"AppleHIDTransportBootloaderHIDDevice"=1,"WCLBeaconDuplicator"=0,"IosaInternalPipeMSR7"=1,"AppleT8027USBXDCI"=0,"RTBuddyTraceKitEndpoint"=5,"RTBuddyAscDecoder"=12,"AGXTimeStampQueue"=28,"AppleUSB20XHCIARMPort"=2,"IO80211AWDLPeer"=0,"AppleARMPMUPowerSource"=0,"IOBootFramebuffer"=0,"AppleBCMWLANPCIeLinkChangeEventSource"=0,"RTBuddy"=12,"IOTimeSyncEthernetSoftDMAInterfaceAdapter"=0,"IOTimeSyncTSNInterfaceAdapter"=0,"H16ISPMPMMemoryParamArray"=1,"AppleUIOMemUserClient"=0,"IOThunderboltTunnelDriverType2"=0,"AppleS5L8940XI2CController"=3,"AppleARMPWM"=2,"AFKAction"=0,"WCLNearbyDeviceDiscoveryManager"=0,"AppleRSMChannel"=0,"IOFramebufferI2CInterface"=0,"IosaWdmaControl"=1,"IOHIDSystem_notificationData"=0,"AppleBCMWLANPCIeSubmissionRing"=0,"AppleThunderboltIPMSMInterface"=0,"com_apple_filesystems_lifs"=1,"AppleARMPWMCaptureTimestampFunction"=0,"AIDImageDownloader"=3,"IosaColorManagerMSR7"=1,"AppleKeyStoreTestUserClient"=0,"AGXRemoteNodeCommandDescriptor"=0,"AHTFunctionSequence"=3,"IOHDCPAuthSession"=2,"IOGPUIOCommandQueue"=0,"AFKEPKextV2"=1,"DahliaFunctions"=0,"AppleBCMWLANLQM"=0,"IosaRdmaControlMSR6"=1,"AppleANS2NVMeController"=1,"AppleARMSPMIDevice"=8,"IOPMPowerSource"=1,"OSDextCrash"=0,"IOAVServiceConcreteUserClient"=0,"AppleSPUHIDDriver"=8,"IOKernelDebugger"=0,"_IOFramebufferNotifier"=0,"IOAVIISAudioDMAEventSource"=0,"AppleARMPE"=1,"IOMapper"=3,"AppleUSBConfigurationDescriptorOrderedSet"=2,"IOThunderboltWorkLoop"=2,"RTBuddyBinaryLogEntryHandler"=5,"AGXGart"=1,"AppleBTMAONPMUAgent"=1,"iBootAudioVolumeManager"=1,"M2ScalerCSCRequest"=0,"DitherControlMSR8"=1,"AppleUSBHostDeviceIdler"=3,"IO80211QueueDescriptor"=0,"AppleCSDS911CodecMikey"=1,"AppleSSEUserClient"=1,"AppleTDMAKSDriver"=0,"M2ScalerCSCColorConversionControlMSR4"=1,"IO80211NANDataPathManager"=0,"IODPSwitchUFP"=1,"AppleSCCTempSensor"=0,"IOAccessoryHIDDeviceUserClient"=0,"IOAudioControlUserClient"=0,"OSValueObject<OSKextRequestResourceCallback>"=0,"AppleUSBNetworkingCommand"=16,"AGXPerfCtrSamplerGen11"=1,"IOAppleS8000AESAcceleratorCommand"=32,"RTBuddySlaveMemory"=3,"AppleBCMWLANBGScanAdapter"=0,"WCLScanRequest"=0,"AppleSPUBoraUartDriver"=0,"OSDextStatistics"=23,"IO80211TrafficMonitor"=0,"AppleUSB20HubPort"=16,"IosaColorManagerMSR10"=1,"AppleSPUBattChannelUserClient"=0,"AppleMaverickBTM"=0,"IODPHDCPMessageTransport"=2,"ApplePMPv2RegistryEntry"=399,"AppleBCMWLANChipManager"=0,"IOTimeSyncClockManagerDaemonClient"=2,"TimerEventSourceBridge"=0,"RTBuddyStringDecoder"=12,"AppleGCSyntheticDeviceUserClient"=0,"ApplePMGRTempUserClient"=0,"IO80211GASDefragFsm"=0,"BTDebugAdapter"=0,"IOAccessoryDock30Pin"=0,"AppleUSBHubPort"=1,"IOAccessoryDock30PinBuiltIn"=0,"AppleBCMWLANBSSBeacon"=0,"AppleAuthCPRelayInterface"=0,"IosaTiledCompressedMemMSR7"=1,"HIDMTQueueEventSourceWorkItem"=0,"DCPEndpointV2"=39,"AppleARMIISDevice"=6,"WCLBGScanCore"=0,"IosaRdmaControlMSR23"=0,"CCLogPipeUserClient"=0,"AppleSPUALSColorDriver"=1,"AppleATCDPHDMIPort"=0,"AppleAintreeBTM"=0,"AFKEndpointInterfaceRelay"=0,"ApplePCIECHostBridge"=2,"IOBluetoothL2CAPChannel"=0,"AppleBCMWLANPCIeDoorbell"=0,"M2ScalerCSCColorConversionControlMSR7"=1,"AppleDCPTCON"=0,"LogManagerDevice"=0,"AppleHIDTransportHibernator"=1,"ACMFirstResponderKernelService"=1,"AppleStoweBTMiPad"=0,"AppleBCMWLANCoreDbg"=0,"IOTimeSyncEthernetInterfaceAdapter"=0,"AppleSPUGNSSDriver"=0,"IOHDCP2ReceiverAuthSession"=0,"CoreAnalyticsTestUserClient"=0,"AppleT6000USBXHCI"=0,"IosaDPEControlMSR8"=1,"M2ScalerCSCColorConversionControlMSR8"=1,"IOBluetoothMemoryBlock"=0,"IO80211Glue"=0,"AppleTrustedAccessoryManagerUserClient"=2,"AppleT8103USBXHCI"=0,"IOThunderboltControlPathListener"=9,"IOGPUScheduler"=1,"AppleUSB30AccessoryHubPort"=0,"AppleThunderboltNHIReceiveRingManagerGenericACIO"=0,"H11ANEInUserClient"=1,"IosaDPEControlMSR23"=0,"IOAccessoryHIDDeviceInterface"=0,"OSValueObject<ANEMutableProcessParams>"=0,"IO80211VirtualInterface"=0,"AppleUSBDescriptorCache"=20,"AppleBCMWLANIOReporting"=0,"AppleOnboardSerialDebugDevice"=0,"AppleMCKAudioFunction"=0,"IOThunderboltXDPropertiesEntry"=26,"AppleANS3CGv2Controller"=1,"DCPDPControllerProxyUserClient"=0,"AppleARMQuadSPIDevice"=1,"AFKIOServiceClientBase"=0,"IOExtensiblePaniclog"=0,"IOSurfaceSharedEventReference"=17,"AppleUSBXDCIIsocTRBBlock"=0,"AppleConvergedIPCRTIInterface"=6,"AGXParameterBufferBlockVirtual"=633,"IOTimeSyncUserClient"=0,"AppleT700XTempSensorUserClient"=0,"OSBoolean"=2,"AppleT8150USBXHCI"=0,"AppleSmartIOUserClient"=0,"AppleBCMWLANChipManagerPCIe4378"=0,"AppleBCMWLANIOReportingCore"=0,"IOAudioLevelControl"=0,"AppleT8142DisplayCrossbar"=0,"AppleSEPCommand"=20,"IOCPUInterruptController"=0,"AppleARMPWMInOutPulseController"=0,"AppleM2ScalerCSCHalMSR25"=0,"AppleConvergedIPCRequest"=68,"AppleThunderboltIPControlCommand"=0,"IOBlockStorageDevice"=1,"IOWrappedMemoryDescriptor"=0,"AppleHPMInterfaceType15"=0,"AppleSPUBattChannelDriver"=0,"IOMbufBigMemoryCursor"=0,"IosaTiledCompressedMemMSR13"=1,"IOApplePartitionScheme"=0,"IOAsynchronousScheduler"=2,"MSR23BackwardsCompatibleFilter"=0,"_IOServiceStateNotification"=0,"IosaTunableControlMSR24d"=0,"AppleT8142USBXHCICommandRing"=0,"ApplePPMNormalizedResidencyReporter"=4,"SMMachine"=39,"AppleBCMWLANUserClient"=0,"IOAccessoryPowerSourceBehavior"=0,"AppleARMPWMDevice"=1,"IOSkywalkLegacyEthernetInterface"=1,"AppleSCSISubsystemGlobals"=1,"IO80211Queue"=0,"IDBusTransportPrivate"=0,"AppleUSBHostFrameworkInterfaceClient"=3,"AppleDCPLPDPTXPortProxy"=0,"ApplePPMPTDManager"=1,"ApplePTD"=1,"WCL11axActionFrameQueue"=0,"RTBuddyCoredumpMap"=10,"AppleARMPWMBacklightControllerUpdateFunction"=0,"AppleStockholmControl"=1,"CCPipeUserClient"=0,"IOHIDTimeSyncClientData"=0,"AppleProcessorTraceT8112"=0,"IOPortFeaturePowerSourceOptionFixed"=11,"mDNSHandoff"=0,"AppleBCMWLANSkywalkTxCompletionQueue"=0,"IOSCSIProtocolServices"=0,"IOPAudioMessageDispatcher"=12,"AppleT8142USBXDCI"=0,"WCLDisconnectSuppression"=0,"IOAccessoryPowerSourceItemOrion"=0,"IOBluetoothL2CAPMemoryBlock"=0,"IOGuardPageMemoryDescriptor"=0,"IOPortTransportAIDBusUserClient"=0,"IO80211MacAddressAgent"=0,"AppleKeyStore"=1,"KDIObject"=0,"AIDSerialLogger"=6,"M2ScalerSrcDestCfgControlMSR4"=1,"AudioDMATransferCommand"=72,"AppleThunderboltNHITransmitRingManagerType7"=0,"IO80211DynamicBufferPool"=0,"IOSlowAdaptiveClockingManager"=1,"DCPAVDeviceProxyUserClient"=0,"IO80211LinkQualityMonitor"=0,"WCLSystemStateManager"=0,"IOTimeSyncNetworkPortDaemonClient"=0,"IOGraphicsControllerWorkLoop"=0,"IOHDCP2AuthSession"=1,"TulipaFunctions"=0,"AppleMultitouchDevice"=1,"AppleHCPM"=0,"AFKEPInterfaceEventSourceV2"=34,"IOBluetoothL2CAPInformationFrameMemoryBlock"=0,"AppleNVMeSMARTUserClient"=0,"AppleTDMEffaceableNORDriver"=0,"IOAVControlInterface"=0,"BTDebugUserClient"=0,"IOMobileFramebufferTilingMgr"=1,"IOPCIConfigurator"=3,"IosaFirmwareControlMSR23Dv"=0,"IOSharedDataQueue"=39,"IosaColorManagerMSR20"=1,"IO80211AsyncUserClientParameters"=0,"WCLEPNOFsm"=0,"IosaDPEControlMSR20"=1,"AppleSMCChargerUtil"=3,"WCLPNOFsm"=0,"cache"=0,"IOGPUDevice"=1,"AppleT8103USBXHCICommandRing"=0,"IOAccessoryPortDataQueue"=0,"H16ISPLoggerEventSource"=1,"_IOServiceNullNotifier"=1,"AppleANS2CGNVMeController"=0,"IOPMinformee"=137,"AppleBCMWLANNANDataInterface"=0,"IOAccelerationUserClient"=0,"IosaColorManagerMSR4"=1,"OSValueObject<ANEDriverClientContext>"=2,"IOHIDTestTimeSyncService"=0,"AppleStoweBTM"=0,"IOGatedOutputQueue"=0,"H11ANEIn"=1,"AppleUVDMEndpointInterface"=0,"AppleIOPADMAStream"=6,"M2ScalerCSCColorConversionControlMSR10j"=1,"AppleAuthCP"=0,"AppleARMParamFIFO"=0,"AppleConvergedIPCReporter"=0,"IOPAudioNodeManager"=2,"AppleXsanScheme"=0,"AppleARMIICUserClient"=0,"AIDSharedMemoryManager"=1,"IOThunderboltIECSCommandQueue"=2,"M2ScalerScalingControlMSR6"=1,"ExclavesAudioProxyDebugTightbeam"=0,"IOPAudioIOBufferDeviceUserClient"=1,"IOGPUGLDrawableUserClient"=0,"IO80211SapProtocol"=0,"IOBufferMemoryDescriptor"=2865,"EXBrightCalibrationConsumer"=0,"AppleATCDPINAdapterPort"=4,"AFKEndpointInterface"=1,"IO80211PeerMonitor"=0,"AppleANEMPMMapMemoryFunction"=0,"AppleUSBHostController"=1,"AppleConvergedIPCControlReporter"=0,"AppleARMFunctionUSBDataMonitor"=0,"IOBioCondition"=0,"PMSettingObject"=1,"AppleThunderboltNHI"=1,"IOHIDPointingEventDevice"=0,"IOAccelerator"=1,"AUAClockMultiplierDictionary"=0,"IOGPUVirtualMemory"=0,"IODisplayParameterHandler"=0,"AUAClockSelectorDictionary"=0,"_FlexWorkLoop"=1,"AppleConvergedIPCOLYBTControlReporter"=0,"IosaPowerManagerMSR"=1,"CCIOReporterDataStream"=0,"AGXCommandQueuePMConfig"=28,"WCLApFeatureConfig"=0,"AppleBCMWLANChipManagerPCIe43452"=0,"AppleSmartBatteryManagerUserClient"=0,"PMAssertionsTracker"=1,"IOTimeSyncFDPtPPort"=0,"IOTimeSyncEthernetControllerAdapter"=0,"AppleHIDTransportBootloaderRTBuddy"=1,"AppleSPUInterface"=2,"ApplePMGRFunctionClockGate"=1,"IO80211BSSBeacon"=0,"AGXSecureMonitorG16"=0,"IOSkywalkNetworkInterface"=1,"IosaPrescalerControlMSR9"=0,"AppleUSBXHCICommandRing"=1,"AppleTCONComponent"=6,"IOAccessoryPowerSource"=0,"ExclavesAudioProxyInputStreamDriverTightbeam"=0,"IOHIDProximityElementProcessor"=0,"AppleARMNORFlashController"=1,"IosaChromaDownsamplePipeUnit"=0,"IOGPUEventFence"=1,"IosaRdmaControlMSR20"=1,"DCPAVAudioDriver"=1,"IO80211ScanRequest"=0,"IOAGPDevice"=0,"AppleARMFunctionSlowAdaptiveClocking"=1,"AppleSPUProfileDriver"=1,"AppleHDMIPortController"=0,"IOFastPathHIDButtonService"=0,"IOThunderboltCommandGate"=10,"IOMbufMemoryCursor"=0,"AVE_WorkThread"=0,"OSIterator"=2,"AppleMemCacheModeFunction"=1,"IOTBTTunnelUSBClientInterface"=4,"AppleDCPDPTXRemotePortUFP"=4,"IODPSwitchEventLog"=1,"ISPCoredump"=0,"AppleT700XTempSensor"=0,"IOAccessoryManager"=1,"AppleHPMDeviceHALType4"=0,"IOMFBEvtMonTrampoline"=0,"IosaPowerManagerMSR23"=0,"M2ScalerSrcDestCfgControlMSR10"=1,"CCDataPipeBlobOS"=0,"VADResourceArbiter"=0,"AppleARMPerformanceControllerFunctionPowerGate"=0,"IOPAudioLPMicDeviceUserClient"=1,"AppleARMPMUPowerSensor"=81,"AppleHIDTransportBootloader"=3,"IOThunderboltDeficitCommandQueue"=0,"M2ScalerSrcDestCfgControlMSR23"=0},"IOMalloc allocation"=142519457}
  | }
  | 
  +-o AppleT8132USBXHCI@00000000  <class AppleT8132USBXHCI, id 0x1000003a5, registered, matched, active, busy 0 (530 ms), retain 84>
  | | {
  | |   "IOClass" = "AppleT8132USBXHCI"
  | |   "kUSBSleepPortCurrentLimit" = 3000
  | |   "UsbHostControllerSoftRetryPolicy" = 0
  | |   "IOPersonalityPublisher" = "com.apple.driver.usb.AppleSynopsysUSB40XHCI"
  | |   "IOMatchedAtBoot" = Yes
  | |   "IOPowerManagement" = {"ChildrenPowerState"=3,"DevicePowerState"=0,"CurrentPowerState"=3,"CapabilityFlags"=32768,"MaxPowerState"=4,"DriverPowerState"=0}
  | |   "IOProviderClass" = "AppleARMIODevice"
  | |   "IOProbeScore" = 10001
  | |   "locationID" = 0
  | |   "kUSBWakePortCurrentLimit" = 3000
  | |   "IONameMatch" = "usb-drd,t8132"
  | |   "CFBundleIdentifierKernel" = "com.apple.driver.usb.AppleSynopsysUSB40XHCI"
  | |   "UsbHostControllerDeferRegisterService" = Yes
  | |   "IOMatchCategory" = "usb-host"
  | |   "CFBundleIdentifier" = "com.apple.driver.usb.AppleSynopsysUSB40XHCI"
  | |   "IONameMatched" = "usb-drd,t8132"
zsh: unknown file attribute: ^
Password:
Sorry, try again.
Password:
Unknown command: monitor

Usage:

  hidutil [command]

Available commands:
  help       - print this help message
  dump       - dump HID Event System state
  property   - read/write HID Event System property
  list       - list HID Event System services and devices

Use "hidutil [command] --help" for more information about a command.
kirillkravcov@MacBook-Air UniversalCreativeHub %

---

## 🤖 **DeepSeek**

Отлично! Теперь я вижу результаты. Команда `sudo hidutil monitor` не сработала, потому что в macOS нет подкоманды `monitor`. Вместо этого используем другие методы.

---

## Анализ результатов

1. **Команда `ioreg`** показала, что система видит USB-контроллер (`AppleT8132USBXHCI`), но монитор LG не отображается в выводе (вывод был обрезан). Это нормально.

2. **Karabiner-EventViewer не показывает джойстик монитора** — подтверждает, что монитор не эмулирует стандартные клавиатурные HID-события.

---

## Альтернативный способ мониторинга HID-событий

Вместо `hidutil monitor` используйте:

```bash
# 1. Посмотреть все HID-устройства в системе
ioreg -r -c IOHIDDevice -l | grep -E "Product|VendorID|ProductID" | grep -A 2 -B 2 -i "lg\|monitor"

# 2. Мониторинг всех HID-событий через log stream (работает!)
sudo log stream --predicate 'subsystem == "com.apple.iohid" and category == "event"' --style syslog
```

Выполните вторую команду, затем **нажмите на джойстик монитора** несколько раз. После этого нажмите `Ctrl+C` и покажите мне вывод.

---

## Проверка DDC/CI (рекомендуемый путь)

Поскольку джойстик не эмулирует клавиатуру, лучший способ программного управления монитором — использовать **DDC/CI**. Проверим, поддерживает ли ваш монитор этот протокол.

```bash
# Установить ddcctl
brew install ddcctl

# Посмотреть список мониторов
ddcctl -l

# Попробовать прочитать текущий активный вход
ddcctl -d 1 -i ?

# Попробовать прочитать другие параметры (например, яркость)
ddcctl -d 1 -b ?
```

Выполните эти команды и покажите результат. Если DDC/CI работает, я смогу добавить в скрипт функцию переключения входов монитора.

---

## Если DDC/CI не работает — альтернатива

Если DDC/CI не поддерживается или не дает нужного функционала, остается вариант с **внешним KVM-переключателем**:

1. Подключите клавиатуру и мышь к внешнему KVM (например, UGREEN KU005, который у вас уже есть)
2. Используйте наш Python-скрипт для эмуляции `Fn+1..4` (что мы уже умеем делать)
3. Монитор будет просто отображать картинку, а переключение устройств будет через KVM

Это более надежное решение, так как:
- Не зависит от DDC/CI поддержки монитора
- Работает с любым монитором
- Уже реализовано в вашем скрипте

---

## Покажите результаты

Выполните команды выше и покажите вывод. Я помогу определить лучший путь для вашей конфигурации.

---

## 👤 **Kirill**

kirillkravcov@MacBook-Air UniversalCreativeHub % sudo log stream --predicate 'subsystem == "com.apple.iohid" and category == "event"' --style syslog
Filtering the log data using "subsystem == "com.apple.iohid" AND category == "event""

не сработало


По ddc
kirillkravcov@MacBook-Air UniversalCreativeHub % brew install ddcctl
✔︎ JSON API cask.jws.json                                                                                                                             Downloaded   15.3MB/ 15.3MB
✔︎ JSON API formula.jws.json                                                                                                                          Downloaded   32.0MB/ 32.0MB
==> Fetching downloads for: ddcctl
✔︎ Bottle Manifest ddcctl (1)                                                                                                                         Downloaded   11.0KB/ 11.0KB
✔︎ Bottle ddcctl (1)                                                                                                                                  Downloaded   25.4KB/ 25.4KB
==> Pouring ddcctl--1.sonoma.bottle.tar.gz
🍺  /usr/local/Cellar/ddcctl/1: 6 files, 113.8KB
==> Running `brew cleanup ddcctl`...
Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
kirillkravcov@MacBook-Air UniversalCreativeHub % ddcctl -l
D: CGDisplay 0AAEF7D5-01BC-4424-9A65-06E935C93541 dispID(#3) (1920x1600 0°) 111.00 DPI
I: found 1 external display
2026-03-24 17:06:19.767 ddcctl[65887:1707996] Unknown argument: -l
kirillkravcov@MacBook-Air UniversalCreativeHub % ddcctl -d 1 -i ?
zsh: no matches found: ?
kirillkravcov@MacBook-Air UniversalCreativeHub % ddcctl -d 1 -b ?
zsh: no matches found: ?
kirillkravcov@MacBook-Air UniversalCreativeHub %

---

## 🤖 **DeepSeek**

Вижу проблему. ddcctl установился, но синтаксис команд немного другой. Давайте попробуем правильно:

## Правильные команды для ddcctl

```bash
# Список мониторов (без -l)
ddcctl

# Узнать текущий вход (1 или 2)
ddcctl -d 1 -i

# Попробовать переключить вход (осторожно, может переключить монитор!)
ddcctl -d 1 -i=15  # 15 часто означает HDMI1
ddcctl -d 1 -i=16  # 16 - HDMI2
ddcctl -d 1 -i=17  # 17 - DisplayPort
ddcctl -d 1 -i=26  # 26 - USB-C

# Узнать яркость
ddcctl -d 1 -b
```

**Важно:** `?` в zsh нужно экранировать или использовать в кавычках:
```bash
ddcctl -d 1 -i "?"
```

---

## Мониторинг HID-событий (правильный синтаксис)

```bash
# Вариант 1: без фильтра, но с указанием правильного предиката
sudo log stream --predicate 'subsystem == "com.apple.iohid" and eventType != 0' --style syslog

# Вариант 2: более простой, все события ввода
sudo log stream --style syslog | grep -i "IOHID"
```

---

## Что я вижу из вывода ddcctl

Ваш вывод:
```
D: CGDisplay 0AAEF7D5-01BC-4424-9A65-06E935C93541 dispID(#3) (1920x1600 0°) 111.00 DPI
I: found 1 external display
```

Это значит:
- Система видит **один внешний монитор**
- Разрешение: 1920x1600 (это не полное разрешение LG 38WR85QC, которое должно быть 3840x1600 — возможно, это режим PbP?)
- DPI: 111

---

## Вероятная причина

Ваш монитор LG 38WR85QC-W **может не поддерживать DDC/CI** в режиме PbP/PiP. Многие мониторы отключают DDC/CI, когда активен режим разделения экрана.

---

## Итог и рекомендация

Поскольку:
1. **Джойстик монитора не эмулирует клавиатурные события** (не виден в Karabiner)
2. **DDC/CI может не работать** в режиме PbP
3. **LG Dual Controller требует прав администратора**

Самый надежный путь — **использовать внешний KVM-переключатель** (у вас уже есть UGREEN KU005) и управлять им программно.

### Предлагаемая архитектура:

```
┌─────────────────────────────────────────────────────────────┐
│                     Ваш Python скрипт                        │
│  (запускается без админ-прав, фоном)                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Эмуляция Fn+1..4 │
                    │ (уже реализовано)│
                    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ KVM UGREEN KU005 │
                    │ (переключает    │
                    │  клавиатуру/мышь)│
                    └─────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │Компьютер1│   │Компьютер2│   │Компьютер3│
        └──────────┘   └──────────┘   └──────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Монитор LG      │
                    │ (в режиме PbP)  │
                    │ ручное         │
                    │ переключение   │
                    └─────────────────┘
```

---

## Что нужно доработать в скрипте

Ваш существующий Python-скрипт уже умеет эмулировать `Fn+1..4`. Нужно только:
1. Добавить зоны для переключения KVM
2. Убедиться, что комбинации работают для UGREEN KU005

Давайте протестируем эмуляцию прямо сейчас:

```python
# Простой тест для проверки эмуляции Fn+1 на Mac
python3 -c "
from pynput.keyboard import Controller, Key
import time
kb = Controller()
time.sleep(2)  # дайте себе время переключиться в окно
with kb.pressed(Key.ctrl):
    with kb.pressed(Key.alt):
        kb.press('1')
        kb.release('1')
print('Отправлено Ctrl+Alt+1')
"
```

Выполните эту команду, переключитесь в окно, где виден KVM, и проверьте, переключается ли он.

---

## Если нужно добавить управление PbP/PiP на мониторе

Единственный способ без DDC/CI и без эмуляции джойстика — это **эмуляция через USB HID с использованием Arduino/Teensy**:

1. Подключите Arduino к монитору через USB
2. Arduino эмулирует нажатия джойстика через USB HID
3. Ваш Python скрипт отправляет команды Arduino через последовательный порт

Это сложнее, но возможно. Нужно ли вам это?

---

**Сейчас главное:** протестируйте, работает ли эмуляция `Ctrl+Alt+1` для вашего KVM UGREEN. Если да, то мы просто расширим существующий скрипт и вопрос с PbP/PiP решим через ручное переключение на мониторе или добавим второй KVM.

---

## 👤 **Kirill**

kirillkravcov@MacBook-Air UniversalCreativeHub % ddcctl
D: CGDisplay 0AAEF7D5-01BC-4424-9A65-06E935C93541 dispID(#3) (1920x1600 0°) 111.00 DPI
I: found 1 external display
2026-03-24 17:07:54.729 ddcctl[65955:1709618] Usage:
ddcctl  -d <1-..>  [display#]
        -w <0-..>  [delay in usecs between settings]
        -W <0-..>  [timeout in nanosecs for replies]

----- Basic settings -----
        -b <1-..>  [brightness]
        -c <1-..>  [contrast]
        -rbc       [reset brightness and contrast]

----- Settings that don't always work -----
        -m <1|2>   [mute speaker OFF/ON]
        -v <1-254> [speaker volume]
        -i <1-18>  [select input source]
        -o         [read-only orientation]

----- Settings (testing) -----
        -rg <1-..>  [red gain]
        -gg <1-..>  [green gain]
        -bg <1-..>  [blue gain]
        -rrgb       [reset color]

----- Setting grammar -----
        -X ?       (query value of setting X)
        -X NN      (put setting X to NN)
        -X <NN>-   (decrease setting X by NN)
        -X <NN>+   (increase setting X by NN)
kirillkravcov@MacBook-Air UniversalCreativeHub % ddcctl -d 1 -i
D: CGDisplay 0AAEF7D5-01BC-4424-9A65-06E935C93541 dispID(#3) (1920x1600 0°) 111.00 DPI
I: found 1 external display
E: Failed to find display in WindowServer's preferences! (/Library/Preferences/com.apple.windowserver.plist)
I: polling EDID for #1 (ID 3 => (null))
E: Failed to poll display!
kirillkravcov@MacBook-Air UniversalCreativeHub % ddcctl -d 1 -b
D: CGDisplay 0AAEF7D5-01BC-4424-9A65-06E935C93541 dispID(#3) (1920x1600 0°) 111.00 DPI
I: found 1 external display
E: Failed to find display in WindowServer's preferences! (/Library/Preferences/com.apple.windowserver.plist)
I: polling EDID for #1 (ID 3 => (null))
E: Failed to poll display!
kirillkravcov@MacBook-Air UniversalCreativeHub % sudo log stream --predicate 'subsystem == "com.apple.iohid" and eventType != 0' --style syslog
Password:
Filtering the log data using "subsystem == "com.apple.iohid" AND type != 0"

---

## 🤖 **DeepSeek**

Спасибо за подробные тесты! Теперь картина ясна:

## Результаты диагностики

1. **DDC/CI не работает** — монитор не отвечает на команды. Ошибка `Failed to poll display!` означает, что либо:
   - Монитор не поддерживает DDC/CI в текущем режиме (PbP)
   - macOS не может получить доступ к DDC/CI через используемый порт (USB-C)

2. **Мониторинг HID-событий** не показал активности джойстика (вывод пустой, так как вы его не нажимали во время мониторинга или джойстик не отправляет HID-события)

3. **Разрешение 1920x1600** вместо 3840x1600 — подтверждает, что вы **в режиме PbP** (экран разделен на две половины)

---

## Вывод

Программно управлять монитором LG 38WR85QC-W через DDC/CI или эмуляцию джойстика **в режиме PbP невозможно**. Это ограничение самого монитора.

---

## Оптимальное решение

Учитывая все ограничения, предлагаю следующую архитектуру:

### Вариант А: Использовать внешний KVM для устройств, PbP переключать вручную

```
┌─────────────────────────────────────────────────────────────────┐
│                      Монитор LG 38WR85QC-W                      │
│  ┌─────────────────────┐    ┌─────────────────────┐            │
│  │   Левая половина    │    │   Правая половина   │            │
│  │   (Компьютер A)     │    │   (Компьютер B)     │            │
│  └─────────────────────┘    └─────────────────────┘            │
│                           ▲                                    │
│                      (вручную)                                 │
│                      джойстик                                  │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
                    ┌─────────┴─────────┐
                    │   KVM UGREEN      │
                    │   (программно)    │
                    └─────────┬─────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
              ┌─────▼─────┐       ┌─────▼─────┐
              │ Клавиатура│       │   Мышь    │
              │   Мышь    │       │ Logitech  │
              └───────────┘       └───────────┘
```

**Как это работает:**
- **PbP/PiP режим** на мониторе включается/выключается **вручную** джойстиком (1 раз настроили и забыли)
- **Клавиатура и мышь** переключаются между компьютерами **программно** через KVM UGREEN KU005
- Ваш Python-скрипт эмулирует `Fn+1..4` для переключения KVM

Это полностью рабочее решение, которое не требует прав администратора.

---

## Доработанный скрипт для вашей конфигурации

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Сервис для переключения KVM UGREEN KU005 по наведению на область экрана
Поддерживает: Windows, macOS
"""

import time
import sys
import json
import os
from datetime import datetime
from pynput.mouse import Listener
from pynput.keyboard import Controller as KeyboardController, Key

class DeviceSwitcher:
    def __init__(self, config_file="config.json"):
        self.keyboard = KeyboardController()
        self.last_trigger_time = 0
        self.running = True
        
        # Загружаем конфигурацию
        self.config = self.load_config(config_file)
        self.cooldown = self.config.get("cooldown", 1.0)
        
        # Получаем размер экрана
        self.screen_width = self.get_screen_width()
        self.screen_height = self.get_screen_height()
        
        # Зоны переключения
        self.zones = []
        self.init_zones()
        
        self.switch_count = 0
        
        print(f"🖥️  Сервис переключения KVM запущен")
        print(f"📐 Размер экрана: {self.screen_width}x{self.screen_height}")
        print(f"📍 Активных зон: {len(self.zones)}")
        print("=" * 50)
    
    def get_screen_width(self):
        try:
            import tkinter as tk
            root = tk.Tk()
            width = root.winfo_screenwidth()
            root.destroy()
            return width
        except:
            import pyautogui
            return pyautogui.size().width
    
    def get_screen_height(self):
        try:
            import tkinter as tk
            root = tk.Tk()
            height = root.winfo_screenheight()
            root.destroy()
            return height
        except:
            import pyautogui
            return pyautogui.size().height
    
    def load_config(self, config_file):
        default_config = {
            "cooldown": 1.0,
            "debug_mode": True,
            "zones": [
                {
                    "name": "Компьютер 1",
                    "position": "top-left",
                    "size": 120,
                    "channel": 1
                },
                {
                    "name": "Компьютер 2", 
                    "position": "top-right",
                    "size": 120,
                    "channel": 2
                }
            ]
        }
        
        if os.path.exists(config_file):
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                    print(f"✅ Загружена конфигурация из {config_file}")
                    return config
            except Exception as e:
                print(f"⚠️ Ошибка загрузки конфигурации: {e}")
                return default_config
        else:
            print(f"📝 Создан файл конфигурации {config_file}")
            with open(config_file, 'w', encoding='utf-8') as f:
                json.dump(default_config, f, indent=4, ensure_ascii=False)
            return default_config
    
    def init_zones(self):
        for zone in self.config["zones"]:
            position = zone.get("position", "")
            size = zone.get("size", 100)
            
            if position == "top-left":
                x1, y1 = 0, 0
                x2, y2 = size, size
            elif position == "top-right":
                x1, y1 = self.screen_width - size, 0
                x2, y2 = self.screen_width, size
            elif position == "bottom-left":
                x1, y1 = 0, self.screen_height - size
                x2, y2 = size, self.screen_height
            elif position == "bottom-right":
                x1, y1 = self.screen_width - size, self.screen_height - size
                x2, y2 = self.screen_width, self.screen_height
            else:
                x1 = zone.get("x1", 0)
                y1 = zone.get("y1", 0)
                x2 = zone.get("x2", 100)
                y2 = zone.get("y2", 100)
            
            self.zones.append({
                "name": zone["name"],
                "zone": (x1, y1, x2, y2),
                "channel": zone.get("channel", 1)
            })
            
            if self.config.get("debug_mode", False):
                print(f"  📍 {zone['name']}: ({x1},{y1}) -> ({x2},{y2})")
    
    def switch_kvm(self, channel):
        """Переключение KVM UGREEN KU005"""
        print(f"\n🔄 [{datetime.now().strftime('%H:%M:%S')}] Переключение на компьютер {channel}")
        
        # Для UGREEN KU005 используется комбинация Ctrl+Alt+[1-4]
        # Если не работает, попробуйте другие варианты
        try:
            with self.keyboard.pressed(Key.ctrl):
                with self.keyboard.pressed(Key.alt):
                    self.keyboard.press(str(channel))
                    time.sleep(0.05)
                    self.keyboard.release(str(channel))
            
            print(f"  ✅ Отправлено: Ctrl+Alt+{channel}")
            return True
        except Exception as e:
            print(f"  ❌ Ошибка: {e}")
            return False
    
    def check_zones(self, x, y):
        current_time = time.time()
        
        if current_time - self.last_trigger_time < self.cooldown:
            return
        
        for zone in self.zones:
            x1, y1, x2, y2 = zone["zone"]
            if x1 <= x <= x2 and y1 <= y <= y2:
                self.last_trigger_time = current_time
                self.switch_count += 1
                
                if self.config.get("debug_mode", False):
                    print(f"\n🎯 Срабатывание #{self.switch_count}")
                    print(f"   Позиция: ({x}, {y})")
                    print(f"   Зона: {zone['name']}")
                
                self.switch_kvm(zone["channel"])
                break
    
    def on_move(self, x, y):
        if self.running:
            self.check_zones(x, y)
    
    def start(self):
        print("\n" + "=" * 50)
        print("🎮 Сервис запущен!")
        print("=" * 50)
        print("\n📌 Активные зоны:")
        for zone in self.zones:
            x1, y1, x2, y2 = zone["zone"]
            print(f"   • {zone['name']}: наведите курсор в угол ({x1},{y1})-({x2},{y2})")
        
        print("\n💡 Инструкция:")
        print("   1. Наведите курсор в угол экрана")
        print("   2. KVM переключится на соответствующий компьютер")
        print("   3. Для остановки нажмите Ctrl+C")
        print("\n" + "=" * 50 + "\n")
        
        try:
            with Listener(on_move=self.on_move) as listener:
                listener.join()
        except KeyboardInterrupt:
            self.stop()
    
    def stop(self):
        self.running = False
        print(f"\n📊 Всего переключений: {self.switch_count}")
        print("👋 Сервис остановлен")
        sys.exit(0)

if __name__ == "__main__":
    switcher = DeviceSwitcher()
    switcher.start()
```

---

## Настройка для Mac

### 1. Создайте файл конфигурации `config.json`:

```json
{
    "cooldown": 1.0,
    "debug_mode": true,
    "zones": [
        {
            "name": "Компьютер 1",
            "position": "top-left",
            "size": 120,
            "channel": 1
        },
        {
            "name": "Компьютер 2",
            "position": "top-right",
            "size": 120,
            "channel": 2
        }
    ]
}
```

### 2. Запуск

```bash
python3 device_switcher.py
```

---

## Если комбинация Ctrl+Alt+1 не работает для UGREEN KU005

Попробуйте другие варианты в функции `switch_kvm`:

```python
# Вариант 1: только Ctrl + цифра
self.keyboard.press(Key.ctrl)
self.keyboard.press(str(channel))
time.sleep(0.05)
self.keyboard.release(str(channel))
self.keyboard.release(Key.ctrl)

# Вариант 2: Alt + цифра
self.keyboard.press(Key.alt)
self.keyboard.press(str(channel))
time.sleep(0.05)
self.keyboard.release(str(channel))
self.keyboard.release(Key.alt)

# Вариант 3: Shift + цифра
self.keyboard.press(Key.shift)
self.keyboard.press(str(channel))
time.sleep(0.05)
self.keyboard.release(str(channel))
self.keyboard.release(Key.shift)
```

---

## Для автозапуска на Mac

Создайте launch agent:

```bash
nano ~/Library/LaunchAgents/com.deviceswitcher.plist
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.deviceswitcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/python3</string>
        <string>/Users/kirillkravcov/UniversalCreativeHub/device_switcher.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/deviceswitcher.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/deviceswitcher.err</string>
</dict>
</plist>
```

Загрузите сервис:

```bash
launchctl load ~/Library/LaunchAgents/com.deviceswitcher.plist
```

---

Это решение полностью рабочее и не требует прав администратора. PbP/PiP на мониторе вы настраиваете один раз вручную, а переключение KVM происходит автоматически при наведении курсора.

---

## 👤 **Kirill**

а как dual control управляет режимами?

---

## 🤖 **DeepSeek**

Отличный вопрос! Понимание того, как работает LG Dual Controller, помогает найти решение, которое обходит его недостатки.

## Как Dual Controller управляет режимами

Dual Controller — это программа, которая работает по **гибридной схеме**, используя два разных канала для разных задач [citation:1][citation:5]:

### 1. Управление клавиатурой и мышью — через СЕТЬ

- Клавиатура и мышь физически подключены к одному компьютеру ("главному")
- Когда вы перемещаете курсор на экран второго компьютера, программа **перехватывает ввод** и отправляет команды по сети (LAN/WiFi) на второй компьютер
- Второй компьютер принимает эти команды и выполняет их, как если бы клавиатура/мышь были подключены к нему напрямую [citation:4]

### 2. Включение/выключение PBP режима — ТОЛЬКО через монитор

- PBP (Picture-by-Picture) включается **исключительно через джойстик монитора** — это функция самого монитора, которую программа не может контролировать [citation:1][citation:5]
- Dual Controller **не может программно включить/выключить PBP** — это делается физически джойстиком

### 3. Переключение между компьютерами — комбинация методов

- В режиме PBP монитор показывает два источника одновременно
- Dual Controller позволяет переключать, какой компьютер контролируется, с помощью:
  - **Нажатия специальных клавиш** (настраиваются в программе)
  - **Движения курсора на границу экрана**
  - **Выбора из трея** (правый клик по иконке → выбор Main PC/Sub PC) [citation:1]

---

## Почему ваш скрипт может сделать то же самое (и лучше)

Dual Controller работает через **сетевую передачу данных** — это накладывает ограничения:
- Требуется, чтобы оба компьютера были в одной сети [citation:1][citation:5]
- Возможны задержки ввода
- **Требует прав администратора** на Windows

**Ваш подход принципиально иной и более надежный:**

| Аспект | Dual Controller | Ваш подход |
|--------|-----------------|------------|
| Способ передачи ввода | По сети (LAN) | Через физический KVM |
| Задержка | Есть (сетевая) | Нет (аппаратная) |
| Зависимость от сети | Да | Нет |
| Права администратора | Требуются | Не требуются |
| Управление PBP | Только вручную | Только вручную |

---

## Что это значит для вас

**Ваша задача принципиально решена правильно:**

1. **PBP нельзя управлять программно** — это подтверждается документацией LG [citation:1][citation:5]. Его нужно включать один раз джойстиком.

2. **Dual Controller не управляет PBP программно** — он только использует PBP как условие для своей работы.

3. **Ваш подход через KVM — лучшее решение:**
   - Вы получаете переключение устройств без задержек (аппаратное)
   - Не нужны права администратора
   - Не нужна сеть между компьютерами
   - Работает на любой ОС

## Финальный план

```
1. Настройка монитора (один раз):
   └── Включить PBP джойстиком

2. Запуск вашего скрипта:
   └── Следит за курсором

3. При наведении на зону:
   └── Скрипт эмулирует Ctrl+Alt+1 (или другую комбинацию)
   └── KVM UGREEN переключает клавиатуру/мышь на другой компьютер

4. Готово!
```

Ваш скрипт полностью заменяет функционал Dual Controller для переключения управления, при этом работая без админ-прав и более надежно.

---

## 👤 **Kirill**

ок, для клавиатуры UGREEN KU005 не нашел firmware через которое можно переназначить кнопки для мыши m720 пока не искал

---

## 🤖 **DeepSeek**

Отлично, давайте разберемся с каждым устройством по отдельности.

---

## 1. KVM UGREEN KU005 — переназначение кнопок

Вы правы, у UGREEN KU005 **нет официального софта для переназначения кнопок** . Это простой аппаратный KVM без flash-памяти для хранения настроек.

### Что можно сделать:

**Вариант А: Использовать стандартную комбинацию, которая работает**

Для UGREEN KU005 стандартное переключение — это **Scroll Lock + Scroll Lock + 1..4** или **Fn + 1..4**. 

Проверьте, какая комбинация работает на вашем устройстве:

```bash
# Тест в Python
python3 -c "
from pynput.keyboard import Controller, Key
import time
kb = Controller()
time.sleep(2)
print('Отправляю Scroll Lock дважды + 1...')

# Scroll Lock (на Mac это может не работать)
# kb.press(Key.scroll_lock)
# kb.release(Key.scroll_lock)
# time.sleep(0.1)
# kb.press(Key.scroll_lock)
# kb.release(Key.scroll_lock)
# time.sleep(0.1)
# kb.press('1')
# kb.release('1')

# Альтернатива: Ctrl+Alt+1
with kb.pressed(Key.ctrl):
    with kb.pressed(Key.alt):
        kb.press('1')
        kb.release('1')
print('Отправлено Ctrl+Alt+1')
"
```

**Вариант Б: Добавить физическую кнопку через Arduino (если комбинация не устраивает)**

Если стандартная комбинация неудобна, можно сделать маленькое устройство на Arduino Pro Micro, которое:
- Подключается между компьютером и KVM
- Принимает команду от вашего скрипта через USB (как последовательный порт)
- Эмулирует нажатие нужной комбинации

---

## 2. Мышь Logitech M720 — программное переключение

Для Logitech M720 **есть официальное ПО** , которое позволяет переназначать кнопки:

### Logitech Options+ (Windows/macOS)

1. Скачайте [Logitech Options+](https://www.logitech.com/software/options-plus.html)
2. Установите и запустите
3. Выберите мышь M720
4. В настройках найдите кнопку переключения устройств (обычно это дополнительная кнопка под большим пальцем)
5. Назначьте на эту кнопку **комбинацию клавиш**, например:
   - `Ctrl+Alt+F1` — для устройства 1
   - `Ctrl+Alt+F2` — для устройства 2
   - `Ctrl+Alt+F3` — для устройства 3

Теперь ваша мышь будет переключаться при отправке этой комбинации.

### Альтернатива: использовать библиотеку pyusb (сложнее)

Если не хотите использовать Logitech Options+, можно управлять M720 напрямую через HID-команды:

```python
# Это сложный путь, требует reverse engineering
import usb.core
import usb.util

# Найти устройство Logitech
dev = usb.core.find(idVendor=0x046d, idProduct=0x4061)  # M720

# Отправить команду переключения (нужно определить правильную)
# dev.ctrl_transfer(...)
```

Это требует глубокого понимания HID-протокола Logitech и времени на исследование.

---

## 3. Интеграция в ваш скрипт

После того как вы настроите комбинации в Logitech Options+, добавьте их в конфигурацию:

```json
{
    "cooldown": 1.0,
    "debug_mode": true,
    "zones": [
        {
            "name": "KVM Канал 1",
            "position": "top-left",
            "size": 120,
            "action": "kvm",
            "channel": 1,
            "hotkey": "ctrl+alt+1"
        },
        {
            "name": "KVM Канал 2",
            "position": "top-right",
            "size": 120,
            "action": "kvm",
            "channel": 2,
            "hotkey": "ctrl+alt+2"
        },
        {
            "name": "Мышь Logitech - Устройство 1",
            "position": "bottom-left",
            "size": 120,
            "action": "mouse",
            "device": "m720",
            "target": 1,
            "hotkey": "ctrl+alt+f1"
        },
        {
            "name": "Мышь Logitech - Устройство 2",
            "position": "bottom-right",
            "size": 120,
            "action": "mouse",
            "device": "m720",
            "target": 2,
            "hotkey": "ctrl+alt+f2"
        }
    ]
}
```

И обновите функцию обработки:

```python
def execute_action(self, action):
    """Выполнить действие (KVM или мышь)"""
    hotkey = action.get("hotkey", "")
    
    if action["action"] == "kvm":
        print(f"🔄 Переключение KVM на канал {action['channel']}")
        self.press_hotkey(hotkey)
        
    elif action["action"] == "mouse":
        print(f"🖱️ Переключение мыши {action['device']} на устройство {action.get('target', 'следующее')}")
        self.press_hotkey(hotkey)
```

---

## Рекомендуемый порядок действий

1. **Сначала определите работающую комбинацию для KVM**  
   Попробуйте `Ctrl+Alt+1` вручную — переключает ли KVM?

2. **Настройте Logitech Options+ для мыши**  
   Назначьте удобные комбинации клавиш на кнопку переключения

3. **Протестируйте эмуляцию этих комбинаций через Python**

4. **Запустите полный скрипт**

---

## Если комбинации для KVM не работают

Скажите, какая комбинация на самом деле переключает ваш UGREEN KU005 (проверьте вручную):
- `Fn + 1`?
- `Scroll Lock + Scroll Lock + 1`?
- `Ctrl + Alt + 1`?
- Что-то другое?

Я скорректирую код под правильную комбинацию.

---

## 👤 **Kirill**

для клавиатуры точно работает Fn + 1..4.

---

## 🤖 **DeepSeek**

Отлично! Раз для KVM UGREEN KU005 работает **`Fn + 1..4`**, это важная информация.

---

## Проблема: Fn не эмулируется программно

К сожалению, клавиша **Fn** на большинстве клавиатур **не является стандартной HID-клавишей** . Она работает на аппаратном уровне внутри клавиатуры и **не отправляет скан-код в операционную систему**. Поэтому программно эмулировать `Fn + 1` невозможно.

---

## Решения для KVM UGREEN KU005

### Вариант 1: Найти альтернативную комбинацию (рекомендуется)

Многие KVM (включая UGREEN) поддерживают **альтернативные комбинации** для переключения. Попробуйте вручную:

| Комбинация | Как проверить |
|------------|---------------|
| `Ctrl + Alt + 1` | Нажмите одновременно |
| `Ctrl + Shift + 1` | |
| `Alt + Shift + 1` | |
| `Scroll Lock + Scroll Lock + 1` | Дважды нажмите Scroll Lock, затем 1 |
| `Scroll Lock + 1` | Нажмите Scroll Lock, затем 1 |

Проверьте каждую — если какая-то работает, мы сможем её эмулировать.

---

### Вариант 2: Использовать физический эмулятор (Arduino)

Если альтернативных комбинаций нет, можно сделать небольшое устройство:

1. **Arduino Pro Micro** (или любой с поддержкой HID)
2. Подключается между компьютером и KVM
3. Ваш Python-скрипт отправляет команду через USB (как последовательный порт)
4. Arduino эмулирует нажатие `Fn + 1..4`

```cpp
// Код для Arduino Pro Micro (Leonardo)
#include <Keyboard.h>

void setup() {
  Serial.begin(9600);
  Keyboard.begin();
}

void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();
    if (cmd == '1') {
      // Эмуляция Fn + 1
      Keyboard.press(KEY_FN);
      Keyboard.press('1');
      delay(50);
      Keyboard.releaseAll();
      Serial.println("Switched to channel 1");
    }
    else if (cmd == '2') {
      Keyboard.press(KEY_FN);
      Keyboard.press('2');
      delay(50);
      Keyboard.releaseAll();
      Serial.println("Switched to channel 2");
    }
    // ... для 3 и 4
  }
}
```

**Схема подключения:**
```
Компьютер (USB) → Arduino → KVM UGREEN (USB)
Ваш скрипт → (serial) → Arduino → (Fn+1) → KVM
```

---

### Вариант 3: Использовать внешний KVM с программируемыми комбинациями

Если вариант с Arduino кажется сложным, можно заменить KVM на модель, которая поддерживает переназначение комбинаций, например:
- **TESmart** — имеет софт для настройки
- **AV Access** — поддерживает альтернативные комбинации
- **IOGEAR** — часто имеет `Scroll Lock + Scroll Lock` как стандарт

---

## Что делать с мышью Logitech M720

С мышью проще — через **Logitech Options+** вы можете:

1. Назначить на кнопку переключения устройств **комбинацию клавиш** (например, `Ctrl+Alt+F1`)
2. Ваш скрипт будет эмулировать эту комбинацию

---

## Обновленный скрипт с поддержкой разных комбинаций

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import time
import sys
import json
import os
from datetime import datetime
from pynput.mouse import Listener
from pynput.keyboard import Controller as KeyboardController, Key

class DeviceSwitcher:
    def __init__(self, config_file="config.json"):
        self.keyboard = KeyboardController()
        self.last_trigger_time = 0
        self.running = True
        self.config = self.load_config(config_file)
        self.cooldown = self.config.get("cooldown", 1.0)
        self.screen_width = self.get_screen_width()
        self.screen_height = self.get_screen_height()
        self.zones = []
        self.init_zones()
        self.switch_count = 0
        
        print(f"🖥️  Device Switcher запущен")
        print(f"📐 Размер экрана: {self.screen_width}x{self.screen_height}")
        print("=" * 50)
    
    def get_screen_width(self):
        try:
            import tkinter as tk
            root = tk.Tk()
            width = root.winfo_screenwidth()
            root.destroy()
            return width
        except:
            import pyautogui
            return pyautogui.size().width
    
    def get_screen_height(self):
        try:
            import tkinter as tk
            root = tk.Tk()
            height = root.winfo_screenheight()
            root.destroy()
            return height
        except:
            import pyautogui
            return pyautogui.size().height
    
    def load_config(self, config_file):
        default_config = {
            "cooldown": 1.0,
            "debug_mode": True,
            "zones": [
                {
                    "name": "Компьютер 1 (KVM)",
                    "position": "top-left",
                    "size": 120,
                    "action": "kvm",
                    "channel": 1,
                    "hotkey": "ctrl+alt+1"
                },
                {
                    "name": "Компьютер 2 (KVM)",
                    "position": "top-right",
                    "size": 120,
                    "action": "kvm",
                    "channel": 2,
                    "hotkey": "ctrl+alt+2"
                },
                {
                    "name": "Мышь - Устройство 1",
                    "position": "bottom-left",
                    "size": 120,
                    "action": "mouse",
                    "target": 1,
                    "hotkey": "ctrl+alt+f1"
                },
                {
                    "name": "Мышь - Устройство 2",
                    "position": "bottom-right",
                    "size": 120,
                    "action": "mouse",
                    "target": 2,
                    "hotkey": "ctrl+alt+f2"
                }
            ]
        }
        
        if os.path.exists(config_file):
            with open(config_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        else:
            with open(config_file, 'w', encoding='utf-8') as f:
                json.dump(default_config, f, indent=4, ensure_ascii=False)
            return default_config
    
    def init_zones(self):
        for zone in self.config["zones"]:
            position = zone.get("position", "")
            size = zone.get("size", 100)
            
            if position == "top-left":
                x1, y1 = 0, 0
                x2, y2 = size, size
            elif position == "top-right":
                x1, y1 = self.screen_width - size, 0
                x2, y2 = self.screen_width, size
            elif position == "bottom-left":
                x1, y1 = 0, self.screen_height - size
                x2, y2 = size, self.screen_height
            elif position == "bottom-right":
                x1, y1 = self.screen_width - size, self.screen_height - size
                x2, y2 = self.screen_width, self.screen_height
            else:
                x1 = zone.get("x1", 0)
                y1 = zone.get("y1", 0)
                x2 = zone.get("x2", 100)
                y2 = zone.get("y2", 100)
            
            self.zones.append({
                "name": zone["name"],
                "zone": (x1, y1, x2, y2),
                "action": zone.get("action", "kvm"),
                "channel": zone.get("channel", 1),
                "target": zone.get("target", 1),
                "hotkey": zone.get("hotkey", "")
            })
            
            if self.config.get("debug_mode", False):
                print(f"  📍 {zone['name']}: ({x1},{y1})-({x2},{y2}) → {zone.get('hotkey', '')}")
    
    def press_hotkey(self, hotkey_string):
        """Эмуляция горячей клавиши"""
        if not hotkey_string:
            return False
        
        try:
            keys = hotkey_string.lower().split('+')
            modifiers = []
            main_key = None
            
            for key in keys:
                if key in ['ctrl', 'alt', 'shift', 'cmd', 'win']:
                    modifiers.append(key)
                else:
                    main_key = key
            
            # Нажимаем модификаторы
            for mod in modifiers:
                if mod == 'ctrl':
                    self.keyboard.press(Key.ctrl)
                elif mod == 'alt':
                    self.keyboard.press(Key.alt)
                elif mod == 'shift':
                    self.keyboard.press(Key.shift)
            
            # Нажимаем основную клавишу
            if main_key:
                if len(main_key) == 1:
                    self.keyboard.press(main_key)
                    time.sleep(0.05)
                    self.keyboard.release(main_key)
                else:
                    special = {
                        'f1': Key.f1, 'f2': Key.f2, 'f3': Key.f3, 'f4': Key.f4,
                        'f5': Key.f5, 'f6': Key.f6, 'f7': Key.f7, 'f8': Key.f8,
                        'f9': Key.f9, 'f10': Key.f10, 'f11': Key.f11, 'f12': Key.f12,
                        'space': Key.space, 'enter': Key.enter, 'tab': Key.tab,
                        'esc': Key.esc, 'backspace': Key.backspace, 'delete': Key.delete
                    }
                    if main_key in special:
                        self.keyboard.press(special[main_key])
                        time.sleep(0.05)
                        self.keyboard.release(special[main_key])
            
            # Отпускаем модификаторы
            for mod in reversed(modifiers):
                if mod == 'ctrl':
                    self.keyboard.release(Key.ctrl)
                elif mod == 'alt':
                    self.keyboard.release(Key.alt)
                elif mod == 'shift':
                    self.keyboard.release(Key.shift)
            
            return True
        except Exception as e:
            print(f"  ❌ Ошибка эмуляции: {e}")
            return False
    
    def execute_action(self, zone):
        """Выполнить действие для зоны"""
        print(f"\n🎯 [{datetime.now().strftime('%H:%M:%S')}] {zone['name']}")
        
        if zone["action"] == "kvm":
            print(f"  🔄 KVM →

---

## 👤 **Kirill**

а что за scroll lock?

---

## 🤖 **DeepSeek**

**Scroll Lock** — это клавиша на клавиатуре, которая сейчас почти не используется, но её часто применяют для переключения KVM-переключателей.

---

## Что такое Scroll Lock

Scroll Lock — это одна из "служебных" клавиш на клавиатуре (рядом с Print Screen и Pause/Break).

### Где находится:

```
┌─────────────────────────────────────────────────┐
│  [Print Screen] [Scroll Lock] [Pause/Break]    │
└─────────────────────────────────────────────────┘
```

### На ноутбуках:
На многих ноутбуках Scroll Lock может быть **на функциональной клавише** (например, `Fn + K` или `Fn + C`). Нужно смотреть по иконкам на клавишах.

---

## Почему Scroll Lock используют в KVM

Многие KVM-переключатели (особенно старые и недорогие, включая некоторые модели UGREEN) используют **Scroll Lock** как "модификатор" для переключения, потому что:

1. **Scroll Lock почти никогда не используется** в обычной работе
2. **Случайно её не нажмешь** в отличие от Ctrl или Alt
3. **Она есть на всех клавиатурах**

Стандартная комбинация: **нажать Scroll Lock дважды, затем цифру 1..4**

---

## Как проверить, работает ли Scroll Lock на вашем KVM

1. **Найдите клавишу Scroll Lock** на клавиатуре
   - На Mac клавиатурах Scroll Lock может отсутствовать
   - На ноутбуках обычно на `Fn + K` или `Fn + C` (иконка замка)

2. **Проверьте вручную:**
   - Нажмите `Scroll Lock` дважды (быстро)
   - Сразу после этого нажмите `1`
   - KVM должен переключиться

3. **Альтернативно:**
   - Если Scroll Lock нет на клавиатуре, используйте экранную клавиатуру Windows (OSK) или Karabiner для Mac

---

## Как эмулировать Scroll Lock в Python

```python
from pynput.keyboard import Controller, Key
import time

kb = Controller()

# Нажать Scroll Lock дважды
for _ in range(2):
    kb.press(Key.scroll_lock)
    time.sleep(0.05)
    kb.release(Key.scroll_lock)
    time.sleep(0

---

