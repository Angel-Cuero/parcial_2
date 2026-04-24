# Accidentes Tuluá + CRUD Establecimientos

Aplicación Flutter desarrollada como Parcial 2. Integra dos módulos funcionales:
1. **Dashboard estadístico** de accidentes de tránsito en Tuluá (Datos Abiertos Colombia), procesado mediante `Isolate.run()`.
2. **CRUD completo** de Establecimientos contra la API REST de VisionTIC Parqueadero.

---

## 📡 APIs Consumidas

### API 1 — Accidentes de Tránsito Tuluá (Datos Abiertos Colombia)

| Campo | Valor |
|---|---|
| **Base URL** | `https://www.datos.gov.co/resource/` |
| **Dataset ID** | `ezt8-5wyj.json` |
| **Autenticación** | No requerida (dataset público) |

**Endpoint usado:**
```
GET https://www.datos.gov.co/resource/ezt8-5wyj.json?$limit=100000
```

**Campos relevantes del JSON:**

| Campo JSON | Descripción |
|---|---|
| `clase_de_accidente` | Tipo: CHOQUE, ATROPELLO, VOLCAMIENTO, etc. |
| `gravedad_del_accidente` | CON MUERTO / CON HERIDOS / SOLO DAÑOS |
| `barrio_hecho` | Nombre del barrio donde ocurrió |
| `dia` | Día de la semana (lunes, martes, …) |
| `hora` | Hora del accidente (HH:MM:SS) |
| `area` | URBANA / RURAL |
| `clase_de_vehiculo` | MOTOCICLETA, CAMIÓN, AUTOMÓVIL, etc. |

**Ejemplo de respuesta JSON:**
```json
[
  {
    "a_o": "2023",
    "fecha": "2023-01-03T00:00:00.000",
    "dia": "martes",
    "hora": "15:40:00",
    "area": "URBANA",
    "direccion_hecho": "CARRERA 21 CALLE 32",
    "controles_de_transito": "VERTICAL",
    "barrio_hecho": "SAJONIA",
    "clase_de_accidente": "CHOQUE",
    "clase_de_servicio": "PARTICULAR",
    "gravedad_del_accidente": "CON HERIDOS",
    "clase_de_vehiculo": "MOTOCICLETA",
    "cordenada_geografica_": {
      "type": "Point",
      "coordinates": [-76.201795, 4.080615]
    }
  }
]
```

---

### API 2 — Establecimientos (VisionTIC Parqueadero)

| Campo | Valor |
|---|---|
| **Base URL** | `https://parking.visiontic.com.co/api` |
| **Documentación** | `https://parking.visiontic.com.co/api/documentation` |
| **Autenticación** | No requerida (API pública) |

**Endpoints consumidos:**

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/establecimientos` | Listar todos |
| `GET` | `/establecimientos/{id}` | Ver uno |
| `POST` | `/establecimientos` | Crear (multipart/form-data) |
| `POST` | `/establecimiento-update/{id}` | Editar (con `_method=PUT`) |
| `DELETE` | `/establecimientos/{id}` | Eliminar |

> **Nota sobre method spoofing:** Laravel no acepta `PUT` con multipart, por eso se envía `POST` con el campo adicional `_method=PUT` en el form-data.

**Campos del establecimiento:**

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | int | Identificador único |
| `nombre` | string | Nombre del establecimiento |
| `nit` | string | NIT del establecimiento |
| `direccion` | string | Dirección física |
| `telefono` | string | Número de contacto |
| `logo` | file/string | Imagen del logo (archivo en POST, URL en GET) |

**Ejemplo de respuesta JSON:**
```json
{
  "data": [
    {
      "id": 1,
      "nombre": "Parqueadero Central",
      "nit": "900123456-7",
      "direccion": "Carrera 10 # 20-30",
      "telefono": "3001234567",
      "logo": "https://parking.visiontic.com.co/storage/logos/logo1.png"
    }
  ]
}
```

---

## ⚡ Future/Async/Await vs Isolate — ¿Cuándo usar cada uno?

### `Future` / `async` / `await`
- Para operaciones de **I/O asíncronas** (peticiones HTTP, lectura de archivos, acceso a base de datos).
- El hilo principal cede el control mientras espera, pero **no ejecuta código en paralelo**.
- Apropiado para: llamadas a APIs, animaciones, timers.
- **Ejemplo:** Todas las llamadas a Dio en los servicios usan `async/await`.

### `Isolate` (o `compute`)
- Para operaciones **intensivas de CPU** que bloquearían el hilo principal.
- Ejecuta código en un hilo separado con **memoria aislada** (sin acceso compartido).
- Apropiado para: parseo de JSON masivo, cálculos estadísticos, compresión, cifrado.

### ¿Por qué se eligió Isolate para las estadísticas?

El endpoint `?$limit=100000` puede retornar **miles de registros JSON**. Procesar ese volumen (iterar, contar, ordenar) en el hilo principal causaría **jank visible** (frames perdidos, UI congelada). Con `Isolate.run()`:

1. La lista cruda de JSON se transfiere al Isolate.
2. El Isolate calcula las 4 estadísticas fuera del hilo principal.
3. Retorna solo el resultado (un `AccidentesStats` ligero).
4. La UI permanece fluida durante todo el proceso.

```dart
// Uso en la app:
final raw = await _service.fetchAllRaw();       // async/await: I/O
final stats = await calcularEstadisticas(raw);  // Isolate.run(): CPU
```

---

## 🏗 Arquitectura y Estructura del Proyecto

```
lib/
├── main.dart                          # Entrada: dotenv + GoRouter + MaterialApp.router
├── config/
│   └── router.dart                    # GoRouter con 6 rutas
├── core/
│   └── theme/
│       └── app_theme.dart             # Tema Material3 oscuro (glassmorphism)
└── features/
    ├── dashboard/
    │   └── views/
    │       └── dashboard_screen.dart  # Home con cards + resumen (Skeletonizer)
    ├── accidentes/
    │   ├── models/
    │   │   └── accidente.dart         # Data class del JSON
    │   ├── services/
    │   │   └── accidentes_service.dart # Dio → fetchAllRaw()
    │   ├── isolates/
    │   │   └── accidentes_isolate.dart # Isolate.run() → AccidentesStats
    │   └── views/
    │       └── estadisticas_screen.dart # 4 gráficas fl_chart
    └── establecimientos/
        ├── models/
        │   └── establecimiento.dart   # Data class
        ├── services/
        │   └── establecimientos_service.dart # CRUD con Dio multipart
        └── views/
            ├── establecimientos_list_screen.dart  # ListView + Skeletonizer
            ├── establecimiento_detail_screen.dart # Detalle + editar/eliminar
            └── establecimiento_form_screen.dart   # Crear/Editar + ImagePicker
```

### Capas de la arquitectura

```
Views (UI)  →  Services (HTTP / Dio)  →  Models (Data Classes)
                     ↓
              Isolates (CPU-bound)
```

- **Models:** Plain Dart classes con `fromJson` / `toJson`.
- **Services:** Encapsulan toda la lógica HTTP (Dio). Los widgets no conocen Dio.
- **Isolates:** Función pura que recibe y retorna datos. Sin acceso a UI.
- **Views:** Consumen services directamente (sin BLoC/Provider por simplicidad del parcial). Manejan estado con `setState`.

---

## 🗺 Rutas GoRouter

| Nombre | Ruta | Widget | Parámetros |
|---|---|---|---|
| `dashboard` | `/` | `DashboardScreen` | — |
| `accidentes` | `/accidentes` | `EstadisticasScreen` | — |
| `establecimientos` | `/establecimientos` | `EstablecimientosListScreen` | — |
| `establecimiento_nuevo` | `/establecimientos/nuevo` | `EstablecimientoFormScreen` | — |
| `establecimiento_detalle` | `/establecimientos/:id` | `EstablecimientoDetailScreen` | `id` (pathParam) |
| `establecimiento_editar` | `/establecimientos/:id/editar` | `EstablecimientoFormScreen` | `id` (pathParam) + `Establecimiento` (extra) |

**Navegación entre pantallas:**
```dart
// Dashboard → Estadísticas
context.push('/accidentes');

// Dashboard → Lista establecimientos
context.push('/establecimientos');

// Lista → Detalle
context.push('/establecimientos/$id');

// Detalle → Editar (con datos precargados via extra)
context.push('/establecimientos/$id/editar', extra: establecimiento);

// Cualquier pantalla → Nueva
context.push('/establecimientos/nuevo');
```

---

## 📦 Paquetes implementados

| Paquete | Versión | Uso |
|---|---|---|
| `dio` | ^5.7.0 | Cliente HTTP para ambas APIs |
| `go_router` | ^14.6.3 | Navegación declarativa |
| `flutter_dotenv` | ^5.2.1 | Variables de entorno (.env) |
| `fl_chart` | ^0.69.0 | PieChart y BarChart |
| `skeletonizer` | ^1.4.2 | Efecto skeleton durante carga |
| `image_picker` | ^1.1.2 | Selector de logo desde galería/cámara |

---

## 🖼 Capturas de pantalla

> *Capturas incluidas en el PDF de entrega.*

- Dashboard (home con cards y resumen)
- Estadísticas — 4 gráficas (PieChart x2, BarChart x2)
- Listado de establecimientos (skeleton + datos cargados)
- Formulario crear establecimiento
- Formulario editar establecimiento
- Eliminación con confirmación

---

## 🔧 Variables de entorno (.env)

```env
ACCIDENTES_BASE_URL=https://www.datos.gov.co/resource/
PARQUEADERO_BASE_URL=https://parking.visiontic.com.co/api
```

---

## 🚀 Cómo ejecutar

```bash
flutter pub get
flutter run
```

Requiere Flutter 3.x / Dart 2.19+ para `Isolate.run()`.
