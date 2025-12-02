import 'dart:async';

import 'package:flutter/material.dart';

class CommonInput extends StatefulWidget {
  // 👇 оставь все параметры как есть
  final String? text;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool editable;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final Color backgroundColor;
  final double borderRadius;
  final Color iconColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;

  const CommonInput({
    super.key,
    this.text,
    required this.icon,
    this.onTap,
    this.enabled = true,
    this.editable = false,
    this.controller,
    this.onChanged,
    this.hintText,
    this.backgroundColor = const Color(0xFFF0F0F0),
    this.borderRadius = 8.0,
    this.iconColor = Colors.grey,
    this.textColor = Colors.grey,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 8),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<CommonInput> createState() => _CommonInputState();
}

class _CommonInputState extends State<CommonInput> {
  late FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChangedDebounced(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged?.call(value);
    });
    setState(() {}); // обновим крестик
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final showClear =
        widget.editable && widget.enabled && (widget.controller?.text.isNotEmpty ?? false);

    final content = widget.editable
        ? TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            onChanged: _onChangedDebounced,
            enabled: widget.enabled,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Найти...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(color: widget.textColor),
          )
        : Text(
            widget.text ?? '',
            style: TextStyle(color: widget.textColor),
            overflow: TextOverflow.ellipsis,
          );

    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: widget.contentPadding,
      
      decoration: BoxDecoration(
        color: isFocused
            ? widget.backgroundColor.withAlpha((0.95 * 255).round())
            : widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            widget.icon,
            color: isFocused
                ? widget.iconColor.withAlpha((0.9 * 255).round())
                : widget.iconColor.withAlpha((0.6 * 255).round()),

          ),
          const SizedBox(width: 8),
          Expanded(child: content),
          if (showClear)
            GestureDetector(
              onTap: () {
                widget.controller?.clear();
                widget.onChanged?.call('');
                setState(() {});
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.clear, size: 18, color: Colors.grey),
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: widget.padding,
      child: widget.enabled && widget.onTap != null && !widget.editable
          ? GestureDetector(onTap: widget.onTap, child: container)
          : container,
    );
  }
}
