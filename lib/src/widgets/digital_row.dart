  import 'package:flutter/material.dart'; 

Widget digitalRow(String value, String prefix, String postfix, { Color? fcolor,double? fsize,}) {
    fsize ??= 30;
    fcolor ??= Colors.green;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [ 
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(prefix,style:  TextStyle(fontSize: 14,height: 1,color: fcolor), textAlign: TextAlign.left),
          ),
        ),
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
            child: Text(postfix,style:  TextStyle(fontSize: 14,height: 1,color: fcolor), textAlign: TextAlign.left),
          ),
        ),
      ],
    );
  }