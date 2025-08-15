import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;
  WebSocketService._internal();

  static WebSocketService get instance => _instance;

  StompClient? _stompClient;
  AuthRepository? _authRepository;

  bool _isConnected = false;
  String? userId;
  String? doctorId;
  String? role;

  final List<Function()> _appointmentCallbacks = [];
  final List<Function()> _kennelCallbacks = [];

  bool get isConnected => _isConnected;

  void addAppointmentListener(Function() callback) {
    if (!_appointmentCallbacks.contains(callback)) {
      _appointmentCallbacks.add(callback);
      print("Added appointment: ${_appointmentCallbacks.length}");
    }
  }

  void removeAppointmentListener(Function() callback) {
    if (_appointmentCallbacks.contains(callback)) {
      _appointmentCallbacks.remove(callback);
    }
  }

  void addKennelListener(Function() callback) {
    if (!_kennelCallbacks.contains(callback)) {
      _kennelCallbacks.add(callback);
    }
  }

  void removeKennelListener(Function() callback) {
    if (_kennelCallbacks.contains(callback)) {
      _kennelCallbacks.remove(callback);
    }
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    _subscribeToAppointments();
    _subcribeToKennels();
    print("Connected");
  }

  void _subscribeToAppointments() {
    if (!_isConnected || _stompClient == null) return;
    _stompClient?.subscribe(
      destination: '/topic/appointments',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final appointmentData = jsonDecode(frame.body!);

          final receivedUserId = appointmentData['userId'];
          final receivedDoctorId = appointmentData['doctorId'];

          if (receivedDoctorId == doctorId || receivedUserId == userId) {
            print(
              "length appointment ${_appointmentCallbacks.length} callbacks",
            );
            for (var callback in _appointmentCallbacks) {
              try {
                callback.call();
              } catch (e) {
                print("Error appointment: $e");
              }
            }
          }
        }
      },
    );
  }

  void _subcribeToKennels() {
    if (!_isConnected || _stompClient == null) return;
    _stompClient?.subscribe(
      destination: '/topic/kennels',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final kennelData = jsonDecode(frame.body!);
          final receivedUserId = kennelData['userId'];
          final receivedDoctorId = kennelData['doctorId'];
          if (receivedDoctorId == doctorId || receivedUserId == userId) {
            for (var callback in _kennelCallbacks) {
              try {
                callback.call();
              } catch (e) {
                print("Error kennel: $e");
              }
            }
          }
        }
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    _isConnected = false;
  }

  Future<void> connect(String role, String id) async {
    if (_isConnected && (userId != null || doctorId != null)) return;
    try {
      if (role == "DOCTOR") {
        doctorId = id;
      } else if (role == "USER") {
        userId = id;
      }
      this.role = role;

      _stompClient = StompClient(
        config: StompConfig(
          url: EndPoints.wsUrl,
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onWebSocketError: (dynamic error) {
            print("WebSocket error details: ${error.runtimeType} - $error");
          },
          onStompError: (frame) {
            print("STOMP error: ${frame.body}");
          },
          onWebSocketDone: () => print("WebSocket closed"),
          heartbeatIncoming: Duration(seconds: 10),
          heartbeatOutgoing: Duration(seconds: 10),
          reconnectDelay: Duration(seconds: 5),
        ),
      );
      _stompClient!.activate();
    } catch (e) {
      print("Error connect websocket : $e");
    }
  }

  Future<void> disconnect() async {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }
    _isConnected = false;
    userId = null;
    doctorId = null;
    role = null;
    _authRepository = null;
    _appointmentCallbacks.clear();
    _kennelCallbacks.clear();
  }
}
