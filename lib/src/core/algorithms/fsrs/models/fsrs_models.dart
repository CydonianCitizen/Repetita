enum CardState {
  newCard(0),
  learning(1),
  review(2),
  relearning(3);

  const CardState(this.value);

  final int value;
}

enum Rating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const Rating(this.value);

  final int value;
}
