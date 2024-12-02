import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_state.dart';
import 'package:intl/intl.dart';

class IndividualBudgetPage extends StatelessWidget {
  final String scheduleId;
  final String scheduleTitle;
  final String roomId;

  const IndividualBudgetPage(
      {super.key,
      required this.roomId,
      required this.scheduleId,
      required this.scheduleTitle});

  @override
  Widget build(BuildContext context) {
    final budgetState = Provider.of<BudgetState>(context);
    final budgetItems = budgetState.schedules[scheduleId] ?? [];
    final NumberFormat formatter = NumberFormat('#,###');

    // 합계 계산
    int totalAmount =
        budgetItems.fold<int>(0, (sum, item) => sum + (item['amount'] as int));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$scheduleTitle 예산 관리',
          style: const TextStyle(
            color: Color(0xFF0F1828),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF0F1828)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 합계 표시
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '합계',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${formatter.format(budgetState.getTotalAmount(scheduleId))}원',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 항목 리스트
          Expanded(
            child: ListView.builder(
              itemCount: budgetItems.length,
              itemBuilder: (context, index) {
                final item = budgetItems[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          '${formatter.format(item['amount'])}원',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 삭제 아이콘
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),
                          onPressed: () async {
                            final bool? confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('삭제 확인'),
                                  content: const Text('정말로 해당 항목을 삭제하시겠습니까?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false); // 취소
                                      },
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true); // 확인
                                      },
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                );
                              },
                            );

                            // 사용자가 확인 버튼을 눌렀을 때만 삭제
                            if (confirmDelete == true) {
                              budgetState.removeBudgetItem(
                                  roomId, scheduleId, index);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 새로운 비용 추가 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String newName = '';
                    int newAmount = 0;

                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text(
                        '새로운 비용 추가',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration:
                                const InputDecoration(labelText: '항목 이름'),
                            onChanged: (value) {
                              newName = value;
                            },
                          ),
                          TextField(
                            decoration: const InputDecoration(labelText: '금액'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              newAmount = int.tryParse(value) ?? 0;
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (newName.isNotEmpty && newAmount > 0) {
                              budgetState.addBudgetItem(roomId, scheduleId,
                                  {'name': newName, 'amount': newAmount});
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('추가'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                '새로운 비용 추가',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
