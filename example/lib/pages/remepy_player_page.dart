import 'package:better_player_plus/better_player_plus.dart';
import 'package:better_player_example/constants.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../remepy_player.dart';

class RemepyPlayerPage extends StatefulWidget {
  @override
  _RemepyPlayerPageState createState() => _RemepyPlayerPageState();
}

class _RemepyPlayerPageState extends State<RemepyPlayerPage> with RouteAware {
  late BetterPlayerController _betterPlayerController;
  bool isPlaying = true;
  int _selectedIndex = 0;
  final List<RemepyPlayer> _pages = [
    RemepyPlayer(index: 0),
    RemepyPlayer(index: 1),
    RemepyPlayer(index: 2),
    RemepyPlayer(index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Remepy player"),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
          Row(children: [
            IconButton(
                onPressed: _back, icon: Icon(Icons.navigate_before_rounded)),
            IconButton(
                onPressed: _next, icon: Icon(Icons.navigate_next_rounded)),
          ])
        ],
      ),
    );
  }

  void _back() {
    if(_selectedIndex>0) {
      _pages[_selectedIndex].pause();
      setState(() {
        _selectedIndex--;
      });
    }
  }
  void _next() {
    if(_selectedIndex < _pages.length-1) {
      _pages[_selectedIndex].pause();
      setState(() {
        _selectedIndex++;
      });
    }

  }
}
