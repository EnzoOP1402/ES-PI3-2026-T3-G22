/* Autor: Gabriela Sichiroli Ferrari */

import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double value) {
    return NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(value);
  }
}