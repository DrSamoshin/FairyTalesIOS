# FairyTales iOS - Правила разработки

## 🎯 Основные принципы

### Безопасность контента
- **КРИТИЧНО**: Только семейный контент (возраст 3-16 лет)
- Запрещены: насилие, страшные сцены, смерть, неподходящий язык
- Соблюдение COPPA и GDPR

### Архитектура
- SwiftUI + MVVM с @Observable паттерном
- Dependency injection через Environment
- Слои: UI → Services → Network → Models

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

## 💻 Код-стайл

### Naming Conventions
```swift
// Managers - суффикс Manager
class AuthManager { }

// Services - суффикс Service  
class StoryService { }

// Screens - суффикс Screen
struct MainScreen: View { }
```

### SwiftUI Best Practices
```swift
// ✅ @Observable для managers (Swift 6.0+)
@Observable
@MainActor
final class MyManager: Sendable {
    static let shared = MyManager()
}

// ✅ Constants только для неизменных элементов
private struct Constants {
    static let iconSize: CGFloat = 80
    static let fontSize: CGFloat = 16
    // НЕ добавляем: paddings, margins, spacing, cornerRadius
}
```

## 🌐 Локализация

### Правила
- **В разработке ТОЛЬКО английский язык**
- Другие языки (RU, ES, FR, DE) добавляются только по запросу
- Все ключи в snake_case

### Использование
```swift
// ✅ Правильно
Text("story_created_title".localized)

// ❌ Неправильно  
Text("Story Created")
```

## 🎨 Design System

### Стандарты
```swift
// Цвета и шрифты через константы
.foregroundColor(AppColors.primary)
.font(.appTitle)

// Constants только для фиксированных размеров
iconSize: 80
fontSize: 16

// Все UI размеры (paddings, margins, spacing, cornerRadius) 
// используются инлайн для гибкости и читаемости
```

### Анимации
```swift
.animation(.easeInOut(duration: 0.3), value: isVisible)
```

## 🔐 Безопасность и производительность

### Токены
```swift
// ✅ Используйте TokenManager
let headers = tokenManager.authHeaders

// ❌ Никогда не логируйте токены
```

### Memory Management
```swift
// ✅ Weak references
NotificationCenter.default.addObserver(forName: .name) { [weak self] _ in }

// ✅ MainActor для UI
@MainActor
func updateUI() { }
```

## 🐛 Error Handling

### Стандартизированные ошибки
```swift
enum NetworkError: Error, LocalizedError {
    case apiError(ErrorResponse)
    case timeout
    case internetConnection
}
```

### Пользовательские сообщения
```swift
// ✅ Локализованные сообщения
errorMessage = "auth_timeout_message".localized
```

## ⚠️ Критические запреты

### НИКОГДА не делать:
- ❌ Хардкодить строки вместо локализации
- ❌ Логировать токены, пароли, личные данные
- ❌ Блокировать main thread
- ❌ Создавать неподходящий для детей контент
- ❌ Force unwrapping без guard/if let

### Осторожно с:
- ⚠️ Retain cycles в closures
- ⚠️ Network calls в init методах
- ⚠️ Блокировка UI во время загрузки

## 📝 Правила взаимодействия

### Общение
- **ВАЖНО**: На вопросы ТОЛЬКО отвечать, НЕ писать код
- Код писать ТОЛЬКО после разрешения: "делай", "реализуй"
- Сначала обсуждение, потом реализация

### Swift версии
- **Использовать ТОЛЬКО Swift 6.0+ фичи**
- Современные SwiftUI паттерны и iOS SDK

## 🧪 Тестирование и Deployment

### Checklist
- [ ] Все строки локализованы
- [ ] Нет debug принтов в production
- [ ] Privacy policy актуальна
- [ ] Семейный контент проверен

---

*Правила обеспечивают качество, безопасность и поддерживаемость FairyTales.*