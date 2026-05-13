import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/deliveries/providers/delivery_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/farmer/providers/farmer_provider.dart';
import 'features/buyer/providers/buyer_provider.dart';
import 'features/auth/models/user_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AgriGovTransporterApp());
}

class AgriGovTransporterApp extends StatelessWidget {
  const AgriGovTransporterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DeliveryProvider>(
          create: (_) => DeliveryProvider(),
          update: (_, auth, delivery) {
            delivery!.setToken(auth.token);
            return delivery;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, auth, notif) {
            notif!.setToken(auth.token);
            return notif;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, FarmerProvider>(
          create: (_) => FarmerProvider(),
          update: (_, auth, farmer) {
            farmer!.setUserAndToken(auth.user, auth.token);
            return farmer;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, BuyerProvider>(
          create: (_) => BuyerProvider(),
          update: (_, auth, buyer) {
            buyer!.setToken(auth.token);
            return buyer;
          },
        ),

      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            title: 'AgriGov Transporter',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router(auth),
          );
        },
      ),
    );
  }
}
