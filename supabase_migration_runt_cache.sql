-- Crear tabla para cachear los datos del RUNT
CREATE TABLE IF NOT EXISTS vehicle_runt_cache (
  vehicle_id TEXT PRIMARY KEY,
  runt_data JSONB NOT NULL,
  last_fetched TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice para búsquedas rápidas por vehículo
CREATE INDEX IF NOT EXISTS idx_vehicle_runt_cache_vehicle_id
ON vehicle_runt_cache(vehicle_id);

-- Índice para búsquedas por fecha de última actualización
CREATE INDEX IF NOT EXISTS idx_vehicle_runt_cache_last_fetched
ON vehicle_runt_cache(last_fetched);

-- Función para actualizar el timestamp automáticamente
CREATE OR REPLACE FUNCTION update_vehicle_runt_cache_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS trigger_update_vehicle_runt_cache_updated_at ON vehicle_runt_cache;
CREATE TRIGGER trigger_update_vehicle_runt_cache_updated_at
  BEFORE UPDATE ON vehicle_runt_cache
  FOR EACH ROW
  EXECUTE FUNCTION update_vehicle_runt_cache_updated_at();

-- Comentarios para documentación
COMMENT ON TABLE vehicle_runt_cache IS 'Caché de datos del RUNT obtenidos de Verifik API';
COMMENT ON COLUMN vehicle_runt_cache.vehicle_id IS 'ID del vehículo (FK a vehicles table)';
COMMENT ON COLUMN vehicle_runt_cache.runt_data IS 'Datos completos del RUNT en formato JSON';
COMMENT ON COLUMN vehicle_runt_cache.last_fetched IS 'Fecha y hora de la última consulta a la API';
