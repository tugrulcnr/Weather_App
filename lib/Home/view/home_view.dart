import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/Home/model/home_model.dart';
import 'package:weather/Home/model/home_other_model.dart';
import 'package:weather/Home/service/home_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeService homeService = HomeService();
  late Future<HomeModel> homeModelFuture;

  late Future<HomeModelOtherDays> homeModelOtherDaysFuture;

  @override
  void initState() {
    super.initState();
    homeModelFuture = init();
    homeModelOtherDaysFuture = initOther();
  }

  Future<HomeModel> init() async {
    try {
      HomeModel model = await homeService.fetchData() as HomeModel;
      return model;
    } catch (e) {
      debugPrint("son " + e.toString());
      throw e;
    }
  }

  Future<HomeModelOtherDays> initOther() async {
    try {
      HomeModelOtherDays model =
          await homeService.fetchOtherDaysData() as HomeModelOtherDays;
      return model;
    } catch (e) {
      debugPrint("son " + e.toString());
      throw e;
    }
  }

  HomeModelOtherDays homeModelOtherDays() {
    HomeModelOtherDays model = initOther() as HomeModelOtherDays;
    return model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // CityNameAndDate(homeModelOtherDaysFuture: homeModelOtherDaysFuture),
          FutureBuilder<HomeModelOtherDays>(
            future: homeModelOtherDaysFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching data'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No data available'));
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(snapshot.data!.city.name,
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w300)),
                      subtitle: Text(DateFormat('MMMM').format(DateTime.parse(
                              snapshot.data!.list[0].dtTxt.toString())) +
                          "." +
                          snapshot.data!.list[0].dtTxt.day.toString() +
                          ", " +
                          snapshot.data!.list[0].dtTxt.year.toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.network(
                            "https://openweathermap.org/img/wn/${snapshot.data!.list[0].weather[0].icon}@4x.png",
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${(snapshot.data!.list[0].main.temp - 273.15).toInt()}°',
                                  style: TextStyle(
                                      fontSize: 55,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: 'C'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    weatherCards(snapshot),
                  ],
                );
              }
            },
          ),

          //DailyWeather(homeModelOtherDaysFuture: homeModelOtherDaysFuture),
        ],
      ),
    );
  }
}

class CityNameAndDate extends StatelessWidget {
  const CityNameAndDate({
    super.key,
    required this.homeModelOtherDaysFuture,
  });

  final Future<HomeModelOtherDays> homeModelOtherDaysFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeModelOtherDays>(
      future: homeModelOtherDaysFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        } else {
          return ListTile(
            title: Text(snapshot.data!.city.name,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300)),
            subtitle: Text(DateFormat('MMMM').format(
                    DateTime.parse(snapshot.data!.list[0].dtTxt.toString())) +
                "." +
                snapshot.data!.list[0].dtTxt.day.toString() +
                ", " +
                snapshot.data!.list[0].dtTxt.year.toString()),
          );
        }
      },
    );
  }
}

class DailyWeather extends StatelessWidget {
  const DailyWeather({
    super.key,
    required this.homeModelOtherDaysFuture,
  });

  final Future<HomeModelOtherDays> homeModelOtherDaysFuture;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber[200],
      height: MediaQuery.of(context).size.height * 0.45,
      child: FutureBuilder<HomeModelOtherDays>(
        future: homeModelOtherDaysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.list.length ~/ 4,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Text(
                      snapshot.data!.list[(index * 4) + 1].dtTxt.toString()),
                  title: Text(snapshot.data!.city.name),
                  trailing: Image.network(
                      "https://openweathermap.org/img/wn/${snapshot.data!.list[(index * 4) + 1].weather[0].icon}@2x.png"),
                  onTap: () {
                    debugPrint('Contact ${((index * 4) + 1 + 1)}');
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

SingleChildScrollView weatherCards(AsyncSnapshot<HomeModelOtherDays> snapshot) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (int i = 0; i < 4; i++)
          Container(
            width: 150,
            height: 200,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Card $i',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    ),
  );
}
