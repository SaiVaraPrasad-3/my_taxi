import 'dart:io';

import 'package:flutter/material.dart';


const Color oranage = Colors.orange;
const Color white = Colors.white;
const Color yellow = Colors.yellow;

const sedanTypeUrl = "https://image.flaticon.com/icons/png/512/89/89131.png";
const vanTypeUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS0ubG-vBEkyfP-IhAZ4JdXRv5e-DmMmBMQbtlidgh-f_i2U_AH";
const flashTypeUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQDfH7ONVQRDzO3syGxmODyJPF4IpRx32dDw171eefSf77w0gqv&s";


const profileTestImage = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQKB2Yv9q0ZjdLY8gskjuT0WAy7adyQUuFub6vkP1vpR-DQ2KXb";


String localhost() {
  if (Platform.isAndroid)
    return 'http://10.0.2.2:7000';
  else // for iOS simulator
    return 'http://localhost:7000';
}