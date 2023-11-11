import 'package:flutter/material.dart';

class CustomInputField  extends StatefulWidget{
  final String labelText;
  Icon? icon;
  bool showPassword;
  TextEditingController controller_;

  CustomInputField({required this.labelText, this.icon,required this.showPassword,required this.controller_});

  @override
  _CustomInputFieldState createState() =>_CustomInputFieldState(); 

    String getText(){
    
    return controller_.text;
  }
}

class _CustomInputFieldState extends State<CustomInputField>{

  

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: !widget.showPassword,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: widget.icon ?? widget.icon,
        suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color: widget.showPassword ? Colors.blue : Colors.grey,
          ),
          onPressed: () {
            setState(() => widget.showPassword = !widget.showPassword);
          },
        ),
        
      ),
      onChanged: (String intext){
        setState(() {
          widget.controller_.text = intext;
        });
      },
    );
  }
}