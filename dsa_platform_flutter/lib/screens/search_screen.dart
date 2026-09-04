import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/engine_provider.dart';
import '../providers/problem_provider.dart';
import '../models/problem.dart';
import '../widgets/problem_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _selectedDifficulty = '';
  String _selectedTopic = '';
  List<Problem> _results = [];
  bool _hasSearched = false;

  final _topics = [
    'Array', 'String', 'Hash Map', 'Tree', 'Graph',
    'Dynamic Programming', 'Binary Search', 'Two Pointers',
    'Sliding Window', 'Stack', 'Queue', 'Heap',
  ];
  final _difficulties = ['EASY', 'MEDIUM', 'HARD'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch() {
    final engine = context.read<EngineProvider>();
    final problemProvider = context.read<ProblemProvider>();

    final query = _controller.text.trim();
    if (query.isEmpty && _selectedDifficulty.isEmpty && _selectedTopic.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    // Build index if not done
    if (problemProvider.problems.isNotEmpty) {
      engine.searchEngine.buildIndex(problemProvider.problems);
    }

    final results = engine.searchEngine.search(
      query: query.isNotEmpty ? query : null,
      difficulty: _selectedDifficulty.isNotEmpty ? _selectedDifficulty : null,
      topic: _selectedTopic.isNotEmpty ? _selectedTopic : null,
    );

    setState(() {
      _results = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search input
                  TextField(
                    controller: _controller,
                    onChanged: (_) => _performSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search problems...',
                      hintStyle: AppTextStyles.label(color: AppColors.smoke),
                      prefixIcon: const Icon(Icons.search, color: AppColors.smoke, size: 20),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _controller.clear();
                                _performSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.tag),
                        borderSide: const BorderSide(color: AppColors.ash),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.tag),
                        borderSide: const BorderSide(color: AppColors.ash),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.tag),
                        borderSide: const BorderSide(color: AppColors.lakeBlue),
                      ),
                      filled: true,
                      fillColor: AppColors.parchment,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    style: AppTextStyles.label(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Difficulty filters
                  Row(
                    children: [
                      Text(
                        'DIFFICULTY:',
                        style: AppTextStyles.labelTiny(color: AppColors.smoke),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ..._difficulties.map((d) {
                        final isSelected = _selectedDifficulty == d;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDifficulty = isSelected ? '' : d;
                              });
                              _performSearch();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.offBlack : Colors.transparent,
                                border: Border.all(color: AppColors.ash, width: 1),
                                borderRadius: BorderRadius.circular(AppRadii.tag),
                              ),
                              child: Text(
                                d,
                                style: AppTextStyles.labelTiny(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.offBlack,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Topic filters
                  SizedBox(
                    height: 30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _topics.map((t) {
                        final isSelected = _selectedTopic == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTopic = isSelected ? '' : t;
                              });
                              _performSearch();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.offBlack : Colors.transparent,
                                border: Border.all(color: AppColors.ash, width: 1),
                                borderRadius: BorderRadius.circular(AppRadii.tag),
                              ),
                              child: Text(
                                t,
                                style: AppTextStyles.labelTiny(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.offBlack,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return Center(
        child: Text(
          'Type to search problems',
          style: AppTextStyles.label(color: AppColors.smoke),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          'No problems found',
          style: AppTextStyles.label(color: AppColors.smoke),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final problem = _results[index];
        return ProblemCard(
          problem: problem,
          subtitle: problem.topics.join(' · '),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/problem-detail',
              arguments: {
                'problem': problem,
                'reason': null,
              },
            );
          },
        );
      },
    );
  }
}
