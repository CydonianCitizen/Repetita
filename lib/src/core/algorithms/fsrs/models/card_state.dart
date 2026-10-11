enum CardState {
  newCard(0),
  learning(1),
  review(2),
  relearning(3);

  const CardState(this.value);

  final int value;
}
