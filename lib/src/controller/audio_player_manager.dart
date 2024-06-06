part of 'controller.dart';

class AudioPlayerManager extends ChangeNotifier with BaseAudioHandler {
  bool _mounted = true;
  bool hasLoaded = false;
  bool isPlaying = false;

  final SliderType _sliderType;
  final AudioSource _source;

  final AudioPlayer _player = AudioPlayer();

  SliderType get sliderType => _sliderType;

  Stream<Duration> get onPositionChanged => _player.positionStream;

  Duration? get duration => _player.duration;

  Stream<Duration> get currentDuration => _player.positionStream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  double maxSeekInMilliseconds = 0;

  AudioPlayerManager._internal({
    SliderType? sliderType,
    required AudioSource source,
  })  : _source = source,
        _sliderType = sliderType ?? SliderType.circular {
    _setSource();
  }

  AudioPlayerManager.asset({
    required String assetPath,
    SliderType? sliderType,
  }) : this._internal(
          sliderType: sliderType,
          source: AudioSource.asset(assetPath),
        );

  AudioPlayerManager.network({
    required String url,
    SliderType? sliderType,
  }) : this._internal(
          sliderType: sliderType,
          source: AudioSource.uri(Uri.parse(url)),
        );

  AudioPlayerManager.file({
    required String filePath,
    SliderType? sliderType,
  }) : this._internal(
          sliderType: sliderType,
          source: AudioSource.file(filePath),
        );

  void _notify() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
    isPlaying = true;
    _notify();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    isPlaying = false;
    _notify();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    isPlaying = false;
    _notify();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
    _notify();
  }

  @override
  void dispose() {
    _mounted = false;
    isPlaying = false;
    super.dispose();
  }

  @override
  Future<void> _setSource() async {
    await _player.setAudioSource(_source);
    hasLoaded = true;
    _notify();
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }
}
