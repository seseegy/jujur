import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/widgets/states.dart';

void main() {
  testWidgets('full empty state is centered on the screen, not on its text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.edit_note,
            title: 'Belum ada refleksi',
            message: 'Pesan pendek.',
            actionLabel: 'Tulis',
            onAction: _noop,
          ),
        ),
      ),
    );
    final screenCenter = tester.getSize(find.byType(Scaffold)).width / 2;
    for (final f in [
      find.text('Belum ada refleksi'),
      find.text('Pesan pendek.'),
      find.byType(OutlinedButton),
    ]) {
      expect(
        tester.getCenter(f).dx,
        moreOrLessEquals(screenCenter, epsilon: 1),
      );
    }
  });
}

void _noop() {}
