import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 숫자 포맷을 위한 패키지

class BudgetState extends ChangeNotifier {
final Map<String, List<Map<String, dynamic>>> schedules = {};

// 예산 합계 계산
int getTotalAmount(String scheduleTitle) {
  final budgetItems = schedules[scheduleTitle] ?? [];
  return budgetItems.fold(0, (sum, item) => sum + (item['amount'] as int));
}

// 비용 추가
void addBudgetItem(String scheduleTitle, Map<String, dynamic> newItem) {
  schedules[scheduleTitle] ??= [];
  schedules[scheduleTitle]!.add(newItem);
  notifyListeners(); // 상태 업데이트
}

// 비용 삭제
void removeBudgetItem(String scheduleTitle, int index) {
  schedules[scheduleTitle]?.removeAt(index);
  notifyListeners(); // 상태 업데이트
}
}
