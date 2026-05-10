/** Autor: Livia Lucizano */

class StartupModel {
  final String id;
  final String name;
  final String shortDescription;
  final String stage;
  final List<String> tags;
  final int totalTokensIssued;
  final num capitalRaisedCents;

  const StartupModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.stage,
    required this.tags,
    required this.totalTokensIssued,
    required this.capitalRaisedCents,
  });

  factory StartupModel.fromMap(Map<String, dynamic> data) {
    return StartupModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Startup sem nome',
      shortDescription: data['shortDescription']?.toString() ?? 'Descrição não informada.',
      stage: data['stage']?.toString() ?? 'Status não informado',
      tags: _parseTags(data['tags']),
      totalTokensIssued: _parseInt(
        data['totalTokensIssued'] ?? '0',
      ),
      capitalRaisedCents: _parseNum(
        data['capitalRaisedCents'] ?? data['capitalAportado'],
      ),
    );
  }

  static List<String> _parseTags(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return <String>[];
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static num _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }

    if (value is String) {
      return num.tryParse(value) ?? 0;
    }

    return 0;
  }

  static String formatStage(String stage) {
    switch (stage) {
      case 'nova':
        return 'Nova';
      case 'em_operacao':
        return 'Em operação';
      case 'em_expansao':
        return 'Em expansão';
      default:
        return stage;
    }
  }
}