import 'package:flutter/material.dart';
import 'package:derss1/database_helper.dart';
import 'package:derss1/models.dart';
import 'package:intl/intl.dart';
import 'package:derss1/widgets/common_app_bar.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event;
  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  late TextEditingController _locationController;
  DateTime _selectedDate = DateTime.now();
  
  List<Community> _communities = [];
  String? _selectedCommunityName;

  final List<String> _categories = [
    'Toplantı',
    'Seminer',
    'Konferans',
    'Eğlence',
    'Konser',
    'Proje Sergisi',
    'Workshop',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    
    if (widget.event != null) {
      _selectedDate = widget.event!.date;
      if (_categories.contains(widget.event!.category)) {
        _selectedCategory = widget.event!.category;
      }
      _selectedCommunityName = widget.event!.communityName;
    }

    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    final communities = await DatabaseHelper.instance.readAllCommunities();
    setState(() {
      _communities = communities;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: widget.event?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        date: _selectedDate,
        location: _locationController.text,
        communityName: _selectedCommunityName,
      );

      if (widget.event == null) {
        await DatabaseHelper.instance.createEvent(event);
      } else {
        await DatabaseHelper.instance.updateEvent(event);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.event == null ? 'Yeni Etkinlik' : 'Etkinliği Düzenle',
        showHome: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Community Selection Dropdown
              if (_communities.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedCommunityName,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Hangi Topluluk?'),
                  items: _communities.map((Community community) {
                    return DropdownMenuItem<String>(
                      value: community.name,
                      child: Text(
                        community.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCommunityName = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Lütfen bir topluluk seçin' : null,
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Başlık'),
                validator: (value) => value!.isEmpty ? 'Lütfen bir başlık girin' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Lütfen bir açıklama girin' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Lütfen bir kategori seçin' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Konum'),
                validator: (value) => value!.isEmpty ? 'Lütfen bir konum girin' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tarih',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text(widget.event == null ? 'Etkinlik Oluştur' : 'Etkinliği Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
