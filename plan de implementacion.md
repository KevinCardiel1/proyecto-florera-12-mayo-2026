# 🌸 Plan de Implementación Definitivo — Florería Ajolote (Firebase)
**Frontend:** Flutter (Android / Web / Windows) | **Backend:** Firebase (Firestore + Auth + Cloud Functions + Storage)  
**Estado:** Riverpod | **Arquitectura:** Clean + Feature-First + Serverless | **UI/UX:** Floral Soft Rosa Dominante + Mascota Ajolote  
**Estándares:** SOLID, DRY, Document-Relational Design, CI/CD, WCAG AA, Responsive Multiplataforma, Ecosistema 100% Dart/Flutter + Firebase

---

## 📐 Fase 0: Gobernanza, Configuración del Entorno & Estándares de Desarrollo

### 1. Estructura de Repositorios & Control de Versiones
- Crear un **repositorio único** con estructura clara:
  - `apps/frontend` (Aplicación Flutter multiplataforma)
  - `functions/` (Cloud Functions para lógica serverless en Dart/TypeScript)
  - `firestore_rules/` (Reglas de seguridad versionadas)
  - `docs/` (ADR, flujos, glosario floral/administrativo)
- Estrategia de ramas: `main`, `develop`, `feature/*`, `hotfix/*`, `release/*`
- Políticas de PR: revisión de 2 pares, checklist de calidad, CI obligatorio, squash merge
- Convención de commits: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `style`, `perf`
- Ganchos pre-commit: `dart analyze`, `flutter format`, verificación de secretos, validación de reglas Firestore con `@firebase/rules-unit-testing`

### 2. Gestión de Entornos & Configuración Segura
- Configuración multiplataforma con `flutterfire configure` → genera `firebase_options.dart` por entorno
- Variables de entorno: `.env.development`, `.env.staging`, `.env.production` para flags, URLs, límites
- Separación estricta: claves de proyecto Firebase, configuración de App Check, flags de features
- Gestión de secretos en CI/CD (GitHub Secrets, Firebase CLI service accounts)
- Lockfiles estrictos (`pubspec.lock`), actualizaciones controladas con Renovate

### 3. Calidad de Código & Documentación Técnica
- Análisis estático: `dart analyze`, `flutter analyze`, reglas de complejidad ciclomática
- Tipado estricto: prohibido `dynamic` innecesario, uso de `freezed` + `json_serializable` para modelos inmutables
- Documentación: ADRs, flujos de negocio, glosario floral/administrativo, esquema de colecciones Firestore
- Métricas objetivo: cobertura ≥ 80%, 0 warnings, 0 vulnerabilidades críticas, reglas Firestore con pruebas unitarias

---

## 🗄️ Fase 1: Diseño de Base de Datos Firestore & Estrategia de Datos

### 1. Modelado Document-Relacional & Desnormalización Controlada
- Estructura basada en 16 colecciones principales, optimizada para lecturas frecuentes:
  - `/users/{uid}` → perfiles de acceso, rol, activo, último_login
  - `/clients/{clientId}` → datos personales, dirección, teléfono, notas
  - `/categories/{categoryId}` → nombre, descripción, icono, color_hex, orden
  - `/products/{productId}` → sku, nombre, precio, stock, activo, fecha_creacion
  - `/products/{productId}/images/{imageId}` → subcolección de imágenes (url, principal, orden)
  - `/inventory/{batchId}` → id_producto, id_proveedor, cantidad, costo, fecha_entrada, vencimiento, stock_restante
  - `/orders/{orderId}` → id_cliente, fecha, estado, subtotal, impuestos, total, notas
  - `/orders/{orderId}/items/{itemId}` → subcolección de detalle (cantidad, precio_unitario, personalizacion)
  - `/payments/{paymentId}` → id_pedido, monto, metodo, referencia, fecha, estado
  - `/shipping/{shippingId}` → id_pedido, id_empleado, direccion, fechas, estado, costo, coordenadas
  - `/events/{eventId}` → id_cliente, tipo, fecha, presupuesto, ubicacion, descripcion
  - `/occasions/{occasionId}` → id_cliente, descripcion, fecha, recordatorio_activo
  - `/coupons/{couponId}` → codigo, descuento, tipo, fechas, usos_max, activo
  - `/audit_logs/{logId}` → usuario, accion, coleccion, documento, timestamp, ip
  - `/config/settings` → documento único para umbrales, moneda, impuestos, notificaciones

### 2. Convenciones, Integridad & Índices
- Nomenclatura: `snake_case`, IDs generados por Firestore o UUIDv4
- Relaciones: `1:N` y `N:M` mediante referencias (`DocumentReference`) o subcolecciones
- Índices compuestos: configurados vía `firebase.json` y consola para `estado + fecha_pedido`, `categoria + activo`, `stock < umbral + activo`
- Validación en reglas de seguridad: tipos de datos, rangos monetarios, fechas coherentes, estados permitidos
- Offline-first: habilitado por defecto con caché persistente ilimitada y sincronización automática al recuperar conexión

### 3. Automatización, Migraciones & Mantenimiento
- Migraciones de esquema: versionado de documentos + Cloud Functions de migración puntual
- Seeders: scripts en Dart/Node para poblar datos base (roles, categorías, productos demo, pedidos simulados)
- Triggers de auditoría: Cloud Function `onWrite` en colecciones críticas → escribe en `/audit_logs`
- Limpieza programada: Cloud Scheduler + Function para expirar cupones, archivar pedidos antiguos, limpiar logs > 2 años
- Backup: exportaciones automatizadas diarias a Cloud Storage con retención 30 días

---

## ⚙️ Fase 2: Arquitectura Backend Serverless (Firebase Services)

### 1. Estructura de Servicios & Responsabilidades
```
/firebase
  ├── auth/                 # Firebase Auth (email/password, roles en claims)
  ├── firestore/            # Colecciones, subcolecciones, índices, reglas
  ├── functions/            # Lógica serverless (auditoría, validación stock, reportes, notificaciones)
  ├── storage/              # Imágenes de productos, comprobantes, assets dinámicos
  ├── hosting/              # Configuración de despliegue web, headers, PWA
  └── emulator/             # Suite local para desarrollo sin afectar producción
```
- Separación clara: Reglas de seguridad (autorización), Cloud Functions (lógica compleja/transaccional), Firestore (almacenamiento)
- Claims personalizados en Auth para `role: admin | vendedor | repartidor`
- Contratos de respuesta: `{ success, data, meta?, errors? }` estandarizados en funciones y frontend

### 2. Autenticación, Autorización & Seguridad
- Firebase Auth maneja sesiones, tokens JWT automáticos y refresh integrado
- Custom claims asignados vía Cloud Functions para control granular de permisos
- Protección avanzada: Firebase App Check (reCAPTCHA/Play Integrity), rate limiting implícito por quotas
- Sanitización y validación: `@firebase/rules-unit-testing` + validación en Cloud Functions con `zod`/`checked_yaml`

### 3. API Serverless & Optimización
- Endpoints indirectos: interacción directa con Firestore desde Flutter + Cloud Functions para operaciones protegidas
- Paginación/filtrado: `limit()`, `startAfter()`, `where()` con índices compuestos obligatorios
- Transacciones ACID: `runTransaction()` para stock, pagos y cambios de estado críticos
- Caché inteligente: `get()` con `GetOptions(source: Source.cache)` para lecturas frecuentes
- Logging estructurado: `functions.logger` con trazabilidad por `correlationId`

---

## 📱 Fase 3: Arquitectura Flutter Multiplataforma & Capas de Abstracción

### 1. Estructura Feature-First + Clean
```
/apps/frontend
  ├── core/            # firebase_init, constants, utils, errors, theme, firebase_rules
  ├── features/        # auth, dashboard, clients, products, inventory, orders, payments, shipping, events, reports
  ├── shared/          # widgets, layout, navigation, theme, axolotl_mascot
  ├── di/              # Riverpod providers, repository injection
  └── main.dart        # App entry, Firebase init, ProviderScope, error zone
```
- Capas unidireccionales: UI → Presentation → Domain → Data (Firestore/Functions)
- Repositorios que abstraen `FirebaseFirestore.instance` y `FirebaseFunctions.instance`
- Uso de `packages/shared` para modelos, validadores y constantes comunes

### 2. Gestión de Estado con Riverpod + Firebase
- `@riverpod` providers escuchan `collection().snapshots()` y `doc().snapshots()`
- `AsyncValue.guard` maneja loading/success/error uniformemente
- Invalidación selectiva tras `set()`, `update()`, `delete()`, `runTransaction()`
- Optimistic updates con rollback automático si falla la escritura
- Persistencia local: Firestore offline cache + `shared_preferences`/`hive` para preferencias UI

### 3. Navegación, Routing & Adaptabilidad
- `go_router` declarativo con guards por `FirebaseAuth.instance.user` y custom claims
- Redirección automática a `/login` si no autenticado o token expirado
- Navegación adaptativa: sidebar fija (Web/Windows), bottom nav/drawer (Android)
- Deep links para compartir pedidos/productos con validación de permisos
- Renderers web: CanvasKit (desktop), HTML (mobile PWA)

### 4. Capa de Red & Manejo de Errores
- `cloud_firestore` + `firebase_functions` como capa de datos
- Interceptor de errores mapea `FirebaseException` → estados UI (vacío, error, reintento)
- Cola offline opcional con sincronización automática al recuperar conexión
- Logging silencioso en producción, detallado en desarrollo

---

## 🌷 Fase 4: Sistema de Diseño UI/UX "Floral Soft" & Integración del Ajolote

### 1. Filosofía Visual & Paleta de Colores (Rosa Predominante)
- **Principio:** Suavidad orgánica, frescura natural, elegancia contemporánea, ternura profesional
- **Rosa Dominante:** `#FFB7C5` (primario), `#FFD6E0` (secundario), `#FFF0F5` (fondos), `#E87A9B` (textos/accentos)
- **Apoyo Sutil:** `#E6D5F0` (lavanda), `#F3E9F7` (lila), `#D6EAF8` (azul cielo), `#F0F7FF` (azul perla)
- **Funcionales:** Éxito `#A8E6CF`, Advertencia `#FFD3B6`, Error `#FFAAA5`, Texto `#5A4A66` / `#8B7A99`
- Modo oscuro opcional: `#2D2436` fondo, `#3D324E` superficie, `#F5E6F7` texto

### 2. Tipografía, Espaciado & Formas Florales
- Familia: `Quicksand` (400/600/700), acento `Dancing Script`
- Escala: H1 32px, H2 24px, H3 20px, Body 16px, Small 14px, Caption 12px
- Espaciado: escala 4px (4–48)
- Bordes: 16px inputs/cards, 20px botones, 24px modales
- Sombras florales sutiles, bordes superiores decorativos rosa→lavanda

### 3. Biblioteca de Componentes Florales Reutilizables
- Botones, inputs, cards, tablas, navegación, feedback (toasts, modales, loaders)
- Todos con hover suaves, transiciones 200-400ms, bordes redondeados, opacidades controladas
- Validación de contraste WCAG AA en todas las combinaciones

### 4. Sistema de Mascota: Ajolote Guía
- Estados: `idle`, `empty`, `success`, `warning`, `error`
- Animaciones Lottie/SVG: 300-600ms, easing `ease-out`, loop suave
- Widget contenedor que recibe estado, renderiza ilustración, gestiona accesibilidad
- Integración en loading, vacíos, confirmaciones, errores y onboarding

### 5. Patrones, Texturas & Fondos Decorativos
- Opacidad ≤10% para patrones florales
- Gradientes radiales suaves en headers/hero
- Fondos alternos rosa/lila para separación visual
- Validación de contraste y rendimiento en todas las plataformas

---

## 🧩 Fase 5: Desarrollo Detallado por Módulos (Flujos, Estados, Validaciones)

### 1. Auth & Sesión
- Login email/password, verificación opcional, recuperación de cuenta
- Custom claims asignados por admin → `role` definido en Cloud Function
- Guards por rol, UI floral con patrón de pétalos, ajolote guía, feedback cálido

### 2. Dashboard Administrativo
- KPIs en tiempo real vía `FirebaseFirestore.instance.collection().snapshots()`
- Gráficos interactivos florales, actividad reciente, grids responsivos
- Agregados optimizados con contadores dedicados o Cloud Functions periódicas

### 3. Clientes & Productos
- CRUD con búsqueda full-text (algolia opcional) o filtros locales
- Galería con zoom suave, SKU único, categorías, precio/stock, disponibilidad
- Estados visuales: activo/inactivo, bajo stock (amarillo suave), agotado (coral suave)

### 4. Inventario & Lotes
- Entrada por lote, FIFO/FEFO, alertas configurables, ajustes con auditoría
- Cards con borde por estado, ajolote revisando inventario en vista vacía
- Transacciones atómicas para evitar inconsistencias de stock

### 5. Pedidos & Detalle
- Máquina de estados validada en Cloud Functions
- Subcolección `items` con precios congelados al confirmar
- Timeline floral que se actualiza en tiempo real con `snapshots()`

### 6. Pagos & Envíos
- Métodos, conciliación, asignación repartidor, coordenadas GPS
- Confirmación con ajolote celebrando, comprobantes en Firebase Storage

### 7. Eventos & Ocasiones
- Calendario, presupuesto, recordatorios automáticos vía Cloud Scheduler
- Vinculación con pedidos existentes, plantillas de arreglos por tipo

---

## 📊 Fase 6: Reportes, Auditoría, Cupones & Funcionalidades Avanzadas

### 1. Reportes & Exportación
- Filtros avanzados, métricas precalculadas, generación asíncrona en Cloud Functions
- PDF/Excel con branding floral, descarga directa o envío por correo
- Historial de reportes almacenado en `/reports/{reportId}`

### 2. Auditoría & Cumplimiento
- Registro inmutable en `/audit_logs` vía triggers `onWrite`
- Visualización filtrada, retención configurable, exportación segura
- Alertas de anomalías: múltiples fallos, accesos fuera de horario, cambios masivos

### 3. Motor de Cupones
- Tipos, reglas, validación en tiempo real con `runTransaction()`
- UI con borde que cambia a verde éxito, ajolote sonriente al aplicar

### 4. Optimización & Caché
- Stale-while-revalidate para catálogo, WebP, lazy loading
- Virtualización de listas largas, memoización de cálculos pesados
- Reducción de reads con `cache` y agregados dedicados

---

## 🧪 Fase 7: Estrategia de Pruebas, Calidad & Pipeline CI/CD

### 1. Pirámide de Pruebas
- Unitarias (70%): lógica, mapeo, validadores, providers Riverpod
- Widgets (20%): componentes florales, estados, responsive, accesibilidad
- Integración (10%): flujos completos, `firebase_emulator_suite`, transacciones de pedidos

### 2. Herramientas & Métricas
- Frontend: `flutter_test`, `mocktail`, `integration_test`
- Firebase: `@firebase/rules-unit-testing`, `firebase emulators:exec`
- Cobertura ≥ 80%, branches críticos 100%, umbrales de bloqueo en PR

### 3. Pipeline CI/CD
- Triggers: push a `develop`, PR a `main`, tags
- Etapas: `dart analyze` → `flutter analyze` → `flutter test` → `firebase emulators:exec` → builds multiplataforma → deploy staging (auto) / prod (manual)
- Versionado semántico, changelog auto, rollback rápido

---

## 🚀 Fase 8: Despliegue, Monitoreo, Mantenimiento & Escalabilidad

### 1. Infraestructura & Entornos
- **Backend:** Firebase Auth, Firestore, Cloud Functions, Storage, App Check
- **Frontend Web:** Firebase Hosting + CDN + PWA con ícono de ajolote
- **Windows:** Instalador firmado, actualizaciones guiadas, soporte DPI alto
- **Android:** Firebase App Distribution → Play Console, App Bundle optimizado
- **Escalabilidad:** Índices automáticos, quotas controladas, Cloud Functions escalado horizontal

### 2. Monitoreo & Observabilidad
- Frontend: Crashlytics, Performance Monitoring, logs de red
- Backend: Cloud Functions logs, Firestore usage dashboard, App Check metrics
- Alertas: error rate, latency, read/write quotas, storage limits
- Runbooks: procedimientos documentados, escalamiento, rollback, migración de reglas

### 3. Mantenimiento & Evolución
- Updates trimestrales Flutter, mensuales Firebase SDK, parches críticos 24h
- Validación de reglas Firestore con cada cambio de esquema
- Feedback loop, analytics, priorización por impacto
- Escalabilidad futura: extensiones de Firebase, multi-tenant, data warehouse externo

---

## 📦 Anexo A: Dependencias Clave (Ecosistema Dart/Flutter + Firebase)

| Categoría | Paquete / Librería | Propósito Floral & Técnico |
|-----------|-------------------|---------------------------|
| **Firebase Core** | `firebase_core` | Inicialización obligatoria, multiplataforma, `firebase_options.dart` |
| **Autenticación** | `firebase_auth` | Login, sesiones, claims personalizados, refresh automático |
| **Base de Datos** | `cloud_firestore` | Colecciones, streams, transacciones, offline cache, reglas |
| **Funciones** | `cloud_functions` | Lógica serverless, auditoría, validación stock, reportes async |
| **Almacenamiento** | `firebase_storage` | Imágenes productos, comprobantes, backups, CDN integrado |
| **Mensajería** | `firebase_messaging` | Push updates pedidos, recordatorios, alertas stock |
| **Seguridad** | `firebase_app_check` | Protección contra clientes no autorizados, quotas controladas |
| **Analytics/Crash** | `firebase_analytics`, `firebase_crashlytics` | Métricas uso, crashes, performance monitoring |
| **Estado** | `flutter_riverpod` + `riverpod_annotation` | Streams → providers reactivos, loading/error unificados |
| **Navegación** | `go_router` | Guards por rol/auth, deep links, adaptativo |
| **Tipografía** | `google_fonts` | Carga `Quicksand` y `Dancing Script` |
| **Animaciones** | `lottie`, `flutter_animate` | Ajolote mascot, transiciones suaves, microinteracciones |
| **Imágenes** | `cached_network_image`, `flutter_svg` | Galería productos, ilustraciones vectoriales, patrones |
| **Formularios** | `formz`, `flutter_form_builder` | Validación estructurada, inputs florales, feedback |
| **Gráficos** | `fl_chart` o `syncfusion_flutter_charts` | KPIs florales, tooltips elegantes |
| **Tablas** | `data_table_2` o `syncfusion_flutter_datagrid` | Datagrids admin, paginación, hover floral |
| **Reportes** | `pdf`, `excel` | Generación documentos branding floral |
| **Caché Local** | `shared_preferences`, `hive` | Tokens, preferencias, estado offline ligero |
| **Testing** | `test`, `flutter_test`, `mocktail`, `firebase_emulator_suite` | Pruebas unitarias, widget, integración, cobertura |

---

## ✅ Anexo B: Criterios de Aceptación, Gestión de Riesgos & Roadmap

### 🎯 Criterios de Aceptación por Fase
| Fase | Entregable | Validación |
|------|------------|------------|
| 0 | Repos, hooks, docs, `firebase_options` | 0 warnings, CI verde, ADRs aprobados |
| 1 | Colecciones, índices, reglas, seeds | Esquema validado, offline activo, backups probados |
| 2 | Auth, Functions, Storage, App Check | Auth/roles funcionales, tests ≥ 85%, reglas seguras |
| 3 | Flutter base, routing, providers | Streams activos, guards, fallback offline |
| 4 | Design system floral, mascot system | Paleta exacta, responsive, ajolote en 5+ estados |
| 5 | Módulos CRUD, flujos | Transacciones atómicas, auditoría, sync real-time |
| 6 | Reportes, cupones, auditoría | PDF/Excel correctos, triggers activos, logs inmutables |
| 7 | Pruebas, CI, cobertura | Emuladores pasando, pipeline estable, métricas OK |
| 8 | Deploy, monitoreo, docs | Web/Android/Windows activos, alertas, runbooks listos |

### ⚠️ Gestión de Riesgos & Mitigación
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Exceso de reads/writes por mal diseño | Media | Alto | Índices compuestos, agregados dedicados, paginación estricta, caché offline |
| Reglas de seguridad inseguras | Baja | Crítico | Pruebas unitarias de reglas, revisión en PR, `security_rules` CI |
| Funciones con timeout/falta de escalado | Baja | Medio | Lógica asíncrona, límites configurados, monitoreo de quotas, retries |
| Saturación visual floral | Media | Medio | Opacidad ≤10%, validación WCAG, pruebas usabilidad |
| Cambios de requisitos tardíos | Alta | Medio | Scope definido, sprints entregables, backlog priorizado |

### 📅 Roadmap Sugerido (14 Semanas)
- **Semanas 1-2:** Fase 0 + 1 (Config Firebase, esquema Firestore, reglas, seeds, emuladores)
- **Semanas 3-4:** Fase 2 (Auth, Functions base, Storage, App Check, validación seguridad)
- **Semanas 5-6:** Fase 3 + 4 (Flutter base, tema floral, routing, providers, ajolote)
- **Semanas 7-9:** Fase 5 (Auth → Dashboard → Clientes → Productos → Inventario)
- **Semanas 10-11:** Fase 5 (Pedidos → Pagos → Envíos → Eventos → Cupones)
- **Semanas 12-13:** Fase 6 + 7 (Reportes, auditoría, pruebas emuladores, CI/CD)
- **Semana 14:** Fase 8 (Deploy staging, ajustes, producción, monitoreo)

---

## 📌 Próximos Pasos Inmediatos (Procedimiento de Inicio)

1. **Validar identidad visual** con stakeholders: aprobar paleta, tipografía, estilo del ajolote, reglas de aplicación floral
2. **Crear kit de diseño en Figma**: componentes florales, patrones, ilustraciones del ajolote, prototipos interactivos
3. **Crear proyecto Firebase** en consola, habilitar Auth, Firestore, Storage, Functions, App Check
4. **Ejecutar `flutterfire configure`** → generar `firebase_options.dart` por plataforma
5. **Configurar Firebase Emulator Suite** local para desarrollo sin cuotas ni datos reales
6. **Escribir Firestore Security Rules** basadas en roles y validación de campos
7. **Inicializar Flutter**: tema global floral, routing, estructura carpetas, provider base con streams
8. **Integrar ajolote mascot system**: widget contenedor estados, animaciones Lottie/SVG, conexión flujos carga/vacío/éxito
9. **Desarrollar módulo Auth + guards**: login/register, claims, redirección por rol, feedback floral
10. **Ejecutar pruebas con emuladores**, validar flujos completos, preparar pipeline de despliegue

---
> 🌸 *"Este plan garantiza un sistema administrativo robusto, escalable y profesional, potenciado por la agilidad serverless de Firebase. La estética floral suave, el rosa predominante y el ajolote guía crean una experiencia cálida y moderna, mientras Firestore, Cloud Functions y las reglas de seguridad mantienen el rendimiento, la coherencia transaccional y la mantenibilidad empresarial. Todo en un solo ecosistema, con la potencia de Firebase y la elegancia de Flutter."*
---

Prompt: 

Quiero que actúes como un desarrollador de software especializado en Flutter, Node.js, Express y MySQL, y que generes un sistema administrativo completo y profesional llamado “Florería Ajolote”. El proyecto debe funcionar en Android, Web y Windows usando Flutter con Riverpod, GoRouter y Dio, mientras que el backend debe usar Node.js + Express con JWT, MySQL, Redis y arquitectura modular profesional. Quiero una arquitectura limpia basada en Clean Architecture, Feature First, Repository Pattern y principios SOLID, separando correctamente frontend y backend en capas organizadas y mantenibles. El sistema debe incluir módulos completos para autenticación, dashboard, clientes, productos, inventario, pedidos, pagos, envíos, eventos, cupones, reportes y auditoría, con CRUDs profesionales, validaciones, filtros, paginación y manejo correcto de errores. La base de datos debe estar normalizada en 3FN, con relaciones bien definidas, migraciones, seeds, índices y auditoría automática. Implementa seguridad empresarial con JWT Access y Refresh Token, rate limiting, Helmet, CORS, validaciones con Zod y consultas parametrizadas.

El diseño UI/UX debe tener una estética moderna llamada “Floral Soft”, usando colores rosas suaves, lavandas y tonos pastel, con tipografías elegantes, componentes modernos, cards, dashboards, tablas administrativas y animaciones suaves. 

También, la mascota es un tipo ajolote integrada en la interfaz. La app debe ser completamente responsive para desktop y móvil, usando sidebar en escritorio y bottom navigation en móvil. Genera estructura profesional de carpetas, documentación, pruebas unitarias, integración CI/CD con Docker y GitHub Actions, además de código limpio, escalable, desacoplado y listo para producción. 

Antes de generar código, explica primero la arquitectura, luego la estructura del proyecto, el modelado de base de datos, backend, frontend, UI/UX, seguridad, testing y finalmente la implementación completa.


Como debe de ser la Estetica:

Quiero que la estetica sea suave, moderno pero bonito y muy floral, muchos tonos rosados, con morado y azules muy bajitos, algo agradable a la vista, floral, que se note que es de una floreria, el nombre es "Floreria Ajolote" y como es un ajolote la mascota de la pagina, quiero que el color rosa sea el predominante en la pagina 

NO debe verse:
* escolar
* básico
* amateur
* saturado de colores
* fuera de la estetica ya establecida
  
El sistema debe permitir:
* Gestión de clientes
* Gestión de productos florales
* Gestión de categorías
* Gestión de proveedores
* Gestión de lotes e inventario
* Gestión de pedidos
* Gestión de pagos
* Gestión de envíos
* Gestión de eventos
* Gestión de ocasiones especiales
* Personalización de arreglos florales
* Panel administrativo moderno
* Reportes
* Estadísticas
* Control de stock
* Historial de pedidos
* Gestión de estados
* Seguimiento de entregas 


Dame un plan de implementacion definitivo con todo ya incluido porfavor, todo lo que te pedi anteriormente, respetando la estetica ya dicha porfavor 


