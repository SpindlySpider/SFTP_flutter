
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomInputField extends StatefulWidget {
  final String labelText;
  final Icon? icon;
  bool showPassword;
  final TextEditingController controller_;
  final bool showEye;
  

  CustomInputField({
    required this.labelText,
    this.icon,
    required this.showPassword,
    required this.controller_,
    required this.showEye,

  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();

  void setDefaultText(String inputText) {
    controller_.value = TextEditingValue(text: inputText);

  }

  String getText() {
    return controller_.text;
  }
}

class _CustomInputFieldState extends State<CustomInputField> {
  Color textColor = Color.fromARGB(255, 197, 115, 255);
  // Color buttonColor = Color.fromARGB(255, 35, 34, 35);
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: !widget.showPassword,
      style: TextStyle(color: textColor,),
      decoration: InputDecoration(
          labelText: widget.labelText,
          // filled: true,
          prefixIcon: widget.icon ?? widget.icon,
          suffixIcon: widget.showEye
              ? IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: widget.showPassword ? textColor : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => widget.showPassword = !widget.showPassword);
                  },
                color: textColor,
                )
              : null,
              // fillColor: buttonColor,
              iconColor: textColor,
              prefixIconColor: textColor,
              suffixIconColor: textColor,
              ),
      onChanged: (String intext) {
        setState(() {
          widget.controller_.text = intext;
        });
      },
      controller: widget.controller_,
    
    );
  }
}
