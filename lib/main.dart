import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  await _initialize();
  runApp(const NaverMapApp());
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
                    _buildCategoryButton('식당', Icons.restaurant, Colors.blue),
                    _buildCategoryButton('카페', Icons.local_cafe, Colors.brown),
                    _buildCategoryButton('편의점', Icons.local_convenience_store, Colors.orange),
                    _buildCategoryButton('약국', Icons.local_pharmacy, Colors.red),
                    _buildCategoryButton('셀프사진관', Icons.camera, Colors.blueGrey),
                    _buildCategoryButton('마트', Icons.shopping_basket, Colors.deepOrangeAccent),
                    _buildCategoryButton('?', Icons.local_hospital, Colors.purple),
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
                        _buildSideButton('한식', Icons.rice_bowl, Colors.white, Colors.black, Colors.black),
                        _buildSideButton('양식', Icons.fastfood, Colors.white, Colors.redAccent, Colors.black),
                        _buildSideButton('일식', Icons.restaurant, Colors.white, Colors.grey, Colors.black),
                        _buildSideButton('중식', Icons.dining, Colors.white, Colors.blueAccent, Colors.black),
                        _buildSideButton('기타', Icons.more_horiz, Colors.white, Colors.black, Colors.black),
                      ],
                    ),
                  ),
                  _buildSideButton('메뉴', Icons.menu_book, Colors.blue, Colors.white, Colors.white, onPressed: () {
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
                    _buildBottomNavigationItem('ㅇㅇ봇', Icons.android, Colors.blueAccent),
                    _buildBottomNavigationItem('가게', Icons.store, Colors.orange),
                    _buildBottomNavigationItem('메뉴 룰렛', Icons.casino, Colors.red),
                    _buildBottomNavigationItem('셔틀', Icons.directions_bus, Colors.blue),
                    _buildBottomNavigationItem('제휴 정보', Icons.info, Colors.purple),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text, IconData icon, Color color) {
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
              Icon(icon, color: color),
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
  Widget _buildSideButton(String text, IconData icon, Color color, Color iconcolor, Color textcolor, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 60,
          height: 60,
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
              Icon(icon, color: iconcolor, size: 24),
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
  Widget _buildBottomNavigationItem(String text, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: color),
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
    );
  }
}