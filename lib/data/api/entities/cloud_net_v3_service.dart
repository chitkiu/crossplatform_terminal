class CloudNetV3Service {

  final int creationTime;
  final CloudNetV3ServiceInfo serviceId;
  final CloudNetV3ServiceAddress address;
  final int connectedTime;
  final String lifeCycle;

  //TODO: Add other fields

  CloudNetV3Service(this.creationTime, this.serviceId, this.address,
      this.connectedTime, this.lifeCycle);

  @override
  String toString() {
    return 'CloudNetV3Service{creationTime: $creationTime, serviceId: $serviceId, address: $address, connectedTime: $connectedTime, lifeCycle: $lifeCycle}';
  }

  factory CloudNetV3Service.fromJSON(Map<String, dynamic> data) {
    return CloudNetV3Service(
        data['creationTime'],
        CloudNetV3ServiceInfo.fromJSON(data['serviceId']),
        CloudNetV3ServiceAddress.fromJSON(data['address']),
        data['connectedTime'],
        data['lifeCycle']
    );
  }
}

class CloudNetV3ServiceInfo {
  final String uniqueId; //UUID
  final String nodeUniqueId;
  final String taskName;
  final int taskServiceId;
  final String environment;

  CloudNetV3ServiceInfo(this.uniqueId, this.nodeUniqueId, this.taskName,
      this.taskServiceId, this.environment);

  @override
  String toString() {
    return 'CloudNetV3ServiceInfo{uniqueId: $uniqueId, nodeUniqueId: $nodeUniqueId, taskName: $taskName, taskServiceId: $taskServiceId, environment: $environment}';
  }

  factory CloudNetV3ServiceInfo.fromJSON(Map<String, dynamic> data) {
    return CloudNetV3ServiceInfo(
      data['uniqueId'],
      data['nodeUniqueId'],
      data['taskName'],
      data['taskServiceId'],
      data['environment'],
    );
  }
}

class CloudNetV3ServiceAddress {
  final String ip;
  final int port;

  CloudNetV3ServiceAddress(this.ip, this.port);

  @override
  String toString() {
    return 'CloudNetV3ServiceAddress{ip: $ip, port: $port}';
  }

  factory CloudNetV3ServiceAddress.fromJSON(Map<String, dynamic> data) {
    return CloudNetV3ServiceAddress(
      data['ip'],
      data['port']
    );
  }
}
