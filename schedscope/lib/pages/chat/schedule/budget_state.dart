import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 숫자 포맷을 위한 패키지
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetState extends ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> schedules = {};

  // 예산 합계 계산
  int getTotalAmount(String scheduleId) {
    final budgetItems = schedules[scheduleId] ?? [];
    return budgetItems.fold(0, (sum, item) => sum + (item['amount'] as int));
  }

  // 비용 추가
  Future<void> addBudgetItem(
      String roomId, String scheduleId, Map<String, dynamic> newItem) async {
    final DocumentReference budgetRef = FirebaseFirestore.instance
        .collection('Message')
        .doc(roomId)
        .collection('schedule')
        .doc(scheduleId)
        .collection('budget')
        .doc();

    await budgetRef.set({
      'amount': newItem['amount'],
      'category': '',
      'name': newItem['name'],
    });

    schedules[scheduleId] ??= [];
    schedules[scheduleId]!.add({
      'id': budgetRef.id,
      'amount': newItem['amount'],
      'category': '',
      'name': newItem['name'],
    });
    notifyListeners(); // 상태 업데이트
  }

  // 비용 삭제
  Future<void> removeBudgetItem(
      String roomId, String scheduleId, int index) async {
    final budgetItems = schedules[scheduleId];
    if (budgetItems != null && index < budgetItems.length) {
      final budgetId = budgetItems[index]['id'];
      await FirebaseFirestore.instance
          .collection('Message')
          .doc(roomId)
          .collection('schedule')
          .doc(scheduleId)
          .collection('budget')
          .doc(budgetId)
          .delete();

      budgetItems.removeAt(index);
      notifyListeners(); // 상태 업데이트
    }
  }

  // 예산 항목 가져오기
  Future<void> fetchBudgetItems(String roomId, String scheduleId) async {
    final CollectionReference budgetCollection = FirebaseFirestore.instance
        .collection('Message')
        .doc(roomId)
        .collection('schedule')
        .doc(scheduleId)
        .collection('budget');

    final QuerySnapshot snapshot = await budgetCollection.get();

    if (snapshot.docs.isEmpty) {
      // budget 컬렉션이 없으면 새로 생성
      await budgetCollection.add({
        'amount': 0,
        'category': '',
        'name': 'Initial Budget Item',
      });
    }

    final List<Map<String, dynamic>> fetchedBudgetItems =
        snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'amount': data['amount'],
        'category': data['category'],
        'name': data['name'],
      };
    }).toList();

    schedules[scheduleId] = fetchedBudgetItems;
    notifyListeners(); // 상태 업데이트
  }
}
