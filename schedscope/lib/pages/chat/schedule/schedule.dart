import 'package:flutter/material.dart';
import 'budget_state.dart';
import 'budget.dart';
import 'package:intl/intl.dart'; // DateFormat을 사용하기 위한 필요한 패키지
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

int calculateTotalBudget(List<Map<String, dynamic>> budgetItems) {
  return budgetItems.fold(0, (sum, item) => sum + (item['amount'] as int));
}

// 금액 형식화 함수
String formatCurrency(int amount) {
  final NumberFormat formatter = NumberFormat('#,###');
  return formatter.format(amount);
}

class _SchedulePageState extends State<SchedulePage> {
  int? totalAmount;

  @override
  void initState() {
    super.initState();
    // 초기화 단계에서 Provider 데이터 가져오기
    Future.delayed(Duration.zero, () {
      final budgetState = Provider.of<BudgetState>(context, listen: false);
      // 초기 일정 데이터를 BudgetState에 추가
      for (final schedule in schedules) {
        budgetState.schedules[schedule['title']] =
            List<Map<String, dynamic>>.from(schedule['budgetItems']);
      }
    });
  }

  // 일정 데이터 샘플
  final List<Map<String, dynamic>> schedules = [
    {
      'title': '제주도 여행',
      'date': '2024.12.11(wed) - 2024.12.15(sun)',
      'time': null,
      'location': '제주도',
      'details': '애월',
      'budgetItems': [
        {'name': '항공권', 'amount': 145500},
        {'name': '숙소', 'amount': 334000},
      ],
    },
    {
      'title': '종강 총회',
      'date': '2024.12.15(fri)',
      'time': '19:00 - 21:00',
      'location': '충무로',
      'details': '20명 참가 예정',
      'budgetItems': [
        {'name': '회식비', 'amount': 20000},
      ],
    },
  ];

// 텍스트 필드 컨트롤러
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  // 일정 추가 함수
  void addSchedule() {
    final title = titleController.text;
    final date = dateController.text;
    final time = timeController.text;
    final location = locationController.text;
    final details = detailsController.text;
    final budgetState = Provider.of<BudgetState>(context, listen: false);

    // 제목만 입력되면 일정 추가
    if (title.isNotEmpty) {
      setState(() {
        schedules.add({
          'title': title,
          'date': date,
          'time': time,
          'location': location,
          'details': details,
        });
      });

      // 폼 초기화
      titleController.clear();
      timeController.clear();
      dateController.clear();
      locationController.clear();
      detailsController.clear();

      Navigator.pop(context); // 다이얼로그 닫기
    } else {
      // 제목이 비어 있으면 경고 메시지
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              '필수 항목 미기재',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            content: const Text(
              '제목을 작성하세요.',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  // 새로운 일정 추가 다이얼로그
  void showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // 모서리를 둥글게
            ),
            title: const Text(
              '새로운 일정 추가',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // 다이얼로그 너비 조정
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: '제목'),
                    ),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: '날짜'),
                      readOnly: true,
                      onTap: () async {
                        // 시작 날짜 선택
                        DateTime? startDate = await showOmniDateTimePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          is24HourMode: true,
                          type: OmniDateTimePickerType.date,
                        );

                        if (startDate != null) {
                          // 종료 날짜 선택
                          DateTime? endDate = await showOmniDateTimePicker(
                            context: context,
                            initialDate: startDate.add(const Duration(days: 1)),
                            firstDate: startDate,
                            lastDate: DateTime(2100),
                            is24HourMode: true,
                            type: OmniDateTimePickerType.date,
                          );

                          if (endDate != null) {
                            // 날짜 형식 지정
                            String formattedStartDate =
                                DateFormat('yyyy.MM.dd(EEE)').format(startDate);
                            String formattedEndDate =
                                DateFormat('yyyy.MM.dd(EEE)').format(endDate);

                            setState(() {
                              dateController.text =
                                  "$formattedStartDate~$formattedEndDate";
                            });
                          }
                        }
                      },
                    ),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: '시간'),
                      readOnly: true,
                      onTap: () async {
                        // 시작 시간 선택
                        DateTime? startTime = await showOmniDateTimePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          is24HourMode: true,
                          type: OmniDateTimePickerType.time,
                        );

                        if (startTime != null) {
                          // 종료 시간 선택
                          DateTime? endTime = await showOmniDateTimePicker(
                            context: context,
                            initialDate:
                                startTime.add(const Duration(hours: 1)),
                            firstDate: startTime,
                            lastDate: startTime.add(const Duration(hours: 12)),
                            is24HourMode: true,
                            type: OmniDateTimePickerType.time,
                          );

                          if (endTime != null) {
                            // 시간 형식 지정
                            String formattedStartTime =
                                DateFormat('HH:mm').format(startTime);
                            String formattedEndTime =
                                DateFormat('HH:mm').format(endTime);

                            setState(() {
                              timeController.text =
                                  "$formattedStartTime~$formattedEndTime";
                            });
                          }
                        }
                      },
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: '장소'),
                    ),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(labelText: '세부사항'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 버튼을 가운데 정렬
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                    },
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 10), // 버튼 간 간격 조정
                  ElevatedButton(
                    onPressed: addSchedule, // 일정 추가
                    child: const Text('추가'),
                  ),
                ],
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat('#,###');
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
            icon: const Icon(Icons.close, color: Color(0xFF0F1828)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              final totalBudget = Provider.of<BudgetState>(context)
                  .getTotalAmount(schedule['title']);
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
                        width: 30,
                        height: 30,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF3498DB),
                          shape: OvalBorder(),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Center: Schedule Details
                      Expanded(
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // 왼쪽 정렬
                            children: [
                              // Title
                              Text(
                                schedule['title']!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
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

                              // Time
                              if (schedule['time'] != null &&
                                  schedule['time']!.isNotEmpty) ...[
                                Text(
                                  schedule['time']!,
                                  style: const TextStyle(
                                    color: Color(0xFF3498DB),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],

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

                              // Amount
                              // Total Budget
                              ...[
                                Text(
                                  '${formatter.format(totalBudget)} 원',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ]),
                      ),

                      // Right: Actions (Delete and Budget)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                schedules.removeAt(index);
                              });
                            },
                          ),
                          const Text(
                            '삭제',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          IconButton(
                            icon: const Icon(
                              Icons.monetization_on_rounded,
                              color: Colors.black,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IndividualBudgetPage(
                                      scheduleTitle: schedule['title']),
                                ),
                              );
                            },
                          ),
                          const Text(
                            '예산 관리',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     spreadRadius: 5,
          //     blurRadius: 7,
          //     offset: const Offset(0, 3), // 그림자 위치 조정
          //   ),
          // ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity, // 버튼이 좌우 공백을 다 채우도록 설정
              child: ElevatedButton(
                onPressed: showAddScheduleDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, // 버튼이 좌우 공백을 다 채우도록 설정
              child: ElevatedButton(
                onPressed: () {
                  // Add your AI request logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
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
      ),
    );
  }
}
