import "package:flutter/material.dart";

import "login.dart";

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.height);
    double height = (MediaQuery.of(context).size.height);
    double containerWidth = 0.45 * width;
    double containerHeight = 0.8 * height;
    double rowButtonH = containerHeight * .25;
    double rowButtonW = containerWidth * .39;
    double buttonFontSize = containerHeight * 0.1;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: const Center(
          child: Text("Home"),
        ),
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          //color: const Color.fromARGB(255, 205, 19, 19),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.25,
                height: height * 0.25,
                child: Center(
                  child: Text(
                    'Welcome Employee name',
                    style: TextStyle(fontSize: height / 29),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: rowButtonH,
                      width: rowButtonW,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          print('Row Button 1');
                        },
                        child: Text(
                          'Customer Wise Report',
                          style: TextStyle(fontSize: buttonFontSize * .35),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: rowButtonH,
                      width: rowButtonW,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          print(rowButtonH);
                        },
                        child: Text(
                          "Overall Report",
                          style: TextStyle(fontSize: buttonFontSize * 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: containerHeight * .30,
                width: containerWidth * .83,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    print('Row Button 3');
                  },
                  child: Text(
                    'Forgot what this did',
                    style: TextStyle(fontSize: buttonFontSize * 0.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
