class Quote {
  final String text;
  final String author;
  final String source; // 'anime' | 'inspirational' | 'bundled'
  final String? character;
  final String? anime;

  const Quote({
    required this.text,
    required this.author,
    required this.source,
    this.character,
    this.anime,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        text: json['text'] as String,
        author: json['author'] as String,
        source: json['source'] as String,
        character: json['character'] as String?,
        anime: json['anime'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
        'source': source,
        if (character != null) 'character': character,
        if (anime != null) 'anime': anime,
      };
}
