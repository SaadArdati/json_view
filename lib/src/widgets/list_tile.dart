import 'package:flutter/material.dart';

import '../models/json_config_data.dart';
import 'json_view.dart';
import 'simple_tiles.dart';

class IndexRange {
  final int start;
  final int end;

  IndexRange({
    required this.start,
    required this.end,
  });

  int get length => end - start;
}

class ListTile extends StatefulWidget {
  final String keyName;
  final List items;
  final IndexRange range;
  final bool expanded;
  final int depth;
  final JsonConfigData config;

  const ListTile({
    Key? key,
    required this.keyName,
    required this.items,
    required this.range,
    this.expanded = false,
    required this.depth,
    required this.config,
  }) : super(key: key);

  @override
  State<ListTile> createState() => _ListTileState();
}

class _ListTileState extends State<ListTile> {
  late bool _isExpanded = widget.expanded;
  int _gap = 2;
  List<Widget> _children = [];

  String get _value {
    if (widget.items.isEmpty) return '[]';
    if (_isExpanded) return '';
    if (widget.items.length == 1) return '[0]';
    if (widget.items.length == 2) return '[0, 1]';
    return '[${widget.range.start} ... ${widget.range.end}]';
  }

  void _changeState() {
    if (widget.items.isNotEmpty) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateChildrenIfNeeded();
    checkExpansion();
  }

  void checkExpansion() {
    bool isExpanded = widget.config.style?.openAtStart ?? false;
    int depth = widget.config.style?.depth ?? 0;
    if (widget.items.length > 20) {
      isExpanded = true;
    }

    if (isExpanded != _isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
      });
    }
  }

  void _updateChildrenIfNeeded() {
    bool shouldUpdate =
        _children.isEmpty || _gap != (widget.config.gap ?? JsonConfigData.kGap);

    if (shouldUpdate) {
      _gap = widget.config.gap ?? JsonConfigData.kGap;
      if (widget.items.isEmpty) return;
      if (widget.range.length < _gap) {
        _children.clear();
        for (var i = 0; i <= widget.range.length; i++) {
          _children.add(
            getIndexedItem(
              index: i,
              value: widget.items[i],
              depth: widget.depth + 1,
              config: widget.config,
            ),
          );
        }
      } else {
        _children = _getGapChildren();
      }
    }
  }

  List<Widget> _getGapChildren() {
    List<Widget> gapChildren = [];
    int currentGap = _gap;
    while (widget.range.length / currentGap > _gap) {
      currentGap *= _gap;
    }
    int divide = widget.range.length ~/ currentGap;
    int dividedLength = currentGap * divide;
    late int gapSize;
    if (dividedLength == widget.items.length) {
      gapSize = divide;
    } else {
      gapSize = divide + 1;
    }

    for (var i = 0; i < gapSize; i++) {
      int startIndex = widget.range.start + i * currentGap;
      int endIndex = widget.range.end;
      gapChildren.add(
        ListTile(
          keyName: '[$i]',
          items: widget.items,
          range: i != gapSize - 1
              ? IndexRange(start: startIndex, end: startIndex + currentGap - 1)
              : IndexRange(start: startIndex, end: endIndex),
          expanded: widget.expanded,
          depth: widget.depth + 1,
          config: widget.config,
        ),
      );
    }
    return gapChildren;
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
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _children.length,
              itemBuilder: (context, index) {
                return _children[index];
              },
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
