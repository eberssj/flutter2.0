class Projeto {
  int? id;
  String nome;
  String descricao;
  String status;

  Projeto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'status': status,
    };
  }

  factory Projeto.fromMap(Map<String, dynamic> map) {
    return Projeto(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      status: map['status'],
    );
  }
}