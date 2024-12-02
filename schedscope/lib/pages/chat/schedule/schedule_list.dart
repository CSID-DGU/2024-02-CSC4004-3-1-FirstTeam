import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'budget.dart';

class ScheduleList extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final String roomId;

  const ScheduleList(
      {super.key, required this.schedules, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat('#,###');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFDBDBDB),
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          shadowColor: const Color(0x3F000000),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Circle Number
                Container(
                  width: 24,
                  height: 24,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF3498DB),
                    shape: OvalBorder(),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Center: Schedule Details (Title and Date)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  schedule['title']!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),

                                // Date
                                if (schedule['date'] != null &&
                                    schedule['date']!.isNotEmpty) ...[
                                  Text(
                                    schedule['date']!,
                                    style: const TextStyle(
                                      color: Color(0xFF3498DB),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ],
                            ),
                          ),

                          // Right: Actions (Delete and Budget)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.monetization_on_rounded,
                                  color: Colors.black,
                                  size: 25,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          IndividualBudgetPage(
                                        scheduleTitle: schedule['title'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // const SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격 조정
                              // const Text(
                              //   '예산 관리',
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              // const SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격 조정
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                  size: 25,
                                ),
                                onPressed: () async {
                                  final scheduleId = schedule['id'];
                                  await FirebaseFirestore.instance
                                      .collection('Message')
                                      .doc(roomId)
                                      .collection('schedule')
                                      .doc(scheduleId)
                                      .delete();

                                  schedules.removeAt(index);
                                },
                              ),
                              const SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격 조정
                              // const Text(
                              //   '삭제',
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Location
                      if (schedule['location'] != null &&
                          schedule['location']!.isNotEmpty) ...[
                        Text(
                          schedule['location']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                      ],

                      // Details
                      if (schedule['details'] != null &&
                          schedule['details']!.isNotEmpty) ...[
                        Text(
                          schedule['details']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
