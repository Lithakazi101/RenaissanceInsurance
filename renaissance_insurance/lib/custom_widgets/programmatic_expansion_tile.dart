// This is a fixed version of the ProgrammaticExpansionTile from
// drag_and_drop_lists package that fixes the subtitle1 deprecation
// Original: https://github.com/phillip-earth/drag_and_drop_lists/blob/master/lib/programmatic_expansion_tile.dart

import 'package:flutter/material.dart';

/// A configurable expansion tile that shows a header with a title and an arrow.
/// The arrow changes based on the expanded state.
/// The contents are then expanded when tapped or programmatically.
class ProgrammaticExpansionTile extends StatefulWidget {
  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// The color to display behind the sublist when expanded.
  final Color? backgroundColor;

  /// A widget to display instead of a rotating arrow icon.
  final Widget? trailing;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  const ProgrammaticExpansionTile({
    super.key,
    required this.title,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.backgroundColor,
    this.trailing,
    this.initiallyExpanded = false,
  });

  @override
  ProgrammaticExpansionTileState createState() =>
      ProgrammaticExpansionTileState();
}

/// State for [ProgrammaticExpansionTile].
///
/// See [showExpansion] for an example of how to control the expansion of the tile.
class ProgrammaticExpansionTileState extends State<ProgrammaticExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));

    _isExpanded = PageStorage.of(context).readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Sets the expansion state of tile.
  ///
  /// Call this method with [expand] set to true to expand the tile, or false to collapse it.
  void setExpanded(bool expand) {
    _setExpanded(expand);
  }

  /// Returns whether this tile is currently expanded.
  bool get isExpanded => _isExpanded;

  void _setExpanded(bool expand) {
    if (expand != _isExpanded) {
      setState(() {
        _isExpanded = expand;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse().then<void>((void value) {
            if (!mounted) return;
            setState(() {
              // Rebuild without widget.children.
            });
          });
        }
        PageStorage.of(context).writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged!(_isExpanded);
      }
    }
  }

  void _handleTap() {
    _setExpanded(!_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor: Theme.of(context).colorScheme.secondary,
            child: ListTile(
              onTap: _handleTap,
              title: widget.title,
              trailing: widget.trailing ??
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(Icons.expand_more),
                  ),
            ),
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.center,
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}

/// A configurable widget that expands a child when tapped.
/// Very similar to [ProgrammaticExpansionTile], but allows for any kind of content.
class ProgrammaticExpander extends StatefulWidget {
  /// Main content that's always visible.
  final Widget child;

  /// Contents that appear/disappear when expanded.
  final Widget expandedContent;

  /// Whether to start expanded.
  final bool initiallyExpanded;

  /// Custom background color.
  final Color? backgroundColor;

  /// Called when expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// Function that builds the expansion indicator icon.
  ///
  /// If null, a default rotating 'expand_more' icon is used.
  /// If provided, it's called with the current expansion state.
  final Widget Function(BuildContext context, bool isExpanded)? arrowBuilder;

  /// Position for the expansion indicator icon.
  final ArrowPosition arrowPosition;

  const ProgrammaticExpander({
    super.key,
    required this.child,
    required this.expandedContent,
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.onExpansionChanged,
    this.arrowBuilder,
    this.arrowPosition = ArrowPosition.right,
  });

  @override
  ProgrammaticExpanderState createState() => ProgrammaticExpanderState();
}

/// State for [ProgrammaticExpander].
///
/// Allows programmatic control of the expansion using [setExpanded].
class ProgrammaticExpanderState extends State<ProgrammaticExpander>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));

    _isExpanded = PageStorage.of(context).readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setExpanded(!_isExpanded);
  }

  /// Controls the expansion state, true to expand, false to collapse.
  void setExpanded(bool expand) {
    if (expand == _isExpanded) return;

    setState(() {
      _isExpanded = expand;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });

    if (widget.onExpansionChanged != null) {
      widget.onExpansionChanged!(_isExpanded);
    }
  }

  Widget _buildRotatingArrow() {
    return RotationTransition(
      turns: _iconTurns,
      child: const Icon(Icons.expand_more),
    );
  }

  Widget _buildContents() {
    final ThemeData theme = Theme.of(context);
    final bool closed = !_isExpanded && _controller.isDismissed;

    // Default arrow builder uses a rotating expand_more icon
    Widget arrow = widget.arrowBuilder != null
        ? widget.arrowBuilder!(context, _isExpanded)
        : _buildRotatingArrow();

    Widget mainContents;
    if (widget.arrowPosition == ArrowPosition.left) {
      mainContents = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          arrow,
          const SizedBox(width: 8),
          Expanded(child: widget.child),
        ],
      );
    } else {
      mainContents = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: widget.child),
          const SizedBox(width: 8),
          arrow,
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: mainContents,
            ),
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.center,
              heightFactor: _heightFactor.value,
              child: closed ? null : widget.expandedContent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (context, _) => _buildContents(),
    );
  }
}

/// Defines positions for the expansion arrow in [ProgrammaticExpander].
enum ArrowPosition {
  left,
  right,
} 