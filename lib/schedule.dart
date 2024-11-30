import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // DateFormat을 사용하기 위한 필요한 패키지
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

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
// 텍스트 필드 컨트롤러
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // 일정 추가 함수
  void addSchedule() {
    final title = titleController.text;
    final date = dateController.text;
    final time = timeController.text;
    final location = locationController.text;
    final details = detailsController.text;
    final amount = amountController.text;

      // 제목만 입력되면 일정 추가
      if (title.isNotEmpty) {
        setState(() {
          schedules.add({
            'title': title,
            'date': date,
            'time': time,
            'location': location,
            'details': details,
            'amount': amount,
          });
        });

        // 폼 초기화
        titleController.clear();
        timeController.clear();
        dateController.clear();
        locationController.clear();
        detailsController.clear();
        amountController.clear();

        Navigator.pop(context); // 다이얼로그 닫기
      } else {
        // 제목이 비어 있으면 경고 메시지
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('입력 오류'),
              content: Text('제목은 필수 항목입니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('확인'),
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
          title: Text(
            '새로운 일정 추가',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: '날짜'),
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
                      initialDate: startDate.add(Duration(days: 1)),
                      firstDate: startDate,
                      lastDate: DateTime(2100),
                      is24HourMode: true,
                      type: OmniDateTimePickerType.date,
                    );

                    if (endDate != null) {
                      // 날짜 형식 지정
                      String formattedStartDate =
                      DateFormat('yyyy-MM-dd').format(startDate);
                      String formattedEndDate =
                      DateFormat('yyyy-MM-dd').format(endDate);

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
                decoration: InputDecoration(labelText: '시간'),
                readOnly: true,
                onTap: () async {
                  // 시작 시간 선택
                  DateTime? startTime = await showOmniDateTimePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    is24HourMode: true,
                    type: OmniDateTimePickerType.time, // 시간 선택 전용
                  );

                  if (startTime != null) {
                    // 종료 시간 선택
                    DateTime? endTime = await showOmniDateTimePicker(
                      context: context,
                      initialDate: startTime.add(Duration(hours: 1)),
                      firstDate: startTime,
                      lastDate: startTime.add(Duration(hours: 12)),
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
                decoration: InputDecoration(labelText: '장소'),
              ),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(labelText: '세부사항'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: '금액'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: addSchedule, // 일정 추가
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }



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
            icon: const Icon(Icons.close, color: Color(0xFF0F1828)), // Add new schedule icon
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
      Expanded(
          child: ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 15),
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
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.black,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                schedules.removeAt(index); // 아이템 삭제
                              });
                            },
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
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        schedule['amount']!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
          ),
          Positioned(
            left: 15,
            right: 15,
            bottom: 100,
            child: ElevatedButton(
              onPressed: showAddScheduleDialog,
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
