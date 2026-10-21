import 'dart:convert';
import 'dart:typed_data';

/// RFC 4180 CSV writer for UTF-8 output.
///
/// - Fields containing commas, quotes, CR or LF are quoted; quotes doubled.
/// - Rows end with CRLF.
/// - Output starts with a UTF-8 byte order mark so spreadsheet applications
///   detect the encoding and keep Indonesian text intact.
/// - User-controlled text that a spreadsheet would treat as a formula
///   (leading `=`, `+`, `-`, `@`, tab or carriage return) is prefixed with a
///   single quote in the exported file only. Stored records are unchanged.
class CsvWriter {
  CsvWriter(this.header) : _buffer = StringBuffer() {
    _writeRow(header.map((h) => CsvCell.text(h)).toList());
  }

  final List<String> header;
  final StringBuffer _buffer;
  int _rows = 0;

  int get rowCount => _rows;

  void addRow(List<CsvCell> cells) {
    if (cells.length != header.length) {
      throw ArgumentError('Jumlah kolom tidak sesuai');
    }
    _writeRow(cells);
    _rows++;
  }

  void _writeRow(List<CsvCell> cells) {
    _buffer
      ..write(cells.map((c) => escape(c.render())).join(','))
      ..write('\r\n');
  }

  String get text => _buffer.toString();

  Uint8List toBytes() =>
      Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(text)]);

  static String escape(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r');
    if (!needsQuotes) return value;
    return '"${value.replaceAll('"', '""')}"';
  }

  /// Neutralizes values that spreadsheets would evaluate as formulas.
  static String neutralizeFormula(String value) {
    if (value.isEmpty) return value;
    const triggers = {'=', '+', '-', '@', '\t', '\r'};
    return triggers.contains(value[0]) ? "'$value" : value;
  }
}

/// A CSV cell. Only [CsvCell.userText] applies formula neutralization;
/// numbers, dates and fixed labels are written as-is.
class CsvCell {
  const CsvCell._(this._value, this._userText);

  const CsvCell.text(String? value) : this._(value, false);
  const CsvCell.userText(String? value) : this._(value, true);
  CsvCell.number(num? value)
    : this._(value == null ? null : _formatNumber(value), false);
  CsvCell.boolean(bool? value)
    : this._(value == null ? null : (value ? 'ya' : 'tidak'), false);

  final String? _value;
  final bool _userText;

  String render() {
    final v = _value ?? '';
    return _userText ? CsvWriter.neutralizeFormula(v) : v;
  }

  static String _formatNumber(num v) =>
      v is double && v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
