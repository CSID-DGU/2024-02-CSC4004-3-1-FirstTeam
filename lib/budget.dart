import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IndividualBudgetPage extends StatelessWidget {
  final Map<String, dynamic> schedule;

  IndividualBudgetPage({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final budgetItems = schedule['budgetItems'] as List<Map<String, dynamic>>;
    final NumberFormat formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: Text('${schedule['title']} 예산 관리',
        style: TextStyle(
        color: Color(0xFF0F1828),
        fontSize: 18,
        fontWeight: FontWeight.w600,),
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
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
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
                    '${formatter.format(budgetItems.fold<int>(0, (sum, item) => sum + (item['amount'] as int)))}원',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          onPressed: () {
                            budgetItems.removeAt(index);
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IndividualBudgetPage(schedule: schedule),
                              ),
                            );
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
                            decoration: const InputDecoration(labelText: '항목 이름'),
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
                              budgetItems.add({'name': newName, 'amount': newAmount});
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IndividualBudgetPage(schedule: schedule),
                                ),
                              );
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
