// @dart=2.9
import 'dart:io';
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../helpers/db_helper.dart';
import '../helpers/location_helper.dart';

class GreatPlaces with ChangeNotifier {
  List<Place> _items = [];

  List<Place> get items {
    return [..._items];
  }

  Future<void> addPlace(
    String title,
    File pickedImage,
    PlaceLocation pickedLocation,
  ) async {
    final address = await LocationHelper.getPlaceAddress(
      pickedLocation.latitude,
      pickedLocation.longitude,
    );
    final updatedLocation = PlaceLocation(
      latitude: pickedLocation.latitude,
      longitude: pickedLocation.longitude,
      address: address,
    );
    final newPlace = Place(
      DateTime.now().toString(),
      title,
      updatedLocation,
      pickedImage,
    );
    _items.add(newPlace);
    notifyListeners();
    DBHelper.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'loc_lat': pickedLocation.latitude,
      'loc_lng': pickedLocation.longitude,
      'address': address,
    });
  }

  Future<void> getAndSetData() async {
    final dataList = await DBHelper.getData('user_places');
    _items = dataList
        .map(
          (item) => Place(
            item['id'],
            item['title'],
            PlaceLocation(
              address: item['address'],
              latitude: item['loc_lat'],
              longitude: item['loc_lng'],
            ),
            File(
              item['image'],
            ),
          ),
        )
        .toList();
    notifyListeners();
  }

  Place findById(String id) {
    return _items.firstWhere((place) => place.id == id);
  }
}
