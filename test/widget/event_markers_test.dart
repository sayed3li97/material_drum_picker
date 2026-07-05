import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';
import 'package:material_drum_picker/src/widgets/internal/day_cell.dart';

import '../helpers.dart';

Widget _cell({
  required List<DrumEventMarker> markers,
  int maxMarkers = 4,
  DrumMarkerBuilder? markerBuilder,
  bool isSelected = false,
}) {
  return buildTestWidget(
    Builder(
      builder: (context) => DayCell(
        day: 15,
        isEnabled: true,
        isSelected: isSelected,
        isToday: false,
        tokens: DrumPickerTheme.resolve(context),
        markers: markers,
        markerBuilder: markerBuilder,
        markerDate: DateTime(2024, 6, 15),
        maxMarkers: maxMarkers,
        onTap: () {},
      ),
    ),
  );
}

void main() {
  group('DayCell markers', () {
    testWidgets('renders one dot per marker', (tester) async {
      await tester.pumpWidget(_cell(markers: const [
        DrumEventMarker(),
        DrumEventMarker(),
      ]));
      // Only the marker dots use Container inside a DayCell.
      expect(find.byType(Container), findsNWidgets(2));
    });

    testWidgets('caps the number of dots at maxMarkers', (tester) async {
      await tester.pumpWidget(_cell(
        markers: List.filled(6, const DrumEventMarker()),
        maxMarkers: 3,
      ));
      expect(find.byType(Container), findsNWidgets(3));
    });

    testWidgets('renders nothing extra when there are no markers',
        (tester) async {
      await tester.pumpWidget(_cell(markers: const []));
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('markerBuilder replaces the default dots', (tester) async {
      await tester.pumpWidget(_cell(
        markers: const [DrumEventMarker(), DrumEventMarker()],
        markerBuilder: (context, day, markers) =>
            Text('x${markers.length}', key: const Key('custom-marker')),
      ));
      expect(find.byKey(const Key('custom-marker')), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      // The default dot Containers are not rendered.
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('exposes the event count in the semantics label',
        (tester) async {
      await tester.pumpWidget(_cell(markers: const [
        DrumEventMarker(),
        DrumEventMarker(),
      ]));
      expect(find.bySemanticsLabel('15, 2 events'), findsOneWidget);
    });

    testWidgets('uses marker semanticLabel when provided', (tester) async {
      await tester.pumpWidget(_cell(markers: const [
        DrumEventMarker(semanticLabel: 'Dentist'),
      ]));
      expect(find.bySemanticsLabel('15, Dentist'), findsOneWidget);
    });
  });

  group('DrumPicker eventLoader', () {
    testWidgets('shows markers under days with events in calendar mode',
        (tester) async {
      final events = {DateTime(2024, 6, 20): 2, DateTime(2024, 6, 25): 1};
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          initialMode: DrumPickerMode.calendar,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          eventLoader: (day) => List.filled(
            events[DateTime(day.year, day.month, day.day)] ?? 0,
            const DrumEventMarker(),
          ),
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // 3 dots total: 2 under the 20th and 1 under the 25th.
      expect(find.byType(Container), findsNWidgets(3));
      expect(find.bySemanticsLabel('20, 2 events'), findsOneWidget);
      expect(find.bySemanticsLabel('25, 1 event'), findsOneWidget);
    });

    testWidgets('no markers renders no dots', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          initialMode: DrumPickerMode.calendar,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(Container), findsNothing);
    });
  });

  testWidgets('DrumCalendarDatePicker drop-in forwards the eventLoader',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumCalendarDatePicker(
        initialDate: DateTime(2024, 6, 15),
        firstDate: DateTime(2024, 6, 1),
        lastDate: DateTime(2024, 6, 30),
        onDateChanged: (_) {},
        eventLoader: (day) => day.day == 10
            ? const [DrumEventMarker(semanticLabel: 'Meeting')]
            : const [],
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('10, Meeting'), findsOneWidget);
  });

  testWidgets('showDrumDatePicker forwards the eventLoader', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showDrumDatePicker(
            context: context,
            initialDate: DateTime(2024, 6, 15),
            firstDate: DateTime(2024, 6, 1),
            lastDate: DateTime(2024, 6, 30),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            eventLoader: (day) => day.day == 12
                ? const [DrumEventMarker(), DrumEventMarker()]
                : const [],
            locale: const Locale('en'),
          ),
          child: const Text('open'),
        ),
      ),
      locale: const Locale('en'),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('12, 2 events'), findsOneWidget);
  });
}
