import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/GoldScheme.dart';
import '../widgets/CustomDrawer.dart';

class GoldSchemeScreen extends StatefulWidget {
  final String title;

  const GoldSchemeScreen({super.key, required this.title});

  @override
  State<GoldSchemeScreen> createState() => _GoldSchemeScreenState();
}

class _GoldSchemeScreenState extends State<GoldSchemeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Stream to listen to real-time changes in the `gold_scheme` table.
  Stream<List<GoldScheme>> genreStream() {
    return supabase
        .from('gold_schemes')
        .stream(primaryKey: ['id'])
        // .map((data) => data.map((row) => GoldScheme.fromJson(row)).toList());
        .map((data) {
          print('Raw data from Supabase: $data'); // Print raw response
          final gold_scheme = data.map((row) => GoldScheme.fromJson(row)).toList();
          print('Parsed playlists: $gold_scheme'); // Print parsed Playlist objects
          return gold_scheme;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(parentContext: context),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh the StreamBuilder by rebuilding the widget.
            },
          ),
        ],
      ),
      body: StreamBuilder<List<GoldScheme>>(
        stream: genreStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {

            print('Error: ${snapshot.error}');

            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final gold_scheme = snapshot.data ?? [];

          if (gold_scheme.isEmpty) {
            return const Center(
              child: Text('No gold scheme available.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Rebuilds the StreamBuilder to refresh data.
            },
            child: ListView.builder(
              itemCount: gold_scheme.length,
              itemBuilder: (context, index) {
                final genre = gold_scheme[index];
                return ListTile(
                  title: Text(genre.name),
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => SongFilterByGoldSchemeScreen(
                    //       title: genre.name,
                    //       genre: genre,
                    //     ),
                    //   ),
                    // );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}