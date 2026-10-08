/// Situação de funcionamento calculada a partir do campo `horario`.
enum StatusHorario { aberto, fechado }

final RegExp _formatoHorario =
    RegExp(r'^([01]\d|2[0-3]):([0-5]\d)\s*-\s*([01]\d|2[0-3]):([0-5]\d)$');

/// Indica se o texto está no formato aceito: "HH:MM - HH:MM" ou "24 horas".
bool horarioValido(String horario) {
  final texto = horario.trim();
  return _eh24Horas(texto) || _formatoHorario.hasMatch(texto);
}

/// Calcula se o local está aberto no instante [agora].
///
/// Retorna `null` quando o horário não está em um formato reconhecido, para a
/// interface simplesmente não exibir o status. Considera expedientes que
/// passam da meia-noite (ex.: "18:00 - 02:00").
StatusHorario? statusDoHorario(String horario, DateTime agora) {
  final texto = horario.trim();
  if (_eh24Horas(texto)) return StatusHorario.aberto;

  final partes = _formatoHorario.firstMatch(texto);
  if (partes == null) return null;

  final abre = int.parse(partes.group(1)!) * 60 + int.parse(partes.group(2)!);
  final fecha = int.parse(partes.group(3)!) * 60 + int.parse(partes.group(4)!);
  final minutoAtual = agora.hour * 60 + agora.minute;

  if (abre == fecha) return StatusHorario.aberto;

  final aberto = abre < fecha
      ? minutoAtual >= abre && minutoAtual < fecha
      : minutoAtual >= abre || minutoAtual < fecha;

  return aberto ? StatusHorario.aberto : StatusHorario.fechado;
}

bool _eh24Horas(String texto) {
  final t = texto.toLowerCase().replaceAll(' ', '');
  return t == '24horas' || t == '24h';
}
