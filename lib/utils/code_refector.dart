import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login_signup/utils/exports.dart';
import 'package:login_signup/utils/exports.dart';

// custom text widget
Widget customText({required String txt, required TextStyle style}) {
  return Text(
    txt,
    style: style,
  );
}

// sign up button
Widget SignUpContainer({required String st}) {
  return Container(
    width: double.infinity,
    height: 60.h,
    decoration: BoxDecoration(
      color: Color.fromRGBO(43, 87, 154, 1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: customText(
          txt: st,
          style: const TextStyle(
            color: AppColors.kwhiteColor,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          )),
    ),
  );
}

// rich text
TextSpan RichTextSpan({required String one, required String two}) {
  return TextSpan(children: [
    TextSpan(
        text: one,
        style: TextStyle(fontSize: 13, color: Colors.black)),
    TextSpan(
        text: two,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.kBlueColor,
        )),
  ]);
}

// TextField
Widget CustomTextField(
    {required String Lone, required String Htwo, required bool obs , required Controller}) {
  return TextField(
    autofocus: false,
    decoration: InputDecoration(
      
       enabledBorder: const OutlineInputBorder(
      borderSide: const BorderSide(color: Color.fromRGBO(43, 87, 154, 1), width: 1),
    ),
      focusedBorder: const OutlineInputBorder(
      borderSide: const BorderSide(color: Color.fromRGBO(43, 87, 154, 1), width: 1),
    ),
        labelText: Lone,
        labelStyle: TextStyle(
        color:  Color.fromRGBO(43, 87, 154, 1),
      ),
        hintText: Htwo,
       
        hintStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
     
        border: const OutlineInputBorder(
          borderSide:  BorderSide(color: Color.fromRGBO(43, 87, 154, 1))
            )),
    obscureText: obs,
    controller:Controller ,
    // autofocus: true,
    keyboardType: TextInputType.multiline,
  );
}
