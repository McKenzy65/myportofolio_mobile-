import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/screens/certification_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class CertificationListScreen extends StatefulWidget {
  const CertificationListScreen({super.key});
  static const routeName = '/certifications';

  @override
  State<CertificationListScreen> createState() =>
      _CertificationListScreenState();
}

class _CertificationListScreenState extends State<CertificationListScreen> {
  late Future<List<Certification>> _certifications;
  final _search = TextEditingController();
  bool _highlightsOnly = false;

  @override
  void initState() {
    super.initState();
    _certifications = context.read<ApiClient>().getCertifications();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final request = context.read<ApiClient>().getCertifications();
    setState(() {
      _certifications = request;
    });
    // FutureBuilder presents the error. The refresh spinner should still finish.
    await request.then<void>((_) {}, onError: (Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Sertifikasi'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: FutureBuilder<List<Certification>>(
              future: _certifications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Daftar sertifikasi belum bisa dimuat.'),
                        TextButton(
                          onPressed: _reload,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  );
                }
                return _results(snapshot.requireData);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _results(List<Certification> entries) {
    final query = _search.text.trim().toLowerCase();
    final filtered = entries.where((entry) {
      if (_highlightsOnly && !entry.isHighlight) return false;
      return entry.title.toLowerCase().contains(query) ||
          entry.description.toLowerCase().contains(query) ||
          entry.year.toString().contains(query);
    }).toList();
    return RefreshIndicator(
      onRefresh: _reload,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (entries.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        labelText: 'Cari sertifikasi',
                        hintText: 'Judul, deskripsi, atau tahun',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus pencarian',
                                onPressed: () => setState(_search.clear),
                                icon: const Icon(Icons.clear),
                              ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    FilterChip(
                      label: const Text('Unggulan'),
                      selected: _highlightsOnly,
                      onSelected: (selected) =>
                          setState(() => _highlightsOnly = selected),
                    ),
                  ],
                ),
              ),
            ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    entries.isEmpty
                        ? 'Belum ada sertifikasi.'
                        : 'Tidak ada sertifikasi yang cocok.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final entry = filtered[index];
                  final id = entry.id;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        entry.isHighlight
                            ? Icons.workspace_premium
                            : Icons.school_outlined,
                      ),
                      title: Text(entry.title),
                      subtitle: Text(
                        entry.isHighlight
                            ? '${entry.year} · Unggulan'
                            : '${entry.year}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: id == null
                          ? null
                          : () => Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CertificationDetailScreen(id: id),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
