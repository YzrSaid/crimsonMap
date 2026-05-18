import 'dart:math';
import 'package:collection/collection.dart';

/// Represents a single node in the pathfinding graph
class PathNode {
  final String nodeId;
  final String name;
  final String type; // 'infrastructure', 'pathway', 'intermediate'
  final String campusId;
  final double latitude;
  final double longitude;
  final double xCoordinate;
  final double yCoordinate;
  final bool isActive;

  PathNode({
    required this.nodeId,
    required this.name,
    required this.type,
    required this.campusId,
    required this.latitude,
    required this.longitude,
    required this.xCoordinate,
    required this.yCoordinate,
    required this.isActive,
  });

  factory PathNode.fromJson(Map<String, dynamic> json) {
    return PathNode(
      nodeId: json['node_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'intermediate',
      campusId: json['campus_id'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      xCoordinate: (json['x_coordinate'] as num?)?.toDouble() ?? 0.0,
      yCoordinate: (json['y_coordinate'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// Represents an edge connecting two nodes
class PathEdge {
  final String fromNodeId;
  final String toNodeId;
  final double distance;
  final String pathType; // 'via_gate', 'via_overpass', 'via_walkway'
  final bool isActive;

  PathEdge({
    required this.fromNodeId,
    required this.toNodeId,
    required this.distance,
    required this.pathType,
    required this.isActive,
  });

  factory PathEdge.fromJson(Map<String, dynamic> json) {
    return PathEdge(
      fromNodeId: json['from_node'] as String? ?? '',
      toNodeId: json['to_node'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      pathType: json['path_type'] as String? ?? 'via_walkway',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// Represents a single route from start to end
class Route {
  final String routeId;
  final List<PathNode> path;
  final double totalDistance;
  final double walkingTime; // in minutes
  final String viaMode; // 'Via Walkway', 'Via Gate', 'Via Overpass'
  final bool isRecommended;
  final String routeName;
  final PathNode startNode;
  final PathNode endNode;

  Route({
    required this.routeId,
    required this.path,
    required this.totalDistance,
    required this.walkingTime,
    required this.viaMode,
    required this.isRecommended,
    required this.routeName,
    required this.startNode,
    required this.endNode,
  });

  String get formattedDistance {
    if (totalDistance >= 1000) {
      return '${(totalDistance / 1000).toStringAsFixed(2)} km';
    }
    return '${totalDistance.toStringAsFixed(0)} m';
  }
}

/// A* Algorithm node for pathfinding
class _AStarNode implements Comparable<_AStarNode> {
  final String nodeId;
  final double fScore;

  _AStarNode({required this.nodeId, required this.fScore});

  @override
  int compareTo(_AStarNode other) {
    return fScore.compareTo(other.fScore);
  }
}

/// Priority queue for A* algorithm
class _PriorityQueue {
  final _nodes = <_AStarNode>[];

  void enqueue(_AStarNode node) {
    _nodes.add(node);
    _nodes.sort();
  }

  _AStarNode? dequeue() {
    if (_nodes.isEmpty) return null;
    return _nodes.removeAt(0);
  }

  bool get isEmpty => _nodes.isEmpty;
  int get length => _nodes.length;
}

/// Main pathfinding service implementing A* algorithm with alternative paths
class PathfindingService {
  final Map<String, PathNode> _allNodes = {};
  final Map<String, List<({String toNodeId, double cost, PathEdge edge})>>
  _adjacencyList = {};

  static const double _alternativePathPenalty = 0.5;
  static const double _walkingSpeedMps = 1.4; // Average human walking speed

  /// Initialize the pathfinding graph with nodes and edges
  void initializeGraph({
    required List<PathNode> nodes,
    required List<PathEdge> edges,
  }) {
    _allNodes.clear();
    _adjacencyList.clear();

    // Add valid nodes
    for (final node in nodes) {
      if (node.isActive &&
          (node.type == 'infrastructure' ||
              node.type == 'pathway' ||
              node.type == 'intermediate')) {
        _allNodes[node.nodeId] = node;
      }
    }

    // Build adjacency list
    for (final node in _allNodes.values) {
      _adjacencyList[node.nodeId] = [];
    }

    for (final edge in edges) {
      if (!edge.isActive) continue;
      if (!_allNodes.containsKey(edge.fromNodeId) ||
          !_allNodes.containsKey(edge.toNodeId))
        continue;

      // Add bidirectional edges
      _adjacencyList[edge.fromNodeId]?.add((
        toNodeId: edge.toNodeId,
        cost: edge.distance,
        edge: edge,
      ));

      _adjacencyList[edge.toNodeId]?.add((
        toNodeId: edge.fromNodeId,
        cost: edge.distance,
        edge: edge,
      ));
    }
  }

  /// Find multiple alternative paths from start to end node
  Future<List<Route>> findMultiplePaths({
    required String startNodeId,
    required String endNodeId,
    int maxPaths = 3,
  }) async {
    if (!_allNodes.containsKey(startNodeId) ||
        !_allNodes.containsKey(endNodeId)) {
      return [];
    }

    final startNode = _allNodes[startNodeId]!;
    final endNode = _allNodes[endNodeId]!;

    if (startNode.type != 'infrastructure' &&
        startNode.type != 'intermediate') {
      return [];
    }

    if (endNode.type != 'infrastructure') {
      return [];
    }

    final allPaths = _findAlternativePaths(
      startId: startNodeId,
      goalId: endNodeId,
      maxPaths: maxPaths,
    );

    if (allPaths.isEmpty) return [];

    final routes = <Route>[];
    for (int i = 0; i < allPaths.length; i++) {
      final pathNodeIds = allPaths[i];
      final pathNodes = pathNodeIds
          .map((id) => _allNodes[id])
          .whereType<PathNode>()
          .toList();

      if (pathNodes.isEmpty) continue;

      final totalDistance = _calculateTotalDistance(pathNodeIds);
      final walkingTime = totalDistance / _walkingSpeedMps / 60; // in minutes
      final viaMode = _determineViaMode(pathNodeIds);

      routes.add(
        Route(
          routeId: 'route_${i + 1}',
          path: pathNodes,
          totalDistance: totalDistance,
          walkingTime: walkingTime,
          viaMode: viaMode,
          isRecommended: false,
          routeName: 'Route ${i + 1}',
          startNode: startNode,
          endNode: endNode,
        ),
      );
    }

    // Mark shortest route as recommended
    if (routes.isNotEmpty) {
      final shortestIndex = routes.indexed
          .reduce((a, b) => a.$2.totalDistance <= b.$2.totalDistance ? a : b)
          .$1;

      routes[shortestIndex] = Route(
        routeId: routes[shortestIndex].routeId,
        path: routes[shortestIndex].path,
        totalDistance: routes[shortestIndex].totalDistance,
        walkingTime: routes[shortestIndex].walkingTime,
        viaMode: routes[shortestIndex].viaMode,
        isRecommended: true,
        routeName: 'Route ${shortestIndex + 1} (Recommended)',
        startNode: startNode,
        endNode: endNode,
      );

      // Rename other routes
      for (int i = 0; i < routes.length; i++) {
        if (!routes[i].isRecommended) {
          routes[i] = Route(
            routeId: routes[i].routeId,
            path: routes[i].path,
            totalDistance: routes[i].totalDistance,
            walkingTime: routes[i].walkingTime,
            viaMode: routes[i].viaMode,
            isRecommended: false,
            routeName: 'Route ${i + 1}',
            startNode: startNode,
            endNode: endNode,
          );
        }
      }
    }

    return routes;
  }

  /// Find alternative paths using A* with penalties
  List<List<String>> _findAlternativePaths({
    required String startId,
    required String goalId,
    required int maxPaths,
  }) {
    final allPaths = <List<String>>[];
    final usedEdges = <String>{};
    final blockedEdges = <String>{};
    final usedCrossings = <String>{};
    final foundPathTypes = <String>{};

    const maxAttempts = 15;

    for (int i = 0; i < maxAttempts && allPaths.length < maxPaths; i++) {
      final path = _aStarWithPenalty(
        startId: startId,
        goalId: goalId,
        penalizedEdges: usedEdges,
        blockedEdges: blockedEdges,
      );

      if (path == null || path.isEmpty) break;

      final pathType = _determineViaMode(path);
      final crossingEdge = _findCrossCampusEdge(path);

      final isNewPathType = !foundPathTypes.contains(pathType);
      final isNewCrossing =
          crossingEdge != null && !usedCrossings.contains(crossingEdge);

      bool isDifferent = true;
      if (allPaths.isNotEmpty && !isNewPathType && !isNewCrossing) {
        for (final existingPath in allPaths) {
          final similarity = _calculatePathSimilarity(path, existingPath);
          if (similarity > 0.5) {
            isDifferent = false;
            break;
          }
        }
      }

      if (allPaths.isEmpty || isNewPathType || isNewCrossing || isDifferent) {
        allPaths.add(path);
        foundPathTypes.add(pathType);

        if (crossingEdge != null) {
          usedCrossings.add(crossingEdge);
          blockedEdges.add(crossingEdge);
        }

        for (int j = 0; j < path.length - 1; j++) {
          final edgeKey = _getEdgeKey(path[j], path[j + 1]);
          usedEdges.add(edgeKey);
        }
      } else {
        if (crossingEdge != null && usedCrossings.contains(crossingEdge)) {
          blockedEdges.add(crossingEdge);
        }

        if (path.length > 4) {
          final positions = [
            path.length ~/ 4,
            path.length ~/ 2,
            (path.length * 3) ~/ 4,
          ];
          for (final pos in positions) {
            if (pos > 0 && pos < path.length - 1) {
              final edgeKey = _getEdgeKey(path[pos], path[pos + 1]);
              usedEdges.add(edgeKey);
            }
          }
        }
      }
    }

    return allPaths;
  }

  /// A* algorithm with edge penalties for alternative paths
  List<String>? _aStarWithPenalty({
    required String startId,
    required String goalId,
    required Set<String> penalizedEdges,
    required Set<String> blockedEdges,
  }) {
    final openSet = _PriorityQueue();
    final openSetHash = <String>{};
    final closedSet = <String>{};

    final gScore = <String, double>{};
    final fScore = <String, double>{};
    final cameFrom = <String, String>{};

    gScore[startId] = 0;
    final heuristic = _heuristic(_allNodes[startId]!, _allNodes[goalId]!);
    fScore[startId] = heuristic;

    openSet.enqueue(_AStarNode(nodeId: startId, fScore: fScore[startId]!));
    openSetHash.add(startId);

    const maxIterations = 200;
    int iterations = 0;

    while (!openSet.isEmpty && iterations < maxIterations) {
      iterations++;

      final current = openSet.dequeue();
      if (current == null) break;

      openSetHash.remove(current.nodeId);

      if (current.nodeId == goalId) {
        return _reconstructPath(cameFrom, current.nodeId);
      }

      closedSet.add(current.nodeId);

      final neighbors = _adjacencyList[current.nodeId] ?? [];
      for (final neighbor in neighbors) {
        final neighborId = neighbor.toNodeId;

        if (closedSet.contains(neighborId)) continue;

        final edgeKey = _getEdgeKey(current.nodeId, neighborId);

        if (blockedEdges.contains(edgeKey)) continue;

        var edgeCost = neighbor.cost;
        if (penalizedEdges.contains(edgeKey)) {
          edgeCost *= (1.0 + _alternativePathPenalty);
        }

        final tentativeGScore = gScore[current.nodeId]! + edgeCost;

        if (!gScore.containsKey(neighborId) ||
            tentativeGScore < gScore[neighborId]!) {
          cameFrom[neighborId] = current.nodeId;
          gScore[neighborId] = tentativeGScore;
          fScore[neighborId] =
              gScore[neighborId]! +
              _heuristic(_allNodes[neighborId]!, _allNodes[goalId]!);

          if (!openSetHash.contains(neighborId)) {
            openSet.enqueue(
              _AStarNode(nodeId: neighborId, fScore: fScore[neighborId]!),
            );
            openSetHash.add(neighborId);
          }
        }
      }
    }

    return null;
  }

  /// Reconstruct path from cameFrom map
  List<String> _reconstructPath(Map<String, String> cameFrom, String current) {
    final path = [current];
    while (cameFrom.containsKey(current)) {
      current = cameFrom[current]!;
      path.insert(0, current);
    }
    return path;
  }

  /// Calculate Euclidean heuristic distance
  double _heuristic(PathNode a, PathNode b) {
    final dx = b.xCoordinate - a.xCoordinate;
    final dy = b.yCoordinate - a.yCoordinate;
    return sqrt(dx * dx + dy * dy);
  }

  /// Calculate total distance for a path
  double _calculateTotalDistance(List<String> path) {
    double total = 0;
    for (int i = 0; i < path.length - 1; i++) {
      final fromId = path[i];
      final toId = path[i + 1];

      final neighbors = _adjacencyList[fromId] ?? [];
      final edge = neighbors.firstWhereOrNull((e) => e.toNodeId == toId);
      if (edge != null) {
        total += edge.cost;
      }
    }
    return total;
  }

  /// Determine via mode (walkway, gate, overpass)
  String _determineViaMode(List<String> path) {
    if (path.isEmpty) return 'Via Walkway';

    final pathTypes = <String>{};
    for (int i = 0; i < path.length - 1; i++) {
      final fromId = path[i];
      final toId = path[i + 1];

      final neighbors = _adjacencyList[fromId] ?? [];
      final edge = neighbors.firstWhereOrNull((e) => e.toNodeId == toId);
      if (edge != null) {
        pathTypes.add(edge.edge.pathType.toLowerCase());
      }
    }

    if (pathTypes.contains('via_overpass')) return 'Via Overpass';
    if (pathTypes.contains('via_gate')) return 'Via Gate';
    return 'Via Walkway';
  }

  /// Find cross-campus edge in path
  String? _findCrossCampusEdge(List<String> path) {
    for (int i = 0; i < path.length - 1; i++) {
      final fromId = path[i];
      final toId = path[i + 1];

      final neighbors = _adjacencyList[fromId] ?? [];
      final edge = neighbors.firstWhereOrNull((e) => e.toNodeId == toId);
      if (edge != null) {
        final pathType = edge.edge.pathType;
        if (pathType == 'via_gate' || pathType == 'via_overpass') {
          return _getEdgeKey(fromId, toId);
        }
      }
    }
    return null;
  }

  /// Calculate path similarity between two paths
  double _calculatePathSimilarity(List<String> path1, List<String> path2) {
    if (path1.isEmpty || path2.isEmpty) return 0;

    int commonNodes = 0;
    final path2Set = path2.toSet();

    for (final node in path1) {
      if (path2Set.contains(node)) {
        commonNodes++;
      }
    }

    return commonNodes / max(path1.length, path2.length);
  }

  /// Get edge key (order independent)
  String _getEdgeKey(String from, String to) {
    return from.compareTo(to) < 0 ? '$from-$to' : '$to-$from';
  }

  /// Check if graph is initialized
  bool get isInitialized => _allNodes.isNotEmpty;
}
