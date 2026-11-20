
import 'package:flutter/material.dart';

// ======================================================
// MODEL ARTIKEL DAN PROMO
// ======================================================

enum ArticleStatus {
  draft,
  published,
}

class ArticleData {
  final int id;
  String title;
  String description;
  String image;
  String category;
  ArticleStatus status;

  ArticleData({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
    this.status = ArticleStatus.draft,
  });
}

// ======================================================
// STORE ARTIKEL
// ======================================================

class ArticleStore extends ChangeNotifier {
  final List<ArticleData> _articles = [
    ArticleData(
      id: 1,
      title: 'Promo Spesial IBC Dining',
      description:
      'Nikmati berbagai pilihan menu favorit dengan promo menarik dari IBC Dining.',
      image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
      category: 'Promo',
      status: ArticleStatus.published,
    ),
    ArticleData(
      id: 2,
      title: 'Menu Favorit Minggu Ini',
      description:
      'Temukan pilihan menu favorit pelanggan yang bisa kamu nikmati minggu ini.',
      image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
      category: 'Artikel',
      status: ArticleStatus.draft,
    ),
  ];

  List<ArticleData> get articles => List.unmodifiable(_articles);

  List<ArticleData> get publishedArticles =>
      _articles.where((item) =>
      item.status == ArticleStatus.published).toList();

  void addArticle(ArticleData article) {
    _articles.add(article);
    notifyListeners();
  }

  void updateArticle(ArticleData updatedArticle) {
    final index =
    _articles.indexWhere((item) => item.id == updatedArticle.id);

    if (index != -1) {
      _articles[index] = updatedArticle;
      notifyListeners();
    }
  }

  void deleteArticle(int id) {
    _articles.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleStatus(ArticleData article) {
    article.status = article.status == ArticleStatus.published
        ? ArticleStatus.draft
        : ArticleStatus.published;

    notifyListeners();
  }
}

// Gunakan instance yang sama di halaman admin dan user.
final ArticleStore articleStore = ArticleStore();

// ======================================================
// HALAMAN ADMIN ARTIKEL & PROMO
// ======================================================

class AdminArtikelPage extends StatefulWidget {
  const AdminArtikelPage({super.key});

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  String selectedFilter = 'Semua';

  List<ArticleData> get filteredArticles {
    if (selectedFilter == 'Artikel') {
      return articleStore.articles
          .where((item) => item.category == 'Artikel')
          .toList();
    }

    if (selectedFilter == 'Promo') {
      return articleStore.articles
          .where((item) => item.category == 'Promo')
          .toList();
    }

    return articleStore.articles;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: articleStore,
      builder: (context, child) {
        final articles = filteredArticles;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F5),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Artikel & Promo',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A34),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kelola informasi artikel dan promo IBC Dining',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => showArticleForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Konten'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3A34),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // FILTER
                Wrap(
                  spacing: 10,
                  children: [
                    filterButton('Semua'),
                    filterButton('Artikel'),
                    filterButton('Promo'),
                  ],
                ),

                const SizedBox(height: 20),

                // DAFTAR KONTEN
                Expanded(
                  child: articles.isEmpty
                      ? const Center(
                    child: Text('Belum ada artikel atau promo.'),
                  )
                      : ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];

                      return articleCard(article);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget filterButton(String value) {
    final isSelected = selectedFilter == value;

    return ChoiceChip(
      label: Text(value),
      selected: isSelected,
      selectedColor: const Color(0xFF2E3A34),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
      ),
      onSelected: (_) {
        setState(() {
          selectedFilter = value;
        });
      },
    );
  }

  // ====================================================
  // CARD ARTIKEL
  // ====================================================

  Widget articleCard(ArticleData article) {
    final isPublished = article.status == ArticleStatus.published;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                article.image,
                width: 110,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 110,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: const TextStyle(
                      color: Color(0xFF56816A),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    isPublished ? 'Dipublikasikan' : 'Draft',
                    style: TextStyle(
                      color: isPublished
                          ? Colors.green.shade700
                          : Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  showArticleForm(context, article: article);
                } else if (value == 'delete') {
                  confirmDelete(article);
                } else if (value == 'status') {
                  articleStore.toggleStatus(article);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(
                        isPublished
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPublished
                            ? 'Jadikan Draft'
                            : 'Publikasikan',
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // FORM TAMBAH DAN EDIT
  // ====================================================

  void showArticleForm(
      BuildContext context, {
        ArticleData? article,
      }) {
    final isEditing = article != null;

    final titleController =
    TextEditingController(text: article?.title ?? '');

    final descriptionController =
    TextEditingController(text: article?.description ?? '');

    final imageController =
    TextEditingController(text: article?.image ?? '');

    String category = article?.category ?? 'Artikel';
    ArticleStatus status =
        article?.status ?? ArticleStatus.draft;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Konten' : 'Tambah Konten',
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: 'URL Gambar',
                          hintText: 'https://example.com/gambar.jpg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Artikel',
                            child: Text('Artikel'),
                          ),
                          DropdownMenuItem(
                            value: 'Promo',
                            child: Text('Promo'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              category = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<ArticleStatus>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: ArticleStatus.draft,
                            child: Text('Draft'),
                          ),
                          DropdownMenuItem(
                            value: ArticleStatus.published,
                            child: Text('Dipublikasikan'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              status = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3A34),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty ||
                        imageController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semua kolom harus diisi.'),
                        ),
                      );
                      return;
                    }

                    if (isEditing) {
                      articleStore.updateArticle(
                        ArticleData(
                          id: article.id,
                          title: titleController.text.trim(),
                          description:
                          descriptionController.text.trim(),
                          image: imageController.text.trim(),
                          category: category,
                          status: status,
                        ),
                      );
                    } else {
                      final newId = articleStore.articles.isEmpty
                          ? 1
                          : articleStore.articles
                          .map((item) => item.id)
                          .reduce((a, b) => a > b ? a : b) +
                          1;

                      articleStore.addArticle(
                        ArticleData(
                          id: newId,
                          title: titleController.text.trim(),
                          description:
                          descriptionController.text.trim(),
                          image: imageController.text.trim(),
                          category: category,
                          status: status,
                        ),
                      );
                    }

                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===================================================
  // KONFIRMASI HAPUS
  // ===================================================

  void confirmDelete(ArticleData article) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Konten'),
          content: Text(
            'Yakin ingin menghapus "${article.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                articleStore.deleteArticle(article.id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

// ======================================================
// WIDGET ARTIKEL UNTUK HOME USER
// ======================================================

class ArticlePromoCard extends StatelessWidget {
  final ArticleData data;

  const ArticlePromoCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            data.image,
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 170,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image_not_supported),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.category,
                  style: const TextStyle(
                    color: Color(0xFF56816A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(data.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// WIDGET LIST ARTIKEL UNTUK HOME USER
// ======================================================

class UserArticleList extends StatelessWidget {
  const UserArticleList({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: articleStore,
      builder: (context, child) {
        final articles = articleStore.publishedArticles;

        if (articles.isEmpty) {
          return const Center(
            child: Text('Belum ada artikel atau promo.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return ArticlePromoCard(
              data: articles[index],
            );
          },
        );
      },
    );
  }
}
