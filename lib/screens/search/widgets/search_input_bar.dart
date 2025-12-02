import 'package:flutter/material.dart';
import 'package:mobile/widgets/common_input.dart';

class SearchInputBar extends StatefulWidget {
  final void Function(String) onChanged;

  const SearchInputBar({
    super.key,
    required this.onChanged,
  });

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<SearchInputBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return CommonInput(
    icon: Icons.search,
    controller: _controller,
    onChanged: widget.onChanged,
    editable: true,
    hintText: 'Найти...',
    onTap: () {},
    borderRadius: 12,
    backgroundColor: Colors.grey[100]!,
    iconColor: Colors.black45,
    textColor: Colors.black87,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    padding: EdgeInsets.zero,
  );
}
}
