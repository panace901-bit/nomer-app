import 'package:flutter/material.dart';

void main() => runApp(const NomerApp());

class NomerApp extends StatelessWidget {
  const NomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOMER',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111827)),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
      ),
      home: const HomeScreen(),
    );
  }
}

class Listing {
  final String plate;
  final String region;
  final String price;
  final String city;
  final String car;
  final bool verified;

  const Listing(this.plate, this.region, this.price, this.city, this.car,
      {this.verified = true});
}

const listings = [
  Listing('А 777 АА', '196', '850 000 ₽', 'Екатеринбург', 'Mercedes-Benz E 200'),
  Listing('М 001 ММ', '77', '1 500 000 ₽', 'Москва', 'BMW X5'),
  Listing('О 999 ОО', '777', '620 000 ₽', 'Москва', 'Audi Q7'),
  Listing('Е 007 КХ', '96', '390 000 ₽', 'Екатеринбург', 'Haval Jolion'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  String query = '';
  final favorites = <String>{};

  @override
  Widget build(BuildContext context) {
    final pages = [
      _catalog(),
      _catalog(searchFocused: true),
      const CreateListingScreen(),
      const Center(child: Text('Чаты появятся в следующей версии')),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Поиск'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Продать'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Чаты'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Профиль'),
        ],
      ),
    );
  }

  Widget _catalog({bool searchFocused = false}) {
    final visible = listings.where((item) {
      final q = query.toUpperCase().replaceAll(' ', '');
      return q.isEmpty ||
          item.plate.toUpperCase().replaceAll(' ', '').contains(q) ||
          item.region.contains(q) ||
          item.city.toUpperCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: [
        const Text('NOMER', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text('Найди свой номер', style: TextStyle(color: Colors.grey.shade700, fontSize: 17)),
        const SizedBox(height: 18),
        TextField(
          autofocus: searchFocused,
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: '777, А***АА, регион 196…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.tune),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Популярные комбинации', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: ['777', '001', '999', '007', 'ААА', 'МММ'].map((e) => ActionChip(label: Text(e), onPressed: () => setState(() => query = e))).toList()),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Новые объявления', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          Text('${visible.length} шт.', style: TextStyle(color: Colors.grey.shade600)),
        ]),
        const SizedBox(height: 10),
        ...visible.map((item) => ListingCard(
              item: item,
              favorite: favorites.contains('${item.plate}${item.region}'),
              onFavorite: () => setState(() {
                final key = '${item.plate}${item.region}';
                favorites.contains(key) ? favorites.remove(key) : favorites.add(key);
              }),
            )),
      ],
    );
  }
}

class ListingCard extends StatelessWidget {
  final Listing item;
  final bool favorite;
  final VoidCallback onFavorite;

  const ListingCard({super.key, required this.item, required this.favorite, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item))),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Plate(plate: item.plate, region: item.region),
              const Spacer(),
              IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border)),
            ]),
            const SizedBox(height: 13),
            Text(item.price, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(item.car, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(item.city, style: TextStyle(color: Colors.grey.shade600)),
          ]),
        ),
      ),
    );
  }
}

class Plate extends StatelessWidget {
  final String plate;
  final String region;
  const Plate({super.key, required this.plate, required this.region});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(plate, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, letterSpacing: 1.2)),
          const SizedBox(width: 8),
          Container(width: 1, height: 25, color: Colors.black),
          const SizedBox(width: 7),
          Column(children: [Text(region, style: const TextStyle(fontWeight: FontWeight.w800)), const Text('RUS', style: TextStyle(fontSize: 8))]),
        ]),
      );
}

class DetailScreen extends StatelessWidget {
  final Listing item;
  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Объявление')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Center(child: Plate(plate: item.plate, region: item.region)),
          const SizedBox(height: 24),
          Text(item.price, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(item.car, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          Text(item.city),
          const SizedBox(height: 22),
          const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.verified), title: Text('Номер подтверждён')),
          const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.directions_car), title: Text('Автомобиль проверен')),
          const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.person), title: Text('Продавец верифицирован')),
          const SizedBox(height: 20),
          FilledButton(onPressed: () {}, child: const Padding(padding: EdgeInsets.all(14), child: Text('Написать продавцу'))),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: () {}, child: const Padding(padding: EdgeInsets.all(14), child: Text('Предложить цену'))),
          const SizedBox(height: 25),
          const Text('Важно: приложение размещает объявления и не является государственным сервисом регистрации транспортных средств.'),
        ]),
      );
}

class CreateListingScreen extends StatelessWidget {
  const CreateListingScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Разместить объявление', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
        const SizedBox(height: 20),
        const TextField(decoration: InputDecoration(labelText: 'Номер, например А777АА', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(labelText: 'Регион', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        const TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Цена, ₽', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(labelText: 'Автомобиль', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(labelText: 'Город', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        FilledButton(onPressed: () {}, child: const Padding(padding: EdgeInsets.all(14), child: Text('Отправить на проверку'))),
      ]);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: const [
        Text('Профиль', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 20),
        ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('Пользователь'), subtitle: Text('Верификация не пройдена')),
        Divider(),
        ListTile(leading: Icon(Icons.favorite_border), title: Text('Избранное')),
        ListTile(leading: Icon(Icons.sell_outlined), title: Text('Мои объявления')),
        ListTile(leading: Icon(Icons.notifications_outlined), title: Text('Уведомления о номерах')),
        ListTile(leading: Icon(Icons.help_outline), title: Text('Как проходит сделка')),
      ]);
}
