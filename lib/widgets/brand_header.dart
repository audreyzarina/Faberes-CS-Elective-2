import 'package:material_ui/material_ui.dart';

import '../core/config.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.local_cafe, size: 34, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(height: 12),
        Text(AppConfig.appName, style: text.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
