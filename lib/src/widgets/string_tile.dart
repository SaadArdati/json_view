import 'package:flutter/material.dart';
import 'package:json_view/src/widgets/simple_tiles.dart';

import '../../json_view.dart';

class StringTile extends StatefulWidget {
  final String keyName;
  final String value;
  final JsonConfigData config;

  const StringTile({
    super.key,
    required this.keyName,
    required this.value,
    required this.config,
  });

  @override
  State<StringTile> createState() => _StringTileState();
}

class _StringTileState extends State<StringTile> {
  final GlobalKey _key = GlobalKey();

  bool expanded = false;
  bool doesFit = true;
  late String parsedKey;

  String getParsedKeyName(JsonConfigData config) {
    final quotation = config.style?.quotation ?? const JsonQuotation();
    if (quotation.isEmpty) return widget.keyName;
    return '${quotation.leftQuote}${widget.keyName}${quotation.rightQuote}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    parsedKey = getParsedKeyName(widget.config);
    checkIfCanFit();
  }

  @override
  void didUpdateWidget(covariant StringTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool recalculateText = false;
    if (oldWidget.keyName != widget.keyName) {
      parsedKey = getParsedKeyName(widget.config);
      recalculateText = true;
    } else if (oldWidget.value != widget.value) {
      recalculateText = true;
    } else {
      final newParsedKey = getParsedKeyName(widget.config);
      if (parsedKey != newParsedKey) {
        parsedKey = newParsedKey;
        recalculateText = true;
      }
    }

    if (recalculateText) {
      checkIfCanFit();
    }
  }

  void checkIfCanFit() {
    if (widget.config.style?.charactersBeforeCutoff != null) {
      final String fullText = '$parsedKey: "${widget.value}"';

      if (fullText.length > widget.config.style!.charactersBeforeCutoff!) {
        if (doesFit) {
          setState(() {
            doesFit = false;
          });
        }
      } else {
        if (!doesFit) {
          setState(() {
            doesFit = true;
          });
        }
      }
      return;
    }
    final double maxWidth = _key.currentContext?.size?.width ?? double.infinity;

    final text = TextSpan(
      children: [
        KeySpan(
          keyValue: parsedKey,
          style: widget.config.style?.keysStyle,
        ),
        const ColonSpan(),
        ValueSpan(
          value: '"${widget.value}"',
          style: widget.config.style?.valuesStyle,
        ),
      ],
    );
    final painter = TextPainter(
      text: text,
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    final realRenderWidth = painter.width;

    if (realRenderWidth > maxWidth) {
      if (!doesFit) {
        setState(() {
          doesFit = true;
        });
      }
    } else {
      if (doesFit) {
        setState(() {
          doesFit = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      key: _key,
      builder: (context) {
        if (!doesFit) {
          Widget result;
          if (expanded) {
            result = _StringInnerTile(
              keyName: widget.keyName,
              value: widget.value,
              config: widget.config,
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            );
          } else {
            result = _StringOnlyDisplayTile(
              keyName: widget.keyName,
              value: widget.value,
              config: widget.config,
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            );
          }

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
        } else {
          return _StringInnerTile(
            keyName: widget.keyName,
            value: widget.value,
            config: widget.config,
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
          );
        }
      },
    );
  }
}

class _StringInnerTile extends KeyValueTile {
  const _StringInnerTile({
    required super.keyName,
    required String value,
    super.maxLines,
    super.onTap,
    required super.config,
  }) : super(
          value: '"$value"',
        );

  @override
  Color valueColor(BuildContext context) =>
      colorScheme(context).stringColor ?? Colors.orange;
}

class _StringOnlyDisplayTile extends _StringInnerTile {
  const _StringOnlyDisplayTile({
    required super.keyName,
    required super.value,
    super.onTap,
    required super.config,
  }) : super(
          maxLines: 1,
        );

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme(context);
    final spans = <InlineSpan>[
      KeySpan(
        keyValue: parsedKeyName(context),
        style: keyStyle(context).copyWith(color: cs.normalColor ?? Colors.grey),
      ),
      ColonSpan(
        style:
            keyStyle(context).copyWith(color: cs.markColor ?? Colors.white70),
      ),
      buildValue(context),
    ];

    Widget result = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(children: spans),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (leading == null) {
      result = Padding(padding: const EdgeInsets.only(left: 16), child: result);
    } else {
      result = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(child: leading),
          Expanded(child: result),
        ],
      );
    }

    return result;
  }
}
