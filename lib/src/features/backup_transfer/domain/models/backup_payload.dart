class DeckPayload {
  const DeckPayload({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory DeckPayload.fromJson(Map<String, dynamic> json) => DeckPayload(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(id, name, description, createdAt, updatedAt);
}

class CardPayload {
  const CardPayload({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.state,
    required this.stability,
    required this.difficulty,
    required this.due,
    this.lastReview,
    required this.reps,
    required this.lapses,
    required this.createdAt,
    this.isSuspended = false,
    this.buriedUntil,
  });

  final int id;
  final int deckId;
  final String front;
  final String back;
  final int state;
  final double stability;
  final double difficulty;
  final DateTime due;
  final DateTime? lastReview;
  final int reps;
  final int lapses;
  final DateTime createdAt;
  final bool isSuspended;
  final DateTime? buriedUntil;

  Map<String, dynamic> toJson() => {
    'id': id,
    'deckId': deckId,
    'front': front,
    'back': back,
    'state': state,
    'stability': stability,
    'difficulty': difficulty,
    'due': due.toUtc().toIso8601String(),
    'lastReview': lastReview?.toUtc().toIso8601String(),
    'reps': reps,
    'lapses': lapses,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'isSuspended': isSuspended,
    'buriedUntil': buriedUntil?.toUtc().toIso8601String(),
  };

  factory CardPayload.fromJson(Map<String, dynamic> json) => CardPayload(
    id: json['id'] as int,
    deckId: json['deckId'] as int,
    front: json['front'] as String,
    back: json['back'] as String,
    state: json['state'] as int,
    stability: (json['stability'] as num).toDouble(),
    difficulty: (json['difficulty'] as num).toDouble(),
    due: DateTime.parse(json['due'] as String).toUtc(),
    lastReview: json['lastReview'] != null
        ? DateTime.parse(json['lastReview'] as String).toUtc()
        : null,
    reps: json['reps'] as int,
    lapses: json['lapses'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    isSuspended: (json['isSuspended'] as bool?) ?? false,
    buriedUntil: json['buriedUntil'] != null
        ? DateTime.parse(json['buriedUntil'] as String).toUtc()
        : null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deckId == other.deckId &&
          front == other.front &&
          back == other.back &&
          state == other.state &&
          stability == other.stability &&
          difficulty == other.difficulty &&
          due == other.due &&
          lastReview == other.lastReview &&
          reps == other.reps &&
          lapses == other.lapses &&
          createdAt == other.createdAt &&
          isSuspended == other.isSuspended &&
          buriedUntil == other.buriedUntil;

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    front,
    back,
    state,
    stability,
    difficulty,
    due,
    lastReview,
    reps,
    lapses,
    createdAt,
    isSuspended,
    buriedUntil,
  );
}

class ReviewLogPayload {
  const ReviewLogPayload({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.reviewedAt,
  });

  final int id;
  final int cardId;
  final int rating;
  final int state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final DateTime reviewedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardId': cardId,
    'rating': rating,
    'state': state,
    'due': due.toUtc().toIso8601String(),
    'stability': stability,
    'difficulty': difficulty,
    'elapsedDays': elapsedDays,
    'lastElapsedDays': lastElapsedDays,
    'scheduledDays': scheduledDays,
    'reviewedAt': reviewedAt.toUtc().toIso8601String(),
  };

  factory ReviewLogPayload.fromJson(Map<String, dynamic> json) =>
      ReviewLogPayload(
        id: json['id'] as int,
        cardId: json['cardId'] as int,
        rating: json['rating'] as int,
        state: json['state'] as int,
        due: DateTime.parse(json['due'] as String).toUtc(),
        stability: (json['stability'] as num).toDouble(),
        difficulty: (json['difficulty'] as num).toDouble(),
        elapsedDays: json['elapsedDays'] as int,
        lastElapsedDays: json['lastElapsedDays'] as int,
        scheduledDays: json['scheduledDays'] as int,
        reviewedAt: DateTime.parse(json['reviewedAt'] as String).toUtc(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewLogPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cardId == other.cardId &&
          rating == other.rating &&
          state == other.state &&
          due == other.due &&
          stability == other.stability &&
          difficulty == other.difficulty &&
          elapsedDays == other.elapsedDays &&
          lastElapsedDays == other.lastElapsedDays &&
          scheduledDays == other.scheduledDays &&
          reviewedAt == other.reviewedAt;

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    rating,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    reviewedAt,
  );
}

class BackupPayload {
  const BackupPayload({
    this.version = 1,
    required this.exportedAt,
    required this.decks,
    required this.cards,
    required this.reviewLogs,
  });

  final int version;
  final DateTime exportedAt;
  final List<DeckPayload> decks;
  final List<CardPayload> cards;
  final List<ReviewLogPayload> reviewLogs;

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'decks': decks.map((d) => d.toJson()).toList(),
    'cards': cards.map((c) => c.toJson()).toList(),
    'reviewLogs': reviewLogs.map((r) => r.toJson()).toList(),
  };

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('version')) {
      throw const FormatException('Missing version field in backup JSON');
    }
    if (!json.containsKey('decks') || json['decks'] is! List) {
      throw const FormatException(
        'Missing or invalid decks array in backup JSON',
      );
    }
    if (!json.containsKey('cards') || json['cards'] is! List) {
      throw const FormatException(
        'Missing or invalid cards array in backup JSON',
      );
    }
    if (!json.containsKey('reviewLogs') || json['reviewLogs'] is! List) {
      throw const FormatException(
        'Missing or invalid reviewLogs array in backup JSON',
      );
    }

    final decksList = (json['decks'] as List)
        .map((d) => DeckPayload.fromJson(d as Map<String, dynamic>))
        .toList();
    final cardsList = (json['cards'] as List)
        .map((c) => CardPayload.fromJson(c as Map<String, dynamic>))
        .toList();
    final reviewLogsList = (json['reviewLogs'] as List)
        .map((r) => ReviewLogPayload.fromJson(r as Map<String, dynamic>))
        .toList();

    return BackupPayload(
      version: json['version'] as int,
      exportedAt: DateTime.parse(json['exportedAt'] as String).toUtc(),
      decks: decksList,
      cards: cardsList,
      reviewLogs: reviewLogsList,
    );
  }
}
