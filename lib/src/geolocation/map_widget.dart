// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '../sqflite/trip_model.dart';

Widget mapWidget({
  required TripModel trip,
  required double imageWidth,
  required double imageHeight,
}) {
  return IgnorePointer(
      ignoring: true,
      child: SizedBox(
        width: imageWidth,
        height: imageHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
              options: MapOptions(
                initialCameraFit: trip.route.length > 7
                    ? CameraFit.bounds(
                        bounds: LatLngBounds.fromPoints(trip.route),
                        padding: const EdgeInsets.all(20),
                      )
                    : null,
                initialCenter: trip.route.last,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                PolylineLayer(polylines: [
                  Polyline(
                      strokeWidth: 3, color: Colors.blue, points: trip.route)
                ]),
                MarkerLayer(rotate: true, markers: [
                  Marker(
                    point: trip.route.first,
                    width: 10,
                    height: 10,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/geo/dotblue.png',
                      scale: .3,
                    ),
                  ),
                  Marker(
                    point: trip.route.last,
                    width: 10,
                    height: 10,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/geo/dotorange.png',
                      scale: .3,
                    ),
                  ),
                ]),
              ]),
        ),
      ));
}
