import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // DateFormat을 사용하기 위한 필요한 패키지
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'schedule_list.dart'; // ScheduleList 위젯 임포트
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulePage extends StatefulWidget {
  final String roomId;

  const SchedulePage({super.key, required this.roomId});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Map<String, dynamic>> schedules = [];

  // 텍스트 필드 컨트롤러
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Message')
        .doc(widget.roomId)
        .collection('schedule')
        .orderBy('start') // 'start' 필드를 기준으로 정렬
        .get();

    final List<Map<String, dynamic>> fetchedSchedules =
        snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final Timestamp startTimestamp = data['start'];
      final Timestamp endTimestamp = data['end'];
      final DateTime startDate =
          startTimestamp.toDate().toLocal(); // 로컬 시간대로 변환
      final DateTime endDate = endTimestamp.toDate().toLocal(); // 로컬 시간대로 변환

      String formattedDate;
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        // 같은 날인 경우 시간만 표시
        formattedDate =
            '${DateFormat('yy.MM.dd(EEE)').format(startDate)} ${DateFormat('HH:mm').format(startDate)} - ${DateFormat('HH:mm').format(endDate)}';
      } else {
        // 다른 날인 경우 전체 날짜와 시간 표시
        formattedDate =
            '${DateFormat('yy.MM.dd(EEE) HH:mm').format(startDate)} 부터 ${DateFormat('yy.MM.dd(EEE) HH:mm').format(endDate)} 까지';
      }

      return {
        'id': doc.id,
        'title': data['name'],
        'start': startDate,
        'end': endDate,
        'date': formattedDate,
        'location': data['location'],
        'details': data['detail'],
      };
    }).toList();

    setState(() {
      schedules = fetchedSchedules;
    });
  }

  Future<void> addSchedule() async {
    final title = titleController.text;
    final date = dateController.text;
    final time = timeController.text;
    final location = locationController.text;
    final details = detailsController.text;

    if (title.isNotEmpty && date.isNotEmpty && time.isNotEmpty) {
      final DocumentReference scheduleRef = FirebaseFirestore.instance
          .collection('Message')
          .doc(widget.roomId)
          .collection('schedule')
          .doc();

      final List<String> dateRange = date.split('~');
      final DateTime startDate =
          DateFormat('yy.MM.dd').parse(dateRange[0].trim());
      final DateTime endDate =
          DateFormat('yy.MM.dd').parse(dateRange[1].trim());

      // 시간 범위 분리
      final List<String> timeRange = time.split('~');
      if (timeRange.length != 2) {
        throw const FormatException('Invalid time range format');
      }

      final List<String> startTimeParts = timeRange[0].trim().split(':');
      final List<String> endTimeParts = timeRange[1].trim().split(':');
      if (startTimeParts.length != 2 || endTimeParts.length != 2) {
        throw const FormatException('Invalid time format');
      }

      final int startHour = int.parse(startTimeParts[0].trim());
      final int startMinute = int.parse(startTimeParts[1].trim());
      final int endHour = int.parse(endTimeParts[0].trim());
      final int endMinute = int.parse(endTimeParts[1].trim());

      final DateTime startDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startHour, // 시작 시간
        startMinute, // 시작 분
      );

      final DateTime endDateTime = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        endHour, // 종료 시간
        endMinute, // 종료 분
      );

      await scheduleRef.set({
        'name': title,
        'start': Timestamp.fromDate(startDateTime),
        'end': Timestamp.fromDate(endDateTime),
        'location': location,
        'detail': details,
        'id': scheduleRef.id,
      });

      setState(() {
        schedules.add({
          'id': scheduleRef.id,
          'title': title,
          'date': date,
          'time': time,
          'location': location,
          'details': details,
        });
      });

      // 입력 필드 초기화
      titleController.clear();
      dateController.clear();
      timeController.clear();
      locationController.clear();
      detailsController.clear();

      Navigator.of(context).pop();
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
                              DateFormat('yy.MM.dd').format(startDate);
                          String formattedEndDate =
                              DateFormat('yy.MM.dd').format(endDate);

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
                          initialDate: startTime.add(const Duration(hours: 1)),
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
            SizedBox(
              width: double.infinity, // 다이얼로그의 가로 크기 채우기
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 균등하게 배치
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // 다이얼로그 닫기
                      },
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 10), // 버튼 간 간격 조정
                  Expanded(
                    child: ElevatedButton(
                      onPressed: addSchedule, // 일정 추가
                      child: const Text('추가'),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

// POST 요청을 보내는 함수
  Future<void> sendPostRequest(String roomId) async {
    const String apiUrl = 'https://example.com/api/your_endpoint'; // 임시 API URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'roomId': roomId,
        }),
      );

      if (response.statusCode == 200) {
        // 요청이 성공했을 때의 처리
        print('Request successful: ${response.body}');
        _showDialog('요청 완료', '요청이 성공적으로 완료되었습니다. \n잠시 기다려주세요.');
      } else {
        // 요청이 실패했을 때의 처리
        print('Request failed with status: ${response.statusCode}');
        _showDialog('오류', '요청 중 오류가 발생했습니다. \n다시 시도해주세요.');
      }
    } catch (e) {
      // 예외 처리
      print('Request error: $e');
      _showDialog('오류', '요청 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  // 다이얼로그를 띄우는 함수
  void _showDialog(String title, String content) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // 다이얼로그 외부를 터치하여 취소 가능
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
      body: Container(
        color: Colors.white, // 배경색 변경
        margin: const EdgeInsets.symmetric(horizontal: 16.0), // 좌우 여백 추가
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 140.0), // bottomSheet 높이만큼 여백 추가
          child: ScheduleList(
            schedules: schedules,
            roomId: widget.roomId,
            onDelete: _fetchSchedules, // 삭제 후 새로고침
          ),
        ),
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
                  sendPostRequest(widget.roomId);
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
