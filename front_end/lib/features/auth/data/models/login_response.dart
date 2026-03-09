class LoginResponse {
  final String token;
  final String tokenType;
  final String role; 

  LoginResponse({
    required this.token,
    required this.tokenType,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      
      token: json['access_token'] ?? json['token'] ?? '', 
      tokenType: json['token_type'] ?? 'bearer',
      role: json['role'] ?? 'customer', 
    );
  }
}