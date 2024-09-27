import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frc_stategy_app/classes/constants.dart';
import 'package:frc_stategy_app/classes/drawing_data.dart';
import 'package:frc_stategy_app/classes/management/save_load_drawing.dart';
import 'package:frc_stategy_app/classes/semantic_line.dart';
import 'package:frc_stategy_app/classes/actions.dart';
import 'package:frc_stategy_app/classes/team.dart';
import 'package:frc_stategy_app/widgets/field/field_painter.dart';
import '../color_picker_button.dart';

enum Tool { pencil, tempPencil, eraser }

enum DrawingPhase { auto, teleop, endgame }

extension ToolExtension on Tool {
  bool get isWritingUtensil {
    return this != Tool.eraser;
  }
}

class FieldDrawing extends StatefulWidget {
  final String? eventKey;
  final String? matchKey;
  final String? phase;
  final ValueNotifier<String> matchNameNotifier;

  const FieldDrawing({
    super.key,
    this.eventKey,
    this.matchKey,
    this.phase,
    required this.matchNameNotifier,
  });

  @override
  FieldDrawingState createState() => FieldDrawingState();
}

class FieldDrawingState extends State<FieldDrawing>
    with SingleTickerProviderStateMixin {
  //phase management TODO: clean up
  Map<DrawingPhase, List<SemanticLine>> phaseLines = {
    DrawingPhase.auto: [],
    DrawingPhase.teleop: [],
    DrawingPhase.endgame: [],
  };
  Map<DrawingPhase, List<SemanticLine>> phaseUndoStack = {
    DrawingPhase.auto: [],
    DrawingPhase.teleop: [],
    DrawingPhase.endgame: [],
  };
  Map<DrawingPhase, List<SemanticLine>> phaseRedoStack = {
    DrawingPhase.auto: [],
    DrawingPhase.teleop: [],
    DrawingPhase.endgame: [],
  };
  Map<DrawingPhase, List<SemanticLine>> phaseErasedStack = {
    DrawingPhase.auto: [],
    DrawingPhase.teleop: [],
    DrawingPhase.endgame: [],
  };
  Map<DrawingPhase, List<SemanticLine>> phaseUndoEraseStack = {
    DrawingPhase.auto: [],
    DrawingPhase.teleop: [],
    DrawingPhase.endgame: [],
  };

  DrawingPhase currentPhase = DrawingPhase.auto;

  //phase-specific
  List<SemanticLine> lines = [];
  List<SemanticLine> undoStack = [];
  List<SemanticLine> redoStack = [];
  List<SemanticLine> erasedStack = [];
  List<SemanticLine> undoEraseStack = [];
  List<Offset> currentLine = [];
  Color selectedColor = Colors.black;
  Tool selectedTool = Tool.pencil;
  bool isDrawingVisible = true;
  SemanticLine? tempLine;
  late AnimationController controller;
  late Animation<double> animation;
  final GlobalKey _containerKey = GlobalKey();

  List<TextEditingController> _leftSidebarControllers = [];
  List<TextEditingController> _rightSidebarControllers = [];

  List<Team> blueAlliance = [
    Team(name: '', color: Colors.red),
    Team(name: '', color: Colors.blue),
    Team(name: '', color: Colors.green),
  ];

  List<Team> redAlliance = [
    Team(name: '', color: Colors.yellow),
    Team(name: '', color: Colors.purple),
    Team(name: '', color: Colors.orange),
  ];
  Team? selectedTeam;

  void _initializeControllers() {
    _leftSidebarControllers = List.generate(3, (index) {
      final controller = TextEditingController(text: blueAlliance[index].name);
      controller.addListener(() {
        setState(() {
          blueAlliance[index].name = controller.text;
        });
      });
      return controller;
    });

    _rightSidebarControllers = List.generate(3, (index) {
      final controller = TextEditingController(text: redAlliance[index].name);
      controller.addListener(() {
        setState(() {
          redAlliance[index].name = controller.text;
        });
      });
      return controller;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedTeam = null;
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    animation = Tween<double>(begin: 1.0, end: 0.0).animate(controller);

    // Initialize controllers with listeners
    _initializeControllers();

    // Load existing drawing data if keys are provided
    if (widget.eventKey != null &&
        widget.matchKey != null &&
        widget.phase != null) {
      loadDrawingData();
    }
  }

  @override
  void dispose() {
    controller.dispose();

    // Save data if keys are provided
    if (widget.eventKey != null &&
        widget.matchKey != null &&
        widget.phase != null) {
      saveDrawingData();
    }

    // Dispose controllers
    for (var controller in _leftSidebarControllers) {
      controller.dispose();
    }
    for (var controller in _rightSidebarControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void updatePhaseData() {
    lines = phaseLines[currentPhase] ?? [];
    undoStack = phaseUndoStack[currentPhase] ?? [];
    redoStack = phaseRedoStack[currentPhase] ?? [];
    erasedStack = phaseErasedStack[currentPhase] ?? [];
    undoEraseStack = phaseUndoEraseStack[currentPhase] ?? [];

    // Update controllers with loaded data
    for (int i = 0; i < blueAlliance.length; i++) {
      _leftSidebarControllers[i].text = blueAlliance[i].name;
    }
    for (int i = 0; i < redAlliance.length; i++) {
      _rightSidebarControllers[i].text = redAlliance[i].name;
    }
  }

  Future<void> loadDrawingData() async {
    Map<String, dynamic> data = await loadDrawing();
    if (data.isNotEmpty) {
      DrawingData drawingData = DrawingData.fromJson(data);
      // Assign the loaded data to the appropriate phases
      for (DrawingPhase phase in DrawingPhase.values) {
        phaseLines[phase] = drawingData.phaseLines[phase] ?? [];
        phaseUndoStack[phase] = drawingData.phaseUndoStack[phase] ?? [];
        phaseRedoStack[phase] = drawingData.phaseRedoStack[phase] ?? [];
        phaseErasedStack[phase] = drawingData.phaseErasedStack[phase] ?? [];
        phaseUndoEraseStack[phase] =
            drawingData.phaseUndoEraseStack[phase] ?? [];
      }
      setState(() {
        blueAlliance = drawingData.blueAlliance;
        redAlliance = drawingData.redAlliance;
        updatePhaseData(); // Update phase data after loading
        String fileName = data['filePath']?.split('\\').last ??
            'Unsaved Match'; // Update match name
        widget.matchNameNotifier.value = fileName.replaceFirst(
            RegExp(r'\.json$'), ''); // Remove file extension
      });
    }
  }

  Future<void> saveDrawingData() async {
    DrawingData data = DrawingData(
      phaseLines: phaseLines,
      phaseUndoStack: phaseUndoStack,
      phaseRedoStack: phaseRedoStack,
      phaseErasedStack: phaseErasedStack,
      phaseUndoEraseStack: phaseUndoEraseStack,
      blueAlliance: blueAlliance,
      redAlliance: redAlliance,
    );

    String? filePath =
        await saveDrawing(widget.eventKey, widget.matchKey, data.toJson());
    setState(() {
      String fileName =
          filePath?.split('\\').last ?? 'Unsaved Match'; // Update match name
      widget.matchNameNotifier.value = fileName.replaceFirst(
          RegExp(r'\.json$'), ''); // Remove file extension
    });
  }

  void undo() {
    if (lines.isNotEmpty) {
      setState(() {
        SemanticLine line = lines.removeLast();
        undoStack.add(line);
      });
    }
  }

  void redo() {
    if (undoStack.isNotEmpty) {
      setState(() {
        SemanticLine line = undoStack.removeLast();
        lines.add(line);
        redoStack.add(line);
      });
    }
  }

  void undoErase() {
    if (erasedStack.isNotEmpty) {
      setState(() {
        SemanticLine line = erasedStack.removeLast();
        lines.add(line);
        undoEraseStack.add(line);
      });
    }
  }

  void redoErase() {
    if (undoEraseStack.isNotEmpty) {
      setState(() {
        SemanticLine line = undoEraseStack.removeLast();
        lines.remove(line);
        erasedStack.add(line);
      });
    }
  }

  void reset() {
    setState(() {
      lines.clear();
      undoStack.clear();
      redoStack.clear();
      erasedStack.clear();
      undoEraseStack.clear();
      selectedTool = Tool.pencil;
      isDrawingVisible = true;

      for (Team team in blueAlliance) {
        team.isVisible = true;
      }

      for (Team team in redAlliance) {
        team.isVisible = true;
      }
    });
  }

  void toggleVisibility() {
    setState(() {
      isDrawingVisible = !isDrawingVisible;
    });
  }

  void applyEraser(SemanticLine eraserLine) {
    setState(() {
      lines.removeWhere((line) {
        bool intersects = lineIntersectsLine(line.points, eraserLine.points);
        if (intersects) {
          erasedStack.add(line);
        }
        return intersects;
      });
    });
  }

  bool lineIntersectsLine(List<Offset> line1, List<Offset> line2) {
    for (var point1 in line1) {
      for (var point2 in line2) {
        if ((point1 - point2).distance < 5.0) {
          return true;
        }
      }
    }
    return false;
  }

  void drawTemporaryLine(List<Offset> points) {
    final tempLine = SemanticLine(
        points: points, color: customRed.withOpacity(1.0), isVisible: true);

    setState(() {
      lines.add(tempLine);
    });

    controller.forward(from: 0.0);

    // Remove existing listeners to avoid multiple triggers
    animation.removeListener(() {});
    animation.removeStatusListener((status) {});

    animation.addListener(() {
      setState(() {
        tempLine.color = tempLine.color.withOpacity(animation.value);
      });
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          lines.remove(tempLine);
        });
      }
    });
  }

  void toggleTeamVisibility(Team team) {
    setState(() {
      team.isVisible = !team.isVisible;
      for (var line in lines) {
        if (line.team == team) {
          line.isVisible = team.isVisible;
        }
      }
    });
  }

  void clearTeamLines(Team team) {
    setState(() {
      lines.removeWhere((line) => line.team == team);
    });
  }

  void changeTeamColor(Team team, Color color) {
    setState(() {
      team.color = color;
      for (var line in lines) {
        if (line.team == team) {
          line.color = color;
        }
      }
    });
  }

  //TODO: move to seperate file
  Widget buildSidebar(
      {required List<TextEditingController> controllers,
      required List<Team> teams}) {
    IconData getIcon(String text) {
      if (RegExp(r'^[0-9]+$').hasMatch(text) && text.isNotEmpty) {
        return Icons.check_box_rounded;
      } else {
        return Icons.help_center_rounded;
      }
    }

    Color getIconColor(String text) {
      if (RegExp(r'^[0-9]+$').hasMatch(text) && text.isNotEmpty) {
        return Colors.green;
      } else {
        return Colors.grey;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(teams.length, (index) {
        final team = teams[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selectedTeam == team) {
                selectedTeam = null; // Deselect if the team is already selected
              } else {
                selectedTeam = team; // Select the clicked team
              }
            });
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: selectedTeam == team
                      ? const Border(
                          top: BorderSide(color: Colors.blue, width: 2),
                          left: BorderSide(color: Colors.blue, width: 2),
                          right: BorderSide(color: Colors.blue, width: 2),
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      decoration: const BoxDecoration(
                        color: complementaryColor,
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.grey,
                              width: 1), // Bottom border only
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(
                              getIcon(controllers[index].text),
                              size: 40,
                              color: getIconColor(controllers[index].text),
                            ),
                          ),
                          Container(
                            height: 45,
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    color: Colors.grey,
                                    width: 1), // Right border
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 60,
                              child: TextField(
                                controller: controllers[
                                    index], // Use the correct controllers
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 24,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(5)
                                ], // Set max length to 5
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '????',
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    // Update the icon and color based on the new text
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: complementaryColor,
                        border: selectedTeam == team
                            ? const Border(
                                bottom:
                                    BorderSide(color: Colors.blue, width: 2),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: Colors.grey,
                                      width: 1), // Right border
                                ),
                              ),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(team.isVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () => toggleTeamVisibility(team),
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: Colors.grey,
                                      width: 1), // Right border
                                ),
                              ),
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => clearTeamLines(team),
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: ColorPickerButton(
                                  key: ValueKey(team.id), // Pass key only here
                                  initialColor: team.color,
                                  onColorChanged: (color) {
                                    changeTeamColor(team, color);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (index != teams.length - 1)
                const SizedBox(
                    height:
                        16), // Add space between each generated section except the last one
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double fieldHeight = 570;
    const double sideBarPadding = 80;
    const double navButtonSpacing = 60;
    const double saveButtonPadding =
        80; // Customize the spacing from the right edge

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
            UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY):
            RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
            LogicalKeyboardKey.keyZ): RedoIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          UndoIntent: UndoAction(undo),
          RedoIntent: RedoAction(redo),
        },
        child: Focus(
          autofocus: true,
          child: Column(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.undo),
                          iconSize: 30.0,
                          onPressed: selectedTool.isWritingUtensil
                              ? (lines.isNotEmpty ? undo : null)
                              : (erasedStack.isNotEmpty ? undoErase : null),
                          color: selectedTool.isWritingUtensil
                              ? (lines.isNotEmpty ? Colors.white : Colors.grey)
                              : (erasedStack.isNotEmpty
                                  ? customPink
                                  : Colors.grey),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          iconSize: 30.0,
                          onPressed: (lines.isNotEmpty ||
                                  undoStack.isNotEmpty ||
                                  undoEraseStack.isNotEmpty)
                              ? reset
                              : null,
                          color: (lines.isNotEmpty ||
                                  undoStack.isNotEmpty ||
                                  undoEraseStack.isNotEmpty)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        IconButton(
                          icon: Icon(isDrawingVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          iconSize: 30.0,
                          onPressed: lines.isNotEmpty ? toggleVisibility : null,
                          color: lines.isNotEmpty ? Colors.white : Colors.grey,
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: ColorPickerButton(
                            initialColor: selectedColor,
                            onColorChanged: (color) {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          iconSize: 30.0,
                          color: selectedTool == Tool.pencil
                              ? Colors.blue
                              : Colors.grey,
                          onPressed: () {
                            setState(() {
                              selectedTool = Tool.pencil;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.rebase_edit),
                          iconSize: 30.0,
                          color: selectedTool == Tool.tempPencil
                              ? Colors.blue
                              : Colors.grey,
                          onPressed: () {
                            setState(() {
                              selectedTool = Tool.tempPencil;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_off_outlined),
                          iconSize: 30.0,
                          color: selectedTool == Tool.eraser
                              ? customPink
                              : Colors.grey,
                          onPressed: () {
                            setState(() {
                              selectedTool = Tool.eraser;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.redo),
                          iconSize: 30.0,
                          onPressed: selectedTool.isWritingUtensil
                              ? (undoStack.isNotEmpty ? redo : null)
                              : (undoEraseStack.isNotEmpty ? redoErase : null),
                          color: selectedTool.isWritingUtensil
                              ? (undoStack.isNotEmpty
                                  ? Colors.white
                                  : Colors.grey)
                              : (undoEraseStack.isNotEmpty
                                  ? customPink
                                  : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: navButtonSpacing,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 20.0,
                          onPressed: currentPhase != DrawingPhase.auto
                              ? () {
                                  setState(() {
                                    currentPhase = DrawingPhase
                                        .values[currentPhase.index - 1];
                                    updatePhaseData();
                                  });
                                }
                              : null,
                        ),
                        Text(
                          currentPhase
                                  .toString()
                                  .split('.')
                                  .last[0]
                                  .toUpperCase() +
                              currentPhase.toString().split('.').last.substring(
                                  1), // Display the current phase name
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          iconSize: 20.0,
                          onPressed: currentPhase != DrawingPhase.endgame
                              ? () {
                                  setState(() {
                                    currentPhase = DrawingPhase
                                        .values[currentPhase.index + 1];
                                    updatePhaseData();
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: saveButtonPadding,
                    child: IconButton(
                      icon: const Icon(Icons.save),
                      iconSize: 30.0,
                      onPressed: () {
                        saveDrawingData();
                      },
                      color: Colors.blue,
                    ),
                  ),
                  Positioned(
                    right: saveButtonPadding +
                        50, // Adjust the padding for the load button
                    child: IconButton(
                      icon: const Icon(Icons.folder_open),
                      iconSize: 30.0,
                      onPressed: () async {
                        await loadDrawingData();
                      },
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Column(
                  children: [
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: sideBarPadding),
                            child: SizedBox(
                              height: fieldHeight,
                              child: buildSidebar(
                                  controllers: _leftSidebarControllers,
                                  teams: blueAlliance),
                            ),
                          ),
                        ), // Left Sidebar
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: fieldHeight,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 1.0),
                            ),
                            child: InteractiveViewer(
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: GestureDetector(
                                onPanStart: (details) {
                                  setState(() {
                                    currentLine = [];
                                    if (selectedTool == Tool.pencil) {
                                      lines.add(SemanticLine(
                                          points: currentLine,
                                          color: selectedTeam?.color ??
                                              selectedColor,
                                          team: selectedTeam));
                                      redoStack
                                          .clear(); // Clear redo stack on new draw
                                    } else if (selectedTool ==
                                        Tool.tempPencil) {
                                      tempLine = SemanticLine(
                                          points: currentLine,
                                          color: selectedColor);
                                    } else if (selectedTool == Tool.eraser) {
                                      tempLine = SemanticLine(
                                          points: currentLine,
                                          color: Colors.white.withOpacity(0.5));
                                    }
                                  });
                                },
                                onPanUpdate: (details) {
                                  RenderBox renderBox = _containerKey
                                      .currentContext!
                                      .findRenderObject() as RenderBox;
                                  Offset localPosition = details.localPosition;

                                  // Canvas bound restriction
                                  if (localPosition.dx >= 0 &&
                                      localPosition.dx <=
                                          renderBox.size.width &&
                                      localPosition.dy >= 0 &&
                                      localPosition.dy <=
                                          renderBox.size.height) {
                                    setState(() {
                                      currentLine.add(localPosition);
                                    });
                                  }
                                },
                                onPanEnd: (details) {
                                  if (selectedTool == Tool.tempPencil) {
                                    drawTemporaryLine(
                                        List<Offset>.from(currentLine));
                                    tempLine = null;
                                  } else if (selectedTool == Tool.eraser) {
                                    applyEraser(SemanticLine(
                                        points: currentLine,
                                        color: Colors.white));
                                    tempLine = null;
                                  }
                                  setState(() {
                                    currentLine = [];
                                  });
                                },
                                child: Container(
                                  key: _containerKey,
                                  height: fieldHeight,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/field24.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: FieldPainter(
                                        (isDrawingVisible ? lines : []),
                                        tempLine),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ), // Main Field
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: sideBarPadding),
                            child: SizedBox(
                              height: fieldHeight,
                              child: buildSidebar(
                                  controllers: _rightSidebarControllers,
                                  teams: redAlliance),
                            ),
                          ),
                        ), // Right Sidebar
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
