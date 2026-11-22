import 'package:intl/intl.dart';

final NumberFormat _money =
    NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
final NumberFormat _moneyWhole =
    NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
final DateFormat _date = DateFormat('MMM d, y • h:mm a');

String money(num value) => _money.format(value);
String moneyWhole(num value) => _moneyWhole.format(value);
String formatDate(DateTime value) => _date.format(value.toLocal());
