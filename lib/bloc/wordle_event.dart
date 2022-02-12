part of 'wordle_bloc.dart';

abstract class WordleEvent extends Equatable {
  const WordleEvent();

  @override
  List<Object> get props => [];
}

class LoadGame extends WordleEvent {}

class EnterLetter extends WordleEvent {
  final String letter;
  const EnterLetter({
    required this.letter,
  });

  @override
  List<Object> get props => [letter];
}

class DeleteLetter extends WordleEvent {}

class SubmitGuess extends WordleEvent {}

class RestartGame extends WordleEvent {}
