import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

void main() {
  test('Model uses DRF keys and excludes the server-assigned id from POST', () {
    const input = {
      'id': '773b0a83-46b7-4c23-8d06-c157da75c47c',
      'title': 'MyPortfolio',
      'description': 'Flutter and Django',
      'tech_stack': 'Flutter',
      'project_url': 'https://example.org',
    };
    final project = Project.fromJson(input);
    expect(project.id, input['id']);
    expect(project.techStack, 'Flutter');
    expect(project.projectImageUrl, isEmpty);
    expect(project.toJson(), {
      'title': 'MyPortfolio',
      'description': 'Flutter and Django',
      'tech_stack': 'Flutter',
      'project_url': 'https://example.org',
      'project_image_url': '',
    });
    expect(
      Project.fromJson({...input, 'project_image_url': null}).projectImageUrl,
      isEmpty,
    );
  });
}
