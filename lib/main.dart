import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final Color col = Colors.purple[900]!;

  String strText = '';
  String birthdayMessage = '';
  String videoMessage = '';
  String? videoPath;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void resetState() {
    setState(() {
      strText = 'يرجى إدخال قيم صحيحة';
      
      birthdayMessage = '';
      videoMessage = '';
      videoPath = 'assets/n12.mp4';
      _initializeVideo();
    });
  }

  void calculateAge() {
    int? day = int.tryParse(dayController.text);
    int? month = int.tryParse(monthController.text);
    int? year = int.tryParse(yearController.text);

    if (day == null || month == null || year == null || day <= 0 || month <= 0 || year <= 0) {
      resetState();
      return;
    }

    DateTime birthDate;
    try {
      birthDate = DateTime(year, month, day);
    } catch (e) {
      resetState();
      return;
    }

    DateTime today = DateTime.now();
    if (birthDate.isAfter(today)) {
      resetState();
      return;
    }

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    DateTime nextBirthday = DateTime(today.year, month, day);
    if (nextBirthday.isBefore(today)) {
      nextBirthday = DateTime(today.year + 1, month, day);
    }
    int daysUntilBirthday = nextBirthday.difference(today).inDays;

    setState(() {
    strText = (age >= 11) 
    ? 'عمرك $age سنة' 
    : (age % 2 == 0 ? 'عمرك $age سنوات' : 'عمرك $age سنة');
      birthdayMessage = 'متبقي $daysUntilBirthday يومًا حتى يوم ميلادك القادم 🎉';
      _selectRandomVideo(age);
    });
  }

void _selectRandomVideo(int age) {
  List<String> videoPaths = [];

  if (age >= 11 && age <= 25) {
    videoPaths = ['assets/n28.mp4', 'assets/n17.mp4', 'assets/n16.mp4', 
    'assets/n19.mp4', 'assets/n5.mp4', 'assets/n6.mp4'];
    videoMessage = '';
  } else if (age >= 26 && age <= 30) {
    videoPaths = ['assets/n1.mp4', 'assets/n13.mp4', 'assets/n5.mp4' , 'assets/n32.mp4'];
    videoMessage = '';
  } else {
    videoPaths = ['assets/n10.mp4', 'assets/n20.mp4', 'assets/n3.mp4', 'assets/n11.mp4', 'assets/n31.mp4'];
    videoMessage = '';
  }

  // اختيار فيديو عشوائي باستخدام مؤشر عشوائي
  if (videoPaths.isNotEmpty) {
    // 🔹 اختيار فيديو عشوائي من القائمة الخاصة بالفئة العمرية فقط
    final randomIndex = Random().nextInt(videoPaths.length);  
    videoPath = videoPaths[randomIndex];

    // تشغيل الفيديو الجديد
    _initializeVideo();
  }

  setState(() {
    _initializeVideo();
  });
}

  void _initializeVideo() {
    if (videoPath != null) {
      _disposeVideo();
      _videoController = VideoPlayerController.asset(videoPath!)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.setLooping(true);
          _videoController!.play();
        });
    }
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[800],
          centerTitle: true,
          title: const Text('احسب عمرك', style: TextStyle(color: Colors.white)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset('assets/GDGs.png', height: 40),
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildTextField(dayController, 'اليوم', 'أدخل اليوم', Icons.calendar_today),
                buildTextField(monthController, 'الشهر', 'أدخل الشهر', Icons.date_range),
                buildTextField(yearController, 'السنة', 'أدخل سنة الميلاد', Icons.event),
                const SizedBox(height: 20),
                Text(strText, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: col)),
                Text(birthdayMessage, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: col)),
                if (_videoController != null && _videoController!.value.isInitialized)
                  Column(
                    children: [
                      SizedBox(
                        height: 400,
                        child: VideoPlayer(_videoController!),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        videoMessage,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ElevatedButton(
                  onPressed: calculateAge,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.purple[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('احسب العمر', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


  Widget buildTextField(TextEditingController controller, String label, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        textAlign: TextAlign.right,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.purple[900]),
          filled: true,
          fillColor: Colors.purple.shade50,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.purple.shade800, width: 2),
          ),
          labelText: label,
          hintText: hint,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }