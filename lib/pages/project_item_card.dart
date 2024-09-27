import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/semantic_line.dart';
import 'package:frc_stategy_app/widgets/conditional_widget.dart';
import 'package:frc_stategy_app/widgets/field/field_painter.dart';

class ProjectItemCard extends StatefulWidget {
  final String name;
  final VoidCallback onOpened;
  final VoidCallback? onDeleted;
  final bool compact;
  final String? warningMessage;
  final bool showOptions;
  final bool choreoItem;

  const ProjectItemCard({
    super.key,
    required this.name,
    required this.onOpened,
    this.onDeleted,
    this.compact = false,
    this.warningMessage,
    this.showOptions = true,
    this.choreoItem = false,
  });

  @override
  State<ProjectItemCard> createState() => _ProjectItemCardState();
}

class _ProjectItemCardState extends State<ProjectItemCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          color: colorScheme.surface,
          surfaceTintColor: colorScheme.surfaceTint,
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 38,
                  color: Colors.white.withOpacity(0.05),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.name,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      if (widget.showOptions)
                        FittedBox(
                          child: PopupMenuButton<String>(
                            tooltip: '',
                            onSelected: (value) {
                            },
                            itemBuilder: (_) {
                              return const [
                                PopupMenuItem(
                                  value: 'duplicate',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy),
                                      SizedBox(width: 12),
                                      Text('Duplicate'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_forever),
                                      SizedBox(width: 12),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ConditionalWidget(
                condition: widget.compact,
                trueChild: Expanded(
                  flex: 5,
                  child: InkWell(
                    onTap: widget.onOpened,
                    hoverColor: Colors.white.withOpacity(0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                falseChild: Expanded(
                  flex: 16,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (event) => setState(() {
                      _hovering = true;
                    }),
                    onExit: (event) => setState(() {
                      _hovering = false;
                    }),
                    child: GestureDetector(
                      onTap: widget.onOpened,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/field24.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    opacity: _hovering ? 1.0 : 0.0,
                                    curve: Curves.easeInOut,
                                    duration: const Duration(milliseconds: 200),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5.0, sigmaY: 5.0),
                                      child: Container(),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Center(
                                    child: AnimatedScale(
                                      scale: _hovering ? 1.0 : 0.0,
                                      curve: Curves.easeInOut,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.edit,
                                        color: colorScheme.onSurface,
                                        size: 64,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.warningMessage != null)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: widget.compact
                  ? const EdgeInsets.all(8.0)
                  : const EdgeInsets.all(12.0),
              child: Tooltip(
                message: widget.warningMessage,
                child: FittedBox(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: widget.compact ? 32 : 48,
                    color: Colors.yellow,
                    shadows: widget.compact
                        ? null
                        : const [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            )
                          ],
                  ),
                ),
              ),
            ),
          ),
        if (false) //TODO: lol
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'images/choreo.png',
                filterQuality: FilterQuality.medium,
                width: widget.compact ? 32 : 40,
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: Text(
              'Are you sure you want to delete the file: ${widget.name}? This cannot be undone.\n\nIf this is a path, any autos using it will have their reference to it removed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeleted?.call();
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }
}