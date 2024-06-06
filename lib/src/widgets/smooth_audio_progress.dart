part of 'widgets.dart';

class SmoothAudioProgress extends StatefulWidget {
  const SmoothAudioProgress({super.key,
    required this.builder,
    this.child,
    required this.positionStream,
    required this.playerStateStream,
    required this.playing,
    this.duration,
  });

  final Widget Function(BuildContext context, Duration progress, Duration duration, Widget? child) builder;
  final Widget? child;
  final Stream<Duration> positionStream;
  final Stream<PlayerState> playerStateStream;
  final bool playing;
  final Duration? duration;

  @override
  _SmoothAudioProgressState createState() => _SmoothAudioProgressState();

}

class _SmoothAudioProgressState extends State<SmoothAudioProgress> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<PlayerState> _stateSubscription;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _positionSubscription = widget.positionStream.listen(_onPositionChange);
    _stateSubscription = widget.playerStateStream.listen(_onPlayerStateChange);
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _stateSubscription.cancel();
    _animationController.dispose();
    _disposed = true;
    super.dispose();
  }

  void _onPositionChange(Duration position) {
    if (_disposed) return;
    final value = _animationController.value;
    final currentPosition = Duration(milliseconds: (value * position.inMilliseconds).round());
    final offset = position - currentPosition;
    final correct = widget.playing && offset.inMilliseconds > -500 && offset.inMilliseconds < -50;
    final correction = const Duration(milliseconds: 500) - offset;
    print('_onPositionChange: correct: $correct offset: $offset correction: $correction');
    final targetPos = correct ? value : position.inMilliseconds / (widget.duration?.inMilliseconds ?? 0);
    final duration = correct ? widget.duration! + correction : widget.duration ?? Duration.zero;

    _animationController.duration = duration;
    if (widget.playing) {
      _animationController.forward(from: targetPos);
    } else {
      _animationController.value = position.inMilliseconds / duration.inMilliseconds;
    }
  }

  void _onPlayerStateChange(PlayerState state) {
    if (_disposed) return;
    if (state.playing) {
      _animationController.forward(from: _animationController.value);
    } else {
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final progressMillis = _animationController.value * (widget.duration?.inMilliseconds ?? 0);
        return widget.builder(
          context,
          Duration(milliseconds: progressMillis.round()),
          widget.duration ?? Duration.zero,
          child,
        );
      },
      child: widget.child,
    );
  }
}
