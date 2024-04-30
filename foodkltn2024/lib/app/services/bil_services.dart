import 'package:cloud_firestore/cloud_firestore.dart';

class BillService {
  final CollectionReference billsCollection = FirebaseFirestore.instance.collection('bills');

  Future<void> saveBill(Map<String, dynamic> billData) async {
    await billsCollection.add(billData);
  }

  Stream<QuerySnapshot> getBills() {
    return billsCollection.snapshots();
  }
}
