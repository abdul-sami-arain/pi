import 'package:flutter/src/widgets/framework.dart';
import 'package:login_signup/utils/exports.dart';

class RedPage extends StatelessWidget {
  const RedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.red,
    );
  }
}
