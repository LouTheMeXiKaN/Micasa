import 'package:equatable/equatable.dart';

enum EventPrivacy { public, inviteOnly }

enum LocationVisibility { 
  immediate, 
  onConfirmation, 
  twentyFourHoursBefore 
}

enum PricingModel { 
  freeRsvp,
  fixedPrice, 
  chooseYourPrice, 
  donationBased 
}

enum GuestListVisibility { public, attendeesLive, private }

class Event extends Equatable {
  final String? id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? coverImageUrl;
  final LocationVisibility locationVisibility;
  final PricingModel pricingModel;
  final double? ticketPrice;
  final double? minimumPrice;
  final double? suggestedPrice;
  final double? suggestedDonation;
  final int? maxCapacity;
  final GuestListVisibility guestListVisibility;
  final EventPrivacy privacy;
  final DateTime createdAt;

  const Event({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.coverImageUrl,
    required this.locationVisibility,
    required this.pricingModel,
    this.ticketPrice,
    this.minimumPrice,
    this.suggestedPrice,
    this.suggestedDonation,
    this.maxCapacity,
    required this.guestListVisibility,
    required this.privacy,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      location: json['location'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      locationVisibility: LocationVisibility.values.firstWhere(
        (e) => e.name == json['location_visibility'],
        orElse: () => LocationVisibility.immediate,
      ),
      pricingModel: PricingModel.values.firstWhere(
        (e) => e.name == json['pricing_model'],
        orElse: () => PricingModel.freeRsvp,
      ),
      ticketPrice: json['ticket_price']?.toDouble(),
      minimumPrice: json['minimum_price']?.toDouble(),
      suggestedPrice: json['suggested_price']?.toDouble(),
      suggestedDonation: json['suggested_donation']?.toDouble(),
      maxCapacity: json['max_capacity'] as int?,
      guestListVisibility: GuestListVisibility.values.firstWhere(
        (e) => e.name == json['guest_list_visibility'],
        orElse: () => GuestListVisibility.public,
      ),
      privacy: json['is_invite_only'] == true 
          ? EventPrivacy.inviteOnly 
          : EventPrivacy.public,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      'location_visibility': locationVisibility.name,
      'pricing_model': pricingModel.name,
      if (ticketPrice != null) 'ticket_price': ticketPrice,
      if (minimumPrice != null) 'minimum_price': minimumPrice,
      if (suggestedPrice != null) 'suggested_price': suggestedPrice,
      if (suggestedDonation != null) 'suggested_donation': suggestedDonation,
      if (maxCapacity != null) 'max_capacity': maxCapacity,
      'guest_list_visibility': guestListVisibility.name,
      'is_invite_only': privacy == EventPrivacy.inviteOnly,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? coverImageUrl,
    LocationVisibility? locationVisibility,
    PricingModel? pricingModel,
    double? ticketPrice,
    double? minimumPrice,
    double? suggestedPrice,
    double? suggestedDonation,
    int? maxCapacity,
    GuestListVisibility? guestListVisibility,
    EventPrivacy? privacy,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      locationVisibility: locationVisibility ?? this.locationVisibility,
      pricingModel: pricingModel ?? this.pricingModel,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      minimumPrice: minimumPrice ?? this.minimumPrice,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      suggestedDonation: suggestedDonation ?? this.suggestedDonation,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      guestListVisibility: guestListVisibility ?? this.guestListVisibility,
      privacy: privacy ?? this.privacy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startTime,
        endTime,
        location,
        coverImageUrl,
        locationVisibility,
        pricingModel,
        ticketPrice,
        minimumPrice,
        suggestedPrice,
        suggestedDonation,
        maxCapacity,
        guestListVisibility,
        privacy,
        createdAt,
      ];
}

class CreateEventResponse {
  final Event event;

  const CreateEventResponse({
    required this.event,
  });

  factory CreateEventResponse.fromJson(Map<String, dynamic> json) {
    return CreateEventResponse(
      event: Event.fromJson(json['event'] as Map<String, dynamic>),
    );
  }
}