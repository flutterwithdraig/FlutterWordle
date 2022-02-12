import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wordle/bloc/wordle_bloc.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WordleBloc()..add(LoadGame()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Flutter Wordle'),
          ),
          body: SizedBox.expand(
            child: BlocBuilder<WordleBloc, WordleState>(
              builder: (context, state) {
                double width = MediaQuery.of(context).size.width * .6 / 5;
                Size size = Size(width * 5, width * 6.5);

                if (state.status.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox.fromSize(
                      size: size,
                      child: GridView.count(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: _buildGrid(state),
                      ),
                    ),
                    if (state.status.isPlaying) ...[
                      Text(state.errorMsg,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          )),
                      const Keyboard(),
                    ] else if (state.status.isFinsished) ...[
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(state.status.isFinishedWon
                          ? 'You won in ${state.guessNo + 1}!'
                          : 'You lost. The word was ${state.word}.'),
                      ElevatedButton(
                        onPressed: () {
                          context.read<WordleBloc>().add(RestartGame());
                        },
                        child: const Text('Play again'),
                      ),
                    ]
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGrid(WordleState state) {
    List<Widget> grid = [];
    for (var box in state.grid) {
      grid.add(
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: _transitionBuilder,
          switchInCurve: Curves.easeInBack,
          switchOutCurve: Curves.easeInBack.flipped,
          layoutBuilder: (widget, list) => Stack(
            children: [widget!, ...list],
          ),
          child: box.status.isBlank || box.status.isAnswered
              ? Container(
                  key: const Key('front'),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    box.letter.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                )
              : Container(
                  key: const Key('back'),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    color: _getColor(box.status),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    box.letter.toUpperCase(),
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
        ),
      );
    }

    return grid;
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotation = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
        animation: rotation,
        child: widget,
        builder: (context, widget) {
          final under = const Key('back') != widget!.key;
          final value = under ? min(rotation.value, pi / 2) : rotation.value;
          return Transform(
            transform: Matrix4.rotationX(value),
            child: widget,
            alignment: Alignment.center,
          );
        });
  }

  Color _getColor(BoxStatus status) {
    if (status.isCorrect) {
      return Colors.orange;
    } else if (status.isOrder) {
      return Colors.green;
    } else if (status.isIncorrect) {
      return Colors.grey;
    } else {
      return Colors.white;
    }
  }
}

class Keyboard extends StatelessWidget {
  const Keyboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            KeyboardKey(letter: 'q'),
            KeyboardKey(letter: 'w'),
            KeyboardKey(letter: 'e'),
            KeyboardKey(letter: 'r'),
            KeyboardKey(letter: 't'),
            KeyboardKey(letter: 'y'),
            KeyboardKey(letter: 'u'),
            KeyboardKey(letter: 'i'),
            KeyboardKey(letter: 'o'),
            KeyboardKey(letter: 'p'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            KeyboardKey(letter: 'a'),
            KeyboardKey(letter: 's'),
            KeyboardKey(letter: 'd'),
            KeyboardKey(letter: 'f'),
            KeyboardKey(letter: 'g'),
            KeyboardKey(letter: 'h'),
            KeyboardKey(letter: 'j'),
            KeyboardKey(letter: 'k'),
            KeyboardKey(letter: 'l'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            KeyboardKey(letter: 'ent'),
            KeyboardKey(letter: 'z'),
            KeyboardKey(letter: 'x'),
            KeyboardKey(letter: 'c'),
            KeyboardKey(letter: 'v'),
            KeyboardKey(letter: 'b'),
            KeyboardKey(letter: 'n'),
            KeyboardKey(letter: 'm'),
            KeyboardKey(letter: 'del'),
          ],
        ),
      ],
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final String letter;
  const KeyboardKey({Key? key, required this.letter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget keyChar = Text(letter.toUpperCase());
    if (letter == 'ent') {
      keyChar = const Icon(Icons.subdirectory_arrow_left, size: 15);
    } else if (letter == 'del') {
      keyChar = const Icon(Icons.west, size: 15);
    }

    return GestureDetector(
      onTap: () {
        if (letter == 'ent') {
          context.read<WordleBloc>().add(SubmitGuess());
        } else if (letter == 'del') {
          context.read<WordleBloc>().add(DeleteLetter());
        } else {
          context.read<WordleBloc>().add(EnterLetter(letter: letter));
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[350],
          borderRadius: BorderRadius.circular(3),
        ),
        width: 30,
        height: 45,
        alignment: Alignment.center,
        child: keyChar,
      ),
    );
  }
}
