import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../data/repositories/collaboration_repository.dart';
import '../../../data/models/position_models.dart';
import '../../models/role_title.dart';
import '../../models/description.dart';
import '../../models/profit_share.dart';
import 'position_form_state.dart';

class PositionFormCubit extends Cubit<PositionFormState> {
  final CollaborationRepository _collaborationRepository;
  final String _eventId;

  PositionFormCubit(
    this._collaborationRepository,
    String eventId, {
    OpenPosition? editPosition,
  }) : _eventId = eventId,
       super(PositionFormState(
         mode: editPosition != null ? PositionFormMode.edit : PositionFormMode.create,
         roleTitle: editPosition != null 
             ? RoleTitle.dirty(editPosition.roleTitle)
             : const RoleTitle.pure(),
         description: editPosition != null
             ? Description.dirty(editPosition.description)
             : const Description.pure(),
         profitShare: editPosition?.profitSharePercentage != null
             ? ProfitShare.dirty(editPosition!.profitSharePercentage.toString())
             : const ProfitShare.pure(),
         originalPosition: editPosition,
       ));

  void roleTitleChanged(String value) {
    final roleTitle = RoleTitle.dirty(value);
    emit(state.copyWith(roleTitle: roleTitle));
  }

  void descriptionChanged(String value) {
    final description = Description.dirty(value);
    emit(state.copyWith(description: description));
  }

  void profitShareChanged(String value) {
    final profitShare = ProfitShare.dirty(value);
    emit(state.copyWith(profitShare: profitShare));
  }

  Future<void> submitForm() async {
    if (!state.isValid || state.status.isInProgress) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final profitShareValue = state.profitShare.value.isEmpty 
        ? null 
        : double.tryParse(state.profitShare.value);

    final result = state.mode == PositionFormMode.create
        ? await _collaborationRepository.createPosition(
            CreatePositionRequest(
              eventId: _eventId,
              roleTitle: state.roleTitle.value,
              description: state.description.value,
              profitSharePercentage: profitShareValue,
            ),
          )
        : await _collaborationRepository.updatePosition(
            state.originalPosition!.id,
            UpdatePositionRequest(
              roleTitle: state.roleTitle.value,
              description: state.description.value,
              profitSharePercentage: profitShareValue,
            ),
          );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }

  Future<void> deletePosition() async {
    if (state.mode != PositionFormMode.edit || !state.canDelete) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _collaborationRepository.deletePosition(
      state.originalPosition!.id,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }
}