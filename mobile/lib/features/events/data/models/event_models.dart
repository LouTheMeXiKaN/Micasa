import 'package:equatable/equatable.dart';

enum EventPrivacy { public, inviteOnly }

enum LocationVisibility { 
  immediate, 
  confirmedGuests, 
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
      id: json['event_id'] as String? ?? json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      location: json['location_address'] as String? ?? json['location'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      locationVisibility: _parseLocationVisibility(json['location_visibility'] as String),
      pricingModel: _parsePricingModel(json['pricing_model'] as String),
      ticketPrice: json['price_fixed']?.toDouble() ?? json['ticket_price']?.toDouble(),
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
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
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
      'location_address': location, // Required by API
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      'location_visibility': _mapLocationVisibility(locationVisibility),
      'pricing_model': _mapPricingModel(pricingModel),
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

  static String _mapLocationVisibility(LocationVisibility visibility) {
    switch (visibility) {
      case LocationVisibility.immediate:
        return 'immediate';
      case LocationVisibility.confirmedGuests:
        return 'confirmed_guests';
      case LocationVisibility.twentyFourHoursBefore:
        return '24_hours_before';
    }
  }

  static LocationVisibility _parseLocationVisibility(String value) {
    switch (value) {
      case 'immediate':
        return LocationVisibility.immediate;
      case 'confirmed_guests':
        return LocationVisibility.confirmedGuests;
      case '24_hours_before':
        return LocationVisibility.twentyFourHoursBefore;
      default:
        return LocationVisibility.immediate;
    }
  }

  static String _mapPricingModel(PricingModel model) {
    switch (model) {
      case PricingModel.freeRsvp:
        return 'free_rsvp';
      case PricingModel.fixedPrice:
        return 'fixed_price';
      case PricingModel.chooseYourPrice:
        return 'choose_your_price';
      case PricingModel.donationBased:
        return 'donation_based';
    }
  }

  static PricingModel _parsePricingModel(String value) {
    switch (value) {
      case 'free_rsvp':
        return PricingModel.freeRsvp;
      case 'fixed_price':
        return PricingModel.fixedPrice;
      case 'choose_your_price':
        return PricingModel.chooseYourPrice;
      case 'donation_based':
        return PricingModel.donationBased;
      default:
        return PricingModel.freeRsvp;
    }
  }
}

class CreateEventResponse {
  final Event event;

  const CreateEventResponse({
    required this.event,
  });

  factory CreateEventResponse.fromJson(Map<String, dynamic> json) {
    // Handle both wrapped and unwrapped responses
    if (json.containsKey('event')) {
      return CreateEventResponse(
        event: Event.fromJson(json['event'] as Map<String, dynamic>),
      );
    } else {
      // Direct event data from backend
      return CreateEventResponse(
        event: Event.fromJson(json),
      );
    }
  }
}