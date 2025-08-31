# Button Styles Guide - Руководство по стилям кнопок

## 🎯 Обзор

Все стили кнопок централизованы в `ButtonStyles.swift` для переиспользования во всех экранах приложения.

## 📐 Layout константы

```swift
ButtonStyles.Layout.cornerRadius        // 16
ButtonStyles.Layout.itemHeight          // 56
ButtonStyles.Layout.itemPadding         // 20
ButtonStyles.Layout.itemSpacing         // 12
ButtonStyles.Layout.iconFrameWidth      // 28
ButtonStyles.Layout.borderWidth         // 2
ButtonStyles.Layout.shadowRadius        // 8
ButtonStyles.Layout.shadowOffset        // CGSize(width: 0, height: 4)
```

## 🎨 Готовые стили кнопок

### 1. Lime Green (Лаймово-зеленая)
```swift
ButtonStyles.ButtonConfig.limeGreen
// Алиас: ButtonStyles.ButtonConfig.subscription
```
- **Цвета**: Лаймово-зеленый градиент (#33CC66 → #1A9933)
- **Граница**: Светло-зеленая (#66E680)
- **Иконка**: `crown.fill`
- **Использование**: Кнопки подписки, premium функции

### 2. Sky Blue (Небесно-голубая)
```swift
ButtonStyles.ButtonConfig.skyBlue
// Алиас: ButtonStyles.ButtonConfig.language
```
- **Цвета**: Небесно-голубой градиент (AppColors.contrastSecondary)
- **Граница**: Светло-голубая (#B3E5E5)
- **Иконка**: `globe`
- **Использование**: Языковые настройки

### 3. Lavender Purple (Лавандово-фиолетовая)
```swift
ButtonStyles.ButtonConfig.lavenderPurple
// Алиас: ButtonStyles.ButtonConfig.privacy
```
- **Цвета**: Лавандово-фиолетовый градиент (#CC80CC → #994DB3)
- **Граница**: Светло-фиолетовая (#E6B3E6)
- **Иконка**: `doc.text`
- **Использование**: Политика конфиденциальности

### 4. Sunset Orange (Закатно-оранжевая)
```swift
ButtonStyles.ButtonConfig.sunsetOrange
// Алиас: ButtonStyles.ButtonConfig.terms
```
- **Цвета**: Закатно-оранжевый градиент (AppColors.orangeGradient)
- **Граница**: Светло-оранжевая (#FFE6B3)
- **Иконка**: `doc.plaintext`
- **Использование**: Условия использования

### 5. Cherry Red (Вишнево-красная)
```swift
ButtonStyles.ButtonConfig.cherryRed
// Алиас: ButtonStyles.ButtonConfig.logout
```
- **Цвета**: Вишнево-красный градиент (#D95959 → #A64040)
- **Граница**: Светло-красная (#FF9999)
- **Иконка**: `rectangle.portrait.and.arrow.right`
- **Использование**: Выход из аккаунта, деструктивные действия

### 6. Forest Green (Лесная зеленая)
```swift
ButtonStyles.ButtonConfig.forestGreen
// Алиас: ButtonStyles.ButtonConfig.heroes
```
- **Цвета**: Лесной зеленый градиент (#337F4D → #B3FFD9)
- **Граница**: Средне-зеленая (#4D9966)
- **Иконка**: `person.3.fill`
- **Использование**: Раздел героев, персонажи

### 7. Peach Cream (Персиково-кремовая)
```swift
ButtonStyles.ButtonConfig.peachCream
// Алиас: ButtonStyles.ButtonConfig.stories
```
- **Цвета**: Персиково-кремовый градиент (#FFD9B3 → #FFF2CC)
- **Граница**: Светло-персиковая (#FFF9D9)
- **Иконка**: `book.fill`
- **Использование**: Мои истории, чтение

## 🛠️ Extension методы для использования

### .styledButtonCard(config:height:)
Применяет полный стиль кнопки с фоном, границей и тенью.

```swift
// Стандартная высота (56px)
content
    .styledButtonCard(config: ButtonStyles.ButtonConfig.subscription)

// Кастомная высота
content
    .styledButtonCard(config: ButtonStyles.ButtonConfig.heroes, height: 70)
```

### .styledButtonIcon(_:)
Создает стандартную иконку кнопки.

```swift
styledButtonIcon("crown.fill")
```

### .styledChevronIcon
Стандартный chevron для навигационных кнопок.

```swift
styledChevronIcon
```

## 💡 Примеры использования

### Простая кнопка Settings Screen
```swift
Button(action: { /* действие */ }) {
    HStack(spacing: 12) {
        styledButtonIcon("crown.fill")
        
        VStack(alignment: .leading) {
            Text("Subscription")
                .font(.appLabel)
                .foregroundColor(.white)
            Text("Manage subscription")
                .font(.appCaption)
                .foregroundColor(.white.opacity(0.8))
        }
        
        Spacer()
        styledChevronIcon
    }
    .styledButtonCard(config: ButtonStyles.ButtonConfig.subscription)
}
```

### Кнопка Main Screen стиль
```swift
private func actionButton(
    iconName: String,
    title: String,
    subtitle: String,
    config: ButtonStyles.ButtonConfig,
    textColor: Color
) -> some View {
    HStack(spacing: 20) {
        Image(iconName)
            .resizable()
            .frame(width: 40, height: 40)
        
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.appSubtitle)
                .foregroundColor(textColor)
            Text(subtitle)
                .font(.appCaption)
                .foregroundColor(textColor.opacity(0.8))
        }
        
        Spacer()
        
        Image(systemName: "chevron.right")
            .font(.appBackIcon)
            .foregroundColor(textColor.opacity(0.7))
    }
    .styledButtonCard(config: config, height: 70)
}
```

### Кнопка с иконкой только
```swift
Button(action: { /* действие */ }) {
    HStack {
        styledButtonIcon("globe")
        Text("Language")
            .font(.appLabel)
            .foregroundColor(.white)
        Spacer()
    }
    .styledButtonCard(config: ButtonStyles.ButtonConfig.language)
}
```

## 🎨 Цветовая палитра по стилям

| Стиль | Основной цвет | Градиент | Граница |
|-------|---------------|----------|---------|
| **Lime Green** | 🟢 Лайм | `#33CC66` → `#1A9933` | `#66E680` |
| **Sky Blue** | 🔵 Небесный | AppColors.contrastSecondary | `#B3E5E5` |
| **Lavender Purple** | 🟣 Лаванда | `#CC80CC` → `#994DB3` | `#E6B3E6` |
| **Sunset Orange** | 🟠 Закат | AppColors.orangeGradient | `#FFE6B3` |
| **Cherry Red** | 🔴 Вишня | `#D95959` → `#A64040` | `#FF9999` |
| **Forest Green** | 🌲 Лес | `#337F4D` → `#B3FFD9` | `#4D9966` |
| **Peach Cream** | 🍑 Персик | `#FFD9B3` → `#FFF2CC` | `#FFF9D9` |

## 📝 Как добавить новый стиль

1. **Добавить в ButtonStyles.swift**:
```swift
static let newStyle = ButtonConfig(
    background: LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.x, green: 0.x, blue: 0.x),
            Color(red: 0.x, green: 0.x, blue: 0.x)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    ),
    border: Color(red: 0.x, green: 0.x, blue: 0.x),
    icon: "system.icon.name"
)
```

2. **Использовать в коде**:
```swift
.styledButtonCard(config: ButtonStyles.ButtonConfig.newStyle)
```

## ✅ Лучшие практики

### DO ✅
- Используйте готовые стили для консистентности
- Применяйте `.styledButtonCard()` для полного стиля
- Используйте `.styledButtonIcon()` для иконок
- Соблюдайте цветовую схему стилей

### DON'T ❌
- Не создавайте inline стили в экранах
- Не дублируйте константы размеров
- Не смешивайте цвета из разных стилей
- Не используйте хардкод значения вместо констант

## 🔄 Миграция существующих кнопок

Чтобы мигрировать старую кнопку:

**Было:**
```swift
Button(action: {}) {
    content()
        .padding(20)
        .background(LinearGradient(...))
        .cornerRadius(16)
        .overlay(RoundedRectangle(...).stroke(...))
        .shadow(...)
}
```

**Стало:**
```swift
Button(action: {}) {
    content()
        .styledButtonCard(config: ButtonStyles.ButtonConfig.subscription)
}
```

---

## 📱 Экраны, использующие стили

- ✅ **SettingsScreen** - полностью мигрирован
- ✅ **MainScreen** - полностью мигрирован  
- 🔄 **StoryCreatorScreen** - можно мигрировать
- 🔄 **MyStoriesScreen** - можно мигрировать
- 🔄 **SubscriptionScreen** - можно мигрировать

---

*Используйте этот гайд для создания консистентных и красивых кнопок во всем приложении!* 🎨✨