import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../widgets/CustomDrawer.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  final CarouselSliderController  _controller = CarouselSliderController ();
  int _current = 0;

  Stream<List<Map<String, dynamic>>> goldPriceStream() {
    return supabase
        .from('gold_prices')
        .stream(primaryKey: ['id'])
        .order('recorded_at', ascending: false)
        .limit(1);
  }

  Stream<List<Map<String, dynamic>>> silverPriceStream() {
    return supabase
        // .from('silver_prices')
        .from('gold_prices')
        .stream(primaryKey: ['id'])
        .order('recorded_at', ascending: false)
        .limit(1);
  }

  final List<String> imgList = [
    'https://d2zny4996dl67j.cloudfront.net/blogs/wp-content/uploads/2023/06/19055507/Blog-Banner-1.jpg',
    'https://www.vummidi.com/blog/wp-content/uploads/2024/01/Gold-Saving-Scheme-1024x574.png',
    'https://bsmedia.business-standard.com/_media/bs/img/about-page/thumb/463_463/1607305466.jpg?im=FitAndFill=(826,465)',
  ];

  List<Widget> get imageSliders => imgList
      .map(
        (item) => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        item,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 100),
      ),
    ),
  )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(parentContext: context),
      appBar: AppBar(title: Text("Gold & Silver Prices Today")),
      body: Column(
        children: [
          SizedBox(height: 10),

          // Carousel Slider
          CarouselSlider(
            items: imageSliders,
            carouselController: _controller,
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),

          // StreamBuilder for Gold and Silver prices
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildPriceCard("Gold Price", goldPriceStream(), Colors.green),
                SizedBox(height: 20),
                _buildPriceCard("Silver Price", silverPriceStream(), Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String title, Stream<List<Map<String, dynamic>>> stream, Color color) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No $title data available"));
        }

        final data = snapshot.data!.first;
        final price = data['price_per_gram'] as double;
        final recordedAt = data['recorded_at'];

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("₹ $price per gram", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                SizedBox(height: 10),
                Text("Last Updated: ${recordedAt.split('T')[0]}", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}
