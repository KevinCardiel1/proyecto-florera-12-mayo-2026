# 🌸 Plan de Implementación: Aplicación "Floreria" (Flutter + Firebase)

> **Nota preliminar:** Se asume que "Antigravity" es un error tipográfico y se refiere a **Android Studio**. El plan está diseñado para ser ejecutado en **VS Code** o **Android Studio**, con Flutter 3.x+ y las herramientas actuales del ecosistema (2026).

---

## 📦 1. Herramientas y Entorno de Desarrollo
1. **SDK y Lenguaje**
   - Flutter SDK (canal estable, versión 3.x o superior)
   - Dart SDK (incluido con Flutter)
2. **IDE y Extensiones**
   - VS Code o Android Studio
   - Extensiones: Flutter, Dart, Firebase CLI, GitLens, Pubspec Assist, Error Lens
   - Configuración de formateo y linting (`dart fix`, `flutter analyze`)
3. **Control de Versiones**
   - Git + plataforma remota (GitHub/GitLab/Bitbucket)
   - Ramas: `main`, `develop`, `feature/*`, `release/*`
4. **Entornos de Prueba**
   - Emuladores Android/iOS
   - Navegador (para compilación web)
   - Dispositivos físicos para pruebas de rendimiento y notificaciones

---

## 🎨 2. Diseño UI/UX
1. **Investigación y Flujos**
   - Definir actores: cliente, administrador (si aplica), invitado
   - Mapear journeys: exploración → selección → carrito → checkout → confirmación
2. **Wireframes y Prototipos**
   - Herramienta recomendada: Figma, Penpot o Adobe XD
   - Crear pantallas clave: splash, login, registro, catálogo, detalle, carrito, perfil, pedidos
3. **Sistema de Diseño**
   - Paleta cromática inspirada en naturaleza y elegancia (tonos pastel, acentos verdes/rosas)
   - Tipografía legible y escalable (Google Fonts)
   - Componentes reutilizables: botones, cards, inputs, loaders, dialogs, bottom navigation
4. **Responsividad y Adaptabilidad**
   - Layouts con `LayoutBuilder`, `MediaQuery` y `ResponsiveBreakpoints`
   - Adaptación a móvil, tablet y escritorio web

---

## 🏗️ 3. Arquitectura y Estructura del Proyecto
1. **Patrón de Organización**
   - Arquitectura **Feature-First** o **Clean Architecture ligera**
   - Carpetas por módulo: `auth`, `catalog`, `cart`, `orders`, `profile`, `core`, `shared`
2. **Capas Lógicas**
   - `presentation` (widgets, pantallas, providers)
   - `domain` (modelos, casos de uso, interfaces)
   - `data` (servicios, repositorios, fuentes remotas)
3. **Navegación**
   - Router declarativo con `go_router` o `auto_route`
   - Guardias de ruta para proteger vistas autenticadas
   - Deep links para compartir productos o recuperar carrito

---

## 🔥 4. Configuración de Firebase
1. **Consola de Firebase**
   - Crear proyecto "Floreria"
   - Habilitar: Authentication, Firestore, Storage, Crashlytics, Analytics
2. **Integración Local**
   - Instalar Firebase CLI (`npm install -g firebase-tools`)
   - Ejecutar `flutterfire configure` para generar archivos de plataforma (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`)
   - Validar que `firebase_core` se inicializa en el `main`
3. **Seguridad y Entornos**
   - Reglas de Firestore por colección y rol
   - Reglas de Storage para imágenes de productos y avatares
   - Separar configuraciones por entorno (dev, staging, prod) mediante variables o archivos `.env`

---

## 🔐 5. Autenticación (Email/Password)
1. **Configuración en Firebase**
   - Habilitar proveedor "Correo electrónico/Contraseña"
   - Activar verificación de correo y recuperación de cuenta
2. **Flujos a Implementar**
   - Registro con validación de formato y fortaleza de contraseña
   - Login con manejo de estados (éxito, error, cuenta no verificada, usuario bloqueado)
   - Restablecimiento de contraseña por correo
   - Cierre de sesión y limpieza de estado local
3. **Persistencia de Sesión**
   - Uso de `authStateChanges()` para redirección automática
   - Almacenamiento seguro de tokens o preferencias si se requiere
   - Manejo de errores de red y tiempos de espera

---

## 📊 6. Gestión de Estado con Provider
1. **Estructura de Providers**
   - `AuthProvider`: estado de autenticación, perfil, acciones de login/logout
   - `ProductProvider`: catálogo, categorías, filtros, paginación
   - `CartProvider`: items, cantidades, totales, sincronización opcional
   - `OrderProvider`: historial, estados de pedido, checkout
   - `ThemeProvider`: modo claro/oscuro, preferencias de UI
2. **Patrones de Uso**
   - `ChangeNotifier` para lógica mutable
   - `MultiProvider` en el árbol superior
   - `Consumer`/`Selector` para reconstrucciones mínimas
   - Separación estricta entre estado y presentación
3. **Sincronización con Firebase**
   - Escuchar streams de Firestore y reflejarlos en providers
   - Desacoplar lógica de red de la UI mediante repositorios

---

## 🗃️ 7. Base de Datos Firestore e Integración
1. **Modelado de Colecciones**
   - `users`: perfil, direcciones, preferencias, rol
   - `categories`: nombre, imagen, orden de visualización
   - `products`: nombre, descripción, precio, stock, categoría, imágenes, disponibilidad
   - `cart`: usuario_id, items (subcolección o mapa), timestamp
   - `orders`: usuario_id, items, total, estado, fecha, dirección, método de pago
2. **Reglas de Seguridad**
   - Lectura pública para catálogo y categorías
   - Escritura/lectura restringida por `request.auth.uid` en usuario, carrito y pedidos
   - Validación de tipos y rangos en Firestore Rules
3. **Operaciones y Optimización**
   - Consultas paginadas (`startAfterDocument`, límites)
   - Índices compuestos para filtros combinados
   - Uso de `withConverter` o serialización manual para mapeo seguro
   - Caché local con `FirebaseFirestore.instance.enableNetwork()` y manejo offline

---

## 🛠️ 8. Desarrollo de Módulos y Funcionalidades
1. **Catálogo y Búsqueda**
   - Grid responsivo con lazy loading
   - Filtros por categoría, precio, disponibilidad
   - Búsqueda por texto con debounce
2. **Carrito y Checkout**
   - Agregar/quitar items, validación de stock
   - Resumen con impuestos y envío (simulado o integrado)
   - Confirmación y generación de orden en Firestore
3. **Perfil y Historial**
   - Edición de datos personales y direcciones
   - Lista de pedidos con estados (pendiente, enviado, entregado)
   - Preferencias de notificación y tema
4. **Extras Recomendados**
   - Notificaciones push (Firebase Cloud Messaging) para actualizaciones de pedidos
   - Compartido de productos (share intent / deep links)
   - Localización (es-ES, en-US) con `intl`

---

## 🧪 9. Pruebas y Calidad
1. **Pruebas Unitarias**
   - Modelos y serialización
   - Lógica de providers y repositorios
   - Validaciones de formularios y reglas de negocio
2. **Pruebas de Widgets**
   - Renderizado de componentes clave
   - Comportamiento con estados de carga/error
   - Accesibilidad y contraste
3. **Pruebas de Integración**
   - Flujos completos: registro → login → navegación → compra → confirmación
   - Simulación de respuestas de Firebase (emuladores o mocks)
4. **Optimización**
   - Reducción de rebuilds innecesarios
   - Compresión y caching de imágenes
   - Eliminación de memory leaks y listeners no cerrados
   - Análisis con `flutter devtools` (performance, memory, network)

---

## 🚀 10. Despliegue y Post-lanzamiento
1. **Generación de Builds**
   - Android: App Bundle (`aab`), firma, optimización ProGuard/R8
   - iOS: Archive, TestFlight, App Store Connect
   - Web: `flutter build web`, optimización de assets y rutas
2. **CI/CD (Opcional pero recomendado)**
   - GitHub Actions, Codemagic o Fastlane
   - Linting, tests automáticos, generación de builds y despliegue
3. **Monitoreo y Analytics**
   - Firebase Crashlytics para reportes de fallos
   - Firebase Analytics para métricas de uso y conversión
   - Logs estructurados para diagnóstico en producción
4. **Mantenimiento**
   - Roadmap de versiones y retrocompatibilidad
   - Actualización de dependencias y migraciones de Flutter/Firebase
   - Canal de feedback y revisión de tiendas

---

## 📜 Dependencias Requeridas (`pubspec.yaml`)
> *Listado descriptivo sin fragmentos de código. Se recomienda instalar las versiones estables más recientes compatibles con tu SDK.*

| Categoría | Paquete | Propósito |
|-----------|---------|-----------|
| **Firebase Core** | `firebase_core` | Inicialización y conexión con Firebase |
| **Autenticación** | `firebase_auth` | Login, registro, gestión de sesiones y contraseñas |
| **Base de Datos** | `cloud_firestore` | CRUD, streams, consultas y sincronización en tiempo real |
| **Almacenamiento** | `firebase_storage` | Gestión de imágenes de productos y avatares |
| **Mensajería** | `firebase_messaging` | Notificaciones push y deep links |
| **Analytics** | `firebase_analytics` | Métricas de uso y comportamiento |
| **Crash Reporting** | `firebase_crashlytics` | Reportes de errores en producción |
| **Estado** | `provider` | Gestión de estado reactivo y arquitectura limpia |
| **Navegación** | `go_router` | Enrutamiento declarativo, guards y deep links |
| **Imágenes** | `cached_network_image` | Carga y caché eficiente de imágenes remotas |
| **SVG** | `flutter_svg` | Renderizado de íconos y gráficos vectoriales |
| **Fuentes** | `google_fonts` | Tipografías consistentes y optimizadas |
| **Formularios** | `formz` + `flutter_form_builder` | Validación estructurada y componentes de input |
| **Utilidades** | `intl` | Formateo de fechas, monedas y localización |
| **Entorno** | `flutter_dotenv` | Gestión de variables por entorno |
| **HTTP/REST** | `dio` o `http` | (Opcional) Integraciones externas o APIs de pago |

---

## ✅ Próximos Pasos Recomendados
1. Validar este plan con el equipo o stakeholders
2. Crear repositorio y ramas iniciales
3. Diseñar en Figma y exportar assets
4. Configurar proyecto Flutter + Firebase
5. Implementar Auth + Provider base
6. Conectar Firestore y desarrollar catálogo
7. Iterar con pruebas y feedback antes de añadir checkout

Cuando estés listo, puedo proporcionar:
- Estructura de carpetas detallada
- Modelo de datos Firestore
- Flujos de navegación
- Guías de implementación por módulo (siempre manteniendo la separación UI/Lógica)

¿Deseas que profundice en alguna fase o ajustar el plan a un alcance específico (MVP, v1, o versión completa)?
