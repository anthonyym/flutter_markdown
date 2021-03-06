// Copyright 2021 Quiverware LLC. Open source contribution. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mockito/mockito.dart';

class TestHttpOverrides extends HttpOverrides {
  HttpClient createHttpClient(SecurityContext? context) {
    return createMockImageHttpClient(context);
  }
}

MockHttpClient createMockImageHttpClient(SecurityContext? _) {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  final _transparentImage = MockTestImage.image;

  when(client.getUrl(any))
      .thenAnswer((_) => Future<MockHttpClientRequest>.value(request));

  when(request.headers).thenReturn(headers);

  when(request.close())
      .thenAnswer((_) => Future<MockHttpClientResponse>.value(response));

  when(client.autoUncompress = any).thenAnswer((_) => null);

  when(response.contentLength).thenReturn(_transparentImage.length);

  when(response.statusCode).thenReturn(HttpStatus.ok);

  when(response.compressionState)
      .thenReturn(HttpClientResponseCompressionState.notCompressed);

  // Define an image stream that streams the mock test image for all
  // image tests that request an image.
  StreamSubscription<List<int>> imageStream(Invocation invocation) {
    final void Function(List<int>)? onData = invocation.positionalArguments[0];
    final void Function()? onDone = invocation.namedArguments[#onDone];
    final void Function(Object, [StackTrace?])? onError =
        invocation.namedArguments[#onError];
    final bool? cancelOnError = invocation.namedArguments[#cancelOnError];

    return Stream<List<int>>.fromIterable(<List<int>>[_transparentImage])
        .listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  when(response.listen(any,
          onError: anyNamed('onError'),
          onDone: anyNamed('onDone'),
          cancelOnError: anyNamed('cancelOnError')))
      .thenAnswer(imageStream);

  return client;
}

class MockTestImage {
  // This string represents the hexidecial bytes of a transparent image. A
  // string is used to make the visual representation of the data compact. A
  // List<int> of the same data requires over 60 lines in a source file with
  // each element in the array on a single line.
  static const _imageBytesAsString = '''
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  ''';

  // Convert the string representing the hexidecimal bytes in the image into
  // a list of integers that can be consumed as image data in a stream.
  static final _transparentImage = LineSplitter()
      .convert(_imageBytesAsString.replaceAllMapped(
          RegExp(r' *0x([A-F0-9]{2}),? *\n? *'), (m) => '${m[1]}\n'))
      .map<int>((b) => int.parse(b, radix: 16))
      .toList();

  static List<int> get image => _transparentImage;
}

/// Define the "fake" data types to be used in mock data type definitions. These
/// fake data types are important in the definition of the return values of the
/// properties and methods of the mock data types for null safety.
class _FakeDuration extends Fake implements Duration {}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {}

class _FakeUri extends Fake implements Uri {}

class _FakeHttpHeaders extends Fake implements HttpHeaders {}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {}

class _FakeSocket extends Fake implements Socket {}

class _FakeStreamSubscription<T> extends Fake implements StreamSubscription<T> {
}

/// A class which mocks [HttpClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClient extends Mock implements HttpClient {
  MockHttpClient() {
    throwOnMissingStub(this);
  }

  @override
  Duration get idleTimeout =>
      (super.noSuchMethod(Invocation.getter(#idleTimeout), _FakeDuration())
          as Duration);

  @override
  set idleTimeout(Duration? _idleTimeout) =>
      super.noSuchMethod(Invocation.setter(#idleTimeout, _idleTimeout));

  @override
  bool get autoUncompress =>
      (super.noSuchMethod(Invocation.getter(#autoUncompress), false) as bool);

  @override
  set autoUncompress(bool? _autoUncompress) =>
      super.noSuchMethod(Invocation.setter(#autoUncompress, _autoUncompress));

  @override
  Future<HttpClientRequest> open(
          String? method, String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#open, [method, host, port, path]),
          Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> openUrl(String? method, Uri? url) =>
      (super.noSuchMethod(Invocation.method(#openUrl, [method, url]),
          Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> get(String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#get, [host, port, path]),
          Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> getUrl(Uri? url) => (super.noSuchMethod(
      Invocation.method(#getUrl, [url]),
      Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> post(String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#post, [host, port, path]),
          Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> postUrl(Uri? url) => (super.noSuchMethod(
      Invocation.method(#postUrl, [url]),
      Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> put(String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#put, [host, port, path]),
          Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> putUrl(Uri? url) => (super.noSuchMethod(
      Invocation.method(#putUrl, [url]),
      Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> delete(String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#delete, [host, port, path]),
          Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> deleteUrl(Uri? url) => (super.noSuchMethod(
      Invocation.method(#deleteUrl, [url]),
      Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> patch(String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#patch, [host, port, path]),
          Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> patchUrl(Uri? url) => (super.noSuchMethod(
      Invocation.method(#patchUrl, [url]),
      Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> head(String? host, int? port, String? path) =>
      (super.noSuchMethod(Invocation.method(#head, [host, port, path]),
          Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  Future<HttpClientRequest> headUrl(Uri? url) => (super.noSuchMethod(
      Invocation.method(#headUrl, [url]),
      Future.value(_FakeHttpClientRequest())) as Future<HttpClientRequest>);

  @override
  void addCredentials(
          Uri? url, String? realm, HttpClientCredentials? credentials) =>
      super.noSuchMethod(
          Invocation.method(#addCredentials, [url, realm, credentials]));

  @override
  void addProxyCredentials(String? host, int? port, String? realm,
          HttpClientCredentials? credentials) =>
      super.noSuchMethod(Invocation.method(
          #addProxyCredentials, [host, port, realm, credentials]));

  @override
  void close({bool? force = false}) =>
      super.noSuchMethod(Invocation.method(#close, [], {#force: force}));
}

/// A class which mocks [HttpClientRequest].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClientRequest extends Mock implements HttpClientRequest {
  MockHttpClientRequest() {
    throwOnMissingStub(this);
  }

  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection), false)
          as bool);

  @override
  set persistentConnection(bool? _persistentConnection) => super.noSuchMethod(
      Invocation.setter(#persistentConnection, _persistentConnection));

  @override
  bool get followRedirects =>
      (super.noSuchMethod(Invocation.getter(#followRedirects), false) as bool);

  @override
  set followRedirects(bool? _followRedirects) =>
      super.noSuchMethod(Invocation.setter(#followRedirects, _followRedirects));

  @override
  int get maxRedirects =>
      (super.noSuchMethod(Invocation.getter(#maxRedirects), 0) as int);

  @override
  set maxRedirects(int? _maxRedirects) =>
      super.noSuchMethod(Invocation.setter(#maxRedirects, _maxRedirects));

  @override
  int get contentLength =>
      (super.noSuchMethod(Invocation.getter(#contentLength), 0) as int);

  @override
  set contentLength(int? _contentLength) =>
      super.noSuchMethod(Invocation.setter(#contentLength, _contentLength));

  @override
  bool get bufferOutput =>
      (super.noSuchMethod(Invocation.getter(#bufferOutput), false) as bool);

  @override
  set bufferOutput(bool? _bufferOutput) =>
      super.noSuchMethod(Invocation.setter(#bufferOutput, _bufferOutput));

  @override
  String get method =>
      (super.noSuchMethod(Invocation.getter(#method), '') as String);

  @override
  Uri get uri =>
      (super.noSuchMethod(Invocation.getter(#uri), _FakeUri()) as Uri);

  @override
  HttpHeaders get headers =>
      (super.noSuchMethod(Invocation.getter(#headers), _FakeHttpHeaders())
          as HttpHeaders);

  @override
  List<Cookie> get cookies =>
      (super.noSuchMethod(Invocation.getter(#cookies), <Cookie>[])
          as List<Cookie>);

  @override
  Future<HttpClientResponse> get done => (super.noSuchMethod(
          Invocation.getter(#done), Future.value(_FakeHttpClientResponse()))
      as Future<HttpClientResponse>);

  @override
  Future<HttpClientResponse> close() => (super.noSuchMethod(
      Invocation.method(#close, []),
      Future.value(_FakeHttpClientResponse())) as Future<HttpClientResponse>);
}

/// A class which mocks [HttpClientResponse].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClientResponse extends Mock implements HttpClientResponse {
  MockHttpClientResponse() {
    throwOnMissingStub(this);
  }

  // Include an override method for the inherited listen method. This method
  // intercepts HttpClientResponse listen calls to return a mock image.
  @override
  StreamSubscription<List<int>> listen(void onData(List<int> event)?,
          {Function? onError, void onDone()?, bool? cancelOnError}) =>
      (super.noSuchMethod(
          Invocation.method(
            #listen,
            [onData],
            {#onError: onError, #onDone: onDone, #cancelOnError: cancelOnError},
          ),
          _FakeStreamSubscription<List<int>>()));

  @override
  int get statusCode =>
      (super.noSuchMethod(Invocation.getter(#statusCode), 0) as int);

  @override
  String get reasonPhrase =>
      (super.noSuchMethod(Invocation.getter(#reasonPhrase), '') as String);

  @override
  int get contentLength =>
      (super.noSuchMethod(Invocation.getter(#contentLength), 0) as int);

  @override
  HttpClientResponseCompressionState get compressionState =>
      (super.noSuchMethod(Invocation.getter(#compressionState),
              HttpClientResponseCompressionState.notCompressed)
          as HttpClientResponseCompressionState);

  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection), false)
          as bool);

  @override
  bool get isRedirect =>
      (super.noSuchMethod(Invocation.getter(#isRedirect), false) as bool);

  @override
  List<RedirectInfo> get redirects =>
      (super.noSuchMethod(Invocation.getter(#redirects), <RedirectInfo>[])
          as List<RedirectInfo>);

  @override
  HttpHeaders get headers =>
      (super.noSuchMethod(Invocation.getter(#headers), _FakeHttpHeaders())
          as HttpHeaders);

  @override
  List<Cookie> get cookies =>
      (super.noSuchMethod(Invocation.getter(#cookies), <Cookie>[])
          as List<Cookie>);

  @override
  Future<HttpClientResponse> redirect(
          [String? method, Uri? url, bool? followLoops]) =>
      (super.noSuchMethod(
              Invocation.method(#redirect, [method, url, followLoops]),
              Future.value(_FakeHttpClientResponse()))
          as Future<HttpClientResponse>);

  @override
  Future<Socket> detachSocket() => (super.noSuchMethod(
          Invocation.method(#detachSocket, []), Future.value(_FakeSocket()))
      as Future<Socket>);
}

/// A class which mocks [HttpHeaders].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpHeaders extends Mock implements HttpHeaders {
  MockHttpHeaders() {
    throwOnMissingStub(this);
  }

  @override
  int get contentLength =>
      (super.noSuchMethod(Invocation.getter(#contentLength), 0) as int);

  @override
  set contentLength(int? _contentLength) =>
      super.noSuchMethod(Invocation.setter(#contentLength, _contentLength));

  @override
  bool get persistentConnection =>
      (super.noSuchMethod(Invocation.getter(#persistentConnection), false)
          as bool);

  @override
  set persistentConnection(bool? _persistentConnection) => super.noSuchMethod(
      Invocation.setter(#persistentConnection, _persistentConnection));

  @override
  bool get chunkedTransferEncoding =>
      (super.noSuchMethod(Invocation.getter(#chunkedTransferEncoding), false)
          as bool);

  @override
  set chunkedTransferEncoding(bool? _chunkedTransferEncoding) =>
      super.noSuchMethod(Invocation.setter(
          #chunkedTransferEncoding, _chunkedTransferEncoding));

  @override
  List<String>? operator [](String? name) =>
      (super.noSuchMethod(Invocation.method(#[], [name])) as List<String>?);

  @override
  String? value(String? name) =>
      (super.noSuchMethod(Invocation.method(#value, [name])) as String?);

  @override
  void add(String? name, Object? value, {bool? preserveHeaderCase = false}) =>
      super.noSuchMethod(Invocation.method(
          #add, [name, value], {#preserveHeaderCase: preserveHeaderCase}));

  @override
  void set(String? name, Object? value, {bool? preserveHeaderCase = false}) =>
      super.noSuchMethod(Invocation.method(
          #set, [name, value], {#preserveHeaderCase: preserveHeaderCase}));

  @override
  void remove(String? name, Object? value) =>
      super.noSuchMethod(Invocation.method(#remove, [name, value]));

  @override
  void removeAll(String? name) =>
      super.noSuchMethod(Invocation.method(#removeAll, [name]));

  @override
  void forEach(void Function(String, List<String>)? action) =>
      super.noSuchMethod(Invocation.method(#forEach, [action]));

  @override
  void noFolding(String? name) =>
      super.noSuchMethod(Invocation.method(#noFolding, [name]));
}
