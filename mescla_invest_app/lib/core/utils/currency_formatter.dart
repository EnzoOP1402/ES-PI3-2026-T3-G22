/* Autor: Gabriela Sichiroli Ferrari */

import 'package:intl/intl.dart';

  // Formata o valor monetário para o padrão brasileiro.
String formatCurrency(double value) {
    return NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(value);
  }