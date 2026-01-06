# Cómo Aplicar las Migraciones de Base de Datos

## Error Actual
```
PostgrestException(message: Could not find the 'ai_confidence' column of 'expenses' in the schema cache)
```

Este error ocurre porque la base de datos no tiene las nuevas columnas para AI que agregamos al modelo `Expense`.

## Solución: Ejecutar Migraciones SQL

### Opción 1: Usando Supabase Dashboard (Recomendado)

1. Ve a tu proyecto en [Supabase Dashboard](https://supabase.com/dashboard)
2. En el menú lateral, selecciona **SQL Editor**
3. Click en **New Query**
4. Copia y pega el siguiente SQL:

```sql
-- Migration: Add AI-related fields to expenses table
-- Created: 2025-01-27

-- Add AI-related columns to expenses table
ALTER TABLE expenses
ADD COLUMN IF NOT EXISTS ai_confidence DECIMAL(3, 2) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS original_transcription TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS parsed_by_ai BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS ai_model_version VARCHAR(50) DEFAULT NULL;

-- Add comments to explain each field
COMMENT ON COLUMN expenses.ai_confidence IS 'Confidence score (0.00-1.00) from AI parsing';
COMMENT ON COLUMN expenses.original_transcription IS 'Original voice transcription before AI parsing';
COMMENT ON COLUMN expenses.parsed_by_ai IS 'Whether this expense was created via AI parsing';
COMMENT ON COLUMN expenses.ai_model_version IS 'Version of AI model used for parsing (e.g., gemini-1.5-flash)';

-- Create index for querying AI-parsed expenses
CREATE INDEX IF NOT EXISTS idx_expenses_parsed_by_ai ON expenses(parsed_by_ai) WHERE parsed_by_ai = TRUE;

-- Create index for low confidence expenses (for review)
CREATE INDEX IF NOT EXISTS idx_expenses_low_confidence ON expenses(ai_confidence) WHERE ai_confidence IS NOT NULL AND ai_confidence < 0.5;
```

5. Click en **Run** o presiona `Ctrl+Enter`
6. Verifica que aparezca el mensaje "Success. No rows returned"

### Opción 2: Usando Supabase CLI

Si tienes Supabase CLI instalado:

```bash
# 1. Asegúrate de estar en el directorio del proyecto
cd c:\Users\jlope\.gemini\antigravity\scratch\vehicle_tracker

# 2. Ejecuta la migración
supabase db push
```

### Opción 3: Crear y Ejecutar Migración Individual

```bash
# 1. Crear nueva migración
supabase migration new add_ai_fields_to_expenses

# 2. Edita el archivo generado en supabase/migrations/ y pega el SQL de arriba

# 3. Aplica la migración
supabase db push
```

## Verificación

Después de ejecutar la migración, verifica que las columnas existen:

1. Ve a **Table Editor** en Supabase Dashboard
2. Selecciona la tabla `expenses`
3. Deberías ver las nuevas columnas:
   - `ai_confidence` (DECIMAL)
   - `original_transcription` (TEXT)
   - `parsed_by_ai` (BOOLEAN)
   - `ai_model_version` (VARCHAR)

## Migración Opcional: Tabla de Sugerencias AI

Si también quieres habilitar las sugerencias de AI (para Fase 4), ejecuta esta segunda migración:

```sql
-- Migration: Create AI expense suggestions table

CREATE TABLE IF NOT EXISTS ai_expense_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    suggestion_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'medium',
    confidence DECIMAL(3, 2) DEFAULT NULL,
    metadata JSONB DEFAULT '{}',
    is_dismissed BOOLEAN DEFAULT FALSE,
    dismissed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- Add comments
COMMENT ON TABLE ai_expense_suggestions IS 'AI-generated suggestions and insights for vehicle expenses';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_vehicle ON ai_expense_suggestions(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_type ON ai_expense_suggestions(suggestion_type);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_active ON ai_expense_suggestions(vehicle_id, is_dismissed, expires_at)
    WHERE is_dismissed = FALSE AND (expires_at IS NULL OR expires_at > NOW());

-- Enable RLS
ALTER TABLE ai_expense_suggestions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their vehicle suggestions"
    ON ai_expense_suggestions FOR SELECT
    USING (vehicle_id IN (SELECT id FROM vehicles WHERE user_id = auth.uid()));

CREATE POLICY "Users can dismiss their suggestions"
    ON ai_expense_suggestions FOR UPDATE
    USING (vehicle_id IN (SELECT id FROM vehicles WHERE user_id = auth.uid()));
```

## Troubleshooting

### Error: "relation 'expenses' does not exist"
- Verifica que estés conectado al proyecto correcto
- Asegúrate de que la tabla `expenses` ya existe

### Error: "column already exists"
- Está bien, significa que la migración ya se ejecutó parcialmente
- El script usa `ADD COLUMN IF NOT EXISTS` para evitar este error

### Error de permisos
- Asegúrate de tener permisos de administrador en Supabase
- Verifica que estés autenticado correctamente

## Después de la Migración

1. **Reinicia la app Flutter** (hot restart no es suficiente)
2. **Prueba agregar un gasto manual** - debería funcionar sin errores
3. **Prueba agregar un gasto por voz** - guardará metadata de AI

## Archivos de Migración Existentes

Los archivos SQL están en:
- `supabase/migrations/20250127_add_ai_fields_to_expenses.sql`
- `supabase/migrations/20250127_create_ai_expense_suggestions.sql`

Puedes copiar el contenido de estos archivos directamente al SQL Editor de Supabase.
