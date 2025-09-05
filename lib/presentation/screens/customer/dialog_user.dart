import 'package:flutter/material.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';

class SelectUserDialog<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) displayName;
  final String? Function(T) avatarUrl;

  const SelectUserDialog({
    super.key,
    required this.items,
    required this.displayName,
    required this.avatarUrl,
  });

  @override
  State<SelectUserDialog<T>> createState() => _SelectUserDialogState<T>();
}

class _SelectUserDialogState<T> extends State<SelectUserDialog<T>> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return RadioListTile<int>(
                  value: index,
                  groupValue: selectedIndex,
                  onChanged: (val) => setState(() => selectedIndex = val),
                  title: Text(widget.displayName(item)),
                  secondary: AppAvatar(
                    imageUrl: widget.avatarUrl(item),
                    fallbackText: widget.displayName(item),
                    size: 40,
                    shape: AvatarShape.circle,
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: selectedIndex == null
                ? null
                : () => Navigator.pop(context, widget.items[selectedIndex!]),
            child: const Text("Chọn"),
          ),
        ],
      ),
    );
  }
}
