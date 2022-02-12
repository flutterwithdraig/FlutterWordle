import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_wordle/data/data.dart';

part 'wordle_event.dart';
part 'wordle_state.dart';

class WordleBloc extends Bloc<WordleEvent, WordleState> {
  WordleBloc() : super(WordleState.initial()) {
    on<LoadGame>(_onLoadGame);
    on<EnterLetter>(_onEnterLetter);
    on<DeleteLetter>(_onDeleteLetter);
    on<SubmitGuess>(_onSubmitGuess);
    on<RestartGame>(_onRestartGame);
  }

  int get _firstEmpty => state.grid.indexWhere((box) => box.letter.isEmpty);
  int get _rowStartIndex => state.guessNo * 5;
  int get _rowEndIndex => _rowStartIndex + 4;
  String get word => state.word;

  FutureOr<void> _onLoadGame(LoadGame event, Emitter<WordleState> emit) {
    // int index = DateTime.now().difference(DateTime.parse('2022-02-08')).inDays %
    //     avaliableWords.length;

    int index = Random().nextInt(availableWords.length);

    String word = availableWords[index];
    print(word);

    emit(state.copyWith(word: word, status: GameStatus.playing));
  }

  FutureOr<void> _onEnterLetter(
      EnterLetter event, Emitter<WordleState> emit) async {
    int index = _firstEmpty;
    if (index < 0 || index > _rowEndIndex) return;

    List<Box> grid = state.copyGrid();
    grid[index] = Box(letter: event.letter, status: BoxStatus.answered);
    emit(state.copyWith(grid: grid));
  }

  FutureOr<void> _onDeleteLetter(
      DeleteLetter event, Emitter<WordleState> emit) async {
    if (state.grid[_rowStartIndex].letter.isNotEmpty) {
      List<Box> grid = state.copyGrid();
      int index = grid.lastIndexWhere((box) => box.letter.isNotEmpty);
      if (index < 0) return;
      grid[index] = Box(letter: '', status: BoxStatus.blank);
      emit(state.copyWith(grid: grid, errorMsg: ''));
    }
  }

  FutureOr<void> _onSubmitGuess(
      SubmitGuess event, Emitter<WordleState> emit) async {
    if (state.grid[_rowEndIndex].letter.isEmpty || state.errorMsg.isNotEmpty) {
      return;
    }

    List<Box> grid = state.copyGrid();
    String guess = grid
        .getRange(_rowStartIndex, _rowEndIndex + 1)
        .map((e) => e.letter)
        .join();

    if (!acceptedWords.contains(guess) && !availableWords.contains(guess)) {
      emit(state.copyWith(errorMsg: 'Not a valid word'));
      return;
    }

    for (var i = _rowStartIndex; i <= _rowEndIndex; i++) {
      if (grid[i].letter == word[i % 5]) {
        grid[i] = grid[i].copyWith(status: BoxStatus.order);
      } else if (word.contains(grid[i].letter)) {
        grid[i] = grid[i].copyWith(status: BoxStatus.correct);
      } else {
        grid[i] = grid[i].copyWith(status: BoxStatus.incorrect);
      }
    }

    bool win = guess == word;

    if (grid.last.letter.isNotEmpty || win) {
      emit(state.copyWith(
          grid: grid,
          status: win ? GameStatus.finishedWon : GameStatus.finishedLost));
    } else {
      emit(state.copyWith(guessNo: state.guessNo + 1, grid: grid));
    }
  }

  FutureOr<void> _onRestartGame(RestartGame event, Emitter<WordleState> emit) {
    emit(WordleState.initial());
    add(LoadGame());
  }
}
