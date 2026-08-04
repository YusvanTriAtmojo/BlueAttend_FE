import 'dart:convert';

class LoginRequestModel {
    final String email;
    final String password;

    LoginRequestModel({
        required this.email,
        required this.password,
    });


    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
    };
}
