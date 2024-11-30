import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // 일정 데이터 샘플
  final List<Map<String, String>> schedules = [
    {
      'title': '제주도 여행',
      'date': '12.12 (목) - 12.15 (금)',
      'location': '제주도',
      'details': '애월',
      'amount': '639,900원',
    },
    {
      'title': '종강 총회',
      'date': '12.15 (금) 19:00 - 21:00',
      'location': '충무로',
      'details': '20명 참가 예정',
      'amount': '20,000원',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '일정 관리',
          style: TextStyle(
            color: Color(0xFF0F1828),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0F1828)), // Add new schedule icon
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Color(0xFFDBDBDB),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                shadowColor: Color(0x3F000000),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row to display the circle and schedule count
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: ShapeDecoration(
                              color: Color(0xFF3498DB),
                              shape: OvalBorder(),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        schedule['title']!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        schedule['date']!,
                        style: TextStyle(
                          color: Color(0xFF3498DB),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        schedule['location']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 5),
                      Text(
                        schedule['details']!,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        schedule['amount']!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 15,
            right: 15,
            bottom: 100,
            child: ElevatedButton(
              onPressed: () {
                // Implement your logic for adding a new schedule here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                '새로운 일정 추가',
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
          Positioned(
            left: 15,
            right: 15,
            bottom: 40,
            child: ElevatedButton(
              onPressed: () {
                // Add your AI request logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3498DB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'AI에게 요청하기',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
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
