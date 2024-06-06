part of 'controller.dart';

abstract mixin class BaseAudioHandler {
  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> seekTo(Duration position);

  Future<void> _setSource();

  Future<void> setVolume(double volume);
}
