import 'package:flutter/material.dart';
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

  // 비용 업데이트
  Future<void> updateBudgetItem(String roomId, String scheduleId, int index,
      String updatedName, int updatedAmount) async {
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
          .update({
        'name': updatedName,
        'amount': updatedAmount,
      });

      budgetItems[index]['name'] = updatedName;
      budgetItems[index]['amount'] = updatedAmount;
      notifyListeners(); // 상태 업데이트
    }
  }

  // 예산 항목 스트림 가져오기
  Stream<List<Map<String, dynamic>>> getBudgetItemsStream(
      String roomId, String scheduleId) {
    return FirebaseFirestore.instance
        .collection('Message')
        .doc(roomId)
        .collection('schedule')
        .doc(scheduleId)
        .collection('budget')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'],
          'category': data['category'],
          'name': data['name'],
        };
      }).toList();
    });
  }
}
