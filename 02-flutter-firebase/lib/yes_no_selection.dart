import 'package:flutter/material.dart';

import 'app_state.dart';
import 'src/widgets.dart';

class YesNoSelection extends StatelessWidget {
  const YesNoSelection(
      {super.key, required this.state, required this.onSelection});
  final Attending state;
  final void Function(Attending selection) onSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ResponseButton(
              option: Attending.yes, state: state, onSelection: onSelection),
          const SizedBox(width: 8),
          ResponseButton(
              option: Attending.no, state: state, onSelection: onSelection),
        ],
      ),
    );
  }
}

class ResponseButton extends StatelessWidget {
  const ResponseButton({
    super.key,
    required this.option,
    required this.state,
    required this.onSelection,
  });
  final Attending option;
  final Attending state;
  final void Function(Attending selection) onSelection;

  @override
  Widget build(BuildContext context) {
    return option == state
        ? FilledButton(
            onPressed: () => onSelection(option),
            child: Text(option == Attending.yes ? 'YES' : 'NO'),
          )
        : StyledButton(
            onPressed: () => onSelection(option),
            child: Text(option == Attending.yes ? 'YES' : 'NO'),
          );
  }
}
