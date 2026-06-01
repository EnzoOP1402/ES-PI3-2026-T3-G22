/* Autor: Livia */

// Enum que representa os tipos de ordem disponíveis no balcão
enum TipoOrdem {
  compra,
  venda,
}

// Enum que representa os modos de execução de uma ordem
enum ModoOrdem {
  mercado,
  limitada,
}

// Enum que representa os possíveis status de uma ordem
enum StatusOrdem {
  aberta,
  executada,
  cancelada,
}

// Extensão com métodos auxiliares para TipoOrdem
extension TipoOrdemExtension on TipoOrdem {
  // Texto amigável para exibição na interface
  String get label {
    switch (this) {
      case TipoOrdem.compra:
        return 'Ordem de compra';
      case TipoOrdem.venda:
        return 'Ordem de venda';
    }
  }

  // Valor utilizado para armazenamento e comunicação com backend
  String get value {
    switch (this) {
      case TipoOrdem.compra:
        return 'compra';
      case TipoOrdem.venda:
        return 'venda';
    }
  }

  // Converte texto para enum
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

// Extensão com métodos auxiliares para ModoOrdem
extension ModoOrdemExtension on ModoOrdem {
  // Texto amigável para exibição
  String get label {
    switch (this) {
      case ModoOrdem.mercado:
        return 'Ordem a mercado';
      case ModoOrdem.limitada:
        return 'Ordem limitada';
    }
  }

  // Valor utilizado para armazenamento
  String get value {
    switch (this) {
      case ModoOrdem.mercado:
        return 'mercado';
      case ModoOrdem.limitada:
        return 'limitada';
    }
  }

  // Converte texto para enum
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

// Extensão com métodos auxiliares para StatusOrdem
extension StatusOrdemExtension on StatusOrdem {
  // Texto amigável para exibição
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

  // Valor utilizado para armazenamento
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

  // Converte texto para enum
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

// Modelo que representa uma oferta disponível no balcão
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

  // Verifica se a oferta é de compra
  bool get isCompra => tipo == TipoOrdem.compra;

  // Verifica se a oferta é de venda
  bool get isVenda => tipo == TipoOrdem.venda;

  // Indica se a variação está positiva
  bool get emAlta => variacaoPercentual >= 0;

  // Calcula o valor total da oferta
  double get valorTotal => quantidadeTokens * precoUnitario;

  // Formata o preço unitário para exibição
  String get precoFormatado {
    return 'R\$ ${precoUnitario.toStringAsFixed(2).replaceAll('.', ',')} / token';
  }

  // Formata a quantidade de tokens para exibição
  String get quantidadeFormatada {
    return '$quantidadeTokens tokens';
  }

  // Cria uma cópia da oferta alterando apenas os campos desejados
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

  // Converte o objeto para Map
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

  // Cria uma oferta a partir de um Map
  factory OfertaBalcao.fromMap(Map<String, dynamic> map) {
    return OfertaBalcao(
      id: map['id']?.toString() ?? '',
      startupId: map['startupId']?.toString() ?? '',
      startupNome: map['startupNome']?.toString() ?? '',
      simbolo: map['simbolo']?.toString() ?? '',
      tipo: TipoOrdemExtension.fromString(
        map['tipo']?.toString() ?? 'compra',
      ),
      quantidadeTokens: _toInt(map['quantidadeTokens']),
      precoUnitario: _toDouble(map['precoUnitario']),
      variacaoPercentual: _toDouble(map['variacaoPercentual']),
      criadaEm: _toDateTime(map['criadaEm']),
    );
  }
}

// Modelo que representa uma ordem criada pelo usuário
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

  // Verifica se é ordem de compra
  bool get isCompra => tipo == TipoOrdem.compra;

  // Verifica se é ordem de venda
  bool get isVenda => tipo == TipoOrdem.venda;

  // Calcula o valor total da ordem
  double get valorTotal => quantidadeTokens * precoUnitario;

  // Formata o valor total para exibição
  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Formata o preço unitário
  String get precoFormatado {
    return 'R\$ ${precoUnitario.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Formata o saldo final
  String get saldoDepoisFormatado {
    return 'R\$ ${saldoDepois.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Cria uma cópia da ordem alterando apenas os campos desejados
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

  // Converte a ordem para Map
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

  // Cria uma ordem a partir de um Map
  factory OrdemBalcao.fromMap(Map<String, dynamic> map) {
    return OrdemBalcao(
      id: map['id']?.toString() ?? '',
      usuarioId: map['usuarioId']?.toString() ?? '',
      startupId: map['startupId']?.toString() ?? '',
      startupNome: map['startupNome']?.toString() ?? '',
      simbolo: map['simbolo']?.toString() ?? '',
      tipo: TipoOrdemExtension.fromString(
        map['tipo']?.toString() ?? 'compra',
      ),
      modo: ModoOrdemExtension.fromString(
        map['modo']?.toString() ?? 'mercado',
      ),
      status: StatusOrdemExtension.fromString(
        map['status']?.toString() ?? 'aberta',
      ),
      quantidadeTokens: _toInt(map['quantidadeTokens']),
      precoUnitario: _toDouble(map['precoUnitario']),
      saldoAntes: _toDouble(map['saldoAntes']),
      saldoDepois: _toDouble(map['saldoDepois']),
      criadaEm: _toDateTime(map['criadaEm']),
    );
  }
}

// Converte valores dinâmicos para inteiro
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();

  return int.tryParse(value.toString()) ?? 0;
}

// Converte valores dinâmicos para double
double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();

  return double.tryParse(
        value.toString().replaceAll(',', '.'),
      ) ??
      0;
}

// Converte valores dinâmicos para DateTime
DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) {
    return value;
  }

  try {
    return value.toDate();
  } catch (_) {
    return DateTime.tryParse(value.toString());
  }
}