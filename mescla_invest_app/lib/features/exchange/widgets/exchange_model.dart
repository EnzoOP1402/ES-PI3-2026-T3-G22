/* Autor: Livia */

enum TipoOrdem {
  compra,
  venda,
}

enum ModoOrdem {
  mercado,
  limitada,
}

enum StatusOrdem {
  aberta,
  executada,
  cancelada,
}

extension TipoOrdemExtension on TipoOrdem {
  String get label {
    switch (this) {
      case TipoOrdem.compra:
        return 'Ordem de compra';
      case TipoOrdem.venda:
        return 'Ordem de venda';
    }
  }

  String get value {
    switch (this) {
      case TipoOrdem.compra:
        return 'compra';
      case TipoOrdem.venda:
        return 'venda';
    }
  }

  static TipoOrdem fromString(String value) {
    switch (value) {
      case 'venda':
        return TipoOrdem.venda;
      case 'compra':
      default:
        return TipoOrdem.compra;
    }
  }
}

extension ModoOrdemExtension on ModoOrdem {
  String get label {
    switch (this) {
      case ModoOrdem.mercado:
        return 'Ordem a mercado';
      case ModoOrdem.limitada:
        return 'Ordem limitada';
    }
  }

  String get value {
    switch (this) {
      case ModoOrdem.mercado:
        return 'mercado';
      case ModoOrdem.limitada:
        return 'limitada';
    }
  }

  static ModoOrdem fromString(String value) {
    switch (value) {
      case 'limitada':
        return ModoOrdem.limitada;
      case 'mercado':
      default:
        return ModoOrdem.mercado;
    }
  }
}

extension StatusOrdemExtension on StatusOrdem {
  String get label {
    switch (this) {
      case StatusOrdem.aberta:
        return 'Aberta';
      case StatusOrdem.executada:
        return 'Executada';
      case StatusOrdem.cancelada:
        return 'Cancelada';
    }
  }

  String get value {
    switch (this) {
      case StatusOrdem.aberta:
        return 'aberta';
      case StatusOrdem.executada:
        return 'executada';
      case StatusOrdem.cancelada:
        return 'cancelada';
    }
  }

  static StatusOrdem fromString(String value) {
    switch (value) {
      case 'executada':
        return StatusOrdem.executada;
      case 'cancelada':
        return StatusOrdem.cancelada;
      case 'aberta':
      default:
        return StatusOrdem.aberta;
    }
  }
}

class OfertaBalcao {
  final String id;
  final String startupId;
  final String startupNome;
  final String simbolo;
  final TipoOrdem tipo;
  final int quantidadeTokens;
  final double precoUnitario;
  final double variacaoPercentual;
  final DateTime? criadaEm;

  const OfertaBalcao({
    required this.id,
    required this.startupId,
    required this.startupNome,
    required this.simbolo,
    required this.tipo,
    required this.quantidadeTokens,
    required this.precoUnitario,
    this.variacaoPercentual = 0,
    this.criadaEm,
  });

  bool get isCompra => tipo == TipoOrdem.compra;

  bool get isVenda => tipo == TipoOrdem.venda;

  bool get emAlta => variacaoPercentual >= 0;

  double get valorTotal => quantidadeTokens * precoUnitario;

  String get precoFormatado {
    return 'R\$ ${precoUnitario.toStringAsFixed(2).replaceAll('.', ',')} / token';
  }

  String get quantidadeFormatada {
    return '$quantidadeTokens tokens';
  }

  OfertaBalcao copyWith({
    String? id,
    String? startupId,
    String? startupNome,
    String? simbolo,
    TipoOrdem? tipo,
    int? quantidadeTokens,
    double? precoUnitario,
    double? variacaoPercentual,
    DateTime? criadaEm,
  }) {
    return OfertaBalcao(
      id: id ?? this.id,
      startupId: startupId ?? this.startupId,
      startupNome: startupNome ?? this.startupNome,
      simbolo: simbolo ?? this.simbolo,
      tipo: tipo ?? this.tipo,
      quantidadeTokens: quantidadeTokens ?? this.quantidadeTokens,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      variacaoPercentual: variacaoPercentual ?? this.variacaoPercentual,
      criadaEm: criadaEm ?? this.criadaEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startupId': startupId,
      'startupNome': startupNome,
      'simbolo': simbolo,
      'tipo': tipo.value,
      'quantidadeTokens': quantidadeTokens,
      'precoUnitario': precoUnitario,
      'variacaoPercentual': variacaoPercentual,
      'criadaEm': criadaEm,
    };
  }

  factory OfertaBalcao.fromMap(Map<String, dynamic> map) {
    return OfertaBalcao(
      id: map['id']?.toString() ?? '',
      startupId: map['startupId']?.toString() ?? '',
      startupNome: map['startupNome']?.toString() ?? '',
      simbolo: map['simbolo']?.toString() ?? '',
      tipo: TipoOrdemExtension.fromString(map['tipo']?.toString() ?? 'compra'),
      quantidadeTokens: _toInt(map['quantidadeTokens']),
      precoUnitario: _toDouble(map['precoUnitario']),
      variacaoPercentual: _toDouble(map['variacaoPercentual']),
      criadaEm: _toDateTime(map['criadaEm']),
    );
  }
}

class OrdemBalcao {
  final String id;
  final String usuarioId;
  final String startupId;
  final String startupNome;
  final String simbolo;
  final TipoOrdem tipo;
  final ModoOrdem modo;
  final StatusOrdem status;
  final int quantidadeTokens;
  final double precoUnitario;
  final double saldoAntes;
  final double saldoDepois;
  final DateTime? criadaEm;

  const OrdemBalcao({
    required this.id,
    required this.usuarioId,
    required this.startupId,
    required this.startupNome,
    required this.simbolo,
    required this.tipo,
    required this.modo,
    required this.status,
    required this.quantidadeTokens,
    required this.precoUnitario,
    required this.saldoAntes,
    required this.saldoDepois,
    this.criadaEm,
  });

  bool get isCompra => tipo == TipoOrdem.compra;

  bool get isVenda => tipo == TipoOrdem.venda;

  double get valorTotal => quantidadeTokens * precoUnitario;

  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get precoFormatado {
    return 'R\$ ${precoUnitario.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get saldoDepoisFormatado {
    return 'R\$ ${saldoDepois.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  OrdemBalcao copyWith({
    String? id,
    String? usuarioId,
    String? startupId,
    String? startupNome,
    String? simbolo,
    TipoOrdem? tipo,
    ModoOrdem? modo,
    StatusOrdem? status,
    int? quantidadeTokens,
    double? precoUnitario,
    double? saldoAntes,
    double? saldoDepois,
    DateTime? criadaEm,
  }) {
    return OrdemBalcao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      startupId: startupId ?? this.startupId,
      startupNome: startupNome ?? this.startupNome,
      simbolo: simbolo ?? this.simbolo,
      tipo: tipo ?? this.tipo,
      modo: modo ?? this.modo,
      status: status ?? this.status,
      quantidadeTokens: quantidadeTokens ?? this.quantidadeTokens,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      saldoAntes: saldoAntes ?? this.saldoAntes,
      saldoDepois: saldoDepois ?? this.saldoDepois,
      criadaEm: criadaEm ?? this.criadaEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'startupId': startupId,
      'startupNome': startupNome,
      'simbolo': simbolo,
      'tipo': tipo.value,
      'modo': modo.value,
      'status': status.value,
      'quantidadeTokens': quantidadeTokens,
      'precoUnitario': precoUnitario,
      'valorTotal': valorTotal,
      'saldoAntes': saldoAntes,
      'saldoDepois': saldoDepois,
      'criadaEm': criadaEm,
    };
  }

  factory OrdemBalcao.fromMap(Map<String, dynamic> map) {
    return OrdemBalcao(
      id: map['id']?.toString() ?? '',
      usuarioId: map['usuarioId']?.toString() ?? '',
      startupId: map['startupId']?.toString() ?? '',
      startupNome: map['startupNome']?.toString() ?? '',
      simbolo: map['simbolo']?.toString() ?? '',
      tipo: TipoOrdemExtension.fromString(map['tipo']?.toString() ?? 'compra'),
      modo: ModoOrdemExtension.fromString(map['modo']?.toString() ?? 'mercado'),
      status: StatusOrdemExtension.fromString(map['status']?.toString() ?? 'aberta'),
      quantidadeTokens: _toInt(map['quantidadeTokens']),
      precoUnitario: _toDouble(map['precoUnitario']),
      saldoAntes: _toDouble(map['saldoAntes']),
      saldoDepois: _toDouble(map['saldoDepois']),
      criadaEm: _toDateTime(map['criadaEm']),
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  try {
    return value.toDate();
  } catch (_) {
    return DateTime.tryParse(value.toString());
  }
}