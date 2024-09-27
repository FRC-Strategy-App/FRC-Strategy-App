import 'dart:async';
import 'dart:math';

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/constants.dart';
import 'package:frc_stategy_app/classes/drawing_data.dart';
import 'package:frc_stategy_app/pages/project_item_card.dart';
import 'package:frc_stategy_app/widgets/conditional_widget.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undo/undo.dart';
import 'package:watcher/watcher.dart';

class ProjectPage extends StatefulWidget {
  final SharedPreferences prefs;
  final Directory pathplannerDirectory;
  final FileSystem fs;
  final bool shortcuts;
  final bool hotReload;
  final VoidCallback? onFoldersChanged;
  final bool simulatePath;
  final bool watchChorDir;

  // Stupid workaround to get when settings are updated
  static bool settingsUpdated = false;

  const ProjectPage({
    super.key,
    required this.prefs,
    required this.pathplannerDirectory,
    required this.fs,
    this.shortcuts = true,
    this.hotReload = false,
    this.onFoldersChanged,
    this.simulatePath = false,
    this.watchChorDir = false,
  });

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final MultiSplitViewController _controller = MultiSplitViewController();
  List<String> _pathFolders = [];
  List<DrawingData> _drawings = [];
  List<String> _drawingFolders = [];
  late Directory _drawingsDirectory;
  late String _drawSortValue;
  late bool _drawCompact;
  late int _drawingsGridCount;
  DirectoryWatcher? _chorWatcher;
  StreamSubscription<WatchEvent>? _chorWatcherSub;

  bool _loading = true;

  String? _drawingsFolder;

  final GlobalKey _addDrawingKey = GlobalKey();

  FileSystem get fs => widget.fs;

  @override
  void initState() {
    super.initState();

    double leftWeight = widget.prefs.getDouble(PrefsKeys.projectLeftWeight) ??
        Defaults.projectLeftWeight;
    _controller.areas = [
      Area(
        weight: leftWeight,
        minimalWeight: 0.33,
      ),
      Area(
        weight: 1.0 - leftWeight,
        minimalWeight: 0.33,
      ),
    ];

    _drawSortValue = widget.prefs.getString(PrefsKeys.drawingSortOption) ??
        Defaults.drawingSortOption;
    _drawCompact = widget.prefs.getBool(PrefsKeys.drawingCompactView) ??
        Defaults.drawingsCompactView;

    _drawingsGridCount = _getCrossAxisCountForWeight(1.0 - leftWeight);

    _pathFolders = widget.prefs.getStringList(PrefsKeys.pathFolders) ??
        Defaults.pathFolders;
    _drawingFolders = widget.prefs.getStringList(PrefsKeys.drawingFolders) ??
        Defaults.drawingFolders;

    _load();
  }

  @override
  void dispose() {
    _chorWatcherSub?.cancel();

    super.dispose();
  }

  void _load() async {
    // Make sure dirs exist
    _drawingsDirectory =
        fs.directory(join(widget.pathplannerDirectory.path, 'drawings'));
    _drawingsDirectory.createSync(recursive: true);

    // Load drawings
    var drawings = await DrawingData.loadAllDrawingsInDir(_drawingsDirectory.path, fs);
    
    // for (int i = 0; i < autos.length; i++) {
    //   if (!_autoFolders.contains(autos[i].folder)) {
    //     autos[i].folder = null;
    //   }
    // }

    setState(() {
      _drawings = drawings;
      _drawingsFolder = null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: colorScheme.surfaceTint.withOpacity(0.05),
            child: MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerPainter: DividerPainters.grooved1(
                  color: colorScheme.surfaceContainerHighest,
                  highlightedColor: colorScheme.primary,
                ),
              ),
              child: MultiSplitView(
                axis: Axis.horizontal,
                controller: _controller,
                onWeightChange: () {
                  setState(() {
                    _drawingsGridCount = _getCrossAxisCountForWeight(
                        1.0 - _controller.areas[0].weight!);
                  });
                  widget.prefs.setDouble(PrefsKeys.projectLeftWeight,
                      _controller.areas[0].weight ?? Defaults.projectLeftWeight);
                },
                children: [
                  _buildDrawingGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCountForWeight(double weight) {
    if (weight < 0.4) {
      return 1;
    } else if (weight < 0.6) {
      return 2;
    } else {
      return 3;
    }
  }

  Widget _buildDrawingGrid(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Card(
        elevation: 0.0,
        margin: const EdgeInsets.all(0),
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      _drawingsFolder ?? 'Drawings',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  Expanded(child: Container()),
                  ConditionalWidget(
                    condition: _drawingsFolder == null,
                    falseChild: Tooltip(
                      message: 'Delete drawing folder',
                      waitDuration: const Duration(seconds: 1),
                      child: IconButton.filledTonal(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Folder'),
                                  content: SizedBox(
                                    width: 400,
                                    child: Text(
                                        'Are you sure you want to delete the folder "$_drawingsFolder"?\n\nThis will also delete all drawings within the folder. This cannot be undone.'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: Navigator.of(context).pop,
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        //TODO: does nothing
                                      },
                                      child: const Text('DELETE'),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(Icons.delete_forever),
                      ),
                    ),
                    trueChild: Tooltip(
                      message: 'Add new drawing folder',
                      waitDuration: const Duration(seconds: 1),
                      child: IconButton.filledTonal(
                        onPressed: () {
                          String folderName = 'New Folder';
                          while (_drawingFolders.contains(folderName)) {
                            folderName = 'New $folderName';
                          }
                        },
                        icon: const Icon(Icons.create_new_folder_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Add new drawing',
                    waitDuration: const Duration(seconds: 1),
                    child: IconButton.filled(
                      key: _addDrawingKey,
                      onPressed: () {
                          _createNewDrawing();
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const Divider(),
              _buildOptionsRow(
                sortValue: _drawSortValue,
                viewValue: _drawCompact,
                onSortChanged: (value) {
                  widget.prefs.setString(PrefsKeys.drawingSortOption, value);
                },
                onViewChanged: (value) {
                  widget.prefs.setBool(PrefsKeys.drawingCompactView, value);
                  setState(() {
                    _drawCompact = value;
                  });
                },
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ConditionalWidget(
                      condition: _drawingsFolder == null,
                      falseChild: GridView.count(
                        crossAxisCount: _drawingsGridCount,
                        childAspectRatio: 5.5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          DragTarget<DrawingData>(
                            onAcceptWithDetails: (details) {
                              setState(() {
                                //TODO: DOES NOTHING :)
                                // details.data.folder = null;
                                // details.data.saveFile();
                              });
                            },
                            builder: (context, candidates, rejects) {
                              ColorScheme colorScheme =
                                  Theme.of(context).colorScheme;
                              return Card(
                                elevation: 2,
                                color: candidates.isNotEmpty
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                                surfaceTintColor: colorScheme.surfaceTint,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() {
                                      _drawingsFolder = null;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.drive_file_move_rtl_outlined,
                                          color: candidates.isNotEmpty
                                              ? colorScheme.onPrimary
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Root Folder',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: candidates.isNotEmpty
                                                    ? colorScheme.onPrimary
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      trueChild: GridView.count(
                        crossAxisCount: _drawingsGridCount,
                        childAspectRatio: 5.5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (int i = 0; i < _drawingFolders.length; i++)
                            DragTarget<DrawingData>(
                              onAcceptWithDetails: (details) {
                                setState(() {
                                  //TODO: Does nothing :)
                                  // details.data.folder = _autoFolders[i];
                                  // details.data.saveFile();
                                });
                              },
                              builder: (context, candidates, rejects) {
                                ColorScheme colorScheme =
                                    Theme.of(context).colorScheme;
                                return Card(
                                  elevation: 2,
                                  color: candidates.isNotEmpty
                                      ? colorScheme.primary
                                      : colorScheme.surface,
                                  surfaceTintColor: colorScheme.surfaceTint,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      setState(() {
                                        _drawingsFolder = _drawingFolders[i];
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.folder_outlined,
                                            color: candidates.isNotEmpty
                                                ? colorScheme.onPrimary
                                                : null,
                                          ),
                                          Expanded(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: 
                                                Text(
                                                  _drawingFolders[i],
                                                  style: const TextStyle(fontSize: 20)
                                                ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    if (_drawingFolders.isNotEmpty) const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount:
                          _drawCompact ? _drawingsGridCount + 1 : _drawingsGridCount,
                      childAspectRatio: _drawCompact ? 2.5 : 1.55,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        for (int i = 0; i < _drawings.length; i++)
                          if (true) //TODO: fix lol __paths[i].folder == _pathFolder 
                            _buildDrawingCard(i, context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewDrawing() {
    setState(() {
      //TODO: does NOTHING
    });
  }

  Widget _buildDrawingCard(int i, BuildContext context) {
    String? warningMessage;

    final drawingCard = ProjectItemCard(
      name: _drawings[i].fileName ?? 'Unnamed Drawing',
      compact: _drawCompact,
      onDeleted: () {
        // _autos[i].delete();
        setState(() {
          _drawings.removeAt(i);
        });
      },
      onOpened: () async {
        //TODO: does nothing
      },
      warningMessage: warningMessage,
    );

    return LayoutBuilder(builder: (context, constraints) {
      return Draggable<DrawingData>(
        data: _drawings[i],
        feedback: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Opacity(
            opacity: 0.8,
            child: drawingCard,
          ),
        ),
        childWhenDragging: Container(),
        child: drawingCard,
      );
    });
  }

  Widget _buildOptionsRow({
    required String sortValue,
    required bool viewValue,
    required ValueChanged<String> onSortChanged,
    required ValueChanged<bool> onViewChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Sort:',
                style: TextStyle(fontSize: 16),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  color: Colors.transparent,
                  child: PopupMenuButton<String>(
                    initialValue: sortValue,
                    tooltip: '',
                    elevation: 12.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: onSortChanged,
                    itemBuilder: (context) => _sortOptions(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _sortLabel(sortValue),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                'View:',
                style: TextStyle(fontSize: 16),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  color: Colors.transparent,
                  child: PopupMenuButton<bool>(
                    initialValue: viewValue,
                    tooltip: '',
                    elevation: 12.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: onViewChanged,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: false,
                        child: Text('Default'),
                      ),
                      PopupMenuItem(
                        value: true,
                        child: Text('Compact'),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(viewValue ? 'Compact' : 'Default',
                              style: const TextStyle(fontSize: 16)),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PopupMenuItem<String>> _sortOptions() {
    return const [
      PopupMenuItem(
        value: 'recent',
        child: Text('Recent'),
      ),
      PopupMenuItem(
        value: 'nameAsc',
        child: Text('Name Ascending'),
      ),
      PopupMenuItem(
        value: 'nameDesc',
        child: Text('Name Descending'),
      ),
    ];
  }

  Widget _sortLabel(String optionValue) {
    return switch (optionValue) {
      'recent' => const Text('Recent', style: TextStyle(fontSize: 16)),
      'nameDesc' =>
        const Text('Name Descending', style: TextStyle(fontSize: 16)),
      'nameAsc' => const Text('Name Ascending', style: TextStyle(fontSize: 16)),
      _ => throw FormatException('Invalid sort value', optionValue),
    };
  }

}