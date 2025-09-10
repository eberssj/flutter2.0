class Tarefa {
  int? id;
  String titulo;
  String prioridade;

  Tarefa({
    this.id,
    required this.titulo,
    required this.prioridade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'prioridade': prioridade,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      titulo: map['titulo'],
      prioridade: map['prioridade'],
    );
  }
}