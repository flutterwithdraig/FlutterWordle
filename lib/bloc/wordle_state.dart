part of 'wordle_bloc.dart';

enum GameStatus {
  loading,
  playing,
  finishedLost,
  finishedWon,
}

extension GameStatusX on GameStatus {
  bool get isLoading => this == GameStatus.loading;
  bool get isPlaying => this == GameStatus.playing;
  bool get isFinishedLost => this == GameStatus.finishedLost;
  bool get isFinishedWon => this == GameStatus.finishedWon;
  bool get isFinsished => isFinishedLost || isFinishedWon;
}

class WordleState extends Equatable {
  const WordleState({
    required this.status,
    required this.word,
    required this.guessNo,
    required this.errorMsg,
    required this.grid,
  });

  final GameStatus status;
  final String word;
  final int guessNo;
  final String errorMsg;
  final List<Box> grid;

  @override
  List<Object> get props => [
        status,
        word,
        guessNo,
        errorMsg,
        grid,
      ];

  factory WordleState.initial() => WordleState(
        status: GameStatus.loading,
        word: '',
        guessNo: 0,
        errorMsg: '',
        grid: List.generate(
          30,
          (index) => Box(
            letter: '',
            status: BoxStatus.blank,
          ),
        ),
      );

  List<Box> copyGrid() => List.from(grid);

  WordleState copyWith({
    GameStatus? status,
    String? word,
    int? guessNo,
    String? errorMsg,
    List<Box>? grid,
  }) {
    return WordleState(
      status: status ?? this.status,
      word: word ?? this.word,
      guessNo: guessNo ?? this.guessNo,
      errorMsg: errorMsg ?? this.errorMsg,
      grid: grid ?? this.grid,
    );
  }
}

enum BoxStatus {
  blank,
  answered,
  correct,
  order,
  incorrect,
}

extension BoxStatusX on BoxStatus {
  bool get isBlank => this == BoxStatus.blank;
  bool get isAnswered => this == BoxStatus.answered;
  bool get isCorrect => this == BoxStatus.correct;
  bool get isOrder => this == BoxStatus.order;
  bool get isIncorrect => this == BoxStatus.incorrect;
}

class Box {
  final String letter;
  final BoxStatus status;
  Box({
    required this.letter,
    required this.status,
  });

  Box copyWith({
    String? letter,
    BoxStatus? status,
  }) {
    return Box(
      letter: letter ?? this.letter,
      status: status ?? this.status,
    );
  }
}
