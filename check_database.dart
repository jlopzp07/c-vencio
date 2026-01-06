import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para verificar si la tabla vehicle_runt_cache existe en Supabase
void main() async {
  print('========================================');
  print('VERIFICACIÓN DE BASE DE DATOS');
  print('========================================\n');

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  print('1. Configuración de Supabase:');
  print('   URL: $supabaseUrl');
  print('   Key disponible: ${supabaseKey.isNotEmpty ? "✓ SÍ" : "✗ NO"}\n');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('✗ ERROR: Falta configuración de Supabase en .env\n');
    return;
  }

  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  final supabase = Supabase.instance.client;

  print('2. Verificando tabla vehicle_runt_cache...\n');

  try {
    // Intentar hacer una consulta simple
    final response = await supabase
        .from('vehicle_runt_cache')
        .select()
        .limit(1);

    print('✓ ¡ÉXITO! La tabla vehicle_runt_cache existe');
    print('   Registros encontrados: ${response.length}');

    if (response.isEmpty) {
      print('   ℹ La tabla está vacía (es normal si es la primera vez)\n');
    } else {
      print('   ℹ Hay datos en caché\n');
      print('   Ejemplo de registro:');
      print('   ${response.first}\n');
    }

    print('========================================');
    print('✓ BASE DE DATOS CONFIGURADA CORRECTAMENTE');
    print('========================================');

  } catch (e) {
    print('✗ ERROR: La tabla vehicle_runt_cache NO existe\n');
    print('Error detallado: $e\n');
    print('========================================');
    print('SOLUCIÓN:');
    print('========================================');
    print('1. Abre Supabase Dashboard: https://app.supabase.com');
    print('2. Ve a tu proyecto');
    print('3. Abre el "SQL Editor"');
    print('4. Copia y pega el contenido de:');
    print('   supabase_migration_runt_cache.sql');
    print('5. Haz clic en "Run" (Ctrl+Enter)');
    print('6. Vuelve a ejecutar este script para verificar\n');
    print('Ver detalles en: SETUP_DATABASE.md');
    print('========================================');
  }
}
