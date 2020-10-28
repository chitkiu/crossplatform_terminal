class ResponseData {

  ResponseData({
    this.success = "",
    this.error = ""
  });

  final String success;
  final String error;

  bool isSuccess() {
    return success.isNotEmpty && this.error.isEmpty;
  }

  bool hasError() {
    return this.error.isNotEmpty;
  }

}