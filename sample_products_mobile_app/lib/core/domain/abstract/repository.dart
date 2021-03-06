import 'package:flutter/material.dart';
import 'package:sample_products_mobile_app/constants/db_insert_confilict_action.dart';
import 'package:sample_products_mobile_app/core/bloc/bloc_provider.dart';
import 'package:sample_products_mobile_app/core/bloc/reactive_bloc.dart';
import 'package:sample_products_mobile_app/core/domain/context/context.dart';
import 'package:sample_products_mobile_app/core/domain/entities/entity_instances.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sample_products_mobile_app/utils/helpers/di_helpers.dart';
import 'base_entity.dart';
import 'base_repository.dart';

class Repository<T extends IEntity> implements IBaseRepository<T?> {
  BehaviorSubject<Database>? reactiveDb;

  @override
  Database? get db {
    // if(_db==null)_db=await reactiveDb.first;
    if (reactiveDb?.value == null) return throw 'Database oluşturulmadı.';

    return reactiveDb?.value;
  }

  @override
  final String tableName;

  final BuildContext context;

  String primaryFieldName = "";

  Repository({
    required this.context,
    required this.tableName,
    required this.primaryFieldName,
    // @required this.db
  }) {
    reactiveDb = ((context.getRequireReactiveValue<Database>()
            as ReactiveBehaviorSubjectBloc<Database>?)
        ?.subject) as BehaviorSubject<Database>?;
  }

  @override
  Future<T?> add(T? seviye) async {
    try {
      final sendData = seviye!.toSqlite();
      final seviyeQuery = (await db?.insert(tableName, sendData))!;
      sendData[primaryFieldName] = sendData[primaryFieldName] == null
          ? seviyeQuery
          : sendData[primaryFieldName];
      return await single(EntityInstances.getEntity(entity, sendData));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(T? seviye) async {
    try {
      await db!.delete(tableName,
          where: "$primaryFieldName=?",
          whereArgs: [seviye!.toSqlite()[primaryFieldName]]);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<T>> query({String? where, List<dynamic>? whereArgs}) async {
    try {
      List<Map<String, dynamic>> seviyelerQueryResult;

      seviyelerQueryResult = where != null
          ? whereArgs != null
              ? (await db?.query(tableName, where: where))!
              : (await db?.query(tableName,
                  where: where, whereArgs: whereArgs))!
          : (await db?.query(
              tableName,
            ))!;
      List<T> seviyelerQueryMap;
      seviyelerQueryMap = seviyelerQueryResult
          .map<T>((e) => EntityInstances.getEntity(entity, e))
          .toList();
      return (seviyelerQueryMap);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<T?> single(T? seviye) async {
    // assert(seviye.toJson()[primaryFieldName]==null);
    // print(seviye.toJson()[primaryFieldName]);
    try {
      final mappedSeviye = seviye!.toSqlite();
      final seviyelerQueryResult = await db!.query(tableName,
          where: "$primaryFieldName=?",
          whereArgs: [mappedSeviye[primaryFieldName]]);
      final seviyelerQueryMap =
          EntityInstances.getEntity(entity, seviyelerQueryResult.first);
      return seviyelerQueryMap as T;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<T?> update(T? seviye) async {
    try {
      final sendData = seviye!.toSqlite();
      final seviyeQuery = await db!.update(tableName, sendData,
          where: "$primaryFieldName=?",
          whereArgs: [sendData[primaryFieldName]]);
      sendData[primaryFieldName] = seviyeQuery;
      return await single(EntityInstances.getEntity(entity, sendData));
    } catch (e) {
      return null;
    }
  }

  @override
  Type get entity => T;

  @override
  Future<List<T>> rawQuery(String query,
      {List<dynamic>? whereArgs, String tag = ""}) async {
    try {
      List<Map<String, dynamic>> seviyelerQueryResult;

      seviyelerQueryResult = whereArgs != null
          ? await db!.rawQuery(query, whereArgs)
          : await db!.rawQuery(query);
      List<T> seviyelerQueryMap;
      seviyelerQueryMap = seviyelerQueryResult
          .map<T>((e) => EntityInstances.getEntity(entity, e))
          .toList();
      return (seviyelerQueryMap);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> addAll(List<String> columns, List<T?> addedList,
      [DbInsertConfilictExtion conflictTypes =
          DbInsertConfilictExtion.ignore]) async {
    try {
      if (addedList.isEmpty) return true;
      final conflictAction = conflictTypes == DbInsertConfilictExtion.ignore
          ? "IGNORE"
          : "REPLACE";
      final cozumInfosQuery =
          "INSERT OR $conflictAction into $tableName (${columns.join(',')}) values ";
      final cozumInfoValues = [];
      for (var item in addedList) {
        String valueString = "(";
        final sqliteModel = item!.toSqlite();
        valueString += columns
                .map((e) => sqliteModel[e] is String
                    ? "'" + sqliteModel[e].replaceAll("'", "''") + "'"
                    : sqliteModel[e].toString())
                .join(",") +
            ")";
        cozumInfoValues.add(valueString);
      }
      await db!.rawQuery(cozumInfosQuery + cozumInfoValues.join(","));
      return true;
    } catch (e) {
      return false;
    }
  }
}
