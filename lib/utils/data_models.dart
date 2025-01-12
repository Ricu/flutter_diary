import 'dart:convert';
class Category {
  String identifier;
  String displayName;
  String description;

  Category(this.identifier, this.displayName, this.description);
}



final List<Category> categories = [
  Category("health", "Health & Symptoms", "Physical and mental health, symptoms, and general well-being."),
  Category("sport", "Physical Activity", "Exercise, sports, and physical activities."),
  Category("social", "Daily Activities & Social Interactions", "Daily routines, social interactions, and events."),
  Category("ideas", "Reflections & Ideas", "Thoughts, ideas, and reflections."),
  Category("food", "Meals & Nutrition", "Food, meals, and nutrition."),
  Category("mood", "Mood Tracker", "Emotions, feelings, and mood."),
  Category("sleep", "Sleep Patterns", "Sleep patterns, quality, and duration."),
  Category("misc", "Miscellaneous Notes", "Notes that do not fit into any other category.")
  ];

class CategoryContent {
  int? id; // Database ID (nullable for new instances)
  String identifier; // e.g., "sport", "health"
  String displayName; // e.g., "Physical Activity"
  Map<String, dynamic>? data; // Flexible for category-specific fields
  String text; // Main text for this category
  int? diaryEntryId; // Foreign key to associate with a DiaryEntry

   CategoryContent({
    this.id,
    required this.identifier,
    required this.displayName,
    this.data,
    required this.text,
    this.diaryEntryId,
  });

    // Convert to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identifier': identifier,
      'display_name': displayName,
      'data': data != null ? jsonEncode(data) : null,
      'text': text,
      'diary_entry_id': diaryEntryId,
    };
  }

  // Create a CategoryContent from a database Map
  factory CategoryContent.fromMap(Map<String, dynamic> map) {
    return CategoryContent(
      id: map['id'],
      identifier: map['identifier'],
      displayName: map['display_name'],
      data: map['data'] != null ? jsonDecode(map['data']) : null,
      text: map['text'],
      diaryEntryId: map['diary_entry_id'],
    );
  }
}



class DiaryEntry {
  int? id; // Database ID (nullable for new instances)
  DateTime date; // YYYY-MM-DD
  String text; // Optional summary or notes
  List<CategoryContent> categories; // List of all categories for the day
  List<String> audioFiles; // Paths to audio recordings

  DiaryEntry({
    this.id,
    required this.date,
    required this.text,
    required this.audioFiles,
    required this.categories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'text': text,
      'audio_files': audioFiles.join(','),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map, List<CategoryContent> categories) {
    return DiaryEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      text: map['text'],
      audioFiles: (map['audio_files'] as String).split(','),
      categories: categories,
    );
  }
}



// class SportContent extends CategoryContent {
//   String? sportType;
//   int? duration;

//   SportContent({String text = "", this.sportType, this.duration})
//       : super("sport", "Physical Activity", text);
// }

// class HealthContent extends CategoryContent {
//   int? generalWellBeing;

//   HealthContent({String text = "", this.generalWellBeing})
//       : super("health", "Health & Symptoms", text);
// }

// class SocialContent extends CategoryContent {
//   String? peopleMet;

//   SocialContent({String text = "", this.peopleMet})
//       : super("social", "Daily Activities & Social Interactions", text);
// }

// class IdeasContent extends CategoryContent {
//   IdeasContent({String text = ""})
//       : super("ideas", "Reflections & Ideas", text);
// }

// class FoodContent extends CategoryContent {

//   FoodContent({String text = ""})
//       : super("food", "Meals & Nutrition", text);
// }

// class MoodContent extends CategoryContent {
//   int? moodLevel; // Make this an enum with different moods

//   MoodContent({String text = "", this.moodLevel})
//       : super("mood", "Mood Tracker", text);
// }

// class SleepContent extends CategoryContent {
//   int? sleepDuration;

//   SleepContent({String text = "", this.sleepDuration})
//       : super("sleep", "Sleep Patterns", text);
// }

// class MiscContent extends CategoryContent {
//   MiscContent({String text = ""})
//       : super("misc", "Miscellaneous Notes", text);
// }