class VocabInfo {
  int? id;
  String word;
  String definition;

  VocabInfo({
    required this.id,
    required this.word,
    required this.definition
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'definition': definition
    };
  }

  @override
  String toString() {
    return 'VocabInfo{id: $id, word: $word, definition: $definition}';
  }
}