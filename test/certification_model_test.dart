import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/certification.dart';

void main() {
  const basics = {
    'id': 17,
    'title': 'Flutter',
    'description': 'Membangun aplikasi',
    'year': 2026,
  };

  test('Django certification metadata is readable but cannot be posted', () {
    final certification = Certification.fromJson({
      ...basics,
      'is_highlight': true,
      'star_count': 2,
      'is_starred': true,
      'starred_by_names': 'satu, dua',
    });

    expect(certification.id, 17);
    expect(certification.starCount, 2);
    expect(certification.isStarred, isTrue);
    expect(certification.starredByNames, 'satu, dua');
    expect(certification.toJson(), {
      'title': 'Flutter',
      'description': 'Membangun aplikasi',
      'year': 2026,
      'is_highlight': true,
    });
  });

  test('Optional response fields have the same defaults as a new draft', () {
    final certification = Certification.fromJson(basics);
    expect(certification.isHighlight, isFalse);
    expect(certification.starCount, 0);
    expect(certification.isStarred, isFalse);
    expect(certification.starredByNames, isEmpty);
  });
}
