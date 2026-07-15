import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';

/// Satu event yang diterima dari SSE (event: notification / booking_update).
/// Event "heartbeat" sengaja tidak diteruskan -- cuma buat jaga koneksi.
class RealtimeEvent {
  final String type;
  final dynamic data;

  RealtimeEvent({required this.type, required this.data});
}

/// Client SSE manual (tanpa package tambahan) buat konsumsi
/// GET /api/realtime-updates. Dio mendukung `ResponseType.stream`
/// sehingga body-nya bisa dibaca chunk-per-chunk seperti stream biasa.
class RealtimeService {
  StreamSubscription? _subscription;
  final _controller = StreamController<RealtimeEvent>.broadcast();

  Stream<RealtimeEvent> get events => _controller.stream;

  Future<void> connect() async {
    await disconnect(); // pastikan gak dobel konek

    try {
      final response = await DioClient.instance.get<ResponseBody>(
        ApiEndpoints.realtimeUpdates,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          // Endpoint ini sengaja gak pernah selesai (infinite loop di server),
          // jadi jangan pakai receiveTimeout bawaan.
          receiveTimeout: Duration.zero,
        ),
      );

      String buffer = '';

      _subscription = response.data!.stream.listen(
        (chunk) {
          buffer += utf8.decode(chunk, allowMalformed: true);

          // 1 event SSE dipisah baris kosong ("\n\n")
          while (buffer.contains('\n\n')) {
            final idx = buffer.indexOf('\n\n');
            final rawEvent = buffer.substring(0, idx);
            buffer = buffer.substring(idx + 2);
            _parseAndEmit(rawEvent);
          }
        },
        onError: (_) {
          // Koneksi putus (server restart, jaringan hilang, dll).
          // Dibiarkan diam -- realtimeListenerProvider akan reconnect
          // saat provider di-watch ulang / screen dibuka lagi.
        },
        cancelOnError: true,
      );
    } catch (_) {
      // Gagal connect sama sekali (server mati) -> silent.
      // Fitur lain (list notifikasi/booking manual refresh) tetap jalan normal.
    }
  }

  void _parseAndEmit(String rawEvent) {
    String? eventType;
    String? eventData;

    for (final line in rawEvent.split('\n')) {
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        eventData = line.substring(5).trim();
      }
    }

    if (eventType == null || eventType == 'heartbeat' || eventData == null) return;

    try {
      final decoded = jsonDecode(eventData);
      _controller.add(RealtimeEvent(type: eventType, data: decoded));
    } catch (_) {
      // payload gagal di-parse, abaikan
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}