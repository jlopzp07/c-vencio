# 🚗 Vehicle Tracker

Una aplicación Flutter multiplataforma (Android, iOS, Web) para rastrear gastos de vehículos y monitorear fechas de vencimiento de documentos (SOAT, Tecnicomecánica) usando la API de Mis Datos.

## ✨ Características

- 🚙 **Gestión de Vehículos**: Agregar, ver y gestionar múltiples vehículos
- 💰 **Seguimiento de Gastos**: Registrar y categorizar gastos por vehículo
- 📅 **Monitoreo de Documentos**: Consulta en tiempo real del estado de SOAT y Tecnicomecánica vía API
- 🌓 **Dark/Light Mode**: Tema automático según preferencias del sistema
- 📱 **Multiplataforma**: Android, iOS y Web
- 🔒 **Seguro**: Variables de entorno para credenciales sensibles

## 🛠️ Tecnologías

- **Flutter** 3.9+
- **Riverpod** 3.0 - State Management
- **Supabase** - Backend as a Service
- **GoRouter** - Navegación
- **FlexColorScheme** - Temas modernos
- **flutter_dotenv** - Variables de entorno

## 📋 Requisitos Previos

- Flutter SDK 3.9.0 o superior
- Cuenta de Supabase (gratuita)
- API Key de Mis Datos (opcional para funcionalidad completa)

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone <tu-repositorio>
cd vehicle_tracker
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

Copia el archivo de ejemplo y configura tus credenciales:

```bash
cp .env.example .env
```

Edita `.env` con tus valores reales:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon-aqui
MIS_DATOS_API_KEY=tu-api-key-de-mis-datos
```

### 4. Configurar Supabase

Ejecuta los siguientes scripts SQL en tu proyecto de Supabase:

**Tabla `vehicles`:**
```sql
create table vehicles (
  id text primary key,
  license_plate text not null,
  brand text not null,
  model text not null,
  year int not null,
  color text not null,
  owner_document_type text not null,
  owner_document_number text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

**Tabla `expenses`:**
```sql
create table expenses (
  id text primary key,
  vehicle_id text not null references vehicles(id) on delete cascade,
  category text not null,
  amount numeric not null,
  date timestamp with time zone not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
```

Ver `SETUP.md` para instrucciones detalladas.

### 5. Ejecutar la aplicación

```bash
flutter run
```

## 📱 Uso

1. **Agregar un vehículo**: Toca el botón "+" y completa la información
2. **Ver detalles**: Toca cualquier vehículo para ver su información y estado de documentos
3. **Agregar gastos**: Desde los detalles del vehículo, toca "View Expenses" → "+"
4. **Consultar RUNT**: Los datos se consultan automáticamente al ver detalles del vehículo

## 🔐 Seguridad

- ✅ Las credenciales se almacenan en `.env` (excluido de git)
- ✅ `.env.example` proporciona la plantilla sin datos sensibles
- ⚠️ **NUNCA** comitas el archivo `.env` con credenciales reales

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/     # Configuración y constantes
│   ├── router/        # Configuración de rutas
│   └── theme/         # Temas Dark/Light
├── features/
│   ├── vehicles/      # Gestión de vehículos
│   │   ├── data/      # Repositorios y servicios API
│   │   ├── domain/    # Entidades
│   │   └── presentation/  # UI y providers
│   └── expenses/      # Gestión de gastos
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
```

## 🤝 Contribuir

Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 🙏 Agradecimientos

- [Supabase](https://supabase.com/) - Backend as a Service
- [Mis Datos](https://misdatos.com.co/) - API de consulta RUNT
- [FlexColorScheme](https://pub.dev/packages/flex_color_scheme) - Temas hermosos

## 📞 Soporte

Si encuentras algún problema o tienes preguntas, por favor abre un issue en GitHub.

---

Hecho con ❤️ usando Flutter
