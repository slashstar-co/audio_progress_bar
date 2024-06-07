library circular_slider;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'utils.dart';
import 'appearance.dart';
import 'slider_label.dart';
import 'dart:math' as math;

part 'curve_painter.dart';

part 'custom_gesture_recognizer.dart';

typedef OnChange = void Function(double value);
typedef InnerWidget = Widget Function(double percentage);

class SleekCircularSlider extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final double maxSeek;
  final CircularSliderAppearance appearance;
  final OnChange? onChange;
  final OnChange? onChangeStart;
  final OnChange? onChangeEnd;
  final InnerWidget? innerWidget;
  static const defaultAppearance = CircularSliderAppearance();

  double get angle {
    return valueToAngle(initialValue, min, max, appearance.angleRange);
  }

  const SleekCircularSlider(
      {super.key,
      this.initialValue = 50,
      this.min = 0,
      this.max = 100,
      this.maxSeek = 100,
      this.appearance = defaultAppearance,
      this.onChange,
      this.onChangeStart,
      this.onChangeEnd,
      this.innerWidget})
      : assert(min <= max),
        assert(initialValue >= min && initialValue <= max);

  @override
  State<SleekCircularSlider> createState() => _SleekCircularSliderState();
}

class _SleekCircularSliderState extends State<SleekCircularSlider> with SingleTickerProviderStateMixin {
  bool _isHandlerSelected = false;
  _CurvePainter? _painter;
  double? _oldWidgetAngle;
  double? _currentAngle;
  late double _startAngle;
  late double _angleRange;
  double? _selectedAngle;
  double? _rotation;
  late int _appearanceHashCode;

  bool get _interactionEnabled => (widget.onChangeEnd != null || widget.onChange != null);

  @override
  void initState() {
    super.initState();
    _startAngle = widget.appearance.startAngle;
    _angleRange = widget.appearance.angleRange;
    _appearanceHashCode = widget.appearance.hashCode;
  }

  @override
  Widget build(BuildContext context) {
    /// _setupPainter excution when _painter is null or appearance has changed.
    if (_painter == null || _appearanceHashCode != widget.appearance.hashCode) {
      _appearanceHashCode = widget.appearance.hashCode;
      _setupPainter();
    }
    return RawGestureDetector(gestures: <Type, GestureRecognizerFactory>{
      _CustomPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<_CustomPanGestureRecognizer>(
        () => _CustomPanGestureRecognizer(
          onPanDown: _onPanDown,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
        ),
        (_CustomPanGestureRecognizer instance) {},
      ),
    }, child: _buildRotatingPainter(rotation: _rotation, size: Size(widget.appearance.size, widget.appearance.size)));
  }

  void _setupPainter() {
    var defaultAngle = _currentAngle ?? widget.angle;
    if (_oldWidgetAngle != null) {
      if (_oldWidgetAngle != widget.angle) {
        _selectedAngle = null;
        defaultAngle = widget.angle;
      }
    }

    _currentAngle = calculateAngle(
      startAngle: _startAngle,
      angleRange: _angleRange,
      selectedAngle: _selectedAngle,
      defaultAngle: defaultAngle,
    );

    _painter = _CurvePainter(
      startAngle: _startAngle,
      angleRange: _angleRange,
      angle: _currentAngle! < 0.5 ? 0.5 : _currentAngle!,
      appearance: widget.appearance,

    );
    _oldWidgetAngle = widget.angle;
  }

  void _updateOnChange() {
    if (widget.onChange != null) {
      final value = angleToValue(_currentAngle!, widget.min, widget.max, _angleRange);
      widget.onChange!(value);
    }
  }

  Widget _buildRotatingPainter({double? rotation, required Size size}) {
    if (rotation != null) {
      return Transform(
          transform: Matrix4.identity()..rotateZ((rotation) * 5 * math.pi / 6),
          alignment: FractionalOffset.center,
          child: _buildPainter(size: size));
    } else {
      return _buildPainter(size: size);
    }
  }

  Widget _buildPainter({required Size size}) {
    return CustomPaint(
      painter: _painter,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: _buildChildWidget(),
      ),
    );
  }

  Widget? _buildChildWidget() {
    final value = angleToValue(_currentAngle!, widget.min, widget.max, _angleRange);
    final childWidget =
        widget.innerWidget != null ? widget.innerWidget!(value) : SliderLabel(value: value, appearance: widget.appearance);
    return childWidget;
  }

  void _onPanUpdate(Offset details) {
    if (!_isHandlerSelected) {
      return;
    }
    if (_painter?.center == null) {
      return;
    }
    _handlePan(details, false);
  }

  void _onPanEnd(Offset details) {
    _handlePan(details, true);
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd!(angleToValue(_currentAngle!, widget.min, widget.max, _angleRange));
    }

    _isHandlerSelected = false;
  }

  void _handlePan(Offset details, bool isPanEnd) {
    if (_painter?.center == null) {
      return;
    }
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.globalToLocal(details);
    final double touchWidth = widget.appearance.progressBarWidth >= 25.0 ? widget.appearance.progressBarWidth : 25.0;
    if (isPointAlongCircle(position, _painter!.center!, _painter!.radius, touchWidth)) {
      _selectedAngle = coordinatesToRadians(_painter!.center!, position);
      // setup painter with new angle values and update onChange
      _setupPainter();
      _updateOnChange();
      setState(() {});
    }
  }

  bool _onPanDown(Offset details) {
    if (_painter == null || _interactionEnabled == false) {
      return false;
    }
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.globalToLocal(details);

    final angleWithinRange = isAngleWithinRange(
      startAngle: _startAngle,
      angleRange: _angleRange,
      touchAngle: coordinatesToRadians(_painter!.center!, position),
      previousAngle: _currentAngle,
    );
    if (!angleWithinRange) {
      return false;
    }

    final double touchWidth = widget.appearance.progressBarWidth >= 25.0 ? widget.appearance.progressBarWidth : 25.0;

    if (isPointAlongCircle(position, _painter!.center!, _painter!.radius, touchWidth)) {
      _isHandlerSelected = true;
      if (widget.onChangeStart != null) {
        widget.onChangeStart!(angleToValue(_currentAngle!, widget.min, widget.max, _angleRange));
      }
      _onPanUpdate(details);
    } else {
      _isHandlerSelected = false;
    }

    return _isHandlerSelected;
  }
}
