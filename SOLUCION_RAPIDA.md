# 🚨 Solución Rápida - Errores Comunes

## Error: "Could not find the table 'vehicle_runt_cache'"

### ❌ Problema:
La tabla de caché **NO existe** en tu base de datos de Supabase.

### ✅ Solución (5 minutos):

1. **Abre Supabase Dashboard**
   - Ve a: https://app.supabase.com
   - Selecciona tu proyecto

2. **Abre el SQL Editor**
   - En el menú lateral izquierdo, haz clic en **"SQL Editor"**

3. **Ejecuta la migración**
   - Abre el archivo `supabase_migration_runt_cache.sql` en este proyecto
   - Copia **TODO** el contenido del archivo
   - Pégalo en el SQL Editor de Supabase
   - Haz clic en el botón **"Run"** (o presiona `Ctrl+Enter`)

4. **Verifica que funcionó**
   - En el SQL Editor, ejecuta:
   ```sql
   SELECT * FROM vehicle_runt_cache;
   ```
   - Si no hay error, la tabla existe correctamente

5. **Reinicia la app**
   ```bash
   flutter run
   ```

---

## ⚠️ Consumo Alto de API de Verifik

### 🔍 Causas identificadas:

1. **Provider autoDispose** (YA CORREGIDO ✅)
   - El provider se estaba reciclando en cada reconstrucción del widget
   - Esto causaba múltiples llamadas a la API
   - **Solución aplicada:** Removido `autoDispose` y agregado `keepAlive()`

2. **Widget rebuilding frecuente**
   - Los hot reloads durante desarrollo cuentan como llamadas
   - Las navegaciones entre pantallas pueden causar rebuilds

### ✅ Verificación de llamadas:

Para monitorear cuántas llamadas se hacen a Verifik:

1. **Abre los logs de la app**
   ```bash
   flutter run --verbose
   ```

2. **Busca estas líneas en los logs:**
   ```
   === VERIFIK API REQUEST ===
   ```
   Cada línea de estas = 1 llamada a la API

3. **Comportamiento esperado:**
   - **Primera vez:** 1 llamada al abrir el vehículo
   - **Siguientes 30 días:** 0 llamadas (usa caché)
   - **Después de 30 días:** 1 llamada al hacer refresh manual

### 🛡️ Protecciones implementadas:

✅ **Sistema de caché de 30 días**
- Los datos se guardan en Supabase
- No se consulta la API si hay caché válido

✅ **Límite de refresh**
- Solo se puede refrescar cada 30 días
- El botón de refresh solo aparece cuando es posible refrescar

✅ **Provider persistente**
- El provider ahora NO se autodispone
- Evita llamadas duplicadas en rebuilds

✅ **Fallback automático**
- Si la API falla, usa el caché aunque esté expirado
- No consume llamadas innecesarias

---

## 🔍 Verificar consumo actual

### Opción 1: Dashboard de Verifik
1. Ve a tu cuenta en Verifik
2. Revisa el dashboard de consumo de API
3. Verifica cuántas llamadas se hicieron HOY

### Opción 2: Logs de la aplicación
1. Ejecuta la app con logs detallados:
   ```bash
   flutter run --verbose 2>&1 | grep "VERIFIK API REQUEST"
   ```
2. Cuenta cuántas veces aparece esa línea

---

## 📊 Monitoreo recomendado

### Durante desarrollo:
- ⚠️ **Hot reload cuenta como rebuild** → puede causar llamadas
- ✅ **Solución:** Usar la app normalmente sin hacer hot reloads frecuentes
- ✅ **O:** Comentar temporalmente el provider durante desarrollo

### En producción:
Con las correcciones aplicadas, deberías tener:
- **1 llamada** por vehículo al agregarlo por primera vez
- **0 llamadas** durante 30 días (usa caché)
- **1 llamada** cada 30 días si el usuario hace refresh manual

---

## 🐛 Otros errores comunes

### Error: "API Key inválida o expirada"
**Solución:**
1. Verifica que `VERIFIK_API_KEY` esté en el archivo `.env`
2. Verifica que el token no haya expirado
3. Ejecuta: `dart run test_verifik.dart` para probar la conexión

### Error: "No se encontró información para esta placa"
**Solución:**
1. Verifica que la placa sea de un vehículo real en Colombia
2. Verifica que el tipo de documento y número sean del propietario registrado en RUNT
3. Usa datos reales, no de prueba

### La app está lenta
**Solución:**
1. Verifica que ejecutaste la migración SQL
2. El caché reduce los tiempos de carga significativamente
3. La primera carga es más lenta (consulta API), las siguientes son instantáneas

---

## 📝 Resumen de cambios aplicados

### Archivo: `vehicle_runt_provider.dart`
- ❌ **Antes:** `FutureProvider.family.autoDispose`
- ✅ **Ahora:** `FutureProvider.family` + `ref.keepAlive()`
- **Beneficio:** Evita múltiples llamadas a la API en rebuilds

### Archivos creados:
- ✅ `check_database.dart` - Verifica que la tabla existe
- ✅ `SOLUCION_RAPIDA.md` - Esta guía

---

## ✅ Checklist final

Antes de usar la app en producción, verifica:

- [ ] Ejecutaste la migración SQL en Supabase
- [ ] Corriste `dart run check_database.dart` sin errores
- [ ] El archivo `.env` tiene las 3 variables configuradas
- [ ] Probaste agregar un vehículo con datos reales
- [ ] Verificaste que el caché funciona (badge "Datos en caché")
- [ ] Monitoreaste el consumo de API en el dashboard de Verifik

---

**¿Necesitas más ayuda?**
- Revisa: `CHANGELOG_NEW_FEATURES.md` - Documentación completa
- Revisa: `SETUP_DATABASE.md` - Guía detallada de base de datos
- Ejecuta: `dart run test_verifik.dart` - Prueba la API de Verifik
- Ejecuta: `dart run check_database.dart` - Verifica la base de datos
