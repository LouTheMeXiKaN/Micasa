import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:formz/formz.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/auth/presentation/widgets/auth_text_field.dart';
import '../../../../features/auth/presentation/widgets/auth_button.dart';
import '../../data/repositories/collaboration_repository.dart';
import '../../data/models/position_models.dart';
import '../cubits/position_form/position_form_cubit.dart';
import '../cubits/position_form/position_form_state.dart';
import '../models/role_title.dart';
import '../models/description.dart';
import '../models/profit_share.dart';

class CreateEditPositionScreen extends StatelessWidget {
  final String eventId;
  final OpenPosition? editPosition;

  const CreateEditPositionScreen({
    Key? key,
    required this.eventId,
    this.editPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PositionFormCubit(
        context.read<CollaborationRepository>(),
        eventId,
        editPosition: editPosition,
      ),
      child: CreateEditPositionView(
        isEditMode: editPosition != null,
        positionTitle: editPosition?.roleTitle,
      ),
    );
  }
}

class CreateEditPositionView extends StatelessWidget {
  final bool isEditMode;
  final String? positionTitle;

  const CreateEditPositionView({
    Key? key,
    required this.isEditMode,
    this.positionTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral950),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditMode ? 'Edit Position' : 'Create Position',
          style: AppTypography.textLg.copyWith(
            color: AppColors.neutral950,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),
      body: BlocListener<PositionFormCubit, PositionFormState>(
        listener: (context, state) {
          if (state.status.isSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    isEditMode ? 'Position updated successfully!' : 'Position created successfully!',
                  ),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            context.pop();
          } else if (state.status.isFailure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.coralRed,
                ),
              );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormCard(),
              const SizedBox(height: AppTheme.space6),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Position Details',
            style: AppTypography.textLg.copyWith(
              fontWeight: AppTypography.semibold,
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: AppTheme.space5),
          _RoleTitleInput(),
          const SizedBox(height: AppTheme.space5),
          _DescriptionInput(),
          const SizedBox(height: AppTheme.space5),
          _ProfitShareInput(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<PositionFormCubit, PositionFormState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthButton(
              text: isEditMode ? 'Save Changes' : 'Post Position',
              isLoading: state.status.isInProgress,
              onPressed: state.isValid && !state.status.isInProgress
                  ? () => context.read<PositionFormCubit>().submitForm()
                  : null,
            ),
            if (isEditMode && state.canDelete) ...[
              const SizedBox(height: AppTheme.space4),
              OutlinedButton(
                onPressed: state.status.isInProgress
                    ? null
                    : () => _showDeleteConfirmation(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coralRed,
                  side: BorderSide(color: AppColors.coralRed),
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
                child: const Text('Delete Position'),
              ),
            ],
            if (isEditMode && !state.canDelete) ...[
              const SizedBox(height: AppTheme.space4),
              Container(
                padding: const EdgeInsets.all(AppTheme.space4),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Expanded(
                      child: Text(
                        'Cannot delete position with existing applications',
                        style: AppTypography.textSm.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Position'),
        content: Text(
          'Are you sure you want to delete "${positionTitle ?? 'this position'}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PositionFormCubit>().deletePosition();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.coralRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _RoleTitleInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PositionFormCubit, PositionFormState>(
      buildWhen: (previous, current) => previous.roleTitle != current.roleTitle,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Role Title',
                  style: AppTypography.textSm.copyWith(
                    color: AppColors.neutral700,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                Text(
                  ' *',
                  style: AppTypography.textSm.copyWith(
                    color: AppColors.coralRed,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.roleTitle.value.length}/${RoleTitle.maxLength}',
                  style: AppTypography.textXs.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space2),
            AuthTextField(
              label: 'Role Title',
              hint: 'e.g. DJ, Photographer, Event Coordinator',
              onChanged: (value) => context.read<PositionFormCubit>().roleTitleChanged(value),
              errorText: _getErrorText(state.roleTitle),
            ),
          ],
        );
      },
    );
  }

  String? _getErrorText(RoleTitle roleTitle) {
    if (roleTitle.isNotValid && roleTitle.value.isNotEmpty) {
      switch (roleTitle.error) {
        case RoleTitleValidationError.empty:
          return 'Role title is required';
        case RoleTitleValidationError.tooLong:
          return 'Role title must be ${RoleTitle.maxLength} characters or less';
        default:
          return null;
      }
    }
    return null;
  }
}

class _DescriptionInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PositionFormCubit, PositionFormState>(
      buildWhen: (previous, current) => previous.description != current.description,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Description',
                  style: AppTypography.textSm.copyWith(
                    color: AppColors.neutral700,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                Text(
                  ' *',
                  style: AppTypography.textSm.copyWith(
                    color: AppColors.coralRed,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space2),
            TextFormField(
              onChanged: (value) => context.read<PositionFormCubit>().descriptionChanged(value),
              maxLines: 4,
              style: AppTypography.textBase.copyWith(
                color: AppColors.neutral950,
              ),
              decoration: InputDecoration(
                hintText: 'Provide details about the role, requirements, and responsibilities...',
                hintStyle: AppTypography.textBase.copyWith(
                  color: AppColors.neutral400,
                ),
                errorText: _getErrorText(state.description),
                contentPadding: const EdgeInsets.all(AppTheme.space4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppColors.neutral300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppColors.neutral300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppColors.deepPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppColors.coralRed, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _getErrorText(Description description) {
    if (description.isNotValid && description.value.isNotEmpty) {
      switch (description.error) {
        case DescriptionValidationError.empty:
          return 'Description is required';
        default:
          return null;
      }
    }
    return null;
  }
}

class _ProfitShareInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PositionFormCubit, PositionFormState>(
      buildWhen: (previous, current) => previous.profitShare != current.profitShare,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profit Share %',
              style: AppTypography.textSm.copyWith(
                color: AppColors.neutral700,
                fontWeight: AppTypography.medium,
              ),
            ),
            const SizedBox(height: AppTheme.space1),
            Text(
              'Optional - Leave empty for unpaid positions',
              style: AppTypography.textXs.copyWith(
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppTheme.space2),
            TextFormField(
              onChanged: (value) => context.read<PositionFormCubit>().profitShareChanged(value),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              style: AppTypography.textBase.copyWith(
                color: AppColors.neutral950,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. 15.5',
                hintStyle: AppTypography.textBase.copyWith(
                  color: AppColors.neutral400,
                ),
                suffixText: '%',
                suffixStyle: AppTypography.textBase.copyWith(
                  color: AppColors.neutral600,
                ),
                errorText: _getErrorText(state.profitShare),
                contentPadding: const EdgeInsets.all(AppTheme.space4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppColors.neutral300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppColors.neutral300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppColors.deepPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppColors.coralRed, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _getErrorText(ProfitShare profitShare) {
    if (profitShare.isNotValid && profitShare.value.isNotEmpty) {
      switch (profitShare.error) {
        case ProfitShareValidationError.invalid:
          return 'Please enter a valid percentage';
        case ProfitShareValidationError.tooHigh:
          return 'Percentage cannot exceed 100%';
        default:
          return null;
      }
    }
    return null;
  }
}