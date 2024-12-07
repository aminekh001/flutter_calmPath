import 'package:flutter/material.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions; // Add actions for customization
  final Color? backgroundColor; // Add customizable background color

  const BasicAppBar({
    this.title,
    this.actions,
    this.backgroundColor, // Allow passing a background color
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor?.withOpacity(0.7) ?? Colors.transparent, // Set opacity
      elevation: 0,
      centerTitle: true,
      title: title ?? const Text(''),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 15,
          ),
        ),
      ),
      actions: actions, // Customizable actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
