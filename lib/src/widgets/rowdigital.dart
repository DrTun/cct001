  import 'package:flutter/material.dart'; 

Widget rowDigital(String value, String label, { Color? fcolor,double? fsize,}) {
    fsize ??= 30;
    fcolor ??= Colors.green;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 6,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(value,style:  TextStyle(fontFamily: "Digital",fontSize: fsize,height: 1,color: fcolor), textAlign: TextAlign.right),
          ),
        ),
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label,style:  TextStyle(fontSize: 20,height: 1,color: fcolor), textAlign: TextAlign.left),
          ),
        ),
      ],
    );
  }