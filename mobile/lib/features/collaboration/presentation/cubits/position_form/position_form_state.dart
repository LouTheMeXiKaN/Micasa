import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../../models/role_title.dart';
import '../../models/description.dart';
import '../../models/profit_share.dart';
import '../../../data/models/position_models.dart';

enum PositionFormMode { create, edit }

class PositionFormState extends Equatable {
  final PositionFormMode mode;
  final RoleTitle roleTitle;
  final Description description;
  final ProfitShare profitShare;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final OpenPosition? originalPosition; // For edit mode

  const PositionFormState({
    required this.mode,
    this.roleTitle = const RoleTitle.pure(),
    this.description = const Description.pure(),
    this.profitShare = const ProfitShare.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.originalPosition,
  });

  bool get isValid => Formz.validate([roleTitle, description, profitShare]);
  bool get canDelete => mode == PositionFormMode.edit && 
                       originalPosition?.canDelete == true;

  PositionFormState copyWith({
    PositionFormMode? mode,
    RoleTitle? roleTitle,
    Description? description,
    ProfitShare? profitShare,
    FormzSubmissionStatus? status,
    String? errorMessage,
    OpenPosition? originalPosition,
  }) {
    return PositionFormState(
      mode: mode ?? this.mode,
      roleTitle: roleTitle ?? this.roleTitle,
      description: description ?? this.description,
      profitShare: profitShare ?? this.profitShare,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      originalPosition: originalPosition ?? this.originalPosition,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        roleTitle,
        description,
        profitShare,
        status,
        errorMessage,
        originalPosition,
      ];
}