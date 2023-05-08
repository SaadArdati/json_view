import 'package:flutter/material.dart';

import '../models/json_config_data.dart';
import 'json_view.dart';
import 'simple_tiles.dart';

class MapTile extends StatefulWidget {
  final String keyName;
  final List<MapEntry> items;
  final bool? isExpanded;
  final int depth;
  final JsonConfigData config;

  const MapTile({
    Key? key,
    required this.keyName,
    required this.items,
    this.isExpanded,
    required this.depth,
    required this.config,
  }) : super(key: key);

  @override
  State<MapTile> createState() => _MapTileState();
}

class _MapTileState extends State<MapTile> {
  late bool _isExpanded = widget.isExpanded ?? false;

  void _changeState() {
    if (mounted && widget.items.isNotEmpty) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  String get _value {
    if (widget.items.isEmpty) return '{}';
    if (_isExpanded) return '';
    return '{ ... }';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkExpansion();
  }

  @override
  void didUpdateWidget(covariant MapTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkExpansion();
  }

  void checkExpansion() {
    bool isExpanded =
        widget.isExpanded ?? widget.config.style?.openAtStart ?? false;
    // int depth = widget.config.style?.depth ?? 0;
    if (widget.isExpanded == null && widget.items.length > 20) {
      isExpanded = true;
    }

    if (isExpanded != _isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
      });
    }
  }

  List<Widget> _buildChildren() {
    return widget.items.map((item) {
      return getParsedItem(
        key: item.key,
        value: item.value,
        depth: widget.depth + 1,
        config: widget.config,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapListTile(
          keyName: widget.keyName,
          value: _value,
          onTap: _changeState,
          expanded: _isExpanded,
          showLeading: widget.items.isNotEmpty,
          config: widget.config,
        ),
        if (_isExpanded)
          Padding(
            padding:
                widget.config.itemPadding ?? const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildChildren(),
            ),
          ),
      ],
    );
    if (widget.config.animation ?? JsonConfigData.kUseAnimation) {
      result = AnimatedSize(
        alignment: Alignment.topCenter,
        duration: widget.config.animationDuration ??
            const Duration(milliseconds: 300),
        curve: widget.config.animationCurve ?? Curves.ease,
        child: result,
      );
    }

    return result;
  }
}
