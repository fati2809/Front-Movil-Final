import 'package:flutter/material.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/widgets/app_drawer.dart';
import 'package:flutter_front/features/map/views/map.view.dart';
import 'package:flutter_front/features/events/views/calendar.view.dart';
import 'package:flutter_front/features/profile/views/profile.view.dart';
import 'package:get/get.dart';

// Key global (fuera de la clase para evitar problemas de referencia)

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  String? initialDestination;
  int _selectedIndex = 0;
  late List<Widget> _pages;

@override
void initState() {
  super.initState();

  final args = Get.arguments;
  initialDestination = args?["destination"];

  _pages = [
    MapView(initialDestinationId: initialDestination),
    const CalendarView(),
    const ProfileView(),
  ];
}

  void changeToMapWithDestination(String? destinationId) {
    print("changeToMapWithDestination llamado | destino: $destinationId");
    if (!mounted) {
      print("HomeView no mounted al intentar cambiar destino");
      return;
    }

    setState(() {
      _selectedIndex = 0;
      _pages[0] = MapView(initialDestinationId: destinationId);
      print("Mapa recreado con initialDestinationId = $destinationId");
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.notifications_outlined, color: GlobalColors.textColor),
          onPressed: () => print('TODO: Notificaciones'),
        ),
        title: Text(
          'MAPPOSTING',
          style: TextStyle(color: GlobalColors.mainColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: GlobalColors.textColor),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: GlobalColors.mainColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}