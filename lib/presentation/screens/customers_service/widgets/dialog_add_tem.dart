import 'package:flutter/material.dart';

class LabelData {
  final String name;
  final Color color;
  LabelData({required this.name, required this.color});
}

class CreateLabelDialog extends StatefulWidget {
  const CreateLabelDialog({super.key});

  @override
  State<CreateLabelDialog> createState() => _CreateLabelDialogState();
}

class _CreateLabelDialogState extends State<CreateLabelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  Color? _selected;

  static const List<Color> _palette = [
    Color(0xFFEA4335),
    Color(0xFFFB8C00),
    Color(0xFFFFB74D),
    Color(0xFFFDD835),
    Color(0xFF7CB342),
    Color(0xFF4CAF50),
    Color(0xFF26C6DA),
    Color(0xFF29B6F6),
    Color(0xFF4285F4),
    Color(0xFF7E57C2),
    Color(0xFF7C4DFF),
    Color(0xFFE57373),
    Color(0xFFD81B60),
    Color(0xFF757575),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool checkValidate() {
    return (_formKey.currentState?.validate() ?? false) && _selected != null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Expanded(child: Text('Tạo nhãn mới')),
          IconButton(
            tooltip: 'Đóng',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(text: 'Tên nhãn '),
                      TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Nhập tên nhãn',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập tên'
                    : null,
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(text: 'Màu sắc '),
                      TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ColorGrid(
                colors: _palette,
                selected: _selected,
                onSelect: (c) => setState(() => _selected = c),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: checkValidate()
              ? () => Navigator.of(context).pop(LabelData(
                    name: _controller.text.trim(),
                    color: _selected!,
                  ))
              : null,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final List<Color> colors;
  final Color? selected;
  final ValueChanged<Color> onSelect;

  const _ColorGrid({
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((c) {
        final isSelected = selected == c;
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onSelect(c),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
              border: Border.all(
                width: isSelected ? 3 : 0,
                color:
                    isSelected ? const Color(0xFF1A73E8) : Colors.transparent,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 1.5,
                  offset: Offset(0, 0.5),
                  color: Color(0x1F000000),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
