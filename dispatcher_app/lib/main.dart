import 'package:dispatcher_app/pages/create_order_page.dart';
import 'package:dispatcher_app/pages/map_view_page.dart';
import 'package:dispatcher_app/pages/orders_list_view.dart';
import 'package:dispatcher_app/utils/lifecycle_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/services/api_service.dart';
import 'services/order_service.dart';
import 'services/courier_service.dart';
import 'package:yandex_maps_mapkit/init.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['YANDEX_MAPKIT_API_KEY'];
  if (apiKey == null) {
    throw Exception('YANDEX_MAPKIT_API_KEY is not set in .env file');
  }

  await initMapkit(apiKey: apiKey, locale: 'ru_RU');


  // ✅ Регистрируем наблюдателя за жизненным циклом
  final lifecycleManager = LifecycleManager();
  WidgetsBinding.instance.addObserver(lifecycleManager);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<OrderService>(create: (context) => OrderService(context.read<ApiService>())),
        Provider<CourierService>(create: (context) => CourierService(context.read<ApiService>())),
      ],
      child: const DispatcherApp(),
    ),
  );
}

class DispatcherApp extends StatelessWidget {
  const DispatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dispatcher App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: _primaryLightColor,
        scaffoldBackgroundColor: _backgroundLightColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: _surfaceLightColor,
          elevation: 0.06,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryLightColor,
              foregroundColor: _secondaryLightColor,
            )),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DispatcherHomePage(),
    );
  }
}

const Color _primaryLightColor = Color(0xFFEFB12C);
const Color _backgroundLightColor = Color(0xffebebe9);
const Color _surfaceLightColor = Color(0xffffffff);
const Color _secondaryLightColor = Color(0xFF20201E);

class DispatcherHomePage extends StatefulWidget {
  const DispatcherHomePage({super.key});

  @override
  State<DispatcherHomePage> createState() => _DispatcherHomePageState();
}

class _DispatcherHomePageState extends State<DispatcherHomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<OrdersListViewState> _ordersListKey = GlobalKey<OrdersListViewState>();

  late final Widget _ordersListView;
  late final Widget _mapViewPage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ordersListView = OrdersListView(key: _ordersListKey);
    _mapViewPage = const MapViewPage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToCreateOrder() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateOrderPage()),
    );
    _ordersListKey.currentState?.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель Диспетчера', style: TextStyle(color: _secondaryLightColor)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Заказы'),
            Tab(icon: Icon(Icons.map), text: 'Карта'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _ordersListView,
          _mapViewPage,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateOrder,
        tooltip: 'Новый заказ',
        child: const Icon(Icons.add, color: _secondaryLightColor),
      ),
    );
  }
}