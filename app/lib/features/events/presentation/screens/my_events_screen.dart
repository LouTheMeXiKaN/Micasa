import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/event_models.dart';
import '../../data/services/event_api_service.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({Key? key}) : super(key: key);

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with WidgetsBindingObserver {
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadEvents();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final eventApiService = context.read<EventApiService>();
      
      // Load upcoming events
      final upcoming = await eventApiService.getUserEvents(status: 'upcoming');
      final past = await eventApiService.getUserEvents(status: 'past');
      
      setState(() {
        _upcomingEvents = upcoming;
        _pastEvents = past;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatEventDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d • h:mm a').format(dateTime);
  }

  Widget _buildEventCard(Event event, {required String role}) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to Screen 7: Dynamic Event Management Screen
            context.push('/event/manage/${event.id}');
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: AppTypography.textBase.copyWith(
                          color: AppColors.neutral950,
                          fontWeight: AppTypography.semibold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space2,
                        vertical: AppTheme.space1,
                      ),
                      decoration: BoxDecoration(
                        color: role == 'Host' ? AppColors.deepPurple : AppColors.forestGreen,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: AppTypography.textXs.copyWith(
                          color: AppColors.white,
                          fontWeight: AppTypography.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space2),
                Text(
                  _formatEventDate(event.startTime),
                  style: AppTypography.textSm.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                if (event.location.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.space1),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.neutral500,
                      ),
                      const SizedBox(width: AppTheme.space1),
                      Expanded(
                        child: Text(
                          event.location,
                          style: AppTypography.textSm.copyWith(
                            color: AppColors.neutral500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events, String emptyMessage, {String? emptySubMessage}) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space6),
          child: CircularProgressIndicator(
            color: AppColors.deepPurple,
          ),
        ),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              emptyMessage,
              style: AppTypography.textBase.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            if (emptySubMessage != null) ...[
              const SizedBox(height: AppTheme.space2),
              Text(
                emptySubMessage,
                style: AppTypography.textSm.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space3),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(events[index], role: 'Host');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            'My Events',
            style: AppTypography.textXl.copyWith(
              color: AppColors.neutral950,
              fontWeight: AppTypography.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.deepPurple,
            unselectedLabelColor: AppColors.neutral500,
            indicatorColor: AppColors.deepPurple,
            labelStyle: AppTypography.textBase.copyWith(
              fontWeight: AppTypography.semibold,
            ),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Tab - Still static for now as we don't have proposals/applications yet
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pending_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    'No pending proposals or applications',
                    style: AppTypography.textBase.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            // Upcoming Tab
            _buildEventsList(
              _upcomingEvents,
              'No upcoming events',
              emptySubMessage: 'Create your first event!',
            ),
            // Past Tab
            _buildEventsList(
              _pastEvents,
              'Your past events will appear here',
            ),
          ],
        ),
      ),
    );
  }
}