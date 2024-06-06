Have you been here before: you created a video player using [just_audio](https://pub.dev/packages/just_audio),
but the progress bar updates way to infrequently and makes your UX look choppy?

Look no further than this package. It will make your audio progress bars look smooth ✨

![Demo GIF](https://github.com/slashstar-co/audio_progress_bar/blob/master/demo.gif)

> Since this is a GIF, the framerate is reduced, but rest assured that the bottom slider
animates at the same framerate as your app.

## Features

- Completely unopinianeted, build whatever you want design-wise
- Build a smoothly progress bar for audio player.
- Use it for progress bars, spinners, more accurate time displays, ...
## Getting started

Install the package. This package depends on [flutter_hooks](https://pub.dev/packages/flutter_hooks), because I use it for everything
anyway, check out the package if you don't know it, it makes life so much easier.

## Usage

Here is how you would build a simple slider for example:
```dart
late AudioPlayerManager manager;

@override
  void initState() {
    manager = AudioPlayerManager.network(
      url: "https://cricscore.b-cdn.net/notifications/Secrets_of_Timing-%2030.mp3",
      sliderType: SliderType.linear,
    );
    super.initState();
  }

Widget build(BuildContext context) {
  AudioProgressBar(
    audioPlayerManager: manager,
       onChanged: (value) {},
    );
}
```

## Example Project
To take a look at the example (seen on the GIF above)
1. Open ``example`` folder
2. Run ``flutter create .``
3. ``flutter run`` on the iOS, android or web