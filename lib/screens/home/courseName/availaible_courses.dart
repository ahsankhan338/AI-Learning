import 'package:aieducator/api/course_api.dart';
import 'package:aieducator/models/course_model.dart';
import 'package:flutter/material.dart';

class AvailaibleCoursesScreen extends StatefulWidget {
  final String categoryId;

  const AvailaibleCoursesScreen({super.key, required this.categoryId});

  @override
  State<AvailaibleCoursesScreen> createState() =>
      _AvailaibleCoursesScreenState();
}

class _AvailaibleCoursesScreenState extends State<AvailaibleCoursesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Course> _courses = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false; // Tracks initial load
  bool _isLoadMoreRunning = false; // Tracks subsequent loads
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    print(
        "AvailaibleCoursesScreen: initState - Category ID: ${widget.categoryId}");
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
    print("AvailaibleCoursesScreen: Scroll listener added.");
  }

  Future<void> _loadInitialData() async {
    print("AvailaibleCoursesScreen: Loading initial data (page 1)...");
    // Avoid calling setState if already loading
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await _fetchData(page: 1);
    // _isLoading is set to false in _fetchData's finally block
    print("AvailaibleCoursesScreen: Initial data load finished.");
  }

  Future<void> _fetchData({required int page}) async {
    // Prevent duplicate load more calls
    if (page > 1) {
      if (_isLoadMoreRunning) {
        print(
            "AvailaibleCoursesScreen: Fetch aborted - Load more already running for page ${_page + 1}");
        return;
      }
      // Set load more running state *before* await
      if (mounted) setState(() => _isLoadMoreRunning = true);
    } else {
      // Ensure initial loading state is true if not already
      if (!_isLoading && mounted) setState(() => _isLoading = true);
    }

    print("AvailaibleCoursesScreen: Fetching data for page $page...");
    try {
      final response = await CourseApi.fetchCourses(
        page,
        _limit,
        categoryId: widget.categoryId,
      );

      // Ensure response and data list exist
      final List<dynamic>? dataList = response['data'] as List<dynamic>?;

      if (dataList == null) {
        print(
            "AvailaibleCoursesScreen: API response['data'] is null or not a list for page $page.");
        if (mounted) {
          setState(() {
            _hasMore = false; // Stop trying if response is malformed
          });
        }
        return;
      }

      final List<Course> newCourses = dataList
          .map((courseJson) {
            try {
              // Ensure courseJson is a Map before parsing
              if (courseJson is Map<String, dynamic>) {
                return Course.fromJson(courseJson);
              } else {
                print(
                    "AvailaibleCoursesScreen: Skipping invalid item in list (not a Map): $courseJson");
                return null;
              }
            } catch (e) {
              print(
                  "AvailaibleCoursesScreen: Error parsing course JSON: $e, JSON: $courseJson");
              return null; // Handle parsing errors gracefully
            }
          })
          .where((course) =>
              course != null) // Filter out nulls from errors/invalid items
          .cast<Course>()
          .toList();

      print(
          "AvailaibleCoursesScreen: Fetched ${newCourses.length} new courses for page $page.");

      if (mounted) {
        // Check if the widget is still mounted before calling setState
        setState(() {
          _hasMore = newCourses.length >= _limit;
          _page = page;
          _courses = page == 1 ? newCourses : [..._courses, ...newCourses];
          print(
              "AvailaibleCoursesScreen: Total courses: ${_courses.length}, hasMore: $_hasMore");
        });
      }
    } catch (e) {
      print(
          "AvailaibleCoursesScreen: Error fetching courses for page $page: $e");
      if (mounted) {
        setState(() {
          _hasMore = false; // Stop trying if there's an error fetching more
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    } finally {
      print("AvailaibleCoursesScreen: Fetch data finished for page $page.");
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          // Reset the correct loading flag
          if (page == 1) _isLoading = false;
          _isLoadMoreRunning = false;
          print(
              "AvailaibleCoursesScreen: Loading states updated - isLoading: $_isLoading, isLoadMoreRunning: $_isLoadMoreRunning");
        });
      }
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients)
      return; // Check if controller is attached

    final double currentScroll = _scrollController.position.pixels;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double threshold =
        maxScroll * 1.0; // Trigger when 100% scrolled (adjust as needed)

    // Debug Print - uncomment if needed, can be very verbose
    // print("Scroll: ${currentScroll.toStringAsFixed(1)} / ${maxScroll.toStringAsFixed(1)} | Threshold: ${threshold.toStringAsFixed(1)} | hasMore: $_hasMore | isLoading: $_isLoading | isLoadMoreRunning: $_isLoadMoreRunning");

    // Check conditions to load more
    if (currentScroll >= threshold &&
        _hasMore &&
        !_isLoading &&
        !_isLoadMoreRunning) {
      print(
          "AvailaibleCoursesScreen: --> Scroll threshold reached. Attempting to load more (Page ${_page + 1}).");
      _loadMoreData();
    } else if (currentScroll >= threshold && !_hasMore) {
      // print("AvailaibleCoursesScreen: Scroll threshold reached, but no more data (_hasMore is false).");
    } else if (currentScroll >= threshold &&
        (_isLoading || _isLoadMoreRunning)) {
      // print("AvailaibleCoursesScreen: Scroll threshold reached, but already loading.");
    }
  }

  Future<void> _loadMoreData() async {
    // Safety check, though primary checks are in _scrollListener and _fetchData
    if (!_hasMore || _isLoading || _isLoadMoreRunning) {
      print("AvailaibleCoursesScreen: Load more skipped (redundant check).");
      return;
    }
    print(
        "AvailaibleCoursesScreen: Requesting _fetchData for page ${_page + 1}");

    await _fetchData(page: _page + 1);

    print("AvailaibleCoursesScreen: Load more fetch completed.");
  }

  @override
  void dispose() {
    print("AvailaibleCoursesScreen: Disposing controller.");
    _scrollController.removeListener(_scrollListener); // Remove listener
    _scrollController.dispose();
    super.dispose();
  }

  // _buildLoader remains the same
  Widget _buildLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        "AvailaibleCoursesScreen: Building UI. Courses: ${_courses.length}, isLoading: $_isLoading, hasMore: $_hasMore, isLoadMoreRunning: $_isLoadMoreRunning");

    // Handle initial loading state explicitly
    if (_isLoading && _courses.isEmpty) {
      print("AvailaibleCoursesScreen: Displaying initial loader.");
      return Center(child: _buildLoader());
    }

    // Handle case where initial load finishes with no courses
    if (!_isLoading && _courses.isEmpty && !_hasMore) {
      print("AvailaibleCoursesScreen: Displaying 'No courses found'.");
      return Center(
          child: Text(
        "No courses found.",
        style: TextTheme.of(context).titleLarge,
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        controller:
            _scrollController, // IMPORTANT: Ensure controller is attached
        // Calculate itemCount: list items + 1 for the loader if there's more data
        itemCount: _courses.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          // If this is the last item index AND there are more items to load, show the loader
          if (index == _courses.length) {
            // This should only be reached if _hasMore is true because of itemCount calculation
            print(
                "AvailaibleCoursesScreen: Displaying load more indicator at index $index");
            return _buildLoader();
          }

          // If index is somehow out of bounds (safety check)
          if (index >= _courses.length) {
            print(
                "AvailaibleCoursesScreen: Warning - Index $index out of bounds (length ${_courses.length})");
            return const SizedBox
                .shrink(); // Should not happen with correct itemCount
          }

          // Otherwise, build the course card for the item at the current index
          final course = _courses[index];
          return buildCourseCard(
              imagePath:
                  "assets/images/languages/python.png", // Replace if dynamic
              courseTitle: course.title,
              availability: "Available on: ${course.site}",
              price: course.programType,
              rating: course.rating,
              duration: course.duration);
        },
      ),
    );
  }

  Widget buildCourseCard({
    required String imagePath,
    required String courseTitle,
    required String availability,
    required String price,
    String? rating,
    String? duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Course title
          Text(
            courseTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
            maxLines: 3,
          ),
          const SizedBox(height: 12),

          // Availability row with fixed width icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 24, // Fixed width for icon container
                child: Icon(
                  Icons.public,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
              Expanded(
                child: Text(
                  availability,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Program type/price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 24, // Fixed width for icon container
                child: Icon(
                  Icons.school,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
              Expanded(
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),

          // Rating row (if available)
          if (rating != null && rating.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 24, // Fixed width for icon container
                  child: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
                Expanded(
                  child: Text(
                    "Rating: $rating stars",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ],

          // Duration row (if available)
          if (duration != null && duration.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24, // Fixed width for icon container
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
                Expanded(
                  child: Text(
                    duration,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
