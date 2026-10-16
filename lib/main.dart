import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class M {
  final String name, icon, text, img;
  const M(this.name, this.icon, {this.text = '', this.img = ''});
}

const names = <M>[
  M('राधा राधा', '💐', img: 'radha2'),
  M('कृष्ण कृष्ण', '🦚', img: 'radha_krishna'),
  M('राम राम', '🏹'),
  M('हनुमान', '🚩'),
  M('महादेव', '🔱', img: 'shiv'),
  M('साम्ब सदाशिव', '🔱', img: 'shiv'),
  M('सीताराम', '🏹'),
  M('हर हर महादेव', '🔱', img: 'shiv'),
  M('हरे कृष्ण', '🪷', img: 'radha_krishna'),
  M('हरे राम', '🏹'),
  M('हरि', '🪷', img: 'vishnu'),
  M('नारायण', '🪷', img: 'vishnu'),
  M('परशुराम', '🪓'),
  M('शंकर', '🔱', img: 'shiv'),
  M('माँ सरस्वती', '🪕'),
  M('माँ भगवती', '🪔'),
  M('माँ खोडियार', '🪔', img: 'khodiyar_maa'),
  M('माँ दशा', '🪔', img: 'dasha_maa'),
  M('माँ आद्याशक्ति', '🪔'),
  M('माँ जगदम्बा', '🪔'),
  M('माँ दुर्गा', '🪔'),
  M('माँ कालका', '🪔'),
];

final mantras = <M>[
  M('ॐ गं गणपतये नमः', '🐘'),
  M('ॐ नमः शिवाय', '🔱'),
  M('श्री राम जय राम जय जय राम', '🏹'),
  M('ॐ नमो नारायणाय', '🪷'),
  M('हरे कृष्ण महामंत्र', '🪷', text: 'हरे कृष्ण हरे कृष्ण, कृष्ण कृष्ण हरे हरे।\nहरे राम हरे राम, राम राम हरे हरे॥'),
  M('कृष्ण मंत्र', '🦚', img: 'krishna_cow', text: 'ॐ कृष्णाय वासुदेवाय हरये परमात्मने।\nप्रणतः क्लेशनाशाय गोविंदाय नमो नमः॥'),
  M('महामृत्युंजय मंत्र', '🔱', img: 'mahamrityunjay', text: 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्।\nउर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय मामृतात्॥'),
  M('गायत्री मंत्र', '🪕', text: 'ॐ भूर्भुवः स्वः।\nतत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि।\nधियो यो नः प्रचोदयात्॥'),
  M('नृसिंह मंत्र', '🦁', text: 'ॐ उग्रं वीरं महाविष्णुं ज्वलन्तं सर्वतोमुखम्।\nनृसिंहं भीषणं भद्रं मृत्युमृत्युं नमाम्यहम्॥'),
  M('ॐ नमो भगवते वासुदेवाय', '🪷'),
  M('सरस्वती मंत्र', '🪕', img: 'saraswati', text: 'ॐ ऐं सरस्वत्यै नमः'),
] + moreMantras;

final moreMantras = [
  'हनुमते', 'दुर्गायै', 'श्रीं महालक्ष्म्यै', 'क्लीं कृष्णाय', 'राधायै', 'राधा कृष्णाय', 'गोविंदाय', 'गोपालाय',
  'माधवाय', 'केशवाय', 'विष्णवे', 'श्रीधराय', 'दामोदराय', 'वामनाय', 'नरसिंहाय', 'त्रिविक्रमाय', 'रुद्राय',
  'महादेवाय', 'शंकराय', 'भोलेनाथाय', 'सदाशिवाय', 'गंगाधराय', 'नीलकंठाय', 'कार्तिकेयाय', 'स्कन्दाय',
  'सूर्याय', 'आदित्याय', 'शनैश्चराय', 'भैरवाय', 'दत्तात्रेयाय', 'परशुरामाय', 'वेंकटेशाय', 'जगन्नाथाय',
  'अच्युताय', 'अनंताय', 'पुरुषोत्तमाय', 'नारायणाय', 'लक्ष्मी नारायणाय', 'सीतारामाय',
].map((x) => M('ॐ $x नमः', '📿')).toList() + const [M('राधे राधे', '💐'), M('जय श्री राम', '🏹')];

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

Widget tile(BuildContext context, M m, {bool del = false}) {
  final has = m.img.isNotEmpty;
  return Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JapPage(m: m))),
      onLongPress: del
          ? () async {
              if (await ask(context, 'Delete "${m.name}"? Your jap history stays.')) {
                store.custom.remove(m.name);
                store.save();
              }
            }
          : null,
      child: Stack(fit: StackFit.expand, children: [
        if (has) Image.asset('assets/images/${m.img}.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
        if (has)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(mainAxisAlignment: has ? MainAxisAlignment.end : MainAxisAlignment.center, children: [
            if (!has) Text(m.icon, style: const TextStyle(fontSize: 34)),
            if (!has) const SizedBox(height: 6),
            Text(m.name,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: has ? Colors.white : null)),
          ]),
        ),
      ]),
    ),
  );
}

Widget grid(BuildContext context, List<M> l, {bool del = false}) => GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [for (final m in l) tile(context, m, del: del)],
    );

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final today = store.total(dkey(DateTime.now()));
        final head = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
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
          const SizedBox(height: 12),
          Text('नाम जप', style: head),
          const SizedBox(height: 8),
          grid(context, names),
          const SizedBox(height: 18),
          Text('मंत्र जप', style: head),
          const SizedBox(height: 8),
          grid(context, mantras),
          if (store.custom.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('मेरे नाम', style: head),
            const SizedBox(height: 8),
            grid(context, [for (final n in store.custom) M(n, '🕉️')], del: true),
          ],
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

class JapPage extends StatefulWidget {
  final M m;
  const JapPage({super.key, required this.m});
  @override
  State<JapPage> createState() => _JapPageState();
}

class _JapPageState extends State<JapPage> with SingleTickerProviderStateMixin {
  late final AnimationController rain = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  M get m => widget.m;

  @override
  void dispose() {
    rain.dispose();
    super.dispose();
  }

  void _tap() {
    final n = store.tap(m.name);
    if (store.vib) HapticFeedback.lightImpact();
    if (store.snd) SystemSound.play(SystemSoundType.click);
    if (n == store.targetOf(m.name)) {
      HapticFeedback.heavyImpact();
      store.finish(m.name);
      rain.forward(from: 0);
      showDialog(
        context: context,
        builder: (d) => AlertDialog(
          title: const Text('Jap Complete 🪷'),
          content: Text('Your ${m.name} jap target of $n is complete. 🙏'),
          actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('🙏 Continue'))],
        ),
      );
    } else if (n % 108 == 0) {
      HapticFeedback.mediumImpact();
      rain.forward(from: 0);
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
        final size = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: const Color(0xFF2A1A0E),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            title: Text(m.name, style: const TextStyle(fontSize: 18)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset count',
                onPressed: () async {
                  if (await ask(context, 'Reset your current count to 0?')) store.finish(m.name);
                },
              ),
            ],
          ),
          body: Stack(fit: StackFit.expand, children: [
            if (m.img.isNotEmpty)
              Image.asset('assets/images/${m.img}.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8B4A16), Color(0xFF2A1A0E)]),
                ),
                alignment: Alignment.center,
                child: const Opacity(opacity: 0.12, child: Text('🪷', style: TextStyle(fontSize: 260))),
              ),
            Container(color: const Color(0x66000000)),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: Column(children: [
                    if (m.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(m.text, textAlign: TextAlign.center, style: const TextStyle(height: 1.6, fontSize: 16)),
                      ),
                    Wrap(spacing: 8, alignment: WrapAlignment.center, children: [
                      for (final v in presets)
                        ChoiceChip(
                          label: Text('$v'),
                          selected: tg == v,
                          selectedColor: cs.primary,
                          backgroundColor: const Color(0x66000000),
                          labelStyle: const TextStyle(color: Colors.white),
                          side: BorderSide.none,
                          showCheckmark: false,
                          onSelected: (_) {
                            store.target[m.name] = v;
                            store.save();
                          },
                        ),
                      ActionChip(
                        label: Text(presets.contains(tg) ? 'Custom' : 'Custom: $tg'),
                        backgroundColor: const Color(0x66000000),
                        labelStyle: const TextStyle(color: Colors.white),
                        side: BorderSide.none,
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
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: MalaPainter(filled),
                        child: Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const SizedBox(height: 24),
                            Text('$n',
                                style: const TextStyle(
                                    fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
                            Text('of $tg  •  ${n ~/ 108} mala${n ~/ 108 == 1 ? '' : 's'}'),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _tap,
                      child: Container(
                        width: 120,
                        height: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary,
                          boxShadow: const [BoxShadow(blurRadius: 16, color: Colors.black54)],
                        ),
                        child: const Text('📿', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to chant'),
                  ]),
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: rain,
                builder: (_, __) {
                  if (!rain.isAnimating) return const SizedBox.shrink();
                  return Stack(children: [
                    for (var i = 0; i < 16; i++)
                      Positioned(
                        left: (i * 67 % 330) / 330 * (size.width - 30),
                        top: -40 + (size.height + 80) * math.pow(((rain.value * 1.4) - i * 0.03).clamp(0.0, 1.0), 2).toDouble(),
                        child: Text('🪷', style: TextStyle(fontSize: 24.0 + (i % 3) * 8)),
                      ),
                  ]);
                },
              ),
            ),
          ]),
        );
      },
    );
  }
}

class MalaPainter extends CustomPainter {
  final int filled;
  MalaPainter(this.filled);

  void bead(Canvas c, Offset p, double r, Color col) {
    final shader = RadialGradient(
      center: const Alignment(-0.4, -0.4),
      colors: [Color.lerp(col, Colors.white, 0.55)!, col, Color.lerp(col, Colors.black, 0.5)!],
      stops: const [0, 0.45, 1],
    ).createShader(Rect.fromCircle(center: p, radius: r));
    c.d
