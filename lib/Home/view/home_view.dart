import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/Home/model/home_model.dart';
import 'package:weather/Home/service/home_service.dart';
import 'package:weather/Home/view_model/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends HomeViewModel {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection:Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [      
            FutureBuilder<HomeModel>(
              future: homeModelFuture,
              builder: builder,
            ),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (int i = 0; i < homeModelList.length; i++)
                    FutureBuilder<HomeModel>(
                        future: homeModelList[i],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error fetching data'));
                          } else if (!snapshot.hasData) {
                            return Center(child: Text('No data available'));
                          } else {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: weatherCards(
                                  snapshot, EnumCityName.values.elementAt(i)),
                            );
                          }
                        })
                ])),
      
            //weatherCards() ,
      
            DailyWeather(homeModelOtherDaysFuture: homeModelFuture),
          ],
        ),
      ),
    );
  }

  Widget builder(context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error fetching data'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(snapshot.data!.city.name,
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w300)),
                      subtitle: DateTextWidget(snapshot: snapshot, index: 0,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.network(
                            "https://openweathermap.org/img/wn/${snapshot.data!.list[0].weather[0].icon}@4x.png",
                          ),
                          TextOfTemp(
                            snapshot: snapshot,
                            fontSize: 75,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            }

  Widget weatherCards(
      AsyncSnapshot<HomeModel> snapshot, EnumCityName enumCityName) {
    updateHomeModelFuture(enumCityName);
    return Container(
      width: 130,
      height: 200,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 74, 142, 219),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Text(
                
                snapshot.data!.city.name,
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground,fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TimeText(snapshot: snapshot, color: Theme.of(context).colorScheme.background),
              Spacer(),
              Image.network(
                "https://openweathermap.org/img/wn/${snapshot.data!.list[0].weather[0].icon}@2x.png",
              ),
              Spacer(),
              TextOfTemp(
                snapshot: snapshot,
                fontSize: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateTextWidget extends StatelessWidget {
  const DateTextWidget({
    super.key, required this.snapshot, required this.index, this.haveYear = true,
  });
final AsyncSnapshot<HomeModel> snapshot;
final int index;
final bool haveYear;
  @override
  Widget build(BuildContext context) {
    return Text(DateFormat('MMMM').format(DateTime.parse(
            snapshot.data!.list[8*index].dtTxt.toString())) +
        "." +
        snapshot.data!.list[8*index].dtTxt.day.toString() +
       (haveYear ? (", " + snapshot.data!.list[8*index].dtTxt.year.toString()): ""));
  }
}
//Text(snapshot.data!.list[(index * 4) + 1].dtTxt.toString()),

class TimeText extends StatelessWidget {
  const TimeText({
    super.key, required this.snapshot, required this.color,
  });
  final AsyncSnapshot<HomeModel> snapshot;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      (snapshot.data!.list[1].dtTxt.hour).toString() +
          ":" +
          (snapshot.data!.list[0].dtTxt.minute).toString() +
          "0 AM",
      style: TextStyle(color: color,fontSize: 12, fontWeight: FontWeight.bold),
    );
  }
}

class TextOfTemp extends StatelessWidget {
  TextOfTemp({super.key, required this.snapshot, required this.fontSize});

  AsyncSnapshot<HomeModel> snapshot;
  double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${(snapshot.data!.list[0].main.temp - 273.15).toInt()}°',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: 'C'),
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

  final Future<HomeModel> homeModelOtherDaysFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeModel>(
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
                style: TextStyle(color: Theme.of(context).colorScheme.background,fontSize: 40, fontWeight: FontWeight.w300)),
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

  final Future<HomeModel> homeModelOtherDaysFuture;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left:8,right: 8,top: 8,bottom: 20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 195, 214, 235),
        borderRadius: BorderRadius.circular(20),
      ),
      height: MediaQuery.of(context).size.height * 0.45,
      child: FutureBuilder<HomeModel>(
        future: homeModelOtherDaysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            return ListView.separated(
              padding: EdgeInsets.all(8),
              separatorBuilder: (context, index) => Divider(),
              itemCount: snapshot.data!.list.length ~/ 8,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left:10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children : [
                      DateTextWidget(snapshot: snapshot, index: index,haveYear: false,),
                    SizedBox(
                      height: 80,
                      child: Image.network(
                          "https://openweathermap.org/img/wn/${snapshot.data!.list[(index * 4)].weather[0].icon}@2x.png"),
                    ),
                        TextOfTemp(
                                snapshot: snapshot,
                                fontSize: 20,
                              ),
                    ]
                    
                    
                    
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
