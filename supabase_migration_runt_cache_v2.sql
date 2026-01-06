-- Migración v2: Agregar soporte para caché de errores
-- Esta migración agrega columnas para almacenar información de errores
-- permitiendo cachear fallos de API y evitar múltiples llamadas innecesarias

-- Agregar columnas para manejo de errores
ALTER TABLE vehicle_runt_cache
ADD COLUMN IF NOT EXISTS has_error BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS error_message TEXT;

-- Actualizar índices para optimizar consultas de errores
CREATE INDEX IF NOT EXISTS idx_vehicle_runt_cache_has_error
ON vehicle_runt_cache(has_error);

-- Comentarios para documentación
COMMENT ON COLUMN vehicle_runt_cache.has_error IS 'Indica si este registro representa un error de API (true) o datos exitosos (false)';
COMMENT ON COLUMN vehicle_runt_cache.error_message IS 'Mensaje de error almacenado cuando has_error es true';

-- Verificar estructura final
DO $$
BEGIN
  RAISE NOTICE 'Migración v2 completada exitosamente';
  RAISE NOTICE 'Nuevas columnas agregadas: has_error (BOOLEAN), error_message (TEXT)';
  RAISE NOTICE 'Comportamiento: Errores se cachean por 1 día, datos exitosos por 30 días';
END $$;
