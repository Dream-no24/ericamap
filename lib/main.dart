import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'env/env.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';

void main() async {
  await _initialize();
  runApp(const NaverMapApp());
  OpenAI.apiKey = Env.apiKey; // Initializes the package with that API key
}

// 지도 초기화하기
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
    clientId: 's1tq4kdivv', // 클라이언트 ID 설정
    onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed"),
  );
}

class NaverMapApp extends StatefulWidget {
  const NaverMapApp({Key? key}) : super(key: key);

  @override
  _NaverMapAppState createState() => _NaverMapAppState();
}

class _NaverMapAppState extends State<NaverMapApp>
    with SingleTickerProviderStateMixin {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // 추가
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Completer<NaverMapController> mapControllerCompleter = Completer();

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Stack(
          children: [
            NaverMap(
              options: const NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(37.299, 126.838),
                  zoom: 15,
                  bearing: 0,
                  tilt: 0,
                ),
                rotationGesturesEnable: true,
                scrollGesturesEnable: true,
                tiltGesturesEnable: true,
                zoomGesturesEnable: true,
                stopGesturesEnable: true,
                scrollGesturesFriction: 0.5,
                zoomGesturesFriction: 0.5,
                rotationGesturesFriction: 0.5,
              ),
              onMapReady: (controller) async {
                final marker = NMarker(
                  id: '셔틀콕',
                  position: const NLatLng(37.298780118023885, 126.83807081164849),
                );
                final marker1 = NMarker(
                  id: 'test1',
                  position: const NLatLng(37.300095108862834, 126.83769014770063),
                );
                controller.addOverlayAll({marker, marker1});

                final onMarkerInfoWindow1 = NInfoWindow.onMarker(
                  id: marker.info.id, text: "셔틀콕",
                );
                marker.openInfoWindow(onMarkerInfoWindow1);

                final onMarkerInfoWindow2 = NInfoWindow.onMarker(
                  id: marker1.info.id, text: "한양대학교 ERICA 정문",
                );
                marker1.openInfoWindow(onMarkerInfoWindow2);

                mapControllerCompleter.complete(controller);
                log("onMapReady", name: "onMapReady");
              },
            ),
            Positioned(
              top: 40,
              left: 12,
              right: 64, // 검색 버튼을 위해 오른쪽 여백 조정
              child: Container(
                height: 47,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _controller.reverse();
                          } else {
                            _controller.forward();
                          }
                          isExpanded = !isExpanded;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        '장소·강의실 검색',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.35),
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 12,
              child: Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ),
            Positioned(
              top: 95,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryButton('식당', 'assets/spoon.png'),
                    _buildCategoryButton('카페', 'assets/coffee.png'),
                    _buildCategoryButton('편의점', 'assets/store.png'),
                    _buildCategoryButton('약국', 'assets/pill.png'),
                    _buildCategoryButton('셀프사진관', 'assets/camera.png'),
                    _buildCategoryButton('?', 'assets/etc.png'),
                    _buildCategoryButton('?', 'assets/etc.png'),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 10,
              child: Column(
                children: [
                  SizeTransition(
                    sizeFactor: _animation,
                    axisAlignment: -1.0,
                    child: Column(
                      children: [
                        _buildSideButton('한식', 'assets/korea.png', Colors.white),
                        _buildSideButton('양식', 'assets/western.png', Colors.white),
                        _buildSideButton('일식', 'assets/japan.png', Colors.white),
                        _buildSideButton('중식', 'assets/china.png', Colors.white),
                        _buildSideButton('기타', 'assets/etc.png', Colors.white),
                      ],
                    ),
                  ),
                  _buildSideButton('메뉴', 'assets/menu.png', Colors.blueAccent, textcolor:Colors.white, onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _controller.reverse();
                      } else {
                        _controller.forward();
                      }
                      isExpanded = !isExpanded;
                    });
                  }),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomNavigationItem('하냥닝', 'assets/cat.png'),
                    _buildBottomNavigationItem('가게', 'assets/store.png'),
                    _buildBottomNavigationItem('메뉴 룰렛', 'assets/roulette.png'),
                    _buildBottomNavigationItem('셔틀', 'assets/bus.png'),
                    _buildBottomNavigationItem('제휴 정보', 'assets/info.png'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text, String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Row(
            children: [
              Image.asset(assetPath, width: 24, height: 24),
              SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideButton(String text, String assetPath, Color color, {Color textcolor = Colors.black, VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 50,
          height: 55,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, width: 24, height: 24),
              SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(
                  color: textcolor,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationItem(String text, String assetPath) {
    return GestureDetector(
      onTap: () {
      if (text == '하냥닝') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => ChatBotPage()), // 추가
        ); // 추가
      }//
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, width: 30, height: 30),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<Map<String, String>> _messages = []; // 사용자와 챗봇의 메시지를 저장하는 리스트
  final TextEditingController _controller = TextEditingController(); // 텍스트 입력 필드를 제어하는 컨트롤러

  // _sendMessage 함수는 사용자가 메시지를 전송할 때 호출됩니다.
  // 메시지를 _messages 리스트에 추가하고 입력 필드를 비움
  void _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      // 사용자의 메시지를 리스트에 추가
      _messages.add({'text': text, 'sender': 'user'});
    });

    _controller.clear(); // 입력 필드를 비웁니다.

    // GPT-3 API를 통해 봇의 응답을 가져옴
    final botResponse = await _getBotResponse(text);

    setState(() {
      // 봇의 응답을 리스트에 추가
      _messages.add({'text': botResponse, 'sender': 'bot'});
    });
  }

  Future<String> _getBotResponse(String query) async {
    Map<String, String> database = {
      '수강신청 팁': '수강신청을 할 때는 미리 원하는 강의를 찜해두는 것이 좋아요. 수강신청 시작 10분 전에 미리 로그인해두라냥!',
      '맛집 추천': '우리 학교 근처 맛집으로는 ABC카페, XYZ식당이 있어요. 특히 ABC카페의 커피는 정말 맛있다냥!',
      '도서관 이용 팁': '도서관은 오전 9시부터 오후 10시까지 운영된다냥. 조용히 공부할 수 있는 공간이 많으니 이용해보라냥!',
    };

    try {
      String databaseHint = '';
      if (database.containsKey(query)) {
        databaseHint = database[query] ?? '';
      }

      final response = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  """
              You are a helpful assistant that speaks in a friendly tone and always ends your sentences with '냥'. Follow these rules:
              1. Convert '~습니다' to '~다냥'.
              2. Convert '~ㅂ니다' to '~다냥'.
              3. Convert '~어요' to '~다냥'.
              4. Convert '~아요' to '~다냥'.
              5. Convert '~했어요' to '~했다냥'.
              6. Convert '~였어요' to '~였다냥'.
              7. Convert '~입니다' to '~이다냥'.
              8. Convert '~에요.' to '라냥'.
              9. Convert '~세요.' to '냥'.
              10. Convert command forms ending in '~세요' to '~라냥'.
              11. Place '냥' before any question mark (?) or exclamation mark (!).
              Here is a hint to use in your response: $databaseHint
              """
              ),
            ],
            role: OpenAIChatMessageRole.system,
          ),
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                query,
              ),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );

      String botResponse = response.choices.first.message?.content?.first.text
          ?.trim() ?? "응답을 가져오는 데 문제가 발생했다냥.. 나중에 다시 시도해주라냥.";
      if (databaseHint.isNotEmpty) {
        botResponse = "$databaseHint 추가적으로, $botResponse";
      }
      return botResponse;
    } catch (e) {
      log("Error: $e");
      return "응답을 가져오는 데 문제가 발생했다냥.. 나중에 다시 시도해주라냥.";
    }
  }
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? '오후' : '오전';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $formattedHour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/cat.png'),
              radius: 16,
            ),
            SizedBox(width: 8),
            Text("하냥닝"),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF8F9FA), // 홈 화면과 유사한 배경색 적용
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.topRight : Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? Color(0xFFFFCDD2) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['text'] ?? '',
                            style: TextStyle(
                                color: isUser ? Colors.black : Colors.black87),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${_formatTime(DateTime.now())}",
                            style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.black54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) {
                        _sendMessage();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}