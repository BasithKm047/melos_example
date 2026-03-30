import 'dart:convert';

import 'package:http/http.dart' as http;
class User{
  String name;
  int age;
  User(this.name, this.age);
  factory User.fromJson(Map<String, dynamic>json){
    return User(json['name'],json['age']);

  }

  Map<String,dynamic>toJson(){
    return {
      'name':name,
      'age':age
    };
  }
}

Future<User>getUser()async{
  final response= await  http.get(Uri.parse(''));

  if(response.statusCode==200){
    final data = jsonDecode(response.body);
    return User.fromJson(data);
  }else{
    throw Exception('Failed to load user');
  }
}