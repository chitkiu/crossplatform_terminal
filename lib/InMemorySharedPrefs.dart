import 'data/api/http_requests.dart';

class InMemorySharedPreference {
  static final HttpApiRequests requests = HttpApiRequests("http", "localhost:8080");
}