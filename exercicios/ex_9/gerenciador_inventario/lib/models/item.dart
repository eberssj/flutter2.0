class Item {
  int? id;
  String nome;
  int quantidade;
  double preco;

  Item({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.preco,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'preco': preco,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      nome: map['nome'],
      quantidade: map['quantidade'],
      preco: map['preco'],
    );
  }
}