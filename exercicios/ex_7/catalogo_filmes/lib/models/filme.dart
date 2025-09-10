class Filme {
  int? id;
  String titulo;
  String diretor;
  int ano;

  Filme({
    this.id,
    required this.titulo,
    required this.diretor,
    required this.ano,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'diretor': diretor,
      'ano': ano,
    };
  }

  factory Filme.fromMap(Map<String, dynamic> map) {
    return Filme(
      id: map['id'],
      titulo: map['titulo'],
      diretor: map['diretor'],
      ano: map['ano'],
    );
  }
}