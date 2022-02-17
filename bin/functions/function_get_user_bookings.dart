import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;

import 'package:firedart/firedart.dart';

import 'function_helpers.dart';

class GetUserBookings {
  Future<Response> getBookings(Request request) async {
    return await request
        .readAsString(request.encoding)
        .then((String jsonString) async {
      Map<String, dynamic> body = json.decode(jsonString);
      String userEmail = body['userEmail'].toString();

      String path = 'users/$userEmail/bookings';

      // This bit of code checks for a document, not a collection

      /*
      String endpoint =
          'https://firestore.googleapis.com/v1/projects/wall-mounted-room-calendar/databases/(default)/documents/' +
              path +
              '?key=' +
              HelperFunctions().getAPI();

      http.Response response = await http.get(Uri.parse(endpoint),
          headers: {'Content-type': 'application/json'});

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody.containsKey('error')) {
        Map<String, dynamic> errorDetails = responseBody['error'];
        String status = errorDetails['status'];
        switch (status) {
          case 'NOT_FOUND':
            return Response.notFound('No bookings exist');

          default:
            return Response.notFound('Something went wrong!');
        }
      }
      */

      return Response.ok(await getCollection(path));
    });
  }

  Future<String> getCollection(String path) async {
    List<Document> documents = await Firestore.instance
        .collection(path)
        .get()
        .then((Page<Document> collection) => collection.toList());

    Map<String, dynamic> userBookings = {};

    for (int i = 0; i < documents.length; i++) {
      Document booking = documents[i];
      String date = booking.path.split(path + '/')[1];
      Map<String, dynamic> details = booking.map;
      userBookings[date] = details;
    }

    String bookings = json.encode(userBookings);
    return bookings;
  }
}