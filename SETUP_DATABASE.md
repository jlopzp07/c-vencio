# Configuración de Base de Datos - Vehicle Tracker

## Pasos para configurar la tabla de caché de RUNT en Supabase

### 1. Acceder al SQL Editor de Supabase

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. En el menú lateral izquierdo, selecciona **SQL Editor**

### 2. Ejecutar la migración

1. Copia todo el contenido del archivo `supabase_migration_runt_cache.sql`
2. Pégalo en el SQL Editor de Supabase
3. Haz clic en el botón **Run** (o presiona `Ctrl+Enter`)

### 3. Verificar la creación de la tabla

Ejecuta el siguiente query para verificar que la tabla se creó correctamente:

```sql
SELECT * FROM vehicle_runt_cache;
```

Deberías ver una tabla vacía sin errores.

### 4. (Opcional) Configurar políticas RLS (Row Level Security)

Si tu proyecto requiere RLS, ejecuta:

```sql
-- Habilitar RLS en la tabla
ALTER TABLE vehicle_runt_cache ENABLE ROW LEVEL SECURITY;

-- Política para permitir a cualquier usuario autenticado leer y escribir su propio caché
CREATE POLICY "Users can manage their own cache"
ON vehicle_runt_cache
FOR ALL
USING (true);  -- Ajusta esto según tus necesidades de seguridad
```

## Estructura de la tabla

La tabla `vehicle_runt_cache` tiene la siguiente estructura:

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `vehicle_id` | TEXT | ID del vehículo (clave primaria) |
| `runt_data` | JSONB | Datos completos del RUNT en formato JSON |
| `last_fetched` | TIMESTAMP | Fecha y hora de la última consulta a Verifik API |
| `created_at` | TIMESTAMP | Fecha de creación del registro |
| `updated_at` | TIMESTAMP | Fecha de última actualización (se actualiza automáticamente) |

## Funcionamiento del sistema de caché

- **Duración del caché**: 30 días
- **Refresh manual**: Solo se permite refrescar los datos cada 30 días
- **Fallback**: Si la API falla, el sistema usará el caché aunque esté expirado
- **Almacenamiento**: Los datos de SOAT y Tecnicomecánica se almacenan en formato JSON

## Próximos pasos

Después de ejecutar la migración:

1. Ejecuta la aplicación Flutter: `flutter run`
2. Agrega un vehículo con datos reales de Colombia
3. La primera vez que veas los detalles del vehículo, consultará la API de Verifik
4. Los datos se guardarán en caché automáticamente
5. Las siguientes veces usará el caché (válido por 30 días)
6. Puedes forzar un refresh deslizando hacia abajo (pull to refresh) en el home o haciendo clic en el botón de refresh (solo disponible después de 30 días)

## Troubleshooting

### Error: relation "vehicle_runt_cache" already exists

Si ves este error, la tabla ya existe. Puedes eliminarla y recrearla:

```sql
DROP TABLE IF EXISTS vehicle_runt_cache CASCADE;
```

Luego vuelve a ejecutar el script de migración.

### Error: permission denied

Asegúrate de tener permisos de administrador en tu proyecto de Supabase.
