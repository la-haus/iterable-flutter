import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Center(
        child: Text('Hola $name'),
      )),
    );
  }
}
