import 'package:flutter/material.dart';
import 'package:graphite/graphite.dart';

import '../../../core/constants/color_constants.dart';
import '../../../features/database/models/device.dart';
import '../../../features/database/models/node_device_info_graph.dart';

class ViewDevicesPage extends StatefulWidget {
  final List<Device> devices;
  const ViewDevicesPage({super.key, required this.devices});

  @override
  State<ViewDevicesPage> createState() => _ViewDevicesPageState();
}

class _ViewDevicesPageState extends State<ViewDevicesPage>
    with SingleTickerProviderStateMixin {
  late Map<String, Device> deviceMap;

  List<NodeInput> buildGraphFromDevices(Map<String, Device> deviceMap) {
    // Pisahkan berdasarkan meshRoot (mac)
    final Map<String, Map<String, Device>> groupedByMesh = {};

    for (var entry in deviceMap.entries) {
      final device = entry.value;
      final mac = device.meshNetwork.macRoot;

      groupedByMesh.putIfAbsent(mac, () => {});
      groupedByMesh[mac]![device.nodeId] = device;
    }

    final List<NodeInput> finalGraphList = [];

    // Untuk setiap group mesh
    for (var meshDevices in groupedByMesh.values) {
      meshDevices.forEach((key, device) {
        // Hanya root yang memiliki next
        if (device.role == 'root') {
          final nextNodes = meshDevices.entries
              .where((entry) => entry.value.role == 'node')
              .map((entry) =>
                  EdgeInput(outcome: entry.key, type: EdgeArrowType.one))
              .toList();

          finalGraphList.add(NodeInput(
            id: key,
            next: nextNodes,
          ));
        } else {
          // Node tidak memiliki next
          finalGraphList.add(NodeInput(id: key, next: []));
        }
      });
    }

    return finalGraphList;
  }

  NodeDeviceInfoGraph? _currentNodeInfo;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    final devices = widget.devices;
    deviceMap = Map.fromEntries(
      devices.map((device) => MapEntry(device.nodeId, device)),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _tooltip(BuildContext context) {
    const tooltipHeight = 160.0;
    const maxWidth = 310.0;
    _animationController.reset();
    _animationController.forward();
    return Positioned(
      top: _currentNodeInfo!.rect.top - tooltipHeight,
      left: _currentNodeInfo!.rect.left +
          _currentNodeInfo!.rect.width * .5 -
          maxWidth * .5,
      child: SizedBox(
        width: maxWidth,
        height: tooltipHeight,
        child: FadeTransition(
          opacity: _animation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(225),
              border: Border.all(
                color: ColorConstants.cardBlueAppColor,
                width: 4,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _currentNodeInfo!.data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Node ID",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8, child: Text(":")),
                      Text(
                        _currentNodeInfo!.data.nodeId,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Role",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8, child: Text(":")),
                      Text(
                        _currentNodeInfo!.data.role,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Mesh Name",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8, child: Text(":")),
                      Text(
                        _currentNodeInfo!.data.meshNetwork.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Mesh Address",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8, child: Text(":")),
                      Text(
                        _currentNodeInfo!.data.meshNetwork.macRoot,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOverlay(
      BuildContext context, List<NodeInput> nodes, List<Edge> edges) {
    return _currentNodeInfo == null ? [] : [_tooltip(context)];
  }

  _onCanvasTap(TapDownDetails details) {
    setState(() {
      _currentNodeInfo = null;
    });
  }

  _onNodeTap(TapUpDetails details, NodeInput node, Rect nodeRect) {
    setState(() {
      _currentNodeInfo = NodeDeviceInfoGraph(
        node: node,
        rect: nodeRect,
        data: deviceMap[node.id]!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("GetDevices = ${widget.devices}");
    final graphData = buildGraphFromDevices(deviceMap);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.lightBlueAppColor,
        leading: Builder(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onBackButtonTapped(context),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
          ),
        ),
        title: const Text("All Devices"),
        centerTitle: true,
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(double.infinity),
        constrained: false,
        minScale: .7,
        maxScale: 1,
        child: DirectGraph(
          list: graphData,
          defaultCellSize: const Size(125, 125),
          cellPadding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
          orientation: MatrixOrientation.Horizontal,
          clipBehavior: Clip.none,
          centered: true,
          overlayBuilder:
              (BuildContext context, List<NodeInput> nodes, List<Edge> edges) =>
                  _buildOverlay(context, nodes, edges),
          onCanvasTap: _onCanvasTap,
          onNodeTapUp: _onNodeTap,
          nodeBuilder: (ctx, node) {
            return Card(
              color: ColorConstants.whiteAppColor,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Opacity(
                        opacity: 0.25,
                        child: Image.asset(
                          'lib/assets/images/logo_biru_putih.png',
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        node.id,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          styleBuilder: (edge) {
            var p = Paint()
              ..color = ColorConstants.darkBlueAppColor
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..strokeWidth = 2;
            LineStyle lineStyle = LineStyle.solid;
            return EdgeStyle(
              lineStyle: lineStyle,
              borderRadius: 40,
              linePaint: p,
            );
          },
        ),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }
}
