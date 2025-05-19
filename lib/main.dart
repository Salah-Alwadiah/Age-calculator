import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
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
      _disposeVideo();
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
      _selectRandomVideo(age); // تحديث الفيديو بناءً على العمر
    });
  }

  void _selectRandomVideo(int age) {
    List<String> videoPaths;

    if (age <= 10) {
      videoPaths = ['assets/n20.mp4', 'assets/n12.mp4'];
    } else if (age >= 11 && age <= 19) {
      videoPaths = ['assets/n4.mp4', 'assets/n15.mp4'];
    } else if (age >= 20 && age <= 25) {
      videoPaths = ['assets/n19.mp4', 'assets/n28.mp4', 'assets/n23.mp4'];
    }else if (age >= 26 && age <= 36) {
      videoPaths = ['assets/n26.mp4', 'assets/n24.mp4', 'assets/n17.mp4', 'assets/n32.mp4'];
    }else if (age >= 37 && age <= 55) {
      videoPaths = ['assets/n32.mp4', 'assets/n25.mp4', 'assets/n30.mp4'];
    }
    else {
      videoPaths = ['assets/n22.mp4', 'assets/n8.mp4', 'assets/n7.mp4'];
    }

    setState(() {
      videoPath = (videoPaths..shuffle()).first;
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 30,
                              color: Colors.purple[800],
                            ),
                            onPressed: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.replay, size: 30, color: Colors.purple[800]),
                            onPressed: () {
                              setState(() {
                                _videoController!.seekTo(Duration.zero);
                                _videoController!.play();
                              });
                            },
                          ),
                        ],
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
}
