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
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _kpiCtrl;
  late AnimationController _chartsCtrl;
  late Animation<double> _headerAnim;
  late Animation<double> _kpiFade;
  late Animation<Offset> _kpiSlide;
  late Animation<double> _chartsFade;
  late Animation<Offset> _chartsSlide;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _kpiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _chartsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _headerAnim =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _kpiFade =
        CurvedAnimation(parent: _kpiCtrl, curve: Curves.easeOut);
    _kpiSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _kpiCtrl, curve: Curves.easeOut));
    _chartsFade =
        CurvedAnimation(parent: _chartsCtrl, curve: Curves.easeOut);
    _chartsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _chartsCtrl, curve: Curves.easeOut));

    _headerCtrl.forward().then((_) {
      _kpiCtrl.forward().then((_) {
        _chartsCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _kpiCtrl.dispose();
    _chartsCtrl.dispose();
    super.dispose();
  }

  int get _total => widget.etudiants.length;
  int _countGroupe(String g) =>
      widget.etudiants.where((e) => e.groupe == g).length;
  int get _totalAbsences =>
      widget.etudiants.fold(0, (s, e) => s + e.absences.length);
  int get _presentsAujourdhui =>
      widget.etudiants.where((e) => !e.isAbsentToday()).length;
  int get _absentsAujourdhui =>
      widget.etudiants.where((e) => e.isAbsentToday()).length;
  double get _moyenneAge {
    if (_total == 0) return 0;
    return widget.etudiants.map((e) => e.age).reduce((a, b) => a + b) /
        _total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final jours = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
    final mois = ['Janvier','Février','Mars','Avril','Mai','Juin',
      'Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    final dateStr =
        '${jours[now.weekday - 1]} ${now.day} ${mois[now.month - 1]} ${now.year}';

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerAnim,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // دوائر ديكور
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 60, bottom: -20,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📊 Dashboard',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Vue d\'ensemble de votre établissement',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(dateStr,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── KPI Cards ──
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _kpiSlide,
              child: FadeTransition(
                opacity: _kpiFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _kpiCard('Total étudiants', '$_total',
                          Icons.people_rounded,
                          const Color(0xFF7B2FF7), const Color(0xFF9B5FE7),
                          '↑ actifs'),
                      _kpiCard('Présents', '$_presentsAujourdhui',
                          Icons.check_circle_rounded,
                          const Color(0xFF00C853), const Color(0xFF1DE9B6),
                          '${_total == 0 ? 0 : (_presentsAujourdhui * 100 / _total).round()}% taux'),
                      _kpiCard('Absents', '$_absentsAujourdhui',
                          Icons.cancel_rounded,
                          const Color(0xFFFF6B35), const Color(0xFFFF8E53),
                          '${_total == 0 ? 0 : (_absentsAujourdhui * 100 / _total).round()}% taux'),
                      _kpiCard('Absences cumulées', '$_totalAbsences',
                          Icons.event_busy_rounded,
                          const Color(0xFF0077B6), const Color(0xFF00C9FF),
                          'ce semestre'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Bar Chart + Pie Chart ──
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _chartsSlide,
              child: FadeTransition(
                opacity: _chartsFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bar Chart
                      Expanded(
                        flex: 3,
                        child: _card(
                          isDark,
                          'Absences par groupe',
                          'Nombre d\'absences',
                          _barChart(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Pie Chart
                      Expanded(
                        flex: 2,
                        child: _card(
                          isDark,
                          'Groupes',
                          'Répartition',
                          _pieChart(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Ranking + Stats ──
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _chartsSlide,
              child: FadeTransition(
                opacity: _chartsFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _rankingCard(isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _detailCard(isDark)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // ── KPI Card ──
  Widget _kpiCard(String label, String value, IconData icon,
      Color c1, Color c2, String trend) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.35),
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
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 10)),
                Text(trend,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Card wrapper ──
  Widget _card(bool isDark, String title, String sub, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
          Text(sub,
              style: TextStyle(
                  color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Bar Chart ──
  Widget _barChart() {
    final groupes = ['G1', 'G2', 'G3', 'G4'];
    final colors = [
      const Color(0xFF7B2FF7),
      const Color(0xFFF107A3),
      const Color(0xFF00BCD4),
      const Color(0xFFFF6B35),
    ];

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(groupes.length, (i) {
            final abs = widget.etudiants
                .where((e) => e.groupe == groupes[i])
                .fold(0, (s, e) => s + e.absences.length);
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: abs.toDouble() == 0 ? 0.3 : abs.toDouble(),
                  gradient: LinearGradient(
                    colors: [colors[i], colors[i].withOpacity(0.6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 24,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    groupes[v.toInt()],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colors[v.toInt()]),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey[500]),
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
    );
  }

  // ── Pie Chart ──
  Widget _pieChart(bool isDark) {
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
      sections.add(PieChartSectionData(
        value: count == 0 ? 0.01 : count.toDouble(),
        color: colors[i],
        title: count == 0 ? '' : '$count',
        radius: 50,
        titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ));
    }
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 28,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: List.generate(groupes.length, (i) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                    color: colors[i], shape: BoxShape.circle),
              ),
              const SizedBox(width: 3),
              Text('${groupes[i]}(${_countGroupe(groupes[i])})',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey[600])),
            ],
          )),
        ),
      ],
    );
  }

  // ── Ranking Card ──
  Widget _rankingCard(bool isDark) {
    final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
    final avatarColors = [
      [const Color(0xFFEEEDFE), const Color(0xFF534AB7)],
      [const Color(0xFFFBEAF0), const Color(0xFF993556)],
      [const Color(0xFFE1F5EE), const Color(0xFF0F6E56)],
      [const Color(0xFFFAEEDA), const Color(0xFF854F0B)],
      [const Color(0xFFE6F1FB), const Color(0xFF185FA5)],
    ];
    final sorted = [...widget.etudiants]
      ..sort((a, b) => b.absences.length.compareTo(a.absences.length));
    final top = sorted.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Classement absences',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          Text('Top étudiants',
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 12),
          if (top.isEmpty)
            Center(
              child: Text('Aucun étudiant',
                  style: TextStyle(color: Colors.grey[400])),
            )
          else
            ...List.generate(top.length, (i) {
              final e = top[i];
              final ac = avatarColors[i % avatarColors.length];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: i < top.length - 1
                      ? Border(
                          bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.1)))
                      : null,
                ),
                child: Row(
                  children: [
                    Text(medals[i],
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: ac[0],
                      child: Text(
                        e.prenom[0] + e.nom[0],
                        style: TextStyle(
                            color: ac[1],
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.nomComplet,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                          Text(e.groupe,
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: e.absences.isEmpty
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${e.absences.length}',
                        style: TextStyle(
                            color: e.absences.isEmpty
                                ? Colors.green
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Detail Card ──
  Widget _detailCard(bool isDark) {
    final groupes = ['G1', 'G2', 'G3', 'G4'];
    final colors = [
      const Color(0xFF7B2FF7),
      const Color(0xFFF107A3),
      const Color(0xFF00BCD4),
      const Color(0xFFFF6B35),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistiques détaillées',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          Text('Indicateurs clés',
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 12),

          // Progress bars
          ...List.generate(groupes.length, (i) {
            final count = _countGroupe(groupes[i]);
            final pct = _total == 0 ? 0.0 : count / _total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(groupes[i],
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors[i])),
                      Text('$count — ${(pct * 100).round()}%',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct),
                      duration: Duration(milliseconds: 800 + i * 150),
                      curve: Curves.easeOut,
                      builder: (_, val, __) => LinearProgressIndicator(
                        value: val,
                        minHeight: 8,
                        backgroundColor: colors[i].withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors[i]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 16),

          _statRow('Âge moyen',
              '${_moyenneAge.toStringAsFixed(1)} ans',
              AppColors.primary),
          _statRow(
              'Plus âgé',
              _total == 0
                  ? '-'
                  : '${widget.etudiants.map((e) => e.age).reduce((a, b) => a > b ? a : b)} ans',
              Colors.green),
          _statRow(
              'Plus jeune',
              _total == 0
                  ? '-'
                  : '${widget.etudiants.map((e) => e.age).reduce((a, b) => a < b ? a : b)} ans',
              Colors.teal),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }
}