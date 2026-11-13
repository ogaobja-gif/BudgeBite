class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String username;
  final String accountType;
  final String accountStatus;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.username,
    required this.accountType,
    required this.accountStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: int.tryParse('${j['user_id']}') ?? 0,
        fullName: j['full_name']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        phone: j['phone_number']?.toString() ?? '',
        username: j['username']?.toString() ?? '',
        accountType: j['account_type']?.toString() ?? 'customer',
        accountStatus: j['account_status']?.toString() ?? 'Active',
      );

  String get firstName => fullName.trim().split(' ').first;

  String get roleLabel {
    switch (accountType) {
      case 'seller':
        return 'Carinderia Seller';
      case 'admin':
        return 'Administrator';
      default:
        return 'Customer';
    }
  }
}
