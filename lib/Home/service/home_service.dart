import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:weather/Home/model/home_model.dart';

enum EnumCityName{
  Moscow, NewYorkCity,Istanbul, London,Paris,Tokyo

}
extension cityId on EnumCityName{
  int ids() {
    switch (this) {
      case EnumCityName.Moscow:
        return 524901;
      case EnumCityName.NewYorkCity:
      return 5128581;
      case EnumCityName.Istanbul:
      return 745044;
      case EnumCityName.London:
      return 2643743;
      case EnumCityName.Paris:
      return 2988507;
      case EnumCityName.Tokyo:
        return 1850147;
    }   
  }
}

class HomeService {
  final dio = Dio();
  final String _url =
      'https://api.openweathermap.org/data/2.5/weather?lat=40.77307363329426&lon=-74.03892900134065&appid=165eea882ce94482baf85e80def4b1d1';

  final String _urlOtherDays = "http://api.openweathermap.org/data/2.5/forecast?id=524901&appid=165eea882ce94482baf85e80def4b1d1";



  Future<HomeModel?> getDataFromIPA() async {
    try {
      final response = await dio.get(_urlOtherDays);
      if (response.statusCode == 200) {
        if (HomeModel.fromJson(response.data).list is List) {
          print("Liste");
        } else {
          print("Liste değil");
          
        }
        return HomeModel.fromJson(response.data);
      } else {
        print('${response.statusCode} : ${response.data.toString()}');
        throw response.statusCode.toString();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<HomeModel?> getDataFromIPAWithEnum(EnumCityName enumCityName) async {
    try {
      final response = await dio.get("http://api.openweathermap.org/data/2.5/forecast?id=${enumCityName.ids()}&appid=165eea882ce94482baf85e80def4b1d1");
      if (response.statusCode == 200) {
        return HomeModel.fromJson(response.data);
      } else {
        print('${response.statusCode} : ${response.data.toString()}');
        throw response.statusCode.toString();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

