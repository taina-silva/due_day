import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:due_day/features/statement_import/presentation/widgets/import_review_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const longMemo =
      'Compra no débito - MARIA DA SILVA COMERCIO DE ALIMENTOS LTDA - '
      'SAO PAULO';

  testWidgets('shows the full memo, wrapped, without truncation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: ImportReviewItemTile(
            item: ImportReviewItem(
              parsed: ParsedStatementTransaction(
                rawIdentifier: 'id-1',
                externalId: 'id-1|-2397',
                date: DateTime(2026, 8, 31),
                amount: -23.97,
                memo: longMemo,
                source: StatementSource.ofx,
                format: StatementFormat.nubankOfx,
              ),
              status: ImportReviewStatus.pendingNew,
              selectedForImport: true,
            ),
          ),
        ),
      ),
    );

    final memo = tester.widget<Text>(find.text(longMemo));
    expect(memo.maxLines, isNull);
    expect(memo.overflow, isNot(TextOverflow.ellipsis));
    // Wrapped onto more than one line.
    expect(
      tester.getSize(find.text(longMemo)).height,
      greaterThan(
        tester.getSize(find.text('Selecionar categoria')).height * 1.5,
      ),
    );
  });
}
