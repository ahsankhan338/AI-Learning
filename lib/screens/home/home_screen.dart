import 'package:aieducator/constants/constants.dart';
import 'package:aieducator/utility/data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double constHeight = 20.0;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchBar(
              hintText: "Search",
              padding:
                  WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
              trailing: [Icon(Icons.search)],
            ),
            SizedBox(
              height: constHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recommended",
                  style: AppTextStyles.bodyTitle(),
                ),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      "See All",
                      style: AppTextStyles.textButtonStyle(),
                    ))
              ],
            ),
            SizedBox(
              height: constHeight,
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Fill vertical space
                children: recommendedCourses.map((item) {
                  return Expanded(
                    // Equal width for all columns
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          context.goNamed(
                            'courseDetail',
                            pathParameters: {'name': item['title'] ?? ''},
                          );
                        },
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Distribute space
                          children: [
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                item['icon']!,
                                height: 75,
                                width: 75,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(item['title']!,
                                    textAlign: TextAlign.center,
                                    maxLines: 2, // Prevent excessive height
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.textLabelSmallStyle()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: constHeight + constHeight + constHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Course In Progress",
                  style: AppTextStyles.bodyTitle(),
                ),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      "See All",
                      style: AppTextStyles.textButtonStyle(),
                    ))
              ],
            ),
            SizedBox(
              height: constHeight,
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: courseInProgress.map((item) {
                  return Expanded(
                    // Equal width for all columns
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          context.goNamed(
                            'courseDetail',
                            pathParameters: {'name': item['title'] ?? ''},
                          );
                        },
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Distribute space
                          children: [
                            Expanded(
                              flex: 2,
                              child: Image.asset(
                                item['icon']!,
                                height: 75,
                                width: 75,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  item['title']!,
                                  textAlign: TextAlign.center,
                                  maxLines: 2, // Prevent excessive height
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.textLabelSmallStyle(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: constHeight,
            ),
          ],
        ),
      ),
    );
  }
}
