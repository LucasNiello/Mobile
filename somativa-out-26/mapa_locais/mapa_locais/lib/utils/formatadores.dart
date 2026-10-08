/// Formata números no padrão brasileiro (vírgula decimal) sem depender do
/// pacote intl.
String formatarDistancia(double km) => '${_umaCasa(km)} km';

String formatarNota(double nota) => _umaCasa(nota);

String _umaCasa(double valor) => valor.toStringAsFixed(1).replaceAll('.', ',');

/// Converte o texto digitado ("4,5" ou "4.5") em número.
double? lerDecimal(String texto) =>
    double.tryParse(texto.trim().replaceAll(',', '.'));
