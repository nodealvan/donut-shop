import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minuman/data/data_minuman.dart';
import 'dart:math' as math;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  double _currentPage = 0;
  bool _isAfter = false;
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  final Map<String, int> _itemCounts = {};

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _bounceAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    for (var drink in drinks) {
      final drinkName = drink['name'];
      if (drinkName != null) {
        _itemCounts[drinkName] = 1;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _formatToRupiah(String price) {
    double amount = double.parse(price.replaceAll('\$', ''));
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount * 1000);
  }

  void _onGetItPressed() {
    setState(() {
      _isAfter = true;
    });
    _animationController.forward().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Yeeee!',
            message: 'Pesanan Anda telah berhasil dimasukan!',
            contentType: ContentType.success,
          ),
        ),
      );
      _animationController.reverse().then((_) {
        setState(() {
          _isAfter = false;
        });
      });
    });
  }

  void _incrementCount(String drinkName) {
    setState(() {
      _itemCounts[drinkName] = (_itemCounts[drinkName] ?? 1) + 1;
    });
  }

  void _decrementCount(String drinkName) {
    setState(() {
      if ((_itemCounts[drinkName] ?? 1) > 1) {
        _itemCounts[drinkName] = (_itemCounts[drinkName] ?? 1) - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        title: Center(
          child: Center(
            child: Image.asset(
              'assets/images/donuts-logo.png',
              width: 100,
              height: 100,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit
                    .cover, // This ensures the image covers the entire container
                colorFilter: ColorFilter.mode(
                  Colors.black38, // Adjust the opacity level here
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: _pageController,
              itemCount: drinks.length,
              itemBuilder: (context, index) {
                final drink = drinks[index];
                final rotation = (_currentPage - index).abs();
                final drinkName = drink['name'] ?? 'Unnamed Drink';
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: rotation * math.pi,
                            child: child,
                          );
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: _isAfter
                              ? ScaleTransition(
                                  scale: _bounceAnimation,
                                  child: Image.asset(
                                    'assets/images/box.png',
                                    key: const ValueKey<String>('afterImage'),
                                    height: 250,
                                  ),
                                )
                              : Image.asset(
                                  drink['image']!,
                                  key: const ValueKey<String>('beforeImage'),
                                  height: 250,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Flexible(
                      child: Container(
                        width: 350,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _formatToRupiah(drink['price']!),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              drinkName,
                              style: const TextStyle(
                                fontSize: 28,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => _decrementCount(drinkName),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.orange),
                                    child: const Icon(Icons.remove,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  '${_itemCounts[drinkName] ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () => _incrementCount(drinkName),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.orange),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                drink['description']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: _onGetItPressed,
                              child: Container(
                                height: 40,
                                width: 320,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.black,
                                ),
                                child: const Center(
                                  child: Text(
                                    'GET IT',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
