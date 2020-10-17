class CloudNetV3Status {
  final CloudNetV3NodeIdentity info;
  final int serviceCount;
  final Iterable<String> modules;
  final CloudNetV3NodeInfo currentNetworkClusterNodeInfoSnapshot;
  final CloudNetV3NodeInfo lastNetworkClusterNodeInfoSnapshot;

  //TODO: add "clientConnections": []

  CloudNetV3Status(this.info, this.currentNetworkClusterNodeInfoSnapshot,
      this.lastNetworkClusterNodeInfoSnapshot, this.serviceCount, this.modules);

  factory CloudNetV3Status.fromJSONMap(Map<String, dynamic> data) {
    return CloudNetV3Status(
        CloudNetV3NodeIdentity.fromJSONMap(data['Identity']),
        CloudNetV3NodeInfo.fromJSONMap(
            data['currentNetworkClusterNodeInfoSnapshot']),
        CloudNetV3NodeInfo.fromJSONMap(
            data['lastNetworkClusterNodeInfoSnapshot']),
        data['providedServicesCount'],
        (data['modules'] as List).map((e) => e.toString()));
  }

  @override
  String toString() {
    return 'CloudNetV3Status{info: $info, serviceCount: $serviceCount, modules: $modules, currentNetworkClusterNodeInfoSnapshot: $currentNetworkClusterNodeInfoSnapshot, lastNetworkClusterNodeInfoSnapshot: $lastNetworkClusterNodeInfoSnapshot}';
  }
}

class CloudNetV3Listener {
  final String ip;
  final int port;

  CloudNetV3Listener(this.ip, this.port);

  factory CloudNetV3Listener.fromJSONMap(Map<String, dynamic> data) {
    return CloudNetV3Listener(data['host'], data['port']);
  }

  @override
  String toString() {
    return 'CloudNetV3Listener{ip: $ip, port: $port}';
  }
}

class CloudNetV3NodeIdentity {
  final String name;
  final Iterable<CloudNetV3Listener> listeners;
  final Map<String, dynamic> properties;

  CloudNetV3NodeIdentity(this.name, this.listeners, this.properties);

  factory CloudNetV3NodeIdentity.fromJSONMap(Map<String, dynamic> data) {
    return CloudNetV3NodeIdentity(
        data['uniqueId'],
        (data['listeners'] as List)
            .map((e) => CloudNetV3Listener.fromJSONMap(e)),
        data['properties']);
  }

  @override
  String toString() {
    return 'CloudNetV3NodeIdentity{name: $name, listeners: $listeners, properties: $properties}';
  }
}

class CloudNetV3NodeInfo {
  final int creationTime;
  final CloudNetV3NodeIdentity info;
  final String version;
  final int serviceCount;

  final int usedMemoryInMB;
  final int reservedMemoryInMB;
  final int maxMemoryInMB;

  final double systemCpuUsage;

  final Map<String, dynamic> properties;

  CloudNetV3NodeInfo(
      this.creationTime,
      this.info,
      this.version,
      this.serviceCount,
      this.usedMemoryInMB,
      this.reservedMemoryInMB,
      this.maxMemoryInMB,
      this.systemCpuUsage,
      this.properties);

  factory CloudNetV3NodeInfo.fromJSONMap(Map<String, dynamic> data) {
    return CloudNetV3NodeInfo(
        data['creationTime'],
        CloudNetV3NodeIdentity.fromJSONMap(data['node']),
        data['version'],
        data['currentServicesCount'],
        data['usedMemory'],
        data['reservedMemory'],
        data['maxMemory'],
        data['systemCpuUsage'],
        data['properties']);
  }

  @override
  String toString() {
    return 'CloudNetV3NodeInfo{creationTime: $creationTime, info: $info, version: $version, serviceCount: $serviceCount, usedMemoryInMB: $usedMemoryInMB, reservedMemoryInMB: $reservedMemoryInMB, maxMemoryInMB: $maxMemoryInMB, systemCpuUsage: $systemCpuUsage, properties: $properties}';
  }

//TODO: add processSnapshot
/*
  "processSnapshot": {
"heapUsageMemory": 159073712,
"noHeapUsageMemory": 79743264,
"maxHeapMemory": 478150656,
"currentLoadedClassCount": 6441,
"totalLoadedClassCount": 6608,
"unloadedClassCount": 167,
"threads": [
{
"id": 3,
"name": "Finalizer",
"threadState": "WAITING",
"daemon": true,
"priority": 8
}
],
"cpuUsage": 8.428246013667426,
"pid": 25625
}
   */
//TODO: add extensions
/*
"extensions": [
{
"group": "aether.projects",
"name": "ScreenWebPanel",
"version": "1.0",
"author": "Aether Project(Dmytro Korotchenko)",
"website": "https://aether-project.games",
"description": "Module provide web console for services",
"properties": {}
}
]
 */
}
