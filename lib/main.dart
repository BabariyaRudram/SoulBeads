import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class M {
  final String name, icon, text;
  const M(this.name, this.icon, [this.text = '']);
}

const mantras = <M>[
  M('Radhe Radhe', '💐'),
  M('Radhe Krishna', '🦚'),
  M('Hare Krishna Maha-Mantra', '🪷'),
  M('Jay Khodiyar Maa', '🫀'),
  M('Jay Dasha Maa', '♥️'),
  M('साम्ब सदाशिव', '🔱'),
  M('Krishna Mantra', '🦚', 'ॐ कृष्णाय वासुदेवाय हरये परमात्मने।\nप्रणतः क्लेशनाशाय गोविंदाय नमो नमः॥'),
  M('Gayatri Mantra', '🪕', 'ॐ भूर्भुवः स्वः ।\nतत्सवितुर्वरेण्यं ।\nभर्गो देवस्य धीमहि ।\nधियो यो नः प्रचोदयात् ॥'),
  M('Maha Mrityunjay Mantra', '📿', 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् ।\nउर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय मामृतात् ॥'),
];
const presets = [11, 21, 51, 108, 501, 1008];

String dkey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class Store extends ChangeNotifier {
  late SharedPreferences p;
  Map<String, Map<String, int>> days = {};
  Map<String, int> cur = {}, target = {};
  List<String> custom = [];
  int theme = 0;
  bool vib = true, snd = true;

  Map<String, int> _ints(String k) {
    final s = p.getString(k);
    if (s == null) return {};
    return (jsonDecode(s) as Map<String, dynamic>).map((a, b) => MapEntry(a, b as int));
  }

  Future<void> load() async {
    p = await SharedPreferences.getInstance();
    final d = p.getString('days');
    if (d != null) {
      (jsonDecode(d) as Map<String, dynamic>).forEach((k, v) {
        days[k] = (v as Map<String, dynamic>).map((a, b) => MapEntry(a, b as int));
      });
    }
    cur = _ints('cur');
    target = _ints('target');
    custom = p.getStringList('custom') ?? [];
    theme = p.getInt('theme') ?? 0;
    vib = p.getBool('vib') ?? true;
    snd = p.getBool('snd') ?? true;
  }

  void save() {
    p.setString('days', jsonEncode(days));
    p.setString('cur', jsonEncode(cur));
    p.setString('target', jsonEncode(target));
    p.setStringList('custom', custom);
    p.setInt('theme', theme);
    p.setBool('vib', vib);
    p.setBool('snd', snd);
    notifyListeners();
  }

  int targetOf(String n) => target[n] ?? 108;
  int count(String n) => cur[n] ?? 0;
  int total(String k) => (days[k] ?? {}).values.fold(0, (a, b) => a + b);

  int tap(String n) {
    final c = count(n) + 1;
    cur[n] = c;
    final d = days.putIfAbsent(dkey(DateTime.now()), () => {});
    d[n] = (d[n] ?? 0) + 1;
    save();
    return c;
  }

  void finish(String n) {
    cur[n] = 0;
    save();
  }

  List<String> get activeDays => (days.keys.where((k) => total(k) > 0).toList()..sort());

  int get streak {
    var d = DateTime.now();
    if (total(dkey(d)) == 0) d = DateTime(d.year, d.month, d.day - 1);
    var n = 0;
    while (total(dkey(d)) > 0) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }

  int get longest {
    var best = 0, run = 0;
    DateTime? prev;
    for (final k in activeDays) {
      final d = DateTime.parse(k);
      run = (prev != null && (d.difference(prev).inHours / 24).round() == 1) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  int get grand => activeDays.fold(0, (a, k) => a + total(k));
  int get best => activeDays.fold(0, (a, k) => math.max(a, total(k)));
}

final store = Store();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const App());
}

Future<bool> ask(BuildContext c, String msg) async {
  final r = await showDialog<bool>(
    context: c,
    builder: (d) => AlertDialog(content: Text(msg), actions: [
      TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
      TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Yes')),
    ]),
  );
  return r ?? false;
}

Future<String?> askText(BuildContext c, String title, {bool number = false}) async {
  final t = TextEditingController();
  final ok = await showDialog<bool>(
    context: c,
    builder: (d) => AlertDialog(
      title: Text(title),
      content: TextField(controller: t, autofocus: true, keyboardType: number ? TextInputType.number : TextInputType.text),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('OK')),
      ],
    ),
  );
  return ok == true ? t.text.trim() : null;
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFC47A24);
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) => MaterialApp(
        title: 'SoulBeads',
        debugShowCheckedModeBanner: false,
        themeMode: [ThemeMode.system, ThemeMode.light, ThemeMode.dark][store.theme],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: seed),
          scaffoldBackgroundColor: const Color(0xFFFFF8E7),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        ),
        home: const Shell(),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const HomePage(), const StatsPage(), const SettingsPage()];
    return Scaffold(
      body: SafeArea(child: pages[i]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final all = [...mantras, ...store.custom.map((n) => M(n, '🕉️'))];
        final today = store.total(dkey(DateTime.now()));
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('SoulBeads 📿',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Pause. Chant. Remember. 🪷', textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text('Today: $today jap  •  🔥 ${store.streak} day streak',
                  textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              for (final m in all)
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JapPage(m: m))),
                    onLongPress: store.custom.contains(m.name)
                        ? () async {
                            if (await ask(context, 'Delete "${m.name}"? Your jap history stays.')) {
                              store.custom.remove(m.name);
                              store.save();
                            }
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(m.icon, style: const TextStyle(fontSize: 34)),
                        const SizedBox(height: 6),
                        Text(m.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () async {
              final n = await askText(context, 'New mantra / name');
              if (n != null && n.isNotEmpty && !store.custom.contains(n)) {
                store.custom.add(n);
                store.save();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add your own mantra'),
          ),
        ]);
      },
    );
  }
}

class JapPage extends StatelessWidget {
  final M m;
  const JapPage({super.key, required this.m});

  void _tap(BuildContext context) {
    final n = store.tap(m.name);
    if (store.vib) HapticFeedback.lightImpact();
    if (store.snd) SystemSound.play(SystemSoundType.click);
    if (n == store.targetOf(m.name)) {
      HapticFeedback.heavyImpact();
      store.finish(m.name);
      showDialog(
        context: context,
        builder: (d) => AlertDialog(
          title: const Text('Jap Complete 🪷'),
          content: Text('Your ${m.name} jap target of $n is complete. 🙏'),
          actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('🙏 Continue'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final n = store.count(m.name), tg = store.targetOf(m.name);
        final inMala = n % 108;
        final filled = (n > 0 && inMala == 0) ? 108 : inMala;
        final cs = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: Text('${m.icon} ${m.name}'), actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset count',
              onPressed: () async {
                if (await ask(context, 'Reset your current count to 0?')) store.finish(m.name);
              },
            ),
          ]),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                if (m.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(m.text, textAlign: TextAlign.center, style: const TextStyle(height: 1.6)),
                  ),
                Wrap(spacing: 8, alignment: WrapAlignment.center, children: [
                  for (final v in presets)
                    ChoiceChip(
                      label: Text('$v'),
                      selected: tg == v,
                      onSelected: (_) {
                        store.target[m.name] = v;
                        store.save();
                      },
                    ),
                  ActionChip(
                    label: Text(presets.contains(tg) ? 'Custom' : 'Custom: $tg'),
                    onPressed: () async {
                      final t = await askText(context, 'Custom target', number: true);
                      final v = int.tryParse(t ?? '');
                      if (v != null && v > 0 && v <= 1000000) {
                        store.target[m.name] = v;
                        store.save();
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: MalaPainter(filled, cs.primary, cs.outlineVariant),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('$n', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
                        Text('of $tg  •  ${n ~/ 108} mala${n ~/ 108 == 1 ? '' : 's'}'),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _tap(context),
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary,
                      boxShadow: const [BoxShadow(blurRadius: 14, color: Colors.black26)],
                    ),
                    child: const Text('📿', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Tap to chant'),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class MalaPainter extends CustomPainter {
  final int filled;
  final Color on, off;
  MalaPainter(this.filled, this.on, this.off);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 16;
    for (var i = 0; i < 108; i++) {
      final a = -math.pi / 2 + 2 * math.pi * i / 108;
      final pos = c + Offset(math.cos(a), math.sin(a)) * r;
      final last = i == filled - 1;
      canvas.drawCircle(
        pos,
        last ? 7.0 : 3.8,
        Paint()..color = last ? const Color(0xFFFFB300) : (i < filled ? on : off),
      );
    }
  }

  @override
  bool shouldRepaint(MalaPainter o) => o.filled != filled || o.on != on || o.off != off;
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final s = store;
        final items = [
          ['🪷', '${s.grand}', 'Total Jap'],
          ['🗓️', '${s.activeDays.length}', 'Days Practiced'],
          ['🏆', '${s.best}', 'Best Day'],
          ['📿', '${s.grand ~/ 108}', 'Malas Completed'],
          ['🔥', '${s.streak}', 'Current Streak'],
          ['⭐', '${s.longest}', 'Longest Streak'],
        ];
        final now = DateTime.now();
        final week = [for (var i = 6; i >= 0; i--) DateTime(now.year, now.month, now.day - i)];
        final vals = week.map((d) => s.total(dkey(d))).toList();
        final mx = math.max(1, vals.fold<int>(0, (a, b) => math.max(a, b)));
        const dn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('Jap Statistics 📊',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              for (final it in items)
                Card(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(it[0], style: const TextStyle(fontSize: 22)),
                    Text(it[1], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(it[2], style: const TextStyle(fontSize: 12)),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Last 7 days', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Container(
                      height: 4 + 70 * vals[i] / mx,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(dn[week[i].weekday - 1], style: const TextStyle(fontSize: 11)),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('📜 Jap History', style: TextStyle(fontWeight: FontWeight.w600)),
          if (s.activeDays.isEmpty)
            const Padding(padding: EdgeInsets.all(12), child: Text('No jap yet. Begin today 🪷')),
          for (final k in s.activeDays.reversed.take(30))
            ListTile(
              dense: true,
              title: Text(k),
              trailing: Text('${s.total(k)} jap', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ]);
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => ListView(padding: const EdgeInsets.all(16), children: [
        Text('Settings ⚙️',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('🎨 Appearance'),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 1, label: Text('☀️ Light')),
            ButtonSegment(value: 2, label: Text('🌙 Dark')),
            ButtonSegment(value: 0, label: Text('📱 System')),
          ],
          selected: {store.theme},
          onSelectionChanged: (v) {
            store.theme = v.first;
            store.save();
          },
        ),
        SwitchListTile(
          title: const Text('📳 Vibration'),
          value: store.vib,
          onChanged: (v) {
            store.vib = v;
            store.save();
          },
        ),
        SwitchListTile(
          title: const Text('🔔 Bead sound'),
          value: store.snd,
          onChanged: (v) {
            store.snd = v;
            store.save();
          },
        ),
      ]),
    );
  }
}
