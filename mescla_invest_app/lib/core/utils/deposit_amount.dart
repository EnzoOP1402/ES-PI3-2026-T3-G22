/// Converte o valor digitado em centavos inteiros para evitar arredondamentos.
/// O usuário edita sempre uma quantia no padrão 1.234,56.
abstract final class DepositAmount {
  static int? parseCents(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'[^0-9,.]'), '');
    if (cleaned.isEmpty) return null;
    // O formulário sempre usa vírgula de centavos: 12,34 ou 1.234,56.
    if (!RegExp(r'^\d{1,3}(\.\d{3})*,\d{2}$|^\d+,\d{2}$').hasMatch(cleaned)) return null;
    final digits = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    final cents = int.tryParse(digits);
    return (cents != null && cents > 0 && cents <= 1000000000) ? cents : null;
  }

  static String formatCents(int cents) {
    final amount = cents.toString().padLeft(3, '0');
    final base = amount.substring(0, amount.length - 2);
    final decimal = amount.substring(amount.length - 2);
    return '${base.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')},$decimal';
  }
}
