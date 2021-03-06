import 'package:flutter/material.dart';
import 'package:sample_products_mobile_app/core/domain/abstract/repository.dart';
import 'package:sample_products_mobile_app/core/domain/entities/user.dart';

class UserRepository extends Repository<User> {
  UserRepository(BuildContext context)
      : super(context: context, tableName: "user", primaryFieldName: "uid");

  Future<bool> hasUser(String uid) async {
    var user = await single(User(id: uid));
    return user != null;
  }
}
