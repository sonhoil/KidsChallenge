/// 모바일 환경용 스텁 파일
/// 웹 환경에서는 dio/browser.dart의 BrowserHttpClientAdapter가 사용됩니다.

import 'package:dio/dio.dart';

class BrowserHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<dynamic>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw UnimplementedError('BrowserHttpClientAdapter is only available on web');
  }

  @override
  void close({bool force = false}) {
    // 모바일 환경에서는 사용되지 않음
  }
}
