library audio_progress_bar;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_progress_bar/src/controller/controller.dart';
import 'package:audio_progress_bar/src/utils/utils.dart';
import 'package:audio_progress_bar/src/widgets/widgets.dart';

import 'src/sleek_circular_slider/src/appearance.dart';
import 'src/sleek_circular_slider/src/circular_slider.dart';

export 'src/controller/controller.dart';
export 'src/utils/utils.dart';
export 'src/widgets/widgets.dart';
export 'src/sleek_circular_slider/sleek_circular_slider.dart';

class AudioProgressBar extends StatefulWidget {
  final AudioPlayerManager _manager;
  final CircularSliderAppearance? circularSliderAppearance;
  final ValueChanged<double>? onChanged;
  final SliderThemeData? sliderTheme;

  AudioProgressBar({
    super.key,
    required AudioPlayerManager audioPlayerManager,
    this.onChanged,
    this.sliderTheme,
    this.circularSliderAppearance,
  })  : _manager = audioPlayerManager,
        assert(
          circularSliderAppearance == null ||
              audioPlayerManager.sliderType != SliderType.linear,
          "You can use circularSliderAppearance with sliderType of SliderType.circular",
        ),
        assert(
            sliderTheme == null ||
                audioPlayerManager.sliderType != SliderType.circular,
            "You can use sliderTheme with sliderType of SliderType.linear");

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget._manager,
      builder: (context, child) {
        return Consumer<AudioPlayerManager>(
          builder: (context, value, child) {
            final manager = value;
            if (manager.hasLoaded) {
              return SmoothAudioProgress(
                playerStateStream: widget._manager.playerStateStream,
                playing: widget._manager.isPlaying,
                duration: widget._manager.duration,
                positionStream: widget._manager.onPositionChanged,
                builder: (context, position, duration, _) => switch (widget._manager.sliderType) {
                  SliderType.linear => _SmoothLinearProgress(
                      position: position,
                      duration: duration,
                      controller: widget._manager,
                      sliderTheme: widget.sliderTheme,
                      onChanged: (value) {
                        if (widget.onChanged != null) {
                          widget.onChanged!.call(value);
                        }
                      },
                    ),
                  _ => _SmoothCircularProgress(
                      circularSliderAppearance: widget.circularSliderAppearance,
                      position: position,
                      duration: duration,
                      maxSeek: Duration(milliseconds: widget._manager.maxSeekInMilliseconds.toInt()),
                      onChange: (value) {
                        widget._manager.seekTo(Duration(milliseconds: value.toInt()));
                        if (widget.onChanged != null) {
                          widget.onChanged!.call(value);
                        }
                      },
                      onPositionChange: (value) {
                        if (widget._manager.maxSeekInMilliseconds < value) {
                          widget._manager.maxSeekInMilliseconds = value;
                        }
                      },
                    ),
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}

class _SmoothLinearProgress extends StatelessWidget {
  const _SmoothLinearProgress({
    required this.position,
    required this.duration,
    required this.controller,
    required this.onChanged,
    this.sliderTheme,
  });

  final Duration position;
  final Duration duration;
  final AudioPlayerManager controller;
  final SliderThemeData? sliderTheme;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, max).toDouble();
    return SliderTheme(
      data: sliderTheme ?? const SliderThemeData(activeTrackColor: Colors.blue),
      child: Slider(
        min: 0,
        max: max,
        value: value,
        thumbColor: Colors.white,
        onChanged: (value) {
          controller.seekTo(Duration(milliseconds: value.toInt()));
          onChanged.call(value);
        },
        onChangeStart: (_) => controller.pause(),
        onChangeEnd: (_) => controller.play(),
      ),
    );
  }
}

class _SmoothCircularProgress extends StatelessWidget {
  const _SmoothCircularProgress({
    // super.key,
    required this.position,
    required this.duration,
    required this.maxSeek,
    required this.onChange,
    required this.onPositionChange,
    this.innerWidget,
    this.innerWidgetTextStyle,
    this.circularSliderAppearance,
  });

  final Duration position;
  final Duration duration;
  final Duration maxSeek;
  final Function(double) onChange;
  final Function(double) onPositionChange;
  final Widget? innerWidget;
  final TextStyle? innerWidgetTextStyle;
  final CircularSliderAppearance? circularSliderAppearance;

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, max).toDouble();
    final maxSeekValue = maxSeek.inMilliseconds.clamp(0, max).toDouble();
    onPositionChange.call(value);
    return SleekCircularSlider(
      min: 0,
      max: max,
      maxSeek: maxSeekValue,
      initialValue: value,
      innerWidget: (percentage) => Center(
        child: innerWidget ??
            Text(
              "${(position.inMinutes).toString().padLeft(2, '0')}:${((position.inSeconds) % 60).toString().padLeft(2, '0')}",
              style: innerWidgetTextStyle ??
                  const TextStyle(
                    fontSize: 36,
                  ),
            ),
      ),
      appearance: circularSliderAppearance ??
          CircularSliderAppearance(
            angleRange: 240,
            size: 320,
            customWidths: CustomSliderWidths(
              progressBarWidth: 40,
              trackWidth: 40,
              handlerSize: 20,
            ),
            customColors: CustomSliderColors(
              progressBarColor: Colors.blueAccent,
              trackColor: Colors.grey,
              hideShadow: true,
              dynamicGradient: false,
              dotColor: Colors.white,
            ),
          ),
      onChange: onChange,
    );
  }
}
