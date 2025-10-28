import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Podcasts'),
              Tab(text: 'Music'),
              Tab(text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildPodcastsTab(),
            _buildMusicTab(),
            _buildUsersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.podcasts,
                  label: 'Total Podcasts',
                  value: '156',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.music_note,
                  label: 'Music Tracks',
                  value: '342',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.hourglass_empty,
                  label: 'Pending',
                  value: '12',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  label: 'Users',
                  value: '1,240',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionButton(
                icon: Icons.add,
                label: 'Upload Music',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.check_circle,
                label: 'Review Content',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.analytics,
                label: 'View Analytics',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildContentTable(
          headers: ['Title', 'Creator', 'Category', 'Status', 'Created', 'Actions'],
          rows: List.generate(10, (index) {
            return _TableRow(
              cells: [
                'Podcast Title ${index + 1}',
                'Creator Name',
                'Category',
                index % 3 == 0 ? 'Approved' : 'Pending',
                '2024-01-15',
                '',
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMusicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Upload Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Music Track',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Artist',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Select Audio File'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Upload'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildContentTable(
            headers: ['Track', 'Artist', 'Genre', 'Status', 'Duration', 'Actions'],
            rows: List.generate(10, (index) {
              return _TableRow(
                cells: [
                  'Track ${index + 1}',
                  'Artist Name',
                  'Worship',
                  index % 2 == 0 ? 'Published' : 'Featured',
                  '3:45',
                  '',
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('User ${index + 1}'),
            subtitle: Text('user${index + 1}@example.com'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentTable({
    required List<String> headers,
    required List<_TableRow> rows,
  }) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: headers.map((header) => DataColumn(label: Text(header))).toList(),
          rows: rows.map((row) {
            return DataRow(
              cells: row.cells.map((cell) => DataCell(Text(cell))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _TableRow {
  final List<String> cells;

  _TableRow({required this.cells});
}

