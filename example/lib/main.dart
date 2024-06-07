import 'package:audio_progress_bar/audio_progress_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AudioPlayerManager manager;
  late AudioPlayerManager manager1;

  @override
  void initState() {
    manager = AudioPlayerManager.network(
      url: "https://cricscore.b-cdn.net/notifications/Secrets_of_Timing-%2030.mp3",
      sliderType: SliderType.circular,
    );
    manager1 = AudioPlayerManager.network(
      url: "https://cricscore.b-cdn.net/notifications/Secrets_of_Timing-%2030.mp3",
      sliderType: SliderType.linear,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blue,
          title: const Text('Smooth Audio Progress bar',style: TextStyle(color: Colors.white),),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AudioProgressBar(
                audioPlayerManager: manager,
                onChanged: (value) {
                  manager1.seekTo(Duration(milliseconds: value.toInt()));
                },
              ),
              AudioProgressBar(
                audioPlayerManager: manager1,
                onChanged: (value) {
                  manager.seekTo(Duration(milliseconds: value.toInt()));
                },
              ),
              const SizedBox(height: 40),
              StreamBuilder(
                stream: manager.playerStateStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data?.playing ?? false;
                  return IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 36),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        manager.pause();
                        manager1.pause();
                      } else {
                        manager.play();
                        manager1.play();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
