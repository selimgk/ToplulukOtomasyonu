import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showHome;
  final bool showBack;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showHome = true,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    
    return AppBar(
      title: Text(title),
      centerTitle: true,
      // Explicitly add leading if requested and possible (or forced)
      // The user wants "Add back button to all screens". 
      // If we are at root, we can't really go back.
      // But we will respect the standard behavior: Show if we can pop.
      leading: showBack && canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: [
        if (showHome)
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Ana Sayfa',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
