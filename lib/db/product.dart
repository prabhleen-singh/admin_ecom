import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class ProductService {
  Firestore _firestore = Firestore.instance;
  String ref = 'products';
  List<String> id = [];

//  void createProduct(String name) {
//    var id = Uuid();
//    String categoryId = id.v1();
//
//    _firestore.collection(ref).document(categoryId).setData({'category': name});
//  }

  Future<List<DocumentSnapshot>> getProducts() =>
      _firestore.collection(ref).getDocuments().then((snaps) {
        return snaps.documents;
      });

  Future<List<DocumentSnapshot>> getSuggestions(String suggestion) =>
      _firestore.collection(ref).where('product', isEqualTo: suggestion).getDocuments().then((snap){
        return snap.documents;
      });

  Future<List<String>> getDocId(String suggestion) async =>
        _firestore.collection(ref).where('product', isEqualTo: suggestion).getDocuments().then((QuerySnapshot snapshot) {
        snapshot.documents.forEach((element) {
          int i=0;
        id.insert(i, element.documentID);  i=i+1; });  return id;
            });

  Future<String> remProduct(String suggestion) async{
      Future<List<String>> _futureDocId=getDocId(suggestion);
      List<String> docId = await _futureDocId;
//      (int i=0;i<docId.l;i=i+1);
    for (String s in docId)
    _firestore.collection(ref).document(s).delete().then((_) => print("success!"));
    }

  }

