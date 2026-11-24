import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'Daftar publik memuat sekali, bisa retry, refresh saat kosong, dan membuka detail',
    (tester) async {
      var calls = 0;
      final first = Completer<http.Response>();
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.headers.containsKey('Authorization'), isFalse);
          expect(request.url.path, '/api/v1/projects/');
          calls++;
          if (calls == 1) return first.future;
          if (calls == 2) return http.Response('[]', 200);
          return http.Response(
            jsonEncode([
              {
                'id': '21ec9d53-15e8-4fb5-8a83-b5e8b7ed67ae',
                'title': 'Uji publik',
                'description': 'Deskripsi dari server',
                'tech_stack': 'Flutter',
                'project_url': 'https://example.org/p',
                'project_image_url': '',
              },
            ]),
            200,
          );
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        Provider.value(
          value: api,
          child: const MaterialApp(home: ProjectListScreen()),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();
      expect(calls, 1);
      first.complete(http.Response('Internal error: sensitive detail', 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('sensitive detail'), findsNothing);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada proyek.'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 450));
      await tester.pumpAndSettle();
      expect(find.text('Uji publik'), findsOneWidget);
      await tester.tap(find.text('Uji publik'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Proyek'), findsOneWidget);
      expect(find.text('https://example.org/p'), findsOneWidget);
      expect(find.text('Deskripsi dari server'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(calls, 3);
    },
  );
}
