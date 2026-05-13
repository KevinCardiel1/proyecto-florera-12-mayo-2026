# 🌸 Plan de Implementación Definitivo — Florería Ajolote

**Frontend:** Flutter (Android / Web / Windows) | **Backend:** Node.js + Express + JWT | **Base de Datos:** MySQL  
**Estado:** Riverpod | **Arquitectura:** Clean + Feature-First + Repository Pattern | **UI/UX:** Floral Soft Rosa Dominante + Mascota Ajolote  
**Estándares:** SOLID, DRY, 3NF, RESTful, CI/CD, WCAG AA, Responsive Multiplataforma

---

## 📐 Fase 0: Gobernanza, Configuración del Entorno & Estándares de Desarrollo

### 1. Estructura de Repositorios & Control de Versiones
- Crear dos repositorios independientes: `floreria-ajolote-backend` y `floreria-ajolote-frontend`
- Definir estrategia de ramas: `main` (producción), `develop` (integración), `feature/*`, `hotfix/*`, `release/*`
- Configurar políticas de Pull Request: revisión mínima de 2 pares, checklist de calidad, CI obligatorio, squash merge
- Implementar convención de commits: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `style`, `perf`
- Establecer ganchos pre-commit: validación de linting, formateo automático, verificación de secretos expuestos

### 2. Gestión de Entornos & Configuración Segura
- Definir archivos de variables por entorno: `.env.development`, `.env.staging`, `.env.production`
- Validar esquemas de variables al inicio de la aplicación con librerías específicas de validación
- Separar estrictamente: credenciales de base de datos, claves JWT, endpoints de API, URLs de almacenamiento, límites de tasa
- Configurar gestión de secretos en CI/CD (GitHub Secrets, Doppler o servicio equivalente)
- Bloquear versiones de dependencias con archivos de lock y configurar actualizaciones automáticas con revisión manual

### 3. Calidad de Código & Documentación Técnica
- Aplicar reglas estrictas de estilo y análisis estático para Dart y JavaScript/TypeScript
- Prohibir uso de tipos genéricos inseguros (`dynamic` innecesario, `any`)
- Documentar decisiones de arquitectura (ADR), flujos de negocio, glosario de términos florales/administrativos
- Generar diagramas de flujo de datos, mapas de navegación y matriz de trazabilidad de requisitos
- Establecer métricas objetivo: cobertura de pruebas ≥ 80%, 0 advertencias de análisis estático, 0 vulnerabilidades críticas

---

## 🗄️ Fase 1: Diseño de Base de Datos MySQL & Estrategia de Datos

### 1. Modelado Relacional & Normalización 3FN
- Diseñar diagrama entidad-relación con las 16 entidades requeridas
- Aplicar normalización hasta tercera forma normal: eliminar redundancias, garantizar atomicidad, separar datos de auditoría
- Definir tipos de datos precisos: `DECIMAL(12,2)` para monetario, `ENUM` o `TINYINT` para estados, `DATETIME` en UTC para fechas
- Establecer relaciones claras: `1:N` para categorías→productos, cliente→pedidos; `N:M` mediante tablas puente si es necesario; `1:1` para usuario→empleado, pedido→envío

### 2. Convenciones, Integridad & Índices
- Nomenclatura: `snake_case` para columnas, singular, tablas en plural opcional
- Claves primarias: `AUTO_INCREMENT`, `PRIMARY KEY` en todas las tablas
- Claves foráneas: `ON UPDATE CASCADE`, `ON DELETE RESTRICT` (o `SET NULL` donde aplique lógica de negocio)
- Crear índices B-Tree en: `email`, `telefono`, `fecha_pedido`, `estado`, `codigo_producto`, `usuario`, `accion`
- Implementar índices compuestos para consultas frecuentes de filtros combinados
- Añadir constraints `CHECK` para validaciones de rango (precios ≥ 0, fechas coherentes, estados válidos)

### 3. Automatización, Migraciones & Mantenimiento
- Seleccionar herramienta de migraciones CLI (Knex, Prisma o Sequelize) con versionado y rollback seguro
- Crear scripts de migración incrementales: esquema inicial, índices, triggers, procedimientos
- Generar seeders estratificados: datos base (roles, categorías, configuraciones), datos de prueba (clientes, productos, pedidos simulados)
- Implementar triggers de auditoría automática en tablas críticas
- Configurar evento programado para expiración de cupones y actualización de estados de pedidos vencidos
- Establecer estrategia de backup: diario completo + binlog incremental + validación mensual de restauración en staging

---

## ⚙️ Fase 2: Arquitectura Backend (Node.js + Express + JWT)

### 1. Estructura de Capas & Responsabilidades
- Organizar por directorios: `config`, `modules`, `core`, `repositories`, `services`, `controllers`, `routes`, `docs`
- Aplicar separación estricta: Controllers solo parsean requests y formatean responses; Services contienen lógica de negocio; Repositories gestionan consultas SQL
- Implementar mapeo DTO ↔ Entity en capa intermedia para desacoplar API de esquema DB
- Definir contratos de respuesta estandarizados: éxito, metadatos de paginación, estructura de errores

### 2. Autenticación, Autorización & Seguridad
- Implementar JWT dual: Access Token de vida corta (15-30 min), Refresh Token de vida larga (7-30 días)
- Aplicar rotación de refresh tokens con invalidación post-uso y detección de reutilización
- Utilizar Argon2id o bcrypt con sal única por usuario e iteraciones configurables
- Crear middleware de autorización basado en roles (`admin`, `vendedor`, `repartidor`) con permisos granulares
- Implementar protección adicional: Helmet, CORS estricto, Rate Limiting por IP y usuario, sanitización de inputs, queries parametrizadas

### 3. API RESTful & Optimización
- Versionar endpoints: `/api/v1/...` con política de deprecación documentada
- Implementar paginación, filtrado y búsqueda con validación estricta de campos permitidos
- Configurar manejo de errores semántico: códigos HTTP correctos, mensajes localizados, stack trace solo en desarrollo
- Configurar connection pooling, timeouts, retry logic y health checks periódicos
- Implementar caché con Redis para consultas frecuentes (catálogo, configuraciones, reportes precalculados)
- Integrar logging estructurado con correlación por `request_id` y niveles configurables

---

## 📱 Fase 3: Arquitectura Flutter Multiplataforma & Capas de Abstracción

### 1. Estructura Feature-First + Clean Architecture
- Organizar por módulos: `auth`, `dashboard`, `clients`, `products`, `inventory`, `orders`, `payments`, `shipping`, `events`, `reports`
- Separar capas: `core` (network, constants, utils, errors), `features` (presentation, domain logic, data sources), `shared` (widgets, layout, navigation, theme)
- Configurar inyección de dependencias y scope de providers por característica
- Mantener dirección de dependencias unidireccional: UI → Presentación → Dominio → Datos

### 2. Gestión de Estado con Riverpod
- Definir arquitectura de providers: Notifiers para lógica mutable, States inmutables serializables, Refs controlados
- Sincronizar con backend usando manejo uniforme de loading/success/error
- Implementar invalidación selectiva tras mutaciones y updates optimistas con rollback en fallo
- Configurar persistencia local para tokens, preferencias de UI y caché de última consulta

### 3. Navegación, Routing & Adaptabilidad
- Implementar enrutamiento declarativo con guards por rol y estado de autenticación
- Configurar redirección automática en expiración de token con refresh silencioso
- Diseñar navegación adaptativa: sidebar fija en Windows/Web, bottom navigation/drawer en Android
- Soportar deep links para compartir pedidos, productos o recuperar sesión desde notificaciones
- Configurar renderers web: CanvasKit para consistencia visual en desktop, HTML para carga rápida en mobile

### 4. Capa de Red & Manejo de Errores
- Configurar cliente HTTP con interceptores: inyección automática de token, detección de 401 con retry, logging en desarrollo
- Mapear códigos HTTP a excepciones tipadas, mensajes localizados y estados de UI (vacío, error, reintento)
- Implementar cola de operaciones offline opcional con sincronización al recuperar conexión y resolución de conflictos por timestamp

---

## 🌷 Fase 4: Sistema de Diseño UI/UX "Floral Soft" & Integración del Ajolote

### 1. Filosofía Visual & Paleta de Colores (Rosa Predominante)
- **Principio:** Suavidad orgánica, frescura natural, elegancia contemporánea, ternura profesional
- **Rosa Dominante:** `#FFB7C5` (primario), `#FFD6E0` (secundario), `#FFF0F5` (fondos), `#E87A9B` (textos/accentos)
- **Apoyo Sutil:** `#E6D5F0` (lavanda sueño), `#F3E9F7` (lila bruma), `#D6EAF8` (azul cielo ajolote), `#F0F7FF` (azul perla)
- **Funcionales Adaptados:** Éxito `#A8E6CF`, Advertencia `#FFD3B6`, Error `#FFAAA5`, Texto Principal `#5A4A66`, Secundario `#8B7A99`
- Modo oscuro opcional con fondo `#2D2436`, superficie `#3D324E`, texto `#F5E6F7`

### 2. Tipografía, Espaciado & Formas Florales
- Familia principal: `Quicksand` (400 cuerpo, 600 subtítulos, 700 títulos)
- Familia acento: `Dancing Script` (logos, headers especiales, precios destacados)
- Escala tipográfica: H1 32px, H2 24px, H3 20px, Body 16px, Small 14px, Caption 12px
- Espaciado basado en escala de 4px (4, 8, 12, 16, 24, 32, 48)
- Bordes redondeados: 16px para inputs/cards, 20px para botones, 24px para modales
- Sombras florales sutiles con opacidad rosa baja, bordes superiores decorativos con gradiente rosa→lavanda

### 3. Biblioteca de Componentes Florales Reutilizables
- **Botones:** Primario relleno rosa, secundario outline floral, ghost con hover suave, animación de escala mínima al presionar
- **Inputs/Forms:** Fondo blanco, borde rosa claro, focus con acento rosa profundo, label flotante con transición suave, iconos florales funcionales
- **Cards:** Fondo blanco, sombra rosa difusa, padding generoso, borde superior decorativo, hover con elevación sutil
- **Tablas Administrativas:** Header con fondo rosa susurro, filas con hover pétalo, paginación con pills florales, chips de filtro con forma de hoja
- **Navegación:** Sidebar con gradiente vertical suave, items activos con borde izquierdo rosa, íconos que florecen al hover
- **Feedback:** Toasts con borde izquierdo por estado, modales con overlay morado suave y cierre con animación de pétalo, loaders con burbujas ascendentes

### 4. Sistema de Mascota: Ajolote Guía
- **Estilo:** Ilustración vectorial suave, líneas orgánicas, tonos pastel integrados a la paleta
- **Estados Visuales:**
  - `idle`: Ajolote nadando suavemente entre burbujas (pantallas de carga)
  - `empty`: Mirando con curiosidad junto a cartel amigable (vistas sin datos)
  - `success`: Sonriendo con flores en branquias y pétalos cayendo (confirmaciones)
  - `warning`: Expresión tierna preocupada, nube que llueve pétalos (alertas suaves)
  - `error`: Postura calmada con mensaje de ayuda en burbuja de diálogo (errores)
- **Animaciones:** Duración 300-600ms, easing `ease-out`, sin rebotes, loop suave en estados de espera
- **Integración Técnica:** Widget contenedor que recibe `state`, renderiza SVG/Lottie correspondiente, anima transición entre estados, gestiona accesibilidad (alt text, role)

### 5. Patrones, Texturas & Fondos Decorativos
- Opacidad máxima del 10% para patrones de pétalos, ondas acuarela o puntos florales
- Gradientes radiales suaves en headers y secciones hero
- Fondos alternos entre rosa susurro y lila bruma para separación visual de secciones
- Validación de contraste WCAG AA en todos los overlays y textos sobre fondos decorativos

---

## 🧩 Fase 5: Desarrollo Detallado por Módulos (Flujos, Estados, Validaciones)

### 1. Auth & Sesión
- Login con validación de formato, bloqueo temporal tras intentos fallidos, verificación opcional
- Persistencia segura de tokens, refresh automático, cierre con limpieza de caché
- Guards por rol: `admin` (total), `vendedor` (pedidos/clientes/productos), `repartidor` (envíos/ruta)
- UI floral: fondo con patrón de pétalos sutil, ajolote guía con burbuja de bienvenida, feedback de error con tono cálido

### 2. Dashboard Administrativo
- KPIs en tiempo real: ventas diarias, pedidos pendientes, stock crítico, ingresos mensuales, eventos próximos
- Gráficos interactivos con líneas suaves, puntos como pétalos, leyendas con hover floral
- Actividad reciente con avatares temáticos, accesos directos con íconos que florecen
- Adaptación responsive: grids 3-4 columnas en desktop, 2 en tablet, lista vertical en mobile

### 3. Clientes & Productos
- CRUD con búsqueda full-text, filtros combinados, paginación fluida
- Validación de email único, teléfono, direcciones múltiples
- Productos: galería con zoom suave, SKU único, categorías, precio/stock, disponibilidad, personalización opcional
- Estados visuales: activo/inactivo, bajo stock (amarillo suave), agotado (coral suave), descontinuado (gris floral)

### 4. Inventario & Lotes
- Entrada por lote: proveedor, costo unitario, fecha vencimiento, cantidad, observaciones
- Control FIFO/FEFO, cálculo automático de stock restante, mermas con justificación
- Alertas configurables: umbral mínimo, proximidad a vencimiento, discrepancias por conteo físico
- Ajustes manuales con auditoría obligatoria y aprobación por rol
- UI floral: cards de lote con borde superior de color según estado, ajolote revisando inventario en vista vacía

### 5. Pedidos & Detalle
- Máquina de estados: `pendiente → confirmado → preparando → enviado → entregado → cancelado`
- Transiciones validadas por rol y condición (no enviar sin pago/stock, cancelar con motivo)
- Detalle: productos, cantidades, precios congelados, personalización, notas internas
- Historial inmutable, edición solo en estados tempranos
- UI floral: timeline con puntos que florecen al cambiar de estado, botones de acción con íconos temáticos

### 6. Pagos & Envíos
- Métodos: efectivo, transferencia, tarjeta, PayPal (simulado o integrado)
- Conciliación: monto esperado vs recibido, referencias, comprobantes, estados parciales/completos
- Envíos: asignación a repartidor, dirección validada, fecha programada vs real, costo, coordenadas GPS, confirmación de entrega
- UI floral: tarjetas de pago con bordes suaves, mapa de ruta con overlay rosa claro, confirmación con ajolote celebrando

### 7. Eventos & Ocasiones
- Calendario mensual/semanal, presupuesto estimado vs real, ubicación, tipo de evento
- Ocasiones especiales: cumpleaños, aniversarios, fechas conmemorativas, recordatorios automáticos
- Vinculación con pedidos existentes, plantillas de arreglos por tipo
- UI floral: calendario con días destacados en rosa, eventos con badges de pétalo, recordatorios con animación suave de campana floral

---

## 📊 Fase 6: Reportes, Auditoría, Cupones & Funcionalidades Avanzadas

### 1. Sistema de Reportes & Exportación
- Filtros avanzados: rango de fechas, categoría, vendedor, estado, cliente
- Métricas precalculadas: ventas por período, rotación de inventario, margen por producto, rendimiento de repartidores
- Exportación: PDF con diseño corporativo floral, Excel con hojas tabulares y formato limpio
- Generación asíncrona para datasets grandes, progreso visible, historial de reportes

### 2. Auditoría & Cumplimiento
- Registro inmutable: usuario, acción, entidad, ID, valores antes/después, IP, timestamp, user-agent
- Visualización con filtros, exportación, retención configurable
- Alertas de actividad anómala: fallos de login múltiples, accesos fuera de horario, cambios masivos
- Privacidad básica: enmascaramiento de datos sensibles en logs, consentimiento para datos de clientes

### 3. Motor de Cupones & Promociones
- Tipos: porcentaje, monto fijo, envío gratis, producto específico
- Reglas: vigencia, usos por cliente, stacking prohibition, mínimo de compra
- Validación en tiempo real durante checkout, aplicación automática, historial de uso
- UI floral: input de cupón con borde que cambia a verde éxito al aplicar, ajolote sonriendo si es válido

### 4. Optimización & Caché
- Stale-while-revalidate para catálogo
- Caché de imágenes con compresión WebP, precarga condicional
- Lazy loading en tablas e imágenes, virtualización de listas largas
- Reducción de rebuilds con selectividad de estado, memoización de cálculos pesados

---

## 🧪 Fase 7: Estrategia de Pruebas, Calidad & Pipeline CI/CD

### 1. Pirámide de Pruebas
- **Unitarias (70%):** Validaciones, mapeo DTO/Entity, lógica de negocio, cálculos de inventario/pedidos, providers Riverpod
- **Widgets (20%):** Componentes florales, estados (loading/success/error), responsive breakpoints, accesibilidad básica
- **Integración (10%):** Flujos completos, mocks de API, reset de estado, validación de transacciones de pedidos

### 2. Herramientas & Métricas de Calidad
- `flutter_test`, `mocktail`, `integration_test` para frontend
- `jest`/`supertest` para backend
- Cobertura objetivo: ≥ 80% líneas, 100% branches críticos
- Reportes de calidad con umbrales de bloqueo en PR

### 3. Pipeline CI/CD
- **Triggers:** Push a `develop`, PR a `main`, tags de release
- **Etapas:**
  1. Lint & format check
  2. Unit & widget tests
  3. Security scan (dependencias, secrets, SAST básico)
  4. Build multiplataforma (APK/Web/Windows)
  5. Deploy a staging (auto), producción (manual con aprobación)
- Gestión de artefactos: versionado semántico, changelog automático, rollback rápido

---

## 🚀 Fase 8: Despliegue, Monitoreo, Mantenimiento & Escalabilidad

### 1. Infraestructura & Entornos
- **Backend:** VPS o Cloud, Docker Compose o Kubernetes ligero, Nginx reverse proxy, SSL/TLS
- **DB:** MySQL administrado, backups automáticos, read replicas si escala > 1k RPS
- **Frontend Web:** CDN para assets, cache headers optimizados, PWA con ícono de ajolote
- **Windows Desktop:** Instalador firmado, actualizaciones guiadas, soporte DPI alto
- **Android:** App Bundle firmado, minSDK optimizado, distribución gradual

### 2. Monitoreo & Observabilidad
- Frontend: Sentry/Crashlytics para crashes, logs de red, métricas de rendimiento
- Backend: APM, logs estructurados, trazas distribuidas, health checks
- Alertas: umbrales configurables (error rate, latencia, conexiones DB, disco)
- Runbooks: procedimientos documentados para incidentes, escalamiento, rollback

### 3. Mantenimiento & Evolución
- Actualizaciones trimestrales de Flutter, mensuales de dependencias, parches críticos en 24h
- Migraciones de DB versionadas y probadas en staging
- Feedback loop: analytics de uso, reportes de errores, priorización por impacto
- Escalabilidad futura: microservicios si módulos crecen, message queue para tareas pesadas, event sourcing para auditoría avanzada, multi-tenant si se requiere SaaS

---

## 📦 Anexo A: Dependencias Clave (`pubspec.yaml` & Backend)

| Categoría | Paquete / Librería | Propósito Floral & Técnico |
|-----------|-------------------|---------------------------|
| **Estado** | `flutter_riverpod` + `riverpod_annotation` | Gestión reactiva, inmutable, testeable, optimizada para UI floral dinámica |
| **Navegación** | `go_router` | Enrutamiento declarativo, guards por rol, deep links, adaptativo multiplataforma |
| **Red** | `dio` + interceptores personalizados | HTTP robusto, inyección JWT, retry, logging, manejo de errores tipados |
| **Tipografía** | `google_fonts` | Carga eficiente de `Quicksand` y `Dancing Script` |
| **Animaciones** | `lottie`, `flutter_animate` | Ajolote mascot, transiciones suaves, microinteracciones florales |
| **Imágenes** | `cached_network_image`, `flutter_svg` | Galería de productos, ilustraciones vectoriales del ajolote y patrones |
| **Formularios** | `formz`, `flutter_form_builder` | Validación estructurada, inputs con estilo floral, feedback inmediato |
| **Gráficos** | `fl_chart` o `syncfusion_flutter_charts` | KPIs con estética floral, líneas suaves, tooltips elegantes |
| **Tablas** | `data_table_2` o `syncfusion_flutter_datagrid` | Datagrids administrativos con paginación, filtros, hover floral |
| **Reportes** | `pdf`, `excel` | Generación de documentos con branding floral |
| **Caché Local** | `hive` o `shared_preferences` | Tokens, preferencias, caché ligero de catálogo |
| **Backend** | `express`, `jsonwebtoken`, `bcrypt`, `mysql2`, `zod`, `winston`, `redis` | API REST segura, JWT dual, validación, logging, caching, pool de conexiones |

---

## ✅ Anexo B: Criterios de Aceptación, Gestión de Riesgos & Roadmap

### 🎯 Criterios de Aceptación por Fase
| Fase | Entregable | Validación |
|------|------------|------------|
| 0 | Repos, hooks, docs, envs | 0 warnings, CI verde, ADRs aprobados |
| 1 | Schema, migraciones, seeds | 3NF verificada, índices activos, backup probado |
| 2 | API REST, JWT, Swagger | Auth/roles funcionales, tests ≥ 85%, OpenAPI validado |
| 3 | Flutter base, routing, providers | Navegación fluida, guards activos, offline fallback |
| 4 | Design system floral, mascot system | Paleta exacta, responsive 3 breakpoints, ajolote en 5+ estados |
| 5 | Módulos CRUD, flujos | Estados validados, auditoría registrada, sync backend |
| 6 | Reportes, cupones, auditoría | PDF/Excel correctos, reglas aplicadas, logs inmutables |
| 7 | Pruebas, CI, cobertura | Tests pasando, pipeline estable, métricas OK |
| 8 | Deploy, monitoreo, docs | App en stores/web/Windows, alertas activas, runbooks listos |

### ⚠️ Gestión de Riesgos & Mitigación
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Cuellos de botella en DB | Media | Alto | Índices optimizados, read replicas, paginación estricta, caché Redis |
| Inconsistencia de stock | Baja | Crítico | Transacciones ACID, locks optimistas, validación pre-commit |
| Token comprometido | Baja | Crítico | Refresh rotation, revocation list, logout remoto |
| Saturación visual floral | Media | Medio | Límites de opacidad ≤10% para patrones, validación WCAG, pruebas de usabilidad |
| Cambios de requisitos tardíos | Alta | Medio | Scope definido, sprints con entregables, backlog priorizado |

### 📅 Roadmap Sugerido (14 Semanas)
- **Semanas 1-2:** Fase 0 + 1 (DB, migraciones, seeds, Docker)
- **Semanas 3-4:** Fase 2 (Backend auth, CRUD base, seguridad, docs)
- **Semanas 5-6:** Fase 3 + 4 (Flutter base, tema floral, routing, componentes, ajolote)
- **Semanas 7-9:** Fase 5 (Auth → Dashboard → Clientes → Productos → Inventario)
- **Semanas 10-11:** Fase 5 (Pedidos → Pagos → Envíos → Eventos → Cupones)
- **Semanas 12-13:** Fase 6 + 7 (Reportes, auditoría, pruebas, CI)
- **Semana 14:** Fase 8 (Deploy staging, ajustes, producción, monitoreo)

---

## 📌 Próximos Pasos Inmediatos (Procedimiento de Inicio)

1. **Validar identidad visual** con stakeholders: aprobar paleta, tipografía, estilo del ajolote, reglas de aplicación floral
2. **Crear kit de diseño en Figma**: componentes florales, patrones, ilustraciones del ajolote, prototipos interactivos, especificaciones de spacing/typography
3. **Configurar repositorios** con estructura definida, CI básico, Docker Compose para MySQL + Redis local
4. **Implementar migraciones iniciales** + seeders de prueba, ejecutar validación de integridad referencial
5. **Desarrollar backend base**: auth, middleware de auditoría, endpoints críticos, documentación OpenAPI
6. **Inicializar Flutter**: tema global floral, routing, estructura de carpetas, provider base, interceptor Dio
7. **Integrar ajolote mascot system**: widget contenedor de estados, animaciones Lottie/SVG, conexión con flujos de carga/vacío/éxito
8. **Desarrollar módulo Auth con UI floral**: login/register, validaciones, feedback visual, guards por rol
9. **Ejecutar pruebas de usabilidad tempranas**: validar que la estética floral no interfiere con usabilidad administrativa
10. **Iterar, documentar y preparar pipeline** para despliegue en staging

---

> 🌸 *"Este plan garantiza un sistema administrativo robusto, escalable y profesional, envuelto en una experiencia visual que respira frescura, calidez y elegancia floral. El ajolote no es un adorno: es un guía funcional que humaniza cada interacción, mientras la arquitectura técnica mantiene el rendimiento, la seguridad y la mantenibilidad de un producto empresarial de clase mundial."*


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


