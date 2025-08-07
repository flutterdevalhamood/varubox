// Create this file as: lib/src/models/login_response_model.dart

class LoginResponse {
  final bool? IsSuccess;
  final UserData? Data;
  final String? Token;
  final List<dynamic>? UserPrivileges;
  final int? StatusCode;
  final String? Message;

  LoginResponse({
    this.IsSuccess,
    this.Data,
    this.Token,
    this.UserPrivileges,
    this.StatusCode,
    this.Message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      IsSuccess: json['IsSuccess'] as bool?,
      Data: json['Data'] != null ? UserData.fromJson(json['Data']) : null,
      Token: json['Token'] as String?,
      UserPrivileges: json['UserPrivileges'] as List<dynamic>?,
      StatusCode: json['StatusCode'] as int?,
      Message: json['Message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IsSuccess': IsSuccess,
      'Data': Data?.toJson(),
      'Token': Token,
      'UserPrivileges': UserPrivileges,
      'StatusCode': StatusCode,
      'Message': Message,
    };
  }
}

class UserData {
  final int? id;
  final String? name;
  final String? roleId;
  final String? email;
  final String? imageUrl;
  final String? isActive;
  final String? contactNumber;
  final UserRole? roles;

  UserData({
    this.id,
    this.name,
    this.roleId,
    this.email,
    this.imageUrl,
    this.isActive,
    this.contactNumber,
    this.roles,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      roleId: json['role_id'] as String?,
      email: json['email'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as String?,
      contactNumber: json['contactNumber'] as String?,
      roles: json['roles'] != null ? UserRole.fromJson(json['roles']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role_id': roleId,
      'email': email,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'contactNumber': contactNumber,
      'roles': roles?.toJson(),
    };
  }
}

class UserRole {
  final int? id;
  final String? Name;

  UserRole({this.id, this.Name});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(id: json['id'] as int?, Name: json['Name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'Name': Name};
  }
}
