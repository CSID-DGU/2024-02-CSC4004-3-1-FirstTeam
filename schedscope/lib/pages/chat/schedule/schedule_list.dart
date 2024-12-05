import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'budget.dart';

class ScheduleList extends StatefulWidget {
  final String roomId;
  final VoidCallback onDelete;

  const ScheduleList({
    super.key,
    required this.roomId,
    required this.onDelete,
  });

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  void showEditScheduleDialog(Map<String, dynamic> schedule) {
    titleController.text = schedule['name'] ?? '';
    locationController.text = schedule['location'] ?? '';
    detailsController.text = schedule['detail'] ?? '';

    // start와 end를 Timestamp 형식으로 처리
    final Timestamp startTimestamp = schedule['start'];
    final Timestamp endTimestamp = schedule['end'];
    final DateTime startDate = startTimestamp.toDate().toLocal();
    final DateTime endDate = endTimestamp.toDate().toLocal();

    // 날짜 및 시간 형식 지정
    String formattedDate;
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      formattedDate =
          '${DateFormat('yy.MM.dd(EEE)').format(startDate)} ${DateFormat('HH:mm').format(startDate)} - ${DateFormat('HH:mm').format(endDate)}';
    } else {
      formattedDate =
          '${DateFormat('yy.MM.dd(EEE) HH:mm').format(startDate)} 부터 ${DateFormat('yy.MM.dd(EEE) HH:mm').format(endDate)} 까지';
    }
    dateController.text = formattedDate;
    timeController.text =
        '${DateFormat('HH:mm').format(startDate)}~${DateFormat('HH:mm').format(endDate)}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 모서리를 둥글게
          ),
          title: const Text(
            '일정 수정',
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
                      onPressed: () => updateSchedule(schedule['id']), // 일정 수정
                      child: const Text('수정'),
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

  Future<void> updateSchedule(String scheduleId) async {
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
          .doc(scheduleId);

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

      try {
        await scheduleRef.update({
          'name': title,
          'start': Timestamp.fromDate(startDateTime),
          'end': Timestamp.fromDate(endDateTime),
          'location': location,
          'detail': details,
        });

        // 입력 필드 초기화
        titleController.clear();
        dateController.clear();
        timeController.clear();
        locationController.clear();
        detailsController.clear();

        Navigator.of(context).pop();
      } catch (e) {
        print('Error updating schedule: $e');
        // 오류 처리 로직 추가 (예: 사용자에게 오류 메시지 표시)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Message')
          .doc(widget.roomId)
          .collection('schedule')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final schedules = snapshot.data!.docs;

        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index].data() as Map<String, dynamic>;

            // 날짜 및 시간 형식 지정
            final Timestamp startTimestamp = schedule['start'];
            final Timestamp endTimestamp = schedule['end'];
            final DateTime startDate = startTimestamp.toDate().toLocal();
            final DateTime endDate = endTimestamp.toDate().toLocal();

            String formattedDate;
            if (startDate.year == endDate.year &&
                startDate.month == endDate.month &&
                startDate.day == endDate.day) {
              formattedDate =
                  '${DateFormat('yy.MM.dd(EEE)').format(startDate)} ${DateFormat('HH:mm').format(startDate)} - ${DateFormat('HH:mm').format(endDate)}';
            } else {
              formattedDate =
                  '${DateFormat('yy.MM.dd(EEE) HH:mm').format(startDate)} 부터 ${DateFormat('yy.MM.dd(EEE) HH:mm').format(endDate)} 까지';
            }

            return GestureDetector(
              onTap: () => showEditScheduleDialog({
                'id': schedule['id'],
                'name': schedule['name'],
                'start': startTimestamp,
                'end': endTimestamp,
                'location': schedule['location'],
                'detail': schedule['detail'],
              }), // 일정 항목을 눌렀을 때 수정 다이얼로그 표시
              child: Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        schedule['name'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),

                                      // Date
                                      if (formattedDate.isNotEmpty) ...[
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            color: Color(0xFF3498DB),
                                            fontSize: 14,
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
                                              roomId: widget.roomId,
                                              scheduleTitle:
                                                  schedule['name'] ?? '',
                                              scheduleId: schedule['id'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                        size: 25,
                                      ),
                                      onPressed: () async {
                                        final scheduleId = schedule['id'];

                                        // 확인 대화상자 표시
                                        final bool? confirmDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('삭제 확인'),
                                              content: const Text(
                                                  '정말로 이 일정을 삭제하시겠습니까?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false); // 취소
                                                  },
                                                  child: const Text('취소'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true); // 확인
                                                  },
                                                  child: const Text('삭제'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        // 사용자가 확인 버튼을 눌렀을 때만 삭제
                                        if (confirmDelete == true) {
                                          await FirebaseFirestore.instance
                                              .collection('Message')
                                              .doc(widget.roomId)
                                              .collection('schedule')
                                              .doc(scheduleId)
                                              .delete();

                                          widget.onDelete(); // 목록 새로고침
                                        }
                                      },
                                    ),
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
                            if (schedule['detail'] != null &&
                                schedule['detail']!.isNotEmpty) ...[
                              Text(
                                schedule['detail']!,
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
              ),
            );
          },
        );
      },
    );
  }
}
