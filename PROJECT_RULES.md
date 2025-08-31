# FairyTales iOS - Правила разработки

## 🎯 Общие принципы

### Безопасность и контент
- **КРИТИЧНО**: Все контент должен быть семейным и детским (возраст 3-16 лет)
- Исключены: насилие, страшные сцены, смерть, неподходящий язык
- Обязательна проверка всего ИИ-генерируемого контента
- Соблюдение COPPA и GDPR требований

### Архитектурные принципы
- SwiftUI + MVVM с @Observable паттерном
- Единая точка истины для состояния (shared managers)
- Dependency injection через SwiftUI Environment
- Четкое разделение слоев: UI → Services → Network → Models

## 📁 Структура проекта

```
FairyTales/
├── Models/              # Данные и API модели
├── Services/            # Бизнес-логика и managers
├── Network/             # Сетевой слой
├── Components/          # Переиспользуемые UI компоненты
├── Constants/           # Цвета, типографика, константы  
├── Extensions/          # Расширения стандартных типов
├── Localization/        # Все файлы локализации (.lproj)
└── Assets.xcassets/     # Ресурсы приложения
```

## 🗣️ Правила взаимодействия с разработчиком

### Общение и планирование
- **ВАЖНО**: Когда пользователь задает вопрос - ТОЛЬКО отвечать, НЕ писать код
- Писать код ТОЛЬКО после явного разрешения: "пиши код", "делай", "реализуй"
- Сначала обсуждение и планирование, потом реализация
- Всегда уточнять требования перед началом кодирования

### Swift версия и современные фичи
- **Использовать ТОЛЬКО последние Swift фичи** (Swift 6.0+)
- Обязательно применять новейшие iOS SDK возможности
- Современные SwiftUI паттерны и API
- Актуальные Xcode и iOS версии

## 💻 Код-стайл

### Naming Conventions
```swift
// Managers - суффикс Manager
class AuthManager { }
class NetworkManager { }

// Services - суффикс Service  
class StoryService { }
class StoryStreamingService { }

// Screens - суффикс Screen
struct MainScreen: View { }
struct StoryCreatorScreen: View { }

// Models - описательные имена
struct Story: Codable { }
struct StoryGenerateRequest: Codable { }
```

### SwiftUI Best Practices (Swift 6.0+)
```swift
// ✅ Используйте @Observable для новых managers (Swift 5.9+)
@Observable
@MainActor
final class MyManager: Sendable {
    static let shared = MyManager()
    private init() {}
}

// ✅ Environment injection (SwiftUI 4.0+)
struct MyView: View {
    @Environment(AuthManager.self) private var authManager
}

// ✅ Константы в отдельной структуре
private struct Constants {
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 20
}

// ✅ Используйте новые Swift 6.0 фичи:
// - Strict concurrency checking
// - Complete concurrency model
// - Enhanced pattern matching
// - Improved generics
```

## 🌐 Локализация

### Правила разработки
- **ВАЖНО**: В процессе разработки делаем ТОЛЬКО английский язык
- НЕ добавлять локализацию на другие языки пока не получено явное указание
- Локализация на RU, ES, FR, DE добавляется только по запросу

### Структура
- Все файлы в папке `Localization/`
- Поддерживаемые языки: EN, RU, ES, FR, DE
- Ключи локализации в snake_case

### Использование в разработке
```swift
// ✅ В процессе разработки - только EN
Text("story_created_title".localized)
Button("generate_story".localized) { }

// ❌ Неправильно  
Text("Story Created")
```

### Когда добавлять полную локализацию
- Только когда разработчик явно скажет "добавь локализацию"
- При финальной подготовке к релизу
- После завершения основного функционала

## 🎨 UI/UX Guidelines

### Design System
```swift
// Используйте AppColors и AppTypography
.foregroundColor(AppColors.primary)
.font(AppTypography.title)

// Стандартные значения
cornerRadius: 16
padding: 20, 30
buttonHeight: 54
```

### Анимации
```swift
// Стандартные анимации
.animation(.easeInOut(duration: 0.3), value: isVisible)
.transition(.asymmetric(insertion: .slide, removal: .opacity))
```

### Темная тема
- Принудительная темная тема: `.preferredColorScheme(.dark)`
- Все цвета через AppColors для консистентности

## 🔐 Безопасность

### Токены и секреты
```swift
// ✅ Используйте TokenManager для токенов
let headers = tokenManager.authHeaders

// ✅ Keychain для чувствительных данных
// ❌ Никогда не логируйте токены или пароли
```

### Network Security
- Только HTTPS соединения
- Certificate pinning (через CustomURLSessionDelegate)
- Proper error handling без раскрытия внутренней информации

## 📱 Производительность

### Memory Management
```swift
// ✅ Weak references в closures
NotificationCenter.default.addObserver(forName: .name) { [weak self] _ in }

// ✅ @MainActor для UI updates
@MainActor
func updateUI() { }
```

### Networking
```swift
// ✅ Proper timeouts
config.timeoutIntervalForRequest = 30
config.timeoutIntervalForResource = 60

// ✅ Cache validation
private let cacheValidityPeriod: TimeInterval = 300 // 5 minutes
```

## 🐛 Error Handling

### Network Errors
```swift
// ✅ Стандартизированная обработка
enum NetworkError: Error, LocalizedError {
    case apiError(ErrorResponse)
    case timeout
    case internetConnection
}
```

### User-Friendly Messages
```swift
// ✅ Локализованные сообщения об ошибках
errorMessage = "auth_timeout_message".localized

// ✅ Предложения по решению
"server_error_suggestion".localized
```

## 📊 Логирование

### Уровни логирования
```swift
// ✅ Production - минимальные логи
// ✅ Debug - детальные логи только в development
// ❌ Никогда не логируйте чувствительную информацию

#if DEBUG
print("Debug info: \(details)")
#endif
```

## 🔄 Streaming

### SSE Implementation
```swift
// ✅ Proper delegate pattern
protocol StoryStreamingDelegate: AnyObject {
    nonisolated func streamingDidReceiveContent(_ content: String)
}

// ✅ Background queue processing
private let bufferQueue = DispatchQueue(label: "buffer.queue")
```

## 💳 Подписки (StoreKit)

### Best Practices
```swift
// ✅ Transaction validation
for await result in Transaction.updates {
    if case .verified(let transaction) = result {
        // Process verified transaction
    }
}

// ✅ Status caching
private let cacheValidityPeriod: TimeInterval = 300
```

## 🧪 Тестирование

### Unit Tests
- Тестируйте бизнес-логику в Services
- Мокайте network calls
- Проверяйте edge cases

### UI Tests  
- Основные user flows
- Accessibility тестирование
- Локализация UI

## 🚀 Deployment

### Pre-Release Checklist
- [ ] Все строки локализованы
- [ ] Нет debug принтов в production коде
- [ ] App Store guidelines соблюдены
- [ ] Privacy policy актуальна
- [ ] Subscription flow протестирован

### Version Management
```swift
// Semantic versioning: MAJOR.MINOR.PATCH
// 1.0.0 - Major release
// 1.1.0 - New features  
// 1.1.1 - Bug fixes
```

## ⚠️ Запреты

### НИКОГДА не делать:
- ❌ Хардкодить строки вместо локализации
- ❌ Логировать токены, пароли, личные данные
- ❌ Блокировать main thread длительными операциями
- ❌ Создавать контент неподходящий для детей
- ❌ Коммитить в main без code review
- ❌ Использовать deprecated APIs без веской причины

### Осторожно с:
- ⚠️ Force unwrapping (!), используйте guard/if let
- ⚠️ Retain cycles в closures
- ⚠️ Network calls в init методах
- ⚠️ Blocking UI во время загрузки

## 📝 Code Review

### Чек-лист для ревьювера:
- [ ] Код соответствует архитектурным принципам
- [ ] Нет утечек памяти или retain cycles  
- [ ] Proper error handling
- [ ] UI responsive и accessible
- [ ] Все строки локализованы
- [ ] Нет детского неподходящего контента
- [ ] Performance implications учтены

---

*Эти правила обеспечивают качество, безопасность и поддерживаемость FairyTales приложения.*