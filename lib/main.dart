import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CentralApp());
}

class CentralApp extends StatelessWidget {
  const CentralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Central Attendance System',
      home: CentralHomePage(),
    );
  }
}

class CentralHomePage extends StatefulWidget {
  @override
  _CentralHomePageState createState() => _CentralHomePageState();
}

class _CentralHomePageState extends State<CentralHomePage> {
  BonsoirDiscovery? _discovery;
  List<ResolvedBonsoirService> _discoveredServices = [];

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  Future<void> _startDiscovery() async {
    // _discovery = BonsoirDiscovery(type: '_attendance._tcp');
    // _discovery!.ready.then((_) {
    //   print("Discovery Started");
    //   _discovery!.start();
    // });
    // _discovery!.eventStream?.listen((event) {
    //   if (event is BonsoirDiscoveryEvent && event.isServiceResolved) {
    //     final service = event.service as ResolvedBonsoirService;
    //     print("Discovered service: ${service.toJson()}");
    //     setState(() {
    //       _discoveredServices.add(service);
    //     });
    //   }
    // });

    BonsoirDiscovery discovery =
        BonsoirDiscovery(type: '_horizonattendan._tcp');
    await discovery.ready;

// If you want to listen to the discovery :
    discovery.eventStream!.listen((event) {
      // `eventStream` is not null as the discovery instance is "ready" !
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        print('Service found : ${event.service?.toJson()}');
        event.service!.resolve(discovery
            .serviceResolver); // Should be called when the user wants to connect to this service.
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolved) {
        print('Service resolved : ${event.service?.toJson()}');
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        print('Service lost : ${event.service?.toJson()}');
      }

      if (event.isServiceResolved) {
        final service = event.service as ResolvedBonsoirService;
        print("Discovered service: ${service.toJson()}");
        setState(() {
          _discoveredServices.add(service);
        });
      }

      if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        print('Service lost2 : ${event.service?.toJson()}');
      }
    });

    // Start the discovery **after** listening to discovery events :
    await discovery.start();
  }

  @override
  void dispose() {
    _discovery?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Central Attendance System'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _discovery?.stop();
          await _startDiscovery();
        },
      ),
      body: ListView.builder(
        itemCount: _discoveredServices.length,
        itemBuilder: (context, index) {
          final service = _discoveredServices[index];
          return ListTile(
            title: Text(service.name),
          );
        },
      ),
    );
  }
}
