import 'package:go_router/go_router.dart';
import 'package:vehicle_tracker/core/constants/app_constants.dart';
import 'package:vehicle_tracker/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_tracker/features/vehicles/presentation/add_vehicle_screen.dart';
import 'package:vehicle_tracker/features/vehicles/presentation/edit_vehicle_screen.dart';
import 'package:vehicle_tracker/features/vehicles/presentation/vehicle_details_screen.dart';
import 'package:vehicle_tracker/features/home/presentation/home_screen.dart';
import 'package:vehicle_tracker/features/expenses/presentation/expenses_screen.dart';
import 'package:vehicle_tracker/features/expenses/presentation/expenses_screen_v2.dart';
import 'package:vehicle_tracker/features/expenses/presentation/add_expense_screen.dart';
import 'package:vehicle_tracker/features/expenses/presentation/add_expense_screen_v2.dart';
import 'package:vehicle_tracker/features/expenses/presentation/quick_voice_expense_screen.dart';
import 'package:vehicle_tracker/features/expenses/presentation/quick_manual_expense_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'add-vehicle',
          builder: (context, state) => const AddVehicleScreen(),
        ),
        GoRoute(
          path: 'quick-voice-expense',
          builder: (context, state) {
            final vehicleId = state.extra as String;
            return QuickVoiceExpenseScreen(vehicleId: vehicleId);
          },
        ),
        GoRoute(
          path: 'quick-manual-expense',
          builder: (context, state) {
            final vehicleId = state.extra as String;
            return QuickManualExpenseScreen(vehicleId: vehicleId);
          },
        ),
        GoRoute(
          path: 'edit-vehicle',
          builder: (context, state) {
            final vehicle = state.extra as Vehicle;
            return EditVehicleScreen(vehicle: vehicle);
          },
        ),
        GoRoute(
          path: 'vehicle-details',
          builder: (context, state) {
            final vehicle = state.extra as Vehicle;
            return VehicleDetailsScreen(vehicle: vehicle);
          },
          routes: [
            GoRoute(
              path: 'expenses',
              builder: (context, state) {
                final vehicleId = state.extra as String;
                // Use V2 if AI features are enabled, otherwise use original
                return AppConstants.enableAiFeatures
                    ? ExpensesScreenV2(vehicleId: vehicleId)
                    : ExpensesScreen(vehicleId: vehicleId);
              },
            ),
            GoRoute(
              path: 'add-expense',
              builder: (context, state) {
                final vehicleId = state.extra as String;
                // Use V2 if voice input is enabled, otherwise use original
                return AppConstants.enableVoiceInput
                    ? AddExpenseScreenV2(vehicleId: vehicleId)
                    : AddExpenseScreen(vehicleId: vehicleId);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
