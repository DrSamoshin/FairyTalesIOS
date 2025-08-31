# Fairy Tales - Comprehensive Product Requirements Document (PRD)

## Обзор продукта

**Название продукта**: Fairy Tales  
**Версия**: 1.0  
**Дата создания**: 2025  
**Архитектура**: iOS приложение + Python Backend API  
**Целевая аудитория**: Дети от 3 до 16 лет и их родители  

### Описание продукта

Fairy Tales - это полнофункциональная мобильная экосистема для генерации персонализированных детских сказок с использованием искусственного интеллекта (OpenAI GPT-4o-mini). Продукт состоит из нативного iOS приложения и мощного backend API, позволяющих создавать уникальные, безопасные и образовательные истории, адаптированные под возраст, интересы и предпочтения ребенка.

## Архитектура системы

### Backend (Python FastAPI)
- **Фреймворк**: FastAPI 
- **База данных**: PostgreSQL
- **ИИ-сервис**: OpenAI GPT-4o-mini
- **Аутентификация**: Apple Sign In
- **Контейнеризация**: Docker + Docker Compose
- **Миграции**: Alembic

### Frontend (iOS Native)
- **Платформа**: iOS (SwiftUI)
- **Минимальная версия**: iOS 15+
- **Фреймворки**: StoreKit (подписки), AuthenticationServices (Apple Sign In)
- **Языки**: Swift
- **Архитектурный паттерн**: MVVM с ObservableObject

### Интеграция
- RESTful API взаимодействие между iOS и Backend
- Server-Sent Events (SSE) для потоковой генерации сказок
- JWT токены для аутентификации
- HTTPS/TLS шифрование

## Бизнес-цели и задачи

### Основные бизнес-цели
- Предоставить родителям инструмент для создания персонализированного образовательного контента
- Способствовать развитию чтения и воображения у детей
- Создать безопасную платформу для генерации детского контента
- Монетизировать через premium-функции и подписки App Store

### Ключевые метрики успеха
- Количество активных пользователей (DAU/MAU)
- Количество сгенерированных сказок в день
- Время удержания пользователей в приложении
- Средняя длительность сессии
- Конверсия в premium-подписку через App Store
- App Store rating и количество reviews
- Время отклика потоковой генерации

## Функциональные требования

### 1. Система аутентификации
**Приоритет**: Высокий

**Backend компоненты**:
- Apple Sign In токен верификация
- JWT токены для сессий
- Refresh token механизм
- User management (создание, обновление, деактивация)

**iOS компоненты**:
- Нативная интеграция с AuthenticationServices
- Автоматическое сохранение токенов в Keychain
- Биометрическая аутентификация (опционально)
- Автоматический refresh токенов

**API Endpoints**:
- `POST /api/v1/auth/apple-signin/` - вход через Apple
- `POST /api/v1/auth/refresh/` - обновление токена

### 2. Генерация сказок
**Приоритет**: Высокий

**Параметры персонализации**:
- Имя главного героя (от пользователя)
- Возраст целевой аудитории (3-16 лет)
- Стиль сказки (Приключения, Фэнтези, Образовательная, Детектив)
- Язык (английский, русский, испанский, французский, немецкий)
- Основная идея сюжета (свободный текст)
- Длина сказки (1-5 уровней)
- Гендер целевого ребенка (мальчик/девочка/нейтральный)

**Backend функциональность**:
- OpenAI GPT-4o-mini интеграция
- Система промптов для безопасного детского контента
- Потоковая генерация через SSE
- Валидация и фильтрация контента
- Сохранение сгенерированных сказок в БД

**iOS функциональность**:
- Пользовательский интерфейс для выбора параметров
- Real-time отображение генерации (потоковый режим)
- Визуальные индикаторы прогресса
- Обработка ошибок и retry механизмы
- Валидация пользовательского ввода

**API Endpoints**:
- `POST /api/v1/stories/generate/` - стандартная генерация
- `POST /api/v1/stories/generate-stream/` - потоковая генерация

### 3. Управление историями
**Приоритет**: Средний

**Backend функциональность**:
- CRUD операции с историями
- Пагинация для больших списков
- Фильтрация по параметрам
- Soft delete (is_deleted flag)
- Full-text search по содержимому

**iOS функциональность**:
- Список пользовательских историй с красивым UI
- Поиск и фильтрация историй
- Детальный просмотр истории
- Удаление историй (с подтверждением)
- Pull-to-refresh и infinite scrolling

**API Endpoints**:
- `GET /api/v1/stories/` - список пользовательских сказок
- `DELETE /api/v1/stories/{story_id}/` - удаление сказки

### 4. Система подписок
**Приоритет**: Высокий

**Backend функциональность**:
- Валидация App Store receipts
- Управление статусом подписки пользователя
- Лимиты для бесплатных пользователей
- Premium функциональность

**iOS функциональность**:
- Интеграция с StoreKit 2
- Отображение статуса подписки
- Покупка и восстановление подписок
- Управление подписками через App Store

**Модель монетизации**:
- Freemium: 3 бесплатных сказки в день
- Premium: неограниченная генерация
- Premium: эксклюзивные стили и функции
- Premium: экспорт в PDF/текстовые форматы

### 5. Система безопасности контента
**Приоритет**: Высокий

**Требования к контенту**:
- 100% семейный и детский контент
- Исключение насилия, страшных сцен, смерти
- Позитивные ценности и мораль
- Образовательные элементы
- Возрастная адаптация языка и сложности

**Технические меры**:
- Многоуровневая система промптов для ИИ
- Content filtering на уровне backend
- Возможность пользовательской модерации
- Система жалоб и блокировки контента

### 6. Многоязычность и локализация
**Приоритет**: Средний

**Backend поддержка**:
- Генерация на 5 языках: английский, русский, испанский, французский, немецкий
- Культурная адаптация контента
- Language detection и validation

**iOS локализация**:
- Полная локализация интерфейса на 5 языков
- Локализованные строки (Localizable.strings)
- Адаптация под региональные особенности
- RTL поддержка (при необходимости)

### 7. Офлайн функциональность
**Приоритет**: Средний

**iOS возможности**:
- Кэширование сгенерированных сказок
- Чтение офлайн ранее созданных историй
- Graceful degradation при отсутствии сети
- Синхронизация при восстановлении соединения

## Технические требования

### Database Schema

#### Таблица Users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apple_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    subscription_status VARCHAR(50) DEFAULT 'free',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Таблица Stories
```sql
CREATE TABLE stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    hero_name VARCHAR(255),
    age INTEGER CHECK (age >= 3 AND age <= 16),
    story_style VARCHAR(50) NOT NULL,
    language VARCHAR(10) NOT NULL,
    story_idea TEXT,
    story_length INTEGER CHECK (story_length >= 1 AND story_length <= 5),
    child_gender VARCHAR(20),
    is_deleted BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### iOS Data Models
```swift
struct Story: Codable, Identifiable {
    let id: String?
    let user_id: String?
    let title: String
    let content: String
    let hero_name: String?
    let age: Int?
    let story_style: String
    let language: String
    let story_idea: String?
    let story_length: Int?
    let child_gender: String?
    let created_at: String?
}

struct StoryGenerateRequest: Codable {
    let story_name: String
    let hero_name: String
    let story_idea: String
    let story_style: String
    let language: String
    let age: Int
    let story_length: Int
    let child_gender: String
}
```

### API Спецификация

#### Аутентификация
- `POST /api/v1/auth/apple-signin/`
  - Body: `{"apple_token": "string"}`
  - Response: `{"access_token": "string", "refresh_token": "string", "user": {...}}`

- `POST /api/v1/auth/refresh/`
  - Body: `{"refresh_token": "string"}`
  - Response: `{"access_token": "string"}`

#### Управление сказками  
- `POST /api/v1/stories/generate/`
  - Body: StoryGenerateRequest
  - Response: `{"success": true, "data": {"story": Story}}`

- `POST /api/v1/stories/generate-stream/`
  - Body: StoryGenerateRequest  
  - Response: SSE stream с прогрессом генерации

- `GET /api/v1/stories/`
  - Query: `?skip=0&limit=20`
  - Response: `{"success": true, "data": {"stories": [Story], "total": number}}`

- `DELETE /api/v1/stories/{story_id}/`
  - Response: `{"success": true, "message": "Story deleted"}`

#### Служебные эндпоинты
- `GET /api/v1/health/` - проверка здоровья системы
- `GET /api/v1/legal/privacy-policy/` - политика конфиденциальности
- `GET /api/v1/legal/terms-of-use/` - условия использования

### Производительность и масштабируемость

**Backend производительность**:
- Поддержка до 10,000 одновременных пользователей
- Время отклика API < 2 секунды
- Потоковая генерация с задержкой < 500ms
- Database connection pooling
- Redis кэширование (опционально)

**iOS производительность**:
- Запуск приложения < 3 секунды
- Плавная прокрутка списков (60 FPS)
- Memory usage < 100MB в обычных условиях
- Battery-efficient networking
- Lazy loading для больших списков

## Нефункциональные требования

### Безопасность

**Backend безопасность**:
- HTTPS для всех соединений
- JWT токен validation
- SQL injection protection (SQLAlchemy ORM)
- Rate limiting и DDoS protection
- Secure headers (CORS, CSP)
- Environment variables для secrets

**iOS безопасность**:
- Keychain storage для sensitive данных
- Certificate pinning для API calls
- App Transport Security (ATS)
- Biometric authentication support
- No sensitive data в логах

### Надежность

**Backend надежность**:
- Доступность сервиса 99.5%
- Database backup и recovery
- Graceful error handling
- Circuit breaker pattern для OpenAI API
- Health checks и monitoring
- Retry механизмы с exponential backoff

**iOS надежность**:
- Crash-free rate > 99.5%
- Network error handling
- Graceful degradation
- Background task completion
- Data persistence при crashes

### UX/UI требования

**iOS Design System**:
- Dark theme по умолчанию
- Accessibility support (VoiceOver, Dynamic Type)
- Smooth animations и transitions
- Haptic feedback
- Pull-to-refresh interactions
- Loading states и progress indicators

**Пользовательский опыт**:
- Onboarding для новых пользователей
- Empty states с полезной информацией
- Error states с четкими инструкциями
- Search и filtering функциональность
- App Store rating prompts в подходящие моменты

## Мониторинг и аналитика

### Backend мониторинг
- Structured logging (JSON format)
- API response time metrics
- OpenAI token usage tracking
- Database performance metrics
- Error rate monitoring
- User activity analytics

### iOS аналитика
- App launch и session metrics
- Story generation success rate
- User retention cohorts
- Premium conversion tracking
- App Store Connect analytics
- Crash reporting (Crashlytics рекомендуется)

## Бизнес-ограничения

### Контентные ограничения
- Строгая модерация ИИ-генерируемого контента
- Соответствие App Store guidelines для детских приложений
- Исключение неприемлемых тем и языка
- Возрастная верификация контента

### Технические ограничения
- OpenAI API rate limits и cost management
- App Store размеры приложения < 200MB
- iOS памяти usage limits
- Network bandwidth optimization

### Правовые ограничения
- COPPA (Children's Online Privacy Protection Act) compliance
- GDPR compliance для европейских пользователей
- App Store Developer Program guidelines
- Privacy policy и terms of service

## План развития продукта

### Фаза 1 (MVP) - Текущая ✅
- ✅ Базовая аутентификация через Apple
- ✅ Генерация сказок с основными параметрами
- ✅ iOS приложение с core functionality
- ✅ Backend API с FastAPI
- ✅ Управление пользовательскими историями
- ✅ Многоязычность (5 языков)
- ✅ Потоковая генерация
- ✅ StoreKit integration для подписок

### Фаза 2 (Расширенный функционал) 📋
- 📋 Push notifications для completed stories
- 📋 Social sharing функциональность
- 📋 Advanced filtering и search
- 📋 Favorite stories система
- 📋 Widget для iOS home screen
- 📋 Apple Watch companion app
- 📋 Siri Shortcuts integration

### Фаза 3 (Монетизация и персонализация) 📋
- 📋 Advanced premium features
- 📋 Story collections и categories
- 📋 PDF/ePub export functionality
- 📋 Персональные рекомендации
- 📋 Family sharing для подписок
- 📋 Gamification elements (достижения, badges)

### Фаза 4 (AI и интеграция) 📋
- 📋 Image generation для сказок (DALL-E integration)
- 📋 Audio narration (Text-to-Speech)
- 📋 AR/VR reading experience
- 📋 Smart content curation
- 📋 Multi-platform expansion (Android, Web)
- 📋 Educational institution partnerships

## Риски и митигация

### Технические риски
**Риск**: Недоступность OpenAI API  
**Митигация**: Резервные ИИ-провайдеры (Anthropic Claude, Google Gemini), локальное кэширование популярных историй

**Риск**: iOS App Store rejection  
**Митигация**: Тщательное следование App Store guidelines, beta testing, legal review

**Риск**: Производительность при высокой нагрузке  
**Митигация**: Load testing, auto-scaling infrastructure, CDN для статического контента

### Бизнес-риски
**Риск**: Низкая конверсия в premium  
**Митигация**: A/B testing на pricing, улучшение onboarding, добавление value proposition

**Риск**: Неприемлемый контент от ИИ  
**Митигация**: Multi-layer content filtering, human moderation для edge cases, user reporting system

### Юридические риски
**Риск**: Нарушение детских законов о защите данных  
**Митигация**: Legal audit, privacy by design, minimal data collection, transparent privacy policy

## Заключение

Fairy Tales представляет собой инновационную экосистему для создания персонализированного детского контента, объединяющую мощный Python backend и intuitive iOS frontend. 

**Ключевые преимущества**:
- Полностью нативная iOS экосистема
- Безопасная и масштабируемая архитектура
- AI-powered персонализация контента
- Соответствие всем требованиям для детских приложений
- Готовая монетизация через App Store

**Критические факторы успеха**:
1. Качество генерируемого контента и его безопасность
2. Плавная и интуитивная пользовательская experience
3. Эффективная монетизация без ущерба для UX
4. Соответствие всем legal и privacy требованиям
5. Стабильная техническая производительность

Проект готов к запуску MVP и дальнейшему итеративному развитию на основе пользовательской обратной связи и данных аналитики.