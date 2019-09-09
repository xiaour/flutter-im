class UserModel {
  final String currentUserId;
  final String currentUserName;
  final List userList;
  final int count;

  UserModel({this.currentUserId, this.currentUserName, this.userList,this.count});
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return new UserModel(
      currentUserId: json['currentUserId'],
      currentUserName: json['currentUserName'],
      userList: json['userList'],
      count: json['count']
    );
  }
}