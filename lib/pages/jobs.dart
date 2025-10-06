import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_api_service.dart';
import '../services/saved_jobs_service.dart';
import 'job_details.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobs = await JobApiService.getJobs();
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterJobs(String query) {
    setState(() {
      _searchQuery = query;
      _filteredJobs = query.isEmpty
          ? _jobs
          : _jobs.where((job) {
        final searchLower = query.toLowerCase();
        return job.title.toLowerCase().contains(searchLower) ||
            job.company.toLowerCase().contains(searchLower) ||
            job.location.toLowerCase().contains(searchLower);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildSearchBar(),
          if (!_isLoading && _error == null) _buildResultsBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterJobs,
        decoration: InputDecoration(
          hintText: 'Search jobs...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
            onPressed: () {
              _searchController.clear();
              _filterJobs('');
            },
          )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F6F7),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredJobs.length} opportunities',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3142),
            ),
          ),
          TextButton.icon(
            onPressed: _loadJobs,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4A90E2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Something went wrong', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadJobs,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No jobs found', style: TextStyle(fontSize: 16)),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _filterJobs('');
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _filteredJobs.length,
        itemBuilder: (context, index) => _JobCard(
          job: _filteredJobs[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailPage(job: _filteredJobs[index]),
            ),
          ),
          onSaveToggle: () async {
            final job = _filteredJobs[index];
            setState(() => job.isSaved = !job.isSaved);

            if (job.isSaved) {
              await SavedJobsService.saveJob(job);
            } else {
              await SavedJobsService.removeJob(job.id);
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(job.isSaved ? 'Saved' : 'Removed'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback onSaveToggle;

  const _JobCard({
    required this.job,
    required this.onTap,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_isNew()) _buildNewBadge(),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.company,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A5568),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSaveButton(context),
                  ],
                ),

                const SizedBox(height: 12),

                // Location & Salary Row
                Row(
                  children: [
                    _buildIconText(Icons.location_on_outlined, job.location),
                    if (job.salary != 'Not Specified') ...[
                      const SizedBox(width: 16),
                      _buildIconText(Icons.payments_outlined, job.salary),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row
                Row(
                  children: [
                    _buildChip(job.type, const Color(0xFF4A90E2)),
                    const SizedBox(width: 8),
                    _buildChip(job.category, const Color(0xFF7B68EE)),
                    const Spacer(),
                    Text(
                      _getTimeAgo(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (job.companyLogo.isNotEmpty) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFF5F6F7),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            job.companyLogo,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
          ),
        ),
      );
    }
    return _buildLogoPlaceholder();
  }

  Widget _buildLogoPlaceholder() {
    final colors = [
      const Color(0xFF4A90E2),
      const Color(0xFF7B68EE),
      const Color(0xFF5AC8FA),
      const Color(0xFF4CD964),
      const Color(0xFFFF9500),
    ];
    final color = colors[job.company.length % colors.length];

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          job.company.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: onSaveToggle,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: job.isSaved
              ? const Color(0xFF4A90E2).withOpacity(0.1)
              : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          job.isSaved ? Icons.bookmark : Icons.bookmark_border,
          size: 20,
          color: job.isSaved
              ? const Color(0xFF4A90E2)
              : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildNewBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.length > 15 ? '${text.substring(0, 15)}...' : text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  bool _isNew() {
    return DateTime.now().difference(job.publishedDate).inDays <= 2;
  }

  String _getTimeAgo() {
    final diff = DateTime.now().difference(job.publishedDate);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}