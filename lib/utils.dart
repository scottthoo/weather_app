import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/services/icon_parse.dart';

enum NotifierState { initial, loading, loaded }

// Functional programming To get Left and Right (Success or Failure)
extension TaskX<T extends Either<Object, U>, U> on Task<T> {
  Task<Either<Failure, U>> mapLeftToFailure() {
    return map(
      (either) => either.leftMap((obj) {
        try {
          return obj as Failure;
        } catch (e) {
          throw obj;
        }
      }),
    );
  }
}

String? iconParse(String code) {
  String iconString = "wi-";
  if (code.isNotEmpty) {
    kIconParse.map((Map map) {
      try {
        iconString += map[code.toString()]["icon"].toString();
      } catch (e) {
        return ("error");
      }
    }).toList();
  }
  return iconString;
}

// Clearer HTTP Error handler
class Failure {
  final String message;
  Failure(this.message);
  @override
  String toString() => message;
}

class UserPreferences {
  static late SharedPreferences _preferences;
  static const _keyCities = 'myCities';
  static Future init() async => _preferences = await SharedPreferences.getInstance();

  static Future setCities(List<String> cities) async => await _preferences.setStringList(_keyCities, cities);
  static List<String> getCities() => _preferences.getStringList(_keyCities) ?? [];

  static void deleteAll() => _preferences.clear();
}
