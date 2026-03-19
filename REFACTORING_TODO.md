# 🔨 Refactorizaciones Pendientes

## 📁 Organización de Repositorios

### ⚠️ Problema Actual

Actualmente, todos los endpoints del backend están en `ApiService` ([api_service.dart](lib/data/services/api_service.dart)), lo cual no es escalable y viola el principio de responsabilidad única.

### ✅ Solución Recomendada

Crear repositorios específicos por dominio que usen `ApiService` internamente:

```
lib/data/
├── services/
│   └── api_service.dart          # Solo métodos HTTP genéricos (GET, POST, PUT, DELETE)
│
└── repositories/
    ├── event_repository.dart      # getEventos(), getEventById(), createEvent(), etc.
    ├── professor_repository.dart  # getProfessors(), getProfessorById(), etc.
    ├── building_repository.dart   # getBuildings(), getBuildingById(), etc.
    ├── user_repository.dart       # getProfile(), updateProfile(), etc.
    └── auth_repository.dart       # login(), register(), logout(), refreshToken()
```

### 📝 Ejemplo de Refactorización

**Antes (actual):**

```dart
// api_service.dart
class ApiService {
  Future<List<Evento>> getEventos() async { ... }
  Future<List<Professor>> getProfessors() async { ... }
  Future<List<Building>> getBuildings() async { ... }
}
```

**Después (recomendado):**

```dart
// event_repository.dart
class EventRepository {
  final ApiService _api = ApiService();

  Future<List<Evento>> getEventos() async {
    final response = await _api.get('/eventos');
    return (response.data as List).map((json) => Evento.fromJson(json)).toList();
  }

  Future<Evento> getEventById(int id) async {
    final response = await _api.get('/eventos/$id');
    return Evento.fromJson(response.data);
  }

  Future<void> registerToEvent(int eventId, String userId) async {
    await _api.post('/eventos/$eventId/register', data: {'user_id': userId});
  }
}
```

### 🎯 Beneficios

- ✅ Código más organizado y mantenible
- ✅ Más fácil de testear (mock repositories en lugar de API)
- ✅ Separa responsabilidades (ApiService solo HTTP, repositories lógica de negocio)
- ✅ Escalable para proyectos grandes

### 📌 Estado Actual

- ⏳ **Pendiente**: Por ahora, `getEventos()` está en `ApiService` para hacerlo funcional rápido
- 📅 **Prioridad**: Media - refactorizar cuando se agreguen más endpoints
- 🔖 **Archivos marcados**: Busca `TODO: Refactorizar` en el código

---

## 🗂️ Otras Refactorizaciones Pendientes

### 1. Modelos de datos

- [ ] Crear `Professor` model en `lib/data/models/professor.dart`
- [ ] Crear `Building` model en `lib/data/models/building.dart`
- [ ] Crear `User` model completo (actualmente solo se usa Map)

### 2. Manejo de estado

- [ ] Migrar AuthController a usar repository en lugar de ApiService directamente
- [ ] Considerar usar GetX para estado de eventos (EventController)

### 3. Configuración

- [ ] Mover URLs base a archivo de environment (.env)
- [ ] Configurar diferentes baseURLs por ambiente (dev, staging, prod)

---

_Última actualización: 4 marzo 2026_
