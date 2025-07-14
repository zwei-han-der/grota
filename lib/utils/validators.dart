class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Informe o e-mail';
    if (!value.contains('@')) return 'E-mail inválido';
    return null;
  }

  static String? senha(String? value) {
    if (value == null || value.length < 6)
      return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }
}
