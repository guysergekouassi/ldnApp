import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';
import 'package:flutter_auth/models/prayer.dart';

class PrayerAgendaScreen extends StatefulWidget {
  const PrayerAgendaScreen({Key? key}) : super(key: key);

  @override
  _PrayerAgendaScreenState createState() => _PrayerAgendaScreenState();
}

class _PrayerAgendaScreenState extends State<PrayerAgendaScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final List<PrayerEvent> _prayerEvents = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSampleEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadSampleEvents() {
    setState(() {
      _prayerEvents.addAll([
        PrayerEvent(
          id: '1',
          title: 'Chapelet du matin',
          time: const TimeOfDay(hour: 7, minute: 0),
          date: DateTime.now(),
          type: PrayerType.rosary,
          isCompleted: false,
        ),
        PrayerEvent(
          id: '2',
          title: 'Angélus',
          time: const TimeOfDay(hour: 12, minute: 0),
          date: DateTime.now(),
          type: PrayerType.angelus,
          isCompleted: true,
        ),
        PrayerEvent(
          id: '3',
          title: 'Office du soir',
          time: const TimeOfDay(hour: 18, minute: 0),
          date: DateTime.now(),
          type: PrayerType.office,
          isCompleted: false,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Agenda de Prière',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: kTextColor),
            onPressed: _selectDate,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: kAccentColor,
          unselectedLabelColor: kTextSecondaryColor,
          indicatorColor: kAccentColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Aujourd\'hui'),
            Tab(text: 'Programme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(),
          _buildScheduleView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPrayerEvent,
        backgroundColor: kAccentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayView() {
    final todayEvents = _prayerEvents.where((event) =>
        event.date.year == _selectedDate.year &&
        event.date.month == _selectedDate.month &&
        event.date.day == _selectedDate.day
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(),
          const SizedBox(height: 24),
          if (todayEvents.isEmpty)
            _buildEmptyState()
          else
            ...todayEvents.map((event) => _buildEventCard(event)).toList(),
          const SizedBox(height: 24),
          _buildPersonalNotesSection(),
        ],
      ),
    );
  }

  Widget _buildScheduleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Programme de la semaine',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
          ),
          const SizedBox(height: 16),
          _buildWeeklySchedule(),
          const SizedBox(height: 24),
          _buildRecurringPrayers(),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryLightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_today, color: kPrimaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aujourd\'hui',
                  style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
                ),
                Text(
                  '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCompletionRate() > 0.7 ? kAccentColor : kPrimaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(_getCompletionRate() * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(PrayerEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: event.isCompleted ? kAccentColor : kPrimaryColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: event.isCompleted ? kTextSecondaryColor : kTextColor,
                      decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: kTextSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTypeColor(event.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTypeName(event.type),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getTypeColor(event.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Checkbox(
              value: event.isCompleted,
              onChanged: (value) {
                setState(() {
                  event.isCompleted = value ?? false;
                });
              },
              activeColor: kAccentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: kTextSecondaryColor),
          const SizedBox(height: 16),
          Text(
            'Aucune prière programmée aujourd\'hui',
            style: TextStyle(fontSize: 16, color: kTextSecondaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour ajouter une prière',
            style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalNotesSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_outlined, color: kAccentColor),
              const SizedBox(width: 8),
              const Text(
                'Notes personnelles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Seigneur, merci pour cette journée. Aide-moi à rester fidèle à mes temps de prière.',
              style: TextStyle(color: kTextSecondaryColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule() {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final today = DateTime.now();
    
    return GlassCard(
      child: Column(
        children: [
          const Text(
            'Cette semaine',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayDate = today.subtract(Duration(days: today.weekday - 1 - index));
              final isToday = dayDate.day == _selectedDate.day &&
                             dayDate.month == _selectedDate.month &&
                             dayDate.year == _selectedDate.year;
              
              return Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? kAccentColor : kTextSecondaryColor,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday ? kAccentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kPrimaryColor),
                    ),
                    child: Center(
                      child: Text(
                        '${dayDate.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : kTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringPrayers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prières récurrentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              _buildRecurringPrayerItem('Chapelet quotidien', 'Tous les jours à 7h00', Icons.celebration),
              const SizedBox(height: 12),
              _buildRecurringPrayerItem('Angélus', 'Tous les jours à 12h00', Icons.notifications_active),
              const SizedBox(height: 12),
              _buildRecurringPrayerItem('Chapelet de la Miséricorde', 'Tous les jours à 15h00', Icons.favorite),
              const SizedBox(height: 12),
              _buildRecurringPrayerItem('Office du soir', 'Tous les jours à 18h00', Icons.nightlight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringPrayerItem(String title, String schedule, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryLightColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(schedule, style: TextStyle(fontSize: 12, color: kTextSecondaryColor)),
            ],
          ),
        ),
        Switch(
          value: true,
          onChanged: (value) {},
          activeColor: kAccentColor,
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addPrayerEvent() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      _showAddEventDialog(pickedTime);
    }
  }

  void _showAddEventDialog(TimeOfDay time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une prière'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de la prière',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                setState(() {
                  _prayerEvents.add(PrayerEvent(
                    id: DateTime.now().toString(),
                    title: _titleController.text,
                    time: time,
                    date: _selectedDate,
                    type: PrayerType.personal,
                    note: _noteController.text,
                    isCompleted: false,
                  ));
                });
                _titleController.clear();
                _noteController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  double _getCompletionRate() {
    final todayEvents = _prayerEvents.where((event) =>
        event.date.year == _selectedDate.year &&
        event.date.month == _selectedDate.month &&
        event.date.day == _selectedDate.day
    ).toList();
    
    if (todayEvents.isEmpty) return 0.0;
    final completed = todayEvents.where((event) => event.isCompleted).length;
    return completed / todayEvents.length;
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  Color _getTypeColor(PrayerType type) {
    switch (type) {
      case PrayerType.rosary:
        return kAccentColor;
      case PrayerType.angelus:
        return kPrimaryColor;
      case PrayerType.office:
        return Colors.purple;
      case PrayerType.personal:
        return Colors.green;
    }
  }

  String _getTypeName(PrayerType type) {
    switch (type) {
      case PrayerType.rosary:
        return 'Chapelet';
      case PrayerType.angelus:
        return 'Angélus';
      case PrayerType.office:
        return 'Office';
      case PrayerType.personal:
        return 'Personnel';
    }
  }
}

enum PrayerType {
  rosary,
  angelus,
  office,
  personal,
}

class PrayerEvent {
  final String id;
  final String title;
  final TimeOfDay time;
  final DateTime date;
  final PrayerType type;
  final String? note;
  bool isCompleted;

  PrayerEvent({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.type,
    this.note,
    this.isCompleted = false,
  });
}
