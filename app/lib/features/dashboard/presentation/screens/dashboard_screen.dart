import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../events/data/models/event_models.dart';
import '../../../events/data/repositories/event_repository.dart';
import '../../../events/data/services/event_api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  List<Event> _upcomingEvents = [];
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
      final events = await eventApiService.getUserEvents(status: 'upcoming');
      
      setState(() {
        _upcomingEvents = events.take(4).toList(); // Show max 4 events
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatEventTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final timeFormat = DateFormat('h:mm a');
    
    if (eventDay == today) {
      return 'Today at ${timeFormat.format(dateTime)}';
    } else if (eventDay == tomorrow) {
      return 'Tomorrow at ${timeFormat.format(dateTime)}';
    } else {
      return DateFormat('EEE, MMM d').format(dateTime);
    }
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space3),
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
            child: Row(
              children: [
                // Event image placeholder or actual image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.event,
                    color: AppColors.deepPurple,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppTheme.space3),
                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTypography.textBase.copyWith(
                          color: AppColors.neutral950,
                          fontWeight: AppTypography.semibold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.space1),
                      Text(
                        _formatEventTime(event.startTime),
                        style: AppTypography.textSm.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space2,
                    vertical: AppTheme.space1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepPurple,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    'HOSTING',
                    style: AppTypography.textXs.copyWith(
                      color: AppColors.white,
                      fontWeight: AppTypography.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadEvents,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: AppTypography.textLg.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space1),
                      Text(
                        'Dashboard',
                        style: AppTypography.text2xl.copyWith(
                          color: AppColors.deepPurple,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Upcoming Events Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Events',
                            style: AppTypography.textXl.copyWith(
                              color: AppColors.neutral950,
                              fontWeight: AppTypography.semibold,
                            ),
                          ),
                          // TODO: Add "View all →" link when > 4 events
                        ],
                      ),
                      const SizedBox(height: AppTheme.space4),
                      
                      // Loading state
                      if (_isLoading)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTheme.space6),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.deepPurple,
                            ),
                          ),
                        )
                      // Events list
                      else if (_upcomingEvents.isNotEmpty)
                        Column(
                          children: _upcomingEvents.map(_buildEventCard).toList(),
                        )
                      // Empty state
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTheme.space6),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_outlined,
                                size: 48,
                                color: AppColors.neutral400,
                              ),
                              const SizedBox(height: AppTheme.space3),
                              Text(
                                'No upcoming events',
                                style: AppTypography.textBase.copyWith(
                                  color: AppColors.neutral600,
                                  fontWeight: AppTypography.medium,
                                ),
                              ),
                              const SizedBox(height: AppTheme.space2),
                              Text(
                                'Create your first event!',
                                style: AppTypography.textSm.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            
              // Bottom padding to ensure FAB doesn't overlap content
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }
  
  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.vibrantOrange.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Screen 5: Event Creation
          context.push('/event/create');
        },
        backgroundColor: AppColors.vibrantOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
        label: Row(
          children: [
            const Icon(Icons.add, size: 20),
            const SizedBox(width: AppTheme.space2),
            Text(
              'Create Event',
              style: AppTypography.textBase.copyWith(
                fontWeight: AppTypography.semibold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}