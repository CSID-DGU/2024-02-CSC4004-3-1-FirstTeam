import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // DateFormat을 사용하기 위한 필요한 패키지
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'budget_state.dart';
import 'budget.dart';
import 'package:provider/provider.dart';

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
        .get();

    final List<Map<String, dynamic>> fetchedSchedules =
        snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final Timestamp startTimestamp = data['start'];
      final Timestamp endTimestamp = data['end'];
      final DateTime startDate = startTimestamp.toDate();
      final DateTime endDate = endTimestamp.toDate();
      final String formattedStartDate =
          DateFormat('yyyy.MM.dd(EEE)').format(startDate);
      final String formattedEndDate =
          DateFormat('yyyy.MM.dd(EEE)').format(endDate);

      return {
        'id': doc.id,
        'title': data['name'],
        'date': '$formattedStartDate - $formattedEndDate',
        'time': null,
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

    if (title.isNotEmpty) {
      final DocumentReference scheduleRef = FirebaseFirestore.instance
          .collection('Message')
          .doc(widget.roomId)
          .collection('schedule')
          .doc();

      final List<String> dateRange = date.split('~');
      final DateTime startDate =
          DateFormat('yyyy.MM.dd(EEE)').parse(dateRange[0].trim());
      final DateTime endDate =
          DateFormat('yyyy.MM.dd(EEE)').parse(dateRange[1].trim());

      await scheduleRef.set({
        'name': title,
        'start': Timestamp.fromDate(startDate),
        'end': Timestamp.fromDate(endDate),
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
          ],
        );
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
                          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
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
                          ],
                        ),
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
                            onPressed: () async {
                              final scheduleId = schedule['id'];
                              await FirebaseFirestore.instance
                                  .collection('Message')
                                  .doc(widget.roomId)
                                  .collection('schedule')
                                  .doc(scheduleId)
                                  .delete();

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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // 그림자 위치 조정
            ),
          ],
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
