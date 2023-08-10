import 'package:flutter/material.dart';
import 'package:weather/Home/model/home_model.dart';
import 'package:weather/Home/service/home_service.dart';

import '../view/home_view.dart';

abstract class HomeViewModel extends State<HomeView>{

List<Future<HomeModel>> homeModelList = [];

  @override
  void initState() {
    super.initState();
    homeModelFuture = fechDataFromService();
    homeModelList.add(fechDataFromServiceWithEnum(EnumCityName.Istanbul));
    homeModelList.add(fechDataFromServiceWithEnum(EnumCityName.NewYorkCity));
    homeModelList.add(fechDataFromServiceWithEnum(EnumCityName.Moscow));
    homeModelList.add(fechDataFromServiceWithEnum(EnumCityName.Paris));
    homeModelList.add(fechDataFromServiceWithEnum(EnumCityName.London));
  }
  
  HomeService homeService = HomeService();
  late Future<HomeModel> homeModelFuture;
   late HomeModel model;

  Future<HomeModel> fechDataFromService() async {
    try {
       model = await homeService.getDataFromIPA() as HomeModel;
      return model;
    } catch (e) {
      rethrow;
    }
  }

  Future<HomeModel> fechDataFromServiceWithEnum(
      EnumCityName enumCityName) async {
    try {
      HomeModel model =
          await homeService.getDataFromIPAWithEnum(enumCityName) as HomeModel;
      return model;
    } catch (e) {
      rethrow;
    }
  }

  void updateHomeModelFuture(EnumCityName enumCityName) {
    homeModelFuture = fechDataFromServiceWithEnum(enumCityName);
  }

  
}