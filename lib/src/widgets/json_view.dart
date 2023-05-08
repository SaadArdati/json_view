import 'package:flutter/widgets.dart';
import 'package:json_view/src/widgets/string_tile.dart';

import '../../json_view.dart';
import 'list_tile.dart';
import 'map_tile.dart';
import 'simple_tiles.dart';

class JsonView extends StatefulWidget {
  /// {@template json_view.json_view.json}
  /// a json object to be displayed
  ///
  /// normally this is a Map or List
  /// {@endtemplate}
  final dynamic json;

  ///{@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  ///{@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? controller;

  /// arrow widget
  @Deprecated('use JsonStyleScheme.arrowWidget instead')
  final Widget? arrow;

  /// {@macro json_view.json_color_scheme.JsonColorScheme}
  final JsonColorScheme? colorScheme;

  /// {@macro json_view.json_style_scheme.JsonStyleScheme}
  final JsonStyleScheme? styleScheme;

  /// {@macro json_view.json_config_data.JsonConfigData.animation}
  final bool? animation;

  /// {@macro json_view.json_config_data.JsonConfigData.itemPadding}
  final EdgeInsets? itemPadding;

  /// {@macro json_view.json_config_data.JsonConfigData.animationDuration}
  final Duration? animationDuration;

  /// {@macro json_view.json_config_data.JsonConfigData.animationCurve}
  final Curve? animationCurve;

  /// {@macro json_view.json_config_data.JsonConfigData.gap}
  final int? gap;

  /// provider a json view, build with listview
  ///
  /// see more [JsonConfig] to customize the view
  const JsonView({
    Key? key,
    required this.json,
    this.shrinkWrap = false,
    this.padding,
    this.physics,
    this.controller,
    this.arrow,
    this.colorScheme,
    this.styleScheme,
    this.animation,
    this.itemPadding,
    this.animationDuration,
    this.animationCurve,
    this.gap,
  }) : super(key: key);

  @override
  State<JsonView> createState() => _JsonViewState();
}

class _JsonViewState extends State<JsonView> {
  JsonConfigData? config;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      config ??= JsonConfig.of(context);
      if (widget.json is! Map && widget.json is! List) {
        return const Text('unsupport type');
      }
      late IndexedWidgetBuilder builder;
      late int count;
      if (widget.json is Map) {
        final items = (widget.json as Map).entries.toList();
        builder = (context, index) {
          final item = items[index];
          final key = item.key;
          return getParsedItem(
              key: key, value: item.value, depth: 0, config: config!);
        };
        count = items.length;
      } else if (widget.json is List) {
        final items = widget.json as List;
        builder = (context, index) {
          final item = items[index];
          return getIndexedItem(
              index: index, value: item, depth: 0, config: config!);
        };
        count = items.length;
      }
      return ListView.builder(
        primary: false,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        physics: widget.physics,
        controller: widget.controller,
        itemBuilder: builder,
        itemCount: count,
      );
    });
  }
}

class JsonViewBody extends StatefulWidget {
  /// use with caution, it will cause performance issue when json root items is too large
  const JsonViewBody({
    Key? key,
    required this.json,
    this.colorScheme,
    this.styleScheme,
    this.animation,
    this.itemPadding,
    this.animationDuration,
    this.animationCurve,
    this.gap,
  }) : super(key: key);

  /// {@macro json_view.json_view.json}
  final dynamic json;

  /// {@macro json_view.json_color_scheme.JsonColorScheme}
  final JsonColorScheme? colorScheme;

  /// {@macro json_view.json_style_scheme.JsonStyleScheme}
  final JsonStyleScheme? styleScheme;

  /// {@macro json_view.json_config_data.JsonConfigData.animation}
  final bool? animation;

  /// {@macro json_view.json_config_data.JsonConfigData.itemPadding}
  final EdgeInsets? itemPadding;

  /// {@macro json_view.json_config_data.JsonConfigData.animationDuration}
  final Duration? animationDuration;

  /// {@macro json_view.json_config_data.JsonConfigData.animationCurve}
  final Curve? animationCurve;

  /// {@macro json_view.json_config_data.JsonConfigData.gap}
  final int? gap;

  @override
  State<JsonViewBody> createState() => _JsonViewBodyState();
}

class _JsonViewBodyState extends State<JsonViewBody> {
  JsonConfigData? config;
  List<Widget> items = [];

  bool init = false;

  @override
  void didUpdateWidget(covariant JsonViewBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.json != widget.json) {
      populateItems();
    }
  }

  void populateItems() {
    if (widget.json is Map) {
      items = [
        for (final entry in (widget.json as Map).entries)
          getParsedItem(key: entry.key, value: entry.value, config: config!)
      ];
    } else if (widget.json is List) {
      items = [
        for (final item in (widget.json as List))
          getIndexedItem(index: 0, value: item, config: config!)
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // This builder is required because JsonConfig.of(context) returns a null
    // view when called directly, in initState, didChangeDependencies, and in
    // this build method. The builder is the only way to get it to parse a
    // non-null value.
    return Builder(builder: (context) {
      if (!init) {
        init = true;
        config ??= JsonConfig.of(context);
        populateItems();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: items,
      );
    });
  }
}

/// get a tile Widget from value & key
Widget getParsedItem({
  required String key,
  required dynamic value,
  required JsonConfigData config,
  int depth = 0,
}) {
  if (value == null) return NullTile(keyName: key, config: config);
  if (value is num) return NumTile(keyName: key, value: value, config: config);
  if (value is bool) {
    return BoolTile(keyName: key, value: value, config: config);
  }
  if (value is String) {
    return StringTile(keyName: key, value: value, config: config);
  }
  if (value is List) {
    return ListTile(
      keyName: key,
      items: value,
      range: IndexRange(start: 0, end: value.length - 1),
      depth: depth,
      config: config,
      isExpanded:
          config.style?.openFirstLayer == true && depth == 0 ? true : null,
    );
  }
  if (value is Map) {
    return MapTile(
      keyName: key,
      items: [...value.entries],
      depth: depth,
      config: config,
      isExpanded:
          config.style?.openFirstLayer == true && depth == 0 ? true : null,
    );
  }
  return const Text('unsupport type');
}

/// get a tile Widget from value & index
Widget getIndexedItem({
  required int index,
  required dynamic value,
  int depth = 0,
  required JsonConfigData config,
}) {
  return getParsedItem(
      key: '[$index]', value: value, depth: depth, config: config);
}
