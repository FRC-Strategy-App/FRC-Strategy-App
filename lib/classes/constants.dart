import 'package:flutter/material.dart';

/// Update version whenever the JSON formatting changes to account for backwards compatibility
const String jsonFormatVersion = 'v1.0';
const Color customRed = Color.fromARGB(255, 255, 17, 0);
const Color customPink = Color.fromARGB(255, 218, 67, 117);
const Color complementaryColor = Color.fromARGB(255, 35, 35, 42);

class PrefsKeys {
  static const String editorTreeWeight = 'editorTreeWeight';
  static const String projectLeftWeight = 'projectLeftWeight';
  static const String treeOnRight = 'treeOnRight';
  static const String robotWidth = 'robotWidth';
  static const String robotLength = 'robotLength';
  static const String teamColor = 'teamColor';
  static const String currentProjectDir = 'currentProjectDir';
  static const String macOSBookmark = 'macOSBookmark';
  static const String fieldImage = 'fieldImage';
  static const String seen2024ResetPopup = 'seen2024ResetPopup';
  static const String holonomicMode = 'holonomicMode';
  static const String ntServerAddress = 'pplibClientHost';
  static const String pathSortOption = 'pathSortOption';
  static const String drawingSortOption = 'drawingSortOption';
  static const String pathsCompactView = 'pathsCompactView';
  static const String drawingCompactView = 'pathsCompactView';
  static const String hotReloadEnabled = 'hotReloadEnabled';
  static const String pathFolders = 'pathFolders';
  static const String drawingFolders = 'drawingFolders';
  static const String snapToGuidelines = 'snapToGuidelines';
  static const String hidePathsOnHover = 'hidePathsOnHover';
  static const String defaultMaxVel = 'defaultMaxVel';
  static const String defaultMaxAccel = 'defaultMaxAccel';
  static const String defaultMaxAngVel = 'defaultMaxAngVel';
  static const String defaultMaxAngAccel = 'defaultMaxAngAccel';
  static const String maxModuleSpeed = 'maxModuleSpeed';
  static const String seen2024Warning = 'seen2024Warning';
}

class Defaults {
  static const int teamColor = 0xFF3F51B5;
  static const double robotWidth = 0.9;
  static const double robotLength = 0.9;
  static const bool holonomicMode = true;
  static const double projectLeftWeight = 0.5;
  static const double editorTreeWeight = 0.5;
  static const String ntServerAddress = '127.0.0.1';
  static const bool treeOnRight = true;
  static const String pathSortOption = 'recent';
  static const String drawingSortOption = 'recent';
  static const bool pathsCompactView = false;
  static const bool drawingsCompactView = false;
  static const bool hotReloadEnabled = false;
  static List<String> pathFolders =
      []; // Can't be const or user wont be able to add new folders
  static List<String> drawingFolders =
      []; // Can't be const or user wont be able to add new folders
  static const bool snapToGuidelines = true;
  static const bool hidePathsOnHover = true;
  static const double defaultMaxVel = 3.0;
  static const double defaultMaxAccel = 3.0;
  static const double defaultMaxAngVel = 540.0;
  static const double defaultMaxAngAccel = 720.0;
  static const double maxModuleSpeed = 4.5;
}