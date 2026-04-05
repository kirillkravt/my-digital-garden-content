---
chat_id: 3b23bcfd-984c-4535-b117-d78d0cc7bcb1
version: 1
title: Keyboard Only Computer Control Guide
saved_at: 2026-04-05T16:01:58.869Z
url: https://chat.deepseek.com/a/chat/s/3b23bcfd-984c-4535-b117-d78d0cc7bcb1
message_count: 9
participants:
  - role: Human
    name: kirill
  - role: AI_Assistant
    name: DeepSeek
---

## AI_Assistant: DeepSeek (19:01:58)

Read 9 web pagesКонечно, давайте разберем Vimium подробно. Это расширение превращает ваш браузер в полностью управляемое с клавиатуры приложение. Ниже я подробно опишу логику работы каждой из упомянутых вами функций.1. Волшебная клавиша f: Клик по любой ссылкеЭто главная "фишка" Vimium. Она позволяет кликнуть по любой ссылке или кнопке на странице, даже не видя её.Как это работает: Нажмите f. Расширение просканирует страницу и навесит на все кликабельные элементы (ссылки, кнопки, поля ввода) небольшие желтые подсказки с уникальными буквенными кодами -9.Ваше действие: Как только вы увидели код нужной ссылки (например, JE), просто наберите его на клавиатуре. Ссылка откроется в текущей вкладке -1.Нюансы регистра: Обратите внимание на регистр, который вы используете для набора кода, так как он меняет поведение:Нижний регистр (je): Открывает ссылку в текущей вкладке -1.Верхний регистр (JE): Открывает ссылку в новой вкладке -1-8.Продвинутый режим: Если вы нажмете F (большую), то режим выбора ссылок активируется, и по умолчанию любой введенный вами код (даже в нижнем регистре) будет открывать ссылку в новой вкладке. Это удобно, если вы часто читаете статьи и открываете ссылки в фоне -1.2. Навигация по странице: gg, G, H, LЭти команды отвечают за быстрое перемещение по странице и истории посещений.gg — В самое начало: Двойное нажатие g мгновенно отправляет вас вверх страницы. Это аналог нажатия клавиши Home на клавиатуре, но более удобное, так как руки остаются в "домашней позиции" -7-8.G — В самый конец: Нажатие Shift + g (или просто большая G) прокручивает страницу к самому низу. Аналог клавиши End -7-8.Полезный совет: Эти команды работают с числовым префиксом. Например, если нажать 5 g g, вы переместитесь не в самое начало, а на 5-ю строку сверху -2-3.H — Назад по истории: Работает как кнопка "Назад" в браузере. Возвращает вас на предыдущую посещенную страницу -8-4.L — Вперед по истории: Работает как кнопка "Вперед". Возвращает вас на страницу, с которой вы только что вернулись, нажав H -8-4.Дополнительные возможности (Для полного отказа от мыши)Поскольку вы стремитесь минимизировать использование мыши, вот еще несколько команд, которые значительно расширят ваши возможности:Скроллинг:j — прокрутить страницу вниз -8-9.k — прокрутить страницу вверх -8-9.d — прокрутить страницу вниз на полэкрана -8.u — прокрутить страницу вверх на полэкрана -8.Работа с URL:gu — "Go Up". Перейти на уровень выше в структуре URL. Например, если вы на странице github.com/user/repo/issues, нажатие gu перенесет вас на github.com/user/repo. Это очень удобно для навигации по сайтам с иерархией -4-8.gU — "Go to root". Перейти в корень сайта (например, с любой страницы GitHub на github.com) -4-8.ge — "Edit URL". Позволяет отредактировать текущий URL и перейти по нему, не хватая мышку -4-8.Управление вкладками:J / K — переключиться на вкладку слева / справа -8.x — закрыть текущую вкладку -8.X — восстановить закрытую вкладку -8.t — открыть новую вкладку -8.Совет: Если команды не работаютИногда Vimium может конфликтовать с самим сайтом (например, с Gmail или Google Docs). В таких случаях:Нажмите i — это переведет вас в режим вставки (Insert Mode), и все команды Vimium временно отключатся, позволяя вам печатать текст как обычно -8.Чтобы вернуть управление, нажмите Esc.Также, если вы заметили, что подсказки (желтые ярлыки) дублируются или отображаются некорректно, попробуйте зайти в настройки расширения (кликните на иконку Vimium) и нажать кнопку сброса настроек. Это часто решает проблемы -5.9 web pages

---

## Human: kirill (19:01:58)

Vimium is not allowed to run on this page.
Your browser does not run web extensions like Vimium on certain pages, usually for security reasons.

---

## AI_Assistant: DeepSeek (19:01:58)

Read 10 web pagesThis is a completely normal, built-in security restriction that you're seeing, and it's not a bug with Vimium or your setup. Browsers intentionally block extensions like Vimium from running on certain "special" pages to protect your privacy and security -1-6-9.Here’s a breakdown of exactly why this happens and, more importantly, how you can fix it for the pages that matter to you.🛡️ Why You're Seeing This MessageYour browser maintains a strict internal list of pages where extensions are disabled by design -6. These are considered "protected pages" -10. You will typically see this message on:Browser Internal Pages: Any page starting with chrome://, edge://, or about: (e.g., Settings, Extensions, History).Add-on Stores: The Chrome Web Store, Microsoft Edge Add-ons site, or Firefox Add-ons site -5-9.New Tab Pages: The default page that appears when you open a new tab.Security/Error Pages: Pages for warnings, SSL errors, or 404 errors -6.This is a security feature, not a restriction you can bypass on these core browser pages. The logic is simple: an extension should not have the ability to manipulate or spy on the page where you manage other extensions or your browser's own settings.🔧 How to Enable Vimium on Most Other WebsitesThe process depends on whether you're using Firefox or a Chromium-based browser (like Chrome, Edge, Brave, or Vivaldi).For Firefox UsersFirefox has a "Quarantined Domains" feature that can block extensions on specific Mozilla-related sites, but it allows you to override this for individual extensions -7.Method 1: Enable for a Specific Extension (Easiest)Click the menu button (≡) and select Add-ons and themes.In the list of extensions, click on Vimium (or Vimium C).Scroll down to the section labeled Run on sites with restrictions.Change the setting from "Don't allow" to Allow -7.Method 2: Disable the Quarantine Feature Globally (Advanced)If you want to force Vimium to run on all sites except the core protected ones (like about: pages), you can disable the quarantine feature. Please note: This is an advanced step and reduces a security layer -7.Type about:config in the address bar and press Enter. Accept the risk warning.Search for the preference extensions.quarantinedDomains.enabled.If it exists, click the toggle button to change its value to false. If it doesn't exist, you can create it as a new Boolean preference and set it to false -7.Restart Firefox.For Chrome, Edge, and Other Chromium BrowsersIn Chromium-based browsers, the list of restricted domains is hardcoded and cannot be modified by the user -6-10. This means Vimium will never run on the Chrome Web Store, the New Tab page, or any chrome:// settings page.What you can do:Accept the limitation: Realize that you'll never need Vimium's f or scrolling commands on the browser's settings page. You will need to use your mouse or standard OS keyboard shortcuts (like Tab) there.Use a Custom New Tab Page: If you hate that Vimium doesn't work on the default New Tab page, install an extension that replaces it. Look for a "New Tab Override" extension that lets you set a blank page or a custom dashboard. Vimium will work on that custom page.✅ Summary: What to Do Right NowIf you are on Firefox: Go to your Add-ons settings and set Vimium to "Allow" on sites with restrictions. This will fix it for 99% of the web.If you are on Chrome, Edge, or Brave: Understand that this is a permanent, unchangeable restriction for the browser's internal pages. You can ignore the message on those specific pages and enjoy full Vimium functionality everywhere else on the web.Try the steps for your specific browser and let me know if you need help with any other Vimium shortcuts.10 web pages

---

## Human: kirill (19:01:58)

Пиши на русском. Как убрать это ограничение?

---

## AI_Assistant: DeepSeek (19:01:58)

Read 10 web pagesК сожалению, полностью убрать это ограничение невозможно. Оно встроено в сам браузер и распространяется на все расширения, а не только на Vimium -2-6-7.🔒 Что это за ограничение?Браузеры (Chrome, Edge, Firefox) по соображениям безопасности отключают работу любых расширений на следующих типах страниц -2-4-6:Служебные страницы браузера — все, что начинается с chrome://, edge://, about:Страницы настроек браузераМагазины расширений — Chrome Web Store, Microsoft Edge Add-ons -9Страницы «Новая вкладка» (в некоторых браузерах) -2-7Страницы с кодом (view-source:)Страницы с системными ошибками (404, SSL-ошибки)На этих страницах вы всегда будете видеть сообщение Vimium is not allowed to run on this page.✅ Что МОЖНО настроить (и это работает)Хотя запретные страницы нельзя "взломать", вы можете настроить работу Vimium на обычных сайтах и локальных файлах.1. Для всех обычных сайтов (Firefox)В Firefox после установки Vimium по умолчанию НЕ работает на всех сайтах — нужно дать разрешение вручную -3:Нажмите на иконку расширений (пазл) в панели инструментовНажмите на шестеренку рядом с Vimium и выберите «Управление расширением»В разделе «Разрешения» найдите пункт «Доступ к вашим данным для всех веб-сайтов» и включите его -3После этого Vimium будет работать на всех обычных сайтах, кроме защищенных страниц браузера.2. Для локальных файлов (file://...)Если вы открываете локальные HTML-файлы (например, сохраненную документацию) и Vimium там не работает -5:В Chrome/Edge/Brave:Перейдите на страницу расширений: chrome://extensions/Найдите Vimium и нажмите «Подробности»Включите опцию «Разрешить доступ к URL файлов» -2-5-7В Firefox: это разрешение дается автоматически, если вы включили «Доступ для всех сайтов» выше.3. Для страницы «Новая вкладка» (частичное решение)В Chrome на новой вкладке Vimium может не работать, потому что фокус сразу находится в адресной строке. Попробуйте:Нажать Tab один или два раза, чтобы переключить фокус на саму страницу -2-7Установить расширение, заменяющее стандартную страницу новой вкладки на любую другую (например, пустую страницу about:blank), где Vimium будет работать4. Для конкретных сайтов, где Vimium мешаетЕсли Vimium работает, но конфликтует с горячими клавишами сайта (например, в Gmail) -2-7:Нажмите на иконку Vimium в панели инструментовНажмите кнопку «Exclude this site» (Исключить этот сайт)📌 Что важно понятьЭто ограничение — не баг Vimium, а архитектурное решение разработчиков браузеров -2-6-9. Даже если вы найдете способ его обойти, он, скорее всего, перестанет работать после следующего обновления браузера -4-8.Практический совет: просто примите, что на этих редких страницах (настройки, магазин расширений) придется использовать мышь или стандартные клавиши браузера (Tab, Ctrl+L, Ctrl+W). На 99% обычных сайтов Vimium будет работать без проблем после правильной настройки разрешений.Если вы используете конкретный браузер (Chrome, Edge или Firefox) и у вас не получается включить Vimium на обычных сайтах, напишите — я помогу с пошаговой настройкой именно для вашего случая.10 web pages

---

## Human: kirill (19:01:58)

ограничивает на сайте https://chat.deepseek.com/
яндекс браузер

---

## AI_Assistant: DeepSeek (19:01:58)

ReadingReadingПроблема, с которой вы столкнулись на сайте DeepSeek, действительно вызвана ограничениями самого браузера, но в этом случае ситуация специфическая.🧐 Почему Vimium не работает именно на chat.deepseek.com?Это не стандартное ограничение для защищённых страниц браузера (таких как chrome://extensions). Это связано с тем, что Яндекс.Браузер имеет более строгую политику безопасности, чем оригинальный Google Chrome.Причины могут быть такими:Сайт использует «песочницу» (sandbox). Современные веб-приложения, особенно работающие с AI, часто изолируют свой код. Vimium может не иметь доступа к DOM (структуре страницы

---

## Human: kirill (19:01:58)

как в jira отвечать на комментарий?

---

## AI_Assistant: DeepSeek (19:01:58)

Read 10 web pagesВ Jira есть несколько способов ответить на комментарий. Самый быстрый — использовать горячие клавиши, но также есть функции для цитирования и ответа с упоминанием автора.⌨️ Способ 1: Горячая клавиша m (самый быстрый)Независимо от того, где вы находитесь в задаче, нажмите клавишу m (от memo — заметка) -1-7. Это мгновенно переместит курсор в поле для комментария, и вы сможете сразу начать печатать.Важно: Если вы используете Jira Service Management, обратите внимание на переключатель под полем комментария. По умолчанию там может быть выбран вариант «Внутренняя заметка» (Internal note). Чтобы ответ был виден клиенту или автору запроса, переключите его на «Ответить клиенту» (Reply to customer) -3-4.🗣️ Способ 2: Ответ с цитированием (как в мессенджере)В Jira есть функция "Reply", которая работает как цитирование в мессенджерах — она автоматически добавляет в поле комментария текст, на который вы отвечаете, и упоминает автора.Найдите комментарий, на который хотите ответить.Нажмите на три точки (•••) в правом верхнем углу этого комментария.В выпадающем меню выберите «Ответить» (Reply) -10.В поле для комментария появится цитата с именем автора (@упоминание), и вы сможете написать свой ответ под ней.✍️ Способ 3: Упоминание (если нужно ответить не по порядку)Если комментариев много и вы хотите ответить на конкретный, не цитируя его полностью, просто используйте символ @ и начните вводить имя автора комментария. Это создаст упоминание (mention) — автор получит уведомление, что вы обращаетесь к нему -7-10.💡 Полезные советы при ответеФорматирование текста: Вы можете использовать Markdown. Например, **жирный** или *курсив* -9.Быстрая вставка: Чтобы вставить код, таблицу или смайлик, начните вводить с косой черты — / (slash command) -9.Порядок комментариев: По умолчанию новые комментарии появляются внизу. Если вам удобнее читать свежие сверху, нажмите на стрелочку в правом верхнем углу блока активности и измените сортировку -7.10 web pages

---

