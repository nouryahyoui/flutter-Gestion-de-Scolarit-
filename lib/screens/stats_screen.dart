import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/etudiant.dart';
import '../theme/app_colors.dart';

class StatsScreen extends StatefulWidget {
  final List<Etudiant> etudiants;
  const StatsScreen({super.key, required this.etudiants});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  int get _total => widget.etudiants.length;

  int _countGroupe(String g) =>
      widget.etudiants.where((e) => e.groupe == g).length;

  int get _totalAbsences =>
      widget.etudiants.fold(0, (sum, e) => sum + e.absences.length);

  int get _totalPresents =>
      widget.etudiants.where((e) => !e.isAbsentToday()).length;

  int get _totalAbsentsAujourdhui =>
      widget.etudiants.where((e) => e.isAbsentToday()).length;

  double get _moyenneAge {
    if (_total == 0) return 0;
    return widget.etudiants.map((e) => e.age).reduce((a, b) => a + b) /
        _total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.mainGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📊 Dashboard',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Vue d\'ensemble complète',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── KPI Cards ──
                    _sectionTitle('Vue Globale'),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _kpiCard('Total', '$_total', Icons.people,
                            const Color(0xFF7B2FF7), const Color(0xFFAB5FFA)),
                        _kpiCard('Présents', '$_totalPresents',
                            Icons.check_circle_outline,
                            const Color(0xFF00C853), const Color(0xFF69F0AE)),
                        _kpiCard('Absents\naujourd\'hui', '$_totalAbsentsAujourdhui',
                            Icons.cancel_outlined,
                            const Color(0xFFFF6B35), const Color(0xFFFF8E53)),
                        _kpiCard('Âge moyen',
                            '${_moyenneAge.toStringAsFixed(1)} ans',
                            Icons.cake_outlined,
                            const Color(0xFFF107A3), const Color(0xFFFF6BA3)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Pie Chart Groupes ──
                    _sectionTitle('Répartition par Groupe'),
                    const SizedBox(height: 12),
                    _pieChartCard(isDark),

                    const SizedBox(height: 24),

                    // ── Bar Chart Absences ──
                    _sectionTitle('Absences par Groupe'),
                    const SizedBox(height: 12),
                    _barChartCard(isDark),

                    const SizedBox(height: 24),

                    // ── Absence ranking ──
                    _sectionTitle('Classement Absences 🏆'),
                    const SizedBox(height: 12),
                    _absenceRanking(isDark),

                    const SizedBox(height: 24),

                    // ── Stats détaillées ──
                    _sectionTitle('Statistiques Détaillées'),
                    const SizedBox(height: 12),
                    _detailCard(isDark),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Title ──
  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── KPI Card ──
  Widget _kpiCard(String label, String value, IconData icon,
      Color color1, Color color2) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white70, size: 26),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Pie Chart ──
  Widget _pieChartCard(bool isDark) {
    final groupes = ['G1', 'G2', 'G3', 'G4'];
    final colors = [
      const Color(0xFF7B2FF7),
      const Color(0xFFF107A3),
      const Color(0xFF00BCD4),
      const Color(0xFFFF6B35),
    ];

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < groupes.length; i++) {
      final count = _countGroupe(groupes[i]);
      if (count == 0) continue;
      final pct = _total == 0 ? 0.0 : count / _total * 100;
      sections.add(PieChartSectionData(
        value: count.toDouble(),
        color: colors[i],
        title: '${pct.toStringAsFixed(0)}%',
        radius: 70,
        titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: sections.isEmpty
                ? const Center(child: Text('Aucun étudiant'))
                : PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 3,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // Légende
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(groupes.length, (i) {
              final count = _countGroupe(groupes[i]);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                        color: colors[i], shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('${groupes[i]} ($count)',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Bar Chart Absences ──
  Widget _barChartCard(bool isDark) {
    final groupes = ['G1', 'G2', 'G3', 'G4'];
    final colors = [
      const Color(0xFF7B2FF7),
      const Color(0xFFF107A3),
      const Color(0xFF00BCD4),
      const Color(0xFFFF6B35),
    ];

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < groupes.length; i++) {
      final absCount = widget.etudiants
          .where((e) => e.groupe == groupes[i])
          .fold(0, (sum, e) => sum + e.absences.length);
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: absCount.toDouble(),
            gradient: LinearGradient(
              colors: [colors[i], colors[i].withOpacity(0.6)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 28,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ],
      ));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) => Text(
                    groupes[v.toInt()],
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors[v.toInt()]),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }

  // ── Absence Ranking ──
  Widget _absenceRanking(bool isDark) {
    if (widget.etudiants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text('Aucun étudiant')),
      );
    }

    final sorted = [...widget.etudiants]
      ..sort((a, b) => b.absences.length.compareTo(a.absences.length));
    final top = sorted.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: List.generate(top.length, (i) {
          final e = top[i];
          final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
          final color = AppColors.groupColor(e.groupe);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: i < top.length - 1
                  ? Border(
                      bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1)))
                  : null,
            ),
            child: Row(
              children: [
                Text(medals[i], style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.15),
                  child: Text(
                    e.prenom[0] + e.nom[0],
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.nomComplet,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(e.groupe,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: e.absences.isEmpty
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${e.absences.length} abs',
                    style: TextStyle(
                        color: e.absences.isEmpty
                            ? Colors.green
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Detail Stats ──
  Widget _detailCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _statRow('👥 Total étudiants', '$_total',
              AppColors.primary),
          _divider(),
          _statRow('✅ Présents aujourd\'hui', '$_totalPresents',
              Colors.green),
          _divider(),
          _statRow('❌ Absents aujourd\'hui', '$_totalAbsentsAujourdhui',
              Colors.redAccent),
          _divider(),
          _statRow('📅 Total absences cumulées', '$_totalAbsences',
              Colors.orange),
          _divider(),
          _statRow('📊 Âge moyen',
              '${_moyenneAge.toStringAsFixed(1)} ans',
              AppColors.secondary),
          _divider(),
          _statRow(
              '🏆 Plus âgé',
              _total == 0
                  ? '-'
                  : '${widget.etudiants.map((e) => e.age).reduce((a, b) => a > b ? a : b)} ans',
              Colors.purple),
          _divider(),
          _statRow(
              '🌱 Plus jeune',
              _total == 0
                  ? '-'
                  : '${widget.etudiants.map((e) => e.age).reduce((a, b) => a < b ? a : b)} ans',
              Colors.teal),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.withOpacity(0.1), height: 1);

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}