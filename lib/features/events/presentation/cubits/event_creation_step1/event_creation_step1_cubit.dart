import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/event_title.dart';
import '../../models/event_description.dart';
import '../../models/event_location.dart';
import '../../models/event_datetime.dart';
import 'event_creation_step1_state.dart';

class EventCreationStep1Cubit extends Cubit<EventCreationStep1State> {
  final ImagePicker _imagePicker;

  EventCreationStep1Cubit({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker(),
        super(const EventCreationStep1State());

  void coverImageChanged(File? image) {
    emit(state.copyWith(coverImage: image));
  }

  void titleChanged(String value) {
    final title = EventTitle.dirty(value);
    emit(state.copyWith(title: title));
  }

  void descriptionChanged(String value) {
    final description = EventDescription.dirty(value);
    emit(state.copyWith(description: description));
  }

  void startTimeChanged(DateTime? value) {
    final startTime = EventDateTime.dirty(value);
    emit(state.copyWith(startTime: startTime));
  }

  void endTimeChanged(DateTime? value) {
    final endTime = EventDateTime.dirty(value);
    emit(state.copyWith(endTime: endTime));
  }

  void locationChanged(String value) {
    final location = EventLocation.dirty(value);
    emit(state.copyWith(location: location));
  }

  Future<void> pickCoverImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        emit(state.copyWith(coverImage: imageFile));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to pick image: ${e.toString()}',
      ));
    }
  }

  void removeCoverImage() {
    emit(state.copyWith(clearCoverImage: true));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  // Get the current state for Step 2
  EventCreationStep1State getCurrentData() => state;
  
  // Validate all fields and show errors
  void validateAllFields() {
    // Touch all fields to show validation errors
    final title = EventTitle.dirty(state.title.value);
    final location = EventLocation.dirty(state.location.value);
    final startTime = EventDateTime.dirty(state.startTime.value);
    final endTime = EventDateTime.dirty(state.endTime.value);
    
    emit(state.copyWith(
      title: title,
      location: location,
      startTime: startTime,
      endTime: endTime,
    ));
  }
}