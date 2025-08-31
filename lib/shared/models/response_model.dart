class ResponseModel<T> {
  bool success;
  T? data;
  String? message;

  ResponseModel(this.data, this.success, this.message);
}
