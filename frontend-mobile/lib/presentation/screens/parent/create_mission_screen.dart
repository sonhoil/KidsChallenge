import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/mission_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/mission_provider.dart';
import 'package:kids_challenge/presentation/state/family_provider.dart';
import 'package:kids_challenge/data/models/family_model.dart';

class CreateMissionScreen extends ConsumerStatefulWidget {
  final MissionModel? mission;

  const CreateMissionScreen({super.key, this.mission});

  @override
  ConsumerState<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends ConsumerState<CreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _pointsController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _assignee = 'all';
  String _frequency = 'daily';
  String _selectedIcon = '🧹';
  final Set<String> _selectedDays = {};
  bool _isSaving = false;

  final List<String> _icons = const ['🧹', '📚', '♻️', '🪥', '🛏️', '🍽️', '🐕', '💪'];

  // _assignees 는 실제 렌더링 시 가족 멤버 목록 + "모두" 를 합쳐서 만든다

  final List<Map<String, String>> _frequencies = const [
    {'id': 'daily', 'label': '매일'},
    {'id': 'custom_days', 'label': '요일 지정'},
    {'id': 'weekly_1', 'label': '주 1회'},
    {'id': 'weekend', 'label': '주말만'},
    {'id': 'one_off', 'label': '스페셜(한번만)'},
  ];

  final List<Map<String, String>> _daysOfWeek = const [
    {'id': 'mon', 'label': '월'},
    {'id': 'tue', 'label': '화'},
    {'id': 'wed', 'label': '수'},
    {'id': 'thu', 'label': '목'},
    {'id': 'fri', 'label': '금'},
    {'id': 'sat', 'label': '토'},
    {'id': 'sun', 'label': '일'},
  ];

  bool get _isEditMode => widget.mission != null;

  @override
  void initState() {
    super.initState();
    final mission = widget.mission;
    if (mission != null) {
      _titleController.text = mission.title;
      _pointsController.text = mission.defaultPoints.toString();
      if (mission.iconType != null && mission.iconType!.isNotEmpty) {
        _selectedIcon = mission.iconType!;
      }

      final parsed = _parseMissionDescription(mission.description);
      _frequency = parsed.frequency;
      _assignee = parsed.assignee;
      _selectedDays.addAll(parsed.days);
      _descriptionController.text = parsed.note;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleDay(String dayId) {
    setState(() {
      if (_selectedDays.contains(dayId)) {
        _selectedDays.remove(dayId);
      } else {
        _selectedDays.add(dayId);
      }
    });
  }

  Future<void> _saveMission() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final family = ref.read(currentFamilyProvider);
    if (family == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('가족 정보가 없습니다. 다시 로그인해주세요.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(missionRepositoryProvider);
      final members = await ref.read(familyMembersProvider(family.id).future);

      // React 버전의 상태를 최대한 살리면서, 백엔드 DTO 구조에 맞춰 매핑
      final title = _titleController.text.trim();
      final points = int.tryParse(_pointsController.text.trim()) ?? 0;

      // frequency / assignee / 요일 정보는 우선 description 으로 저장
      final buffer = StringBuffer();
      buffer.writeln('frequency=$_frequency');
      buffer.writeln('assignee=$_assignee');
      if (_frequency == 'custom_days' && _selectedDays.isNotEmpty) {
        buffer.writeln('days=${_selectedDays.join(",")}');
      }
      if (_descriptionController.text.trim().isNotEmpty) {
        buffer.writeln('note=${_descriptionController.text.trim()}');
      }

      final request = {
        'familyId': family.id,
        'title': title,
        'description': buffer.toString(),
        'defaultPoints': points,
        'iconType': _selectedIcon,
      };

      if (_isEditMode) {
        await repo.updateMission(widget.mission!.id, request);
      } else {
        final createdMission = await repo.createMission(request);

        final childMembers = members.where((member) => member.role == 'child').toList();
        final linkedChildMembers =
            childMembers.where((member) => member.userId != null && member.userId!.isNotEmpty).toList();

        // 스페셜(one_off)만 즉시 무기한 할당 생성. 반복미션은 자동 생성 로직에 맡긴다.
        if (_frequency == 'one_off') {
          if (_assignee == 'all') {
            for (final member in linkedChildMembers) {
              await repo.assignMission({
                'missionId': createdMission.id,
                'assigneeId': member.userId,
                'familyId': family.id,
                'points': points,
              });
            }
          } else {
            final selectedMember = childMembers.where((member) => member.id == _assignee).firstOrNull;
            if (selectedMember == null) {
              throw Exception('미션을 수행할 아이를 찾을 수 없습니다.');
            }
            if (selectedMember.userId == null || selectedMember.userId!.isEmpty) {
              throw Exception('선택한 아이 계정이 아직 연결되지 않아 미션을 할당할 수 없습니다.');
            }

            await repo.assignMission({
              'missionId': createdMission.id,
              'assigneeId': selectedMember.userId,
              'familyId': family.id,
              'points': points,
            });
          }
        }
      }

      // 가족의 미션 목록 / 대기 미션 목록 갱신
      ref.invalidate(missionsProvider(family.id));
      ref.invalidate(pendingMissionsProvider(family.id));
      ref.invalidate(familyAssignmentsProvider(family.id));
      ref.invalidate(myMissionsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? '미션이 수정되었습니다.' : '미션이 생성되었습니다.'),
          backgroundColor: AppTheme.emerald500,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('미션 ${_isEditMode ? '수정' : '생성'}에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _titleController.text.trim().isNotEmpty &&
        _pointsController.text.trim().isNotEmpty &&
        !_isSaving;

    final family = ref.watch(currentFamilyProvider);
    final membersAsync = family != null
        ? ref.watch(familyMembersProvider(family.id))
        : const AsyncValue<List<FamilyMemberModel>>.loading();

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          _isEditMode ? '미션 수정' : '새 미션 등록',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.slate800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.slate500),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: canSave ? _saveMission : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndIconSection(),
                const SizedBox(height: 24),
                _buildPointsSection(),
                const SizedBox(height: 24),
                _buildAssigneeSection(membersAsync),
                const SizedBox(height: 24),
                _buildFrequencySection(),
                const SizedBox(height: 24),
                _buildDescriptionSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndIconSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag, size: 18, color: AppTheme.slate500),
            SizedBox(width: 6),
            Text(
              '미션 이름',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.slate200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _selectedIcon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '예: 내 방 청소하기',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppTheme.slate200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppTheme.slate200),
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate800,
                ),
                onTap: () {
                  // #region agent log
                  print('[CreateMissionScreen] Title field tapped');
                  // #endregion
                },
                onChanged: (value) {
                  // #region agent log
                  print('[CreateMissionScreen] Title changed: $value');
                  // #endregion
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '미션 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _icons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final icon = _icons[index];
              final isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryLight.withOpacity(0.3) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.slate200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard, size: 18, color: AppTheme.slate500),
            SizedBox(width: 6),
            Text(
              '보상 포인트',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pointsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '포인트',
            hintText: '예: 100',
            border: OutlineInputBorder(),
          ),
          onTap: () {
            print('[CreateMissionScreen] Points field tapped');
          },
          onChanged: (value) {
            print('[CreateMissionScreen] Points changed: $value');
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '포인트를 입력해주세요';
            }
            final parsed = int.tryParse(value.trim());
            if (parsed == null || parsed <= 0) {
              return '1 이상의 숫자를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAssigneeSection(AsyncValue<List<FamilyMemberModel>> membersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_alt, size: 18, color: AppTheme.slate500),
            SizedBox(width: 6),
            Text(
              '수행 대상',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        membersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 4),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '멤버를 불러오지 못했습니다: $e',
              style: const TextStyle(color: AppTheme.error, fontSize: 12),
            ),
          ),
          data: (members) {
            final childMembers = members.where((member) => member.role == 'child').toList();
            final items = <Map<String, String>>[
              {'id': 'all', 'label': '모두'},
              ...childMembers.map((m) {
                final label = m.nickname?.isNotEmpty == true ? m.nickname! : '아이';
                return {
                  'id': m.id,
                  'label': label,
                };
              }),
            ];

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                final isSelected = _assignee == item['id'];
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 20 * 2 - 8) / 2,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _assignee = item['id']!;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          isSelected ? AppTheme.primaryLight.withOpacity(0.2) : Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.slate200,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      item['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.primary : AppTheme.slate500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 18, color: AppTheme.slate500),
            SizedBox(width: 6),
            Text(
              '반복 주기',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _frequencies.map((item) {
            final isSelected = _frequency == item['id'];
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 20 * 2 - 8) / 2,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _frequency = item['id']!;
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? AppTheme.primaryLight.withOpacity(0.2) : Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.slate200,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  item['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primary : AppTheme.slate500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_frequency == 'custom_days') ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _daysOfWeek.map((day) {
              final isSelected = _selectedDays.contains(day['id']);
              final isWeekend = day['id'] == 'sat' || day['id'] == 'sun';
              return GestureDetector(
                onTap: () => _toggleDay(day['id']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.primary : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.slate200,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isWeekend
                              ? Colors.redAccent
                              : AppTheme.slate500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '설명 (선택)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.slate500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '아이에게 보여줄 설명을 적어주세요',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
          ),
        ),
      ],
    );
  }

  ({String frequency, String assignee, Set<String> days, String note}) _parseMissionDescription(
    String? description,
  ) {
    var frequency = 'daily';
    var assignee = 'all';
    final days = <String>{};
    var note = '';

    if (description == null || description.trim().isEmpty) {
      return (frequency: frequency, assignee: assignee, days: days, note: note);
    }

    for (final rawLine in description.split('\n')) {
      final line = rawLine.trim();
      if (line.startsWith('frequency=')) {
        frequency = line.substring('frequency='.length);
      } else if (line.startsWith('assignee=')) {
        assignee = line.substring('assignee='.length);
      } else if (line.startsWith('days=')) {
        final values = line.substring('days='.length);
        for (final day in values.split(',')) {
          final trimmed = day.trim();
          if (trimmed.isNotEmpty) {
            days.add(trimmed);
          }
        }
      } else if (line.startsWith('note=')) {
        note = line.substring('note='.length);
      } else if (line.isNotEmpty && note.isEmpty) {
        note = line;
      }
    }

    return (frequency: frequency, assignee: assignee, days: days, note: note);
  }
}
