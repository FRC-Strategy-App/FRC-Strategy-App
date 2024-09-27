import 'package:flutter/material.dart';

class UndoIntent extends Intent {}

class RedoIntent extends Intent {}

class UndoAction extends Action<UndoIntent> {
  final VoidCallback onUndo;

  UndoAction(this.onUndo);

  @override
  void invoke(covariant UndoIntent intent) {
    onUndo();
  }
}

class RedoAction extends Action<RedoIntent> {
  final VoidCallback onRedo;

  RedoAction(this.onRedo);

  @override
  void invoke(covariant RedoIntent intent) {
    onRedo();
  }
}
