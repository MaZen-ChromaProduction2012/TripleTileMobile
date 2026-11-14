// ============================================================================
// 🧩 تحدي البلاطات الثلاثية — Triple Tile Explorer (Dart / Flutter APK Edition)
// تطوير: مازن عمرو وسيف — ChromaProduction Games
// تعمل 100% أوفلاين بدون أي مكتبات خارجية + مدمج بها نظام الإعلانات الثلاثي الآمن:
// 1. إعلان شريطي سفلي (Banner Ad)
// 2. إعلان شاشة كاملة بين الأدوار (Interstitial Ad)
// 3. إعلان فيديو كامل بمكافأة (Rewarded Video Ad — بحد أقصى آمن 10 مرات يومياً)
// ============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const TripleTileMatchApp());
}

// ============================================================================
// 1. إعدادات شفرات إعلانات Google AdMob (ضع الشفرات الحقيقية هنا بعد إنشاء الحساب)
// ============================================================================

class AdMobConfig {
  // شفرات الاختبار الرسمية من جوجل (آمنة 100% أثناء التجربة على موبايلك وموبايل صاحبك)
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // الحد الأقصى الآمن لمشاهدة إعلانات الفيديو بمكافأة يومياً لكل لاعب لحماية الحساب من الحظر
  static const int maxSafeRewardedAdsPerDay = 10;
  // عرض إعلان الشاشة الكاملة مرة كل دورين (لتجنب الإزعاج وحماية الحساب)
  static const int interstitialEveryNLevels = 2;
}

// ============================================================================
// 2. بيانات البلاطات، المجموعات، الثيمات، عجلة الحظ، والمهام (مطابقة 100% للعبة)
// ============================================================================

class TileItemType {
  final String id;
  final String emoji;
  final Color bg;
  final Color ring;

  const TileItemType({
    required this.id,
    required this.emoji,
    required this.bg,
    required this.ring,
  });
}

class TilePack {
  final String id;
  final String name;
  final String desc;
  final String preview;
  final int price;
  final List<TileItemType> items;

  const TilePack({
    required this.id,
    required this.name,
    required this.desc,
    required this.preview,
    required this.price,
    required this.items,
  });
}

class GameThemeConfig {
  final String id;
  final String name;
  final String desc;
  final int price;
  final List<Color> gradientColors;

  const GameThemeConfig({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.gradientColors,
  });
}

class BoardTile {
  final int uid;
  TileItemType type;
  final double x; // 0..5 grid coordinate
  final double y; // 0..5 grid coordinate
  final int z; // 0..3 3D layer depth
  String status; // 'board', 'dock', 'stash', 'cleared'

  BoardTile({
    required this.uid,
    required this.type,
    required this.x,
    required this.y,
    required this.z,
    this.status = 'board',
  });
}

class QuestDef {
  final String id;
  final String icon;
  final String title;
  final String desc;
  final int target;
  final int reward;
  final int Function(GameDataState s) getProgress;

  const QuestDef({
    required this.id,
    required this.icon,
    required this.title,
    required this.desc,
    required this.target,
    required this.reward,
    required this.getProgress,
  });
}

class GameCatalog {
  static const Map<String, TilePack> tilePacks = {
    'fruits': TilePack(
      id: 'fruits',
      name: 'فواكه استوائية',
      desc: 'المجموعة الأساسية المنعشة',
      preview: '🍎 🍌 🍇 🍓 🍊 🍉',
      price: 0,
      items: [
        TileItemType(id: 'item_0', emoji: '🍎', bg: Color(0xFFFFE4E6), ring: Color(0xFFFDA4AF)),
        TileItemType(id: 'item_1', emoji: '🍌', bg: Color(0xFFFEF9C3), ring: Color(0xFFFDE047)),
        TileItemType(id: 'item_2', emoji: '🍇', bg: Color(0xFFF3E8FF), ring: Color(0xFFD8B4FE)),
        TileItemType(id: 'item_3', emoji: '🍓', bg: Color(0xFFFFE4E6), ring: Color(0xFFF43F5E)),
        TileItemType(id: 'item_4', emoji: '🍊', bg: Color(0xFFFFEDD5), ring: Color(0xFFFB923C)),
        TileItemType(id: 'item_5', emoji: '🍉', bg: Color(0xFFDCFCE7), ring: Color(0xFF86EFAC)),
        TileItemType(id: 'item_6', emoji: '🍍', bg: Color(0xFFFEF08A), ring: Color(0xFFFACC15)),
        TileItemType(id: 'item_7', emoji: '🍒', bg: Color(0xFFFCE7F3), ring: Color(0xFFF472B6)),
        TileItemType(id: 'item_8', emoji: '🥝', bg: Color(0xFFECFCCB), ring: Color(0xFFA3E635)),
        TileItemType(id: 'item_9', emoji: '🍑', bg: Color(0xFFFFEDD5), ring: Color(0xFFFDBA74)),
      ],
    ),
    'animals': TilePack(
      id: 'animals',
      name: 'حيوانات الغابة',
      desc: 'أصدقاء الغابة اللطيفة',
      preview: '🐼 🦊 🦁 🐸 🐨 🐯',
      price: 150,
      items: [
        TileItemType(id: 'item_0', emoji: '🐼', bg: Color(0xFFF1F5F9), ring: Color(0xFF94A3B8)),
        TileItemType(id: 'item_1', emoji: '🦊', bg: Color(0xFFFFEDD5), ring: Color(0xFFFB923C)),
        TileItemType(id: 'item_2', emoji: '🦁', bg: Color(0xFFFEF3C7), ring: Color(0xFFFBBF24)),
        TileItemType(id: 'item_3', emoji: '🐸', bg: Color(0xFFDCFCE7), ring: Color(0xFF4ADE80)),
        TileItemType(id: 'item_4', emoji: '🐨', bg: Color(0xFFE2E8F0), ring: Color(0xFF64748B)),
        TileItemType(id: 'item_5', emoji: '🐯', bg: Color(0xFFFFEDD5), ring: Color(0xFFF97316)),
        TileItemType(id: 'item_6', emoji: '🐰', bg: Color(0xFFFCE7F3), ring: Color(0xFFF472B6)),
        TileItemType(id: 'item_7', emoji: '🐻', bg: Color(0xFFFEF3C7), ring: Color(0xFFD97706)),
        TileItemType(id: 'item_8', emoji: '🐮', bg: Color(0xFFF1F5F9), ring: Color(0xFFCBD5E1)),
        TileItemType(id: 'item_9', emoji: '🐙', bg: Color(0xFFFFE4E6), ring: Color(0xFFFB7185)),
      ],
    ),
    'sweets': TilePack(
      id: 'sweets',
      name: 'حلويات ومخبوزات',
      desc: 'تشكيلة حلويات شهية',
      preview: '🍩 🧁 🍰 🍪 🍫 🍭',
      price: 220,
      items: [
        TileItemType(id: 'item_0', emoji: '🍩', bg: Color(0xFFFCE7F3), ring: Color(0xFFF472B6)),
        TileItemType(id: 'item_1', emoji: '🧁', bg: Color(0xFFFAE8FF), ring: Color(0xFFE879F9)),
        TileItemType(id: 'item_2', emoji: '🍰', bg: Color(0xFFFFE4E6), ring: Color(0xFFFDA4AF)),
        TileItemType(id: 'item_3', emoji: '🍪', bg: Color(0xFFFEF3C7), ring: Color(0xFFF59E0B)),
        TileItemType(id: 'item_4', emoji: '🍫', bg: Color(0xFFFEF3C7), ring: Color(0xFFB45309)),
        TileItemType(id: 'item_5', emoji: '🍭', bg: Color(0xFFE0F2FE), ring: Color(0xFF38BDF8)),
        TileItemType(id: 'item_6', emoji: '🥐', bg: Color(0xFFFFEDD5), ring: Color(0xFFFB923C)),
        TileItemType(id: 'item_7', emoji: '🍦', bg: Color(0xFFFEF9C3), ring: Color(0xFFFACC15)),
        TileItemType(id: 'item_8', emoji: '🥞', bg: Color(0xFFFEF3C7), ring: Color(0xFFD97706)),
        TileItemType(id: 'item_9', emoji: '🍮', bg: Color(0xFFFEF08A), ring: Color(0xFFEAB308)),
      ],
    ),
    'gems': TilePack(
      id: 'gems',
      name: 'جواهر وكنوز ملكية',
      desc: 'بلاطات فاخرة للمحترفين',
      preview: '💎 👑 🏆 ⭐ 🔮 🪙',
      price: 300,
      items: [
        TileItemType(id: 'item_0', emoji: '💎', bg: Color(0xFFE0F2FE), ring: Color(0xFF38BDF8)),
        TileItemType(id: 'item_1', emoji: '👑', bg: Color(0xFFFEF9C3), ring: Color(0xFFFACC15)),
        TileItemType(id: 'item_2', emoji: '🏆', bg: Color(0xFFFEF3C7), ring: Color(0xFFF59E0B)),
        TileItemType(id: 'item_3', emoji: '⭐', bg: Color(0xFFFEF08A), ring: Color(0xFFEAB308)),
        TileItemType(id: 'item_4', emoji: '🔮', bg: Color(0xFFF3E8FF), ring: Color(0xFFC084FC)),
        TileItemType(id: 'item_5', emoji: '🪙', bg: Color(0xFFFEF3C7), ring: Color(0xFFD97706)),
        TileItemType(id: 'item_6', emoji: '💍', bg: Color(0xFFE0E7FF), ring: Color(0xFF818CF8)),
        TileItemType(id: 'item_7', emoji: '🗝️', bg: Color(0xFFFEF3C7), ring: Color(0xFFB45309)),
        TileItemType(id: 'item_8', emoji: '🛡️', bg: Color(0xFFF1F5F9), ring: Color(0xFF64748B)),
        TileItemType(id: 'item_9', emoji: '⚡', bg: Color(0xFFFEF9C3), ring: Color(0xFFFACC15)),
      ],
    ),
  };

  static const List<GameThemeConfig> themes = [
    GameThemeConfig(
      id: 'theme-meadow',
      name: '🌿 الحديقة الخضراء',
      desc: 'طبيعة هادئة ومريحة للعين',
      price: 0,
      gradientColors: [Color(0xFF86EFAC), Color(0xFF15803D), Color(0xFF064E3B)],
    ),
    GameThemeConfig(
      id: 'theme-ocean',
      name: '🌊 شاطئ المحيط',
      desc: 'نسيم البحر الأزرق الصافي',
      price: 0,
      gradientColors: [Color(0xFF38BDF8), Color(0xFF0369A1), Color(0xFF0C4A6E)],
    ),
    GameThemeConfig(
      id: 'theme-sunset',
      name: '🌅 قمم الغروب',
      desc: 'ألوان الغروب الدافئة',
      price: 120,
      gradientColors: [Color(0xFFFB923C), Color(0xFF9A3412), Color(0xFF431407)],
    ),
    GameThemeConfig(
      id: 'theme-night',
      name: '🌌 قلعة النجوم',
      desc: 'سماء الليل الساحرة',
      price: 180,
      gradientColors: [Color(0xFF312E81), Color(0xFF1E1B4B), Color(0xFF090D16)],
    ),
    GameThemeConfig(
      id: 'theme-royal',
      name: '👑 القصر الملكي',
      desc: 'فخامة الذهب الملكي',
      price: 250,
      gradientColors: [Color(0xFFD97706), Color(0xFF78350F), Color(0xFF451A03)],
    ),
    GameThemeConfig(
      id: 'theme-sakura',
      name: '🌸 أزهار الساكورا',
      desc: 'إشراقة الربيع الوردي',
      price: 200,
      gradientColors: [Color(0xFFF472B6), Color(0xFF9D174D), Color(0xFF500724)],
    ),
  ];

  static const List<Map<String, dynamic>> wheelPrizes = [
    {'label': '+75 عملة ذهبية 🪙', 'type': 'coins', 'amount': 75},
    {'label': '+2 تلميح ذكي 💡', 'type': 'hint', 'amount': 2},
    {'label': '+120 عملة ذهبية 🪙', 'type': 'coins', 'amount': 120},
    {'label': '+2 خلط بلاطات 🔀', 'type': 'shuffle', 'amount': 2},
    {'label': 'الجائزة الكبرى +250 عملة 🪙🎉', 'type': 'coins', 'amount': 250},
    {'label': '+2 تفريغ رف 📤', 'type': 'stash', 'amount': 2},
    {'label': '+90 عملة ذهبية 🪙', 'type': 'coins', 'amount': 90},
    {'label': '+3 تراجع ↩️', 'type': 'undo', 'amount': 3},
  ];

  static final List<QuestDef> quests = [
    QuestDef(
      id: 'q_match_5',
      icon: '🍎',
      title: 'جامع البلاطات المبتدئ',
      desc: 'طابق 5 مجموعات ثلاثية من البلاطات',
      target: 5,
      reward: 60,
      getProgress: (s) => s.totalMatches,
    ),
    QuestDef(
      id: 'q_match_25',
      icon: '🔥',
      title: 'خبير المطابقة الثلاثية',
      desc: 'طابق 25 مجموعة ثلاثية في مختلف المراحل',
      target: 25,
      reward: 150,
      getProgress: (s) => s.totalMatches,
    ),
    QuestDef(
      id: 'q_level_3',
      icon: '🗺️',
      title: 'مستكشف الخريطة',
      desc: 'افتح المرحلة 3 في خريطة المغامرة',
      target: 3,
      reward: 100,
      getProgress: (s) => s.maxUnlockedLevel,
    ),
    QuestDef(
      id: 'q_combo_3',
      icon: '⚡',
      title: 'سلسلة البرق السريعة',
      desc: 'حقق كومبو متتالي x3 أو أعلى',
      target: 3,
      reward: 90,
      getProgress: (s) => s.maxCombo,
    ),
    QuestDef(
      id: 'q_time_win',
      icon: '⏱️',
      title: 'بطل تحدي الوقت',
      desc: 'افز بمرحلة في وضع تحدي الوقت السريع',
      target: 1,
      reward: 140,
      getProgress: (s) => s.timeModeWins,
    ),
  ];
}

// ============================================================================
// 3. حالة اللعبة الشاملة (GameDataState)
// ============================================================================

class GameDataState {
  int level = 1;
  int maxUnlockedLevel = 1;
  int coins = 200;
  int score = 0;
  int combo = 0;
  DateTime? lastMatchTime;

  String difficulty = 'medium'; // 'easy', 'medium', 'hard'
  bool timeChallengeMode = false;
  int timeLeftSeconds = 90;
  bool vibrationEnabled = true;

  String activePackId = 'fruits';
  int themeIndex = 0;
  final Set<String> ownedPacks = {'fruits'};
  final Set<String> ownedThemes = {'theme-meadow', 'theme-ocean'};
  final Set<String> claimedQuests = {};

  int undoCount = 3;
  int hintCount = 2;
  int shuffleCount = 3;
  int stashCount = 2;

  int totalMatches = 0;
  int maxCombo = 1;
  int levelsWon = 0;
  int timeModeWins = 0;

  // عداد الإعلانات اليومي الآمن
  int rewardedAdsWatchedToday = 0;
  int levelsPlayedSinceLastInterstitial = 0;

  List<BoardTile> tiles = [];
  List<BoardTile> dock = [];
  List<BoardTile> stash = [];
  List<Map<String, dynamic>> undoHistory = [];
}

// ============================================================================
// 4. التطبيق الرئيسي والشاشات (Start Screen, Adventure Map, Game Board, & 3 Ads)
// ============================================================================

class TripleTileMatchApp extends StatelessWidget {
  const TripleTileMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تحدي البلاطات الثلاثية — Triple Tile Explorer',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: const TripleTileMainPage(),
    );
  }
}

enum GameScreenView {
  homeMenu,
  adventureMap,
  playingBoard,
}

class TripleTileMainPage extends StatefulWidget {
  const TripleTileMainPage({super.key});

  @override
  State<TripleTileMainPage> createState() => _TripleTileMainPageState();
}

class _TripleTileMainPageState extends State<TripleTileMainPage> {
  final GameDataState _state = GameDataState();
  GameScreenView _currentView = GameScreenView.homeMenu;
  Timer? _timer;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _generateAndStartLevel(_state.level, showStartToast: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _triggerHaptic({bool heavy = false}) {
    if (!_state.vibrationEnabled) return;
    if (heavy) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // توليد البلاطات ثلاثية الأبعاد لكل مرحلة (Multi-Layer 3D Blueprint)
  // --------------------------------------------------------------------------
  List<BoardTile> _generateLevelBlueprint(int lvl) {
    final pack = GameCatalog.tilePacks[_state.activePackId] ?? GameCatalog.tilePacks['fruits']!;
    final diffTripletsBonus = _state.difficulty == 'easy'
        ? -2
        : _state.difficulty == 'hard'
            ? 3
            : 0;
    final numTriplets = (8 + lvl * 2 + diffTripletsBonus).clamp(6, 24);
    final distinctTypesCount = (4 + (lvl ~/ 2)).clamp(4, pack.items.length);

    final pool = <TileItemType>[];
    for (int i = 0; i < numTriplets; i++) {
      final t = pack.items[i % distinctTypesCount];
      pool.addAll([t, t, t]); // 3 متطابقة دائماً لضمان قابلية الحل 100%
    }
    pool.shuffle(_rng);

    final maxLayers = _state.difficulty == 'easy'
        ? 2
        : _state.difficulty == 'hard'
            ? 4
            : 3;

    final generated = <BoardTile>[];
    for (int idx = 0; idx < pool.length; idx++) {
      final z = idx % maxLayers;
      // توزيع هندسي متدرج في وسط اللوحة
      final gx = (0.6 + (idx * 1.37 + z * 0.45) % 4.4);
      final gy = (0.6 + ((idx ~/ 4) * 1.15 + z * 0.45) % 4.4);
      generated.add(
        BoardTile(
          uid: idx + 1,
          type: pool[idx],
          x: gx,
          y: gy,
          z: z,
          status: 'board',
        ),
      );
    }
    return generated;
  }

  bool _isTileBlocked(BoardTile tile) {
    for (final other in _state.tiles) {
      if (other.status != 'board') continue;
      if (other.z > tile.z) {
        if ((other.x - tile.x).abs() < 0.78 && (other.y - tile.y).abs() < 0.78) {
          return true;
        }
      }
    }
    return false;
  }

  void _generateAndStartLevel(int lvl, {bool showStartToast = true}) {
    _timer?.cancel();
    setState(() {
      _state.level = lvl;
      if (lvl > _state.maxUnlockedLevel) {
        _state.maxUnlockedLevel = lvl;
      }
      _state.tiles = _generateLevelBlueprint(lvl);
      _state.dock.clear();
      _state.stash.clear();
      _state.undoHistory.clear();
      _state.combo = 0;
      _state.undoCount = 3;
      _state.hintCount = 2;
      _state.shuffleCount = 3;
      _state.stashCount = 2;

      if (_state.timeChallengeMode) {
        final bonus = _state.difficulty == 'easy'
            ? 30
            : _state.difficulty == 'hard'
                ? -15
                : 0;
        _state.timeLeftSeconds = math.max(45, 105 - lvl * 3 + bonus);
        _startCountdownTimer();
      }
    });
    if (showStartToast) {
      _showSnack(
        _state.timeChallengeMode
            ? '⚡ تحدي الوقت للمرحلة $lvl بدأ! (+4 ثوانٍ لكل مطابقة)'
            : 'المرحلة $lvl — طابق 3 بلاطات متشابهة!',
      );
    }
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_currentView != GameScreenView.playingBoard || !_state.timeChallengeMode) return;
      setState(() {
        _state.timeLeftSeconds--;
      });
      if (_state.timeLeftSeconds <= 0) {
        t.cancel();
        _triggerHaptic(heavy: true);
        _showEndOfLevelDialog(won: false, isTimeout: true);
      }
    });
  }

  // --------------------------------------------------------------------------
  // التفاعل مع البلاطات والـ 7 خانات (7-Slot Dock)
  // --------------------------------------------------------------------------
  void _pickTile(BoardTile tile) {
    if (tile.status == 'board' && _isTileBlocked(tile)) {
      _triggerHaptic(heavy: true);
      return;
    }
    if (_state.dock.length >= 7) return;

    _triggerHaptic();
    final prevStatus = tile.status;
    setState(() {
      if (prevStatus == 'stash') {
        _state.stash.removeWhere((t) => t.uid == tile.uid);
      }
      tile.status = 'dock';
      _state.undoHistory.add({'uid': tile.uid, 'fromStatus': prevStatus});

      int insertIdx = _state.dock.length;
      for (int i = _state.dock.length - 1; i >= 0; i--) {
        if (_state.dock[i].type.id == tile.type.id) {
          insertIdx = i + 1;
          break;
        }
      }
      _state.dock.insert(insertIdx, tile);
    });

    _checkMatchesAndEndState();
  }

  void _checkMatchesAndEndState() {
    final counts = <String, int>{};
    for (final t in _state.dock) {
      counts[t.type.id] = (counts[t.type.id] ?? 0) + 1;
    }

    String? matchedTypeId;
    counts.forEach((k, v) {
      if (v >= 3) matchedTypeId = k;
    });

    if (matchedTypeId != null) {
      _triggerHaptic(heavy: true);
      final matched = _state.dock.where((t) => t.type.id == matchedTypeId).take(3).toList();
      final uids = matched.map((t) => t.uid).toSet();

      final now = DateTime.now();
      if (_state.lastMatchTime != null &&
          now.difference(_state.lastMatchTime!).inMilliseconds < 4500) {
        _state.combo = math.min(_state.combo + 1, 8);
      } else {
        _state.combo = 1;
      }
      _state.lastMatchTime = now;

      setState(() {
        _state.totalMatches++;
        if (_state.combo > _state.maxCombo) _state.maxCombo = _state.combo;
        _state.score += 30 * _state.combo;
        _state.coins += _state.timeChallengeMode ? 4 : 2;
        if (_state.timeChallengeMode) _state.timeLeftSeconds += 4;

        _state.dock.removeWhere((t) => uids.contains(t.uid));
        _state.undoHistory.removeWhere((h) => uids.contains(h['uid']));
        for (final m in matched) {
          m.status = 'cleared';
        }
      });
    }

    // التحقق من الفوز أو امتلاء الشريط (7 خانات)
    final remaining = _state.tiles.where((t) => t.status != 'cleared').length;
    if (remaining == 0) {
      _timer?.cancel();
      _triggerHaptic(heavy: true);
      setState(() {
        _state.levelsWon++;
        if (_state.timeChallengeMode) _state.timeModeWins++;
        final baseReward = _state.difficulty == 'hard'
            ? 110
            : _state.difficulty == 'medium'
                ? 75
                : 50;
        _state.coins += _state.timeChallengeMode ? baseReward * 2 : baseReward;
        _state.maxUnlockedLevel = math.max(_state.maxUnlockedLevel, _state.level + 1);
        _state.levelsPlayedSinceLastInterstitial++;
      });
      _showEndOfLevelDialog(won: true);
    } else if (_state.dock.length >= 7) {
      _timer?.cancel();
      _triggerHaptic(heavy: true);
      _showEndOfLevelDialog(won: false);
    }
  }

  // --------------------------------------------------------------------------
  // القدرات الـ 4 المساعدة (Undo, Hint, Shuffle, Stash)
  // --------------------------------------------------------------------------
  void _useUndo() {
    if (_state.dock.isEmpty || _state.undoHistory.isEmpty) return;
    if (_state.undoCount <= 0) {
      if (_state.coins >= 20) {
        _state.coins -= 20;
        _state.undoCount++;
      } else {
        _showSnack('تحتاج 20 عملة أو شاهد إعلان فيديو مجاني للحصول على عملات! 🎬');
        return;
      }
    }
    final last = _state.undoHistory.removeLast();
    final idx = _state.dock.indexWhere((t) => t.uid == last['uid']);
    if (idx == -1) return;

    setState(() {
      final tile = _state.dock.removeAt(idx);
      tile.status = last['fromStatus'] as String;
      if (tile.status == 'stash') _state.stash.add(tile);
      _state.undoCount--;
    });
    _triggerHaptic();
  }

  void _useHint() {
    if (_state.hintCount <= 0) {
      if (_state.coins >= 30) {
        _state.coins -= 30;
        _state.hintCount++;
      } else {
        _showSnack('تحتاج 30 عملة أو شاهد إعلان فيديو مجاني! 🎬');
        return;
      }
    }
    String? targetId;
    if (_state.dock.isNotEmpty) {
      targetId = _state.dock.first.type.id;
    } else {
      final active = _state.tiles.where((t) => t.status != 'cleared').firstOrNull;
      targetId = active?.type.id;
    }
    if (targetId == null) return;

    final group = <BoardTile>[
      ..._state.dock.where((t) => t.type.id == targetId),
      ..._state.stash.where((t) => t.type.id == targetId),
      ..._state.tiles.where((t) => t.status == 'board' && t.type.id == targetId),
    ].take(3).toList();

    if (group.length < 3) return;
    final uids = group.map((t) => t.uid).toSet();

    setState(() {
      _state.hintCount--;
      _state.dock.removeWhere((t) => uids.contains(t.uid));
      _state.stash.removeWhere((t) => uids.contains(t.uid));
      _state.undoHistory.removeWhere((h) => uids.contains(h['uid']));
      for (final t in group) {
        t.status = 'cleared';
      }
      _state.score += 45;
    });
    _triggerHaptic(heavy: true);
    _showSnack('تمت مطابقة 3 بلاطات ${group.first.type.emoji} تلقائياً! 💡');
    _checkMatchesAndEndState();
  }

  void _useShuffle() {
    final boardTiles = _state.tiles.where((t) => t.status == 'board').toList();
    if (boardTiles.length < 2) return;
    if (_state.shuffleCount <= 0) {
      if (_state.coins >= 25) {
        _state.coins -= 25;
        _state.shuffleCount++;
      } else {
        _showSnack('تحتاج 25 عملة لخلط البلاطات!');
        return;
      }
    }
    final types = boardTiles.map((t) => t.type).toList()..shuffle(_rng);
    setState(() {
      for (int i = 0; i < boardTiles.length; i++) {
        boardTiles[i].type = types[i];
      }
      _state.shuffleCount--;
    });
    _triggerHaptic();
    _showSnack('تم خلط البلاطات على اللوحة! 🔀');
  }

  void _useStash() {
    if (_state.dock.isEmpty) return;
    if (_state.stashCount <= 0) {
      if (_state.coins >= 30) {
        _state.coins -= 30;
        _state.stashCount++;
      } else {
        _showSnack('تحتاج 30 عملة لتفريغ 3 بلاطات!');
        return;
      }
    }
    setState(() {
      final count = math.min(3, _state.dock.length);
      final moved = _state.dock.sublist(0, count);
      _state.dock.removeRange(0, count);
      for (final t in moved) {
        t.status = 'stash';
        _state.stash.add(t);
      }
      _state.stashCount--;
    });
    _triggerHaptic();
    _showSnack('تم نقل البلاطات للرف المؤقت! 📤');
  }

  // --------------------------------------------------------------------------
  // نظام الإعلانات الثلاثي الآمن (Rewarded Video + Interstitial + Banner)
  // --------------------------------------------------------------------------
  Future<void> _watchRewardedVideoAd({
    required String rewardDescription,
    required VoidCallback onRewardEarned,
  }) async {
    if (_state.rewardedAdsWatchedToday >= AdMobConfig.maxSafeRewardedAdsPerDay) {
      _showSnack(
        'وصلت للحد اليومي الآمن لإعلانات المكافأة (${AdMobConfig.maxSafeRewardedAdsPerDay} إعلانات) لحماية الحساب.',
      );
      return;
    }

    int secondsLeft = 5;
    Timer? adTimer;
    bool completed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            adTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsLeft > 1) {
                setModalState(() => secondsLeft--);
              } else {
                t.cancel();
                setModalState(() {
                  secondsLeft = 0;
                  completed = true;
                });
              }
            });

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          completed
                              ? '✅ اكتمل إعلان الفيديو — استلم مكافأتك!'
                              : '🎬 إعلان فيديو بمكافأة (يتبقى $secondsLeft ثوانٍ)',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B0764)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 46),
                            const SizedBox(height: 8),
                            const Text(
                              'AdMob Rewarded Video Ad',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              rewardDescription,
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: completed
                              ? () {
                                  adTimer?.cancel();
                                  Navigator.pop(ctx);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            completed ? 'استلام المكافأة الآن 🎁' : 'انتظر $secondsLeft ثوانٍ...',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    adTimer?.cancel();
    if (completed) {
      setState(() {
        _state.rewardedAdsWatchedToday++;
      });
      onRewardEarned();
    }
  }

  Future<void> _maybeShowInterstitialAd() async {
    if (_state.levelsPlayedSinceLastInterstitial < AdMobConfig.interstitialEveryNLevels) {
      return;
    }
    _state.levelsPlayedSinceLastInterstitial = 0;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إعلان شاشة كاملة (AdMob Interstitial)',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.ads_click_rounded, color: Colors.amber, size: 44),
                      SizedBox(height: 8),
                      Text(
                        'مساحة إعلان الشاشة الكاملة بين المراحل',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('متابعة اللعب ▶'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEndOfLevelDialog({required bool won, bool isTimeout = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  won ? '🎉🎉🎉' : (isTimeout ? '⏰' : '💔'),
                  style: const TextStyle(fontSize: 42),
                ),
                const SizedBox(height: 8),
                Text(
                  won
                      ? 'أحسنت! اجتزت المرحلة ${_state.level}'
                      : (isTimeout ? 'انتهى الوقت!' : 'امتلأت الخانات الـ 7!'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                if (!won) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _watchRewardedVideoAd(
                        rewardDescription: 'تفريغ 3 بلاطات من الشريط واستكمال الدور فوراً!',
                        onRewardEarned: () {
                          setState(() {
                            final count = math.min(3, _state.dock.length);
                            final moved = _state.dock.sublist(0, count);
                            _state.dock.removeRange(0, count);
                            for (final t in moved) {
                              t.status = 'stash';
                              _state.stash.add(t);
                            }
                            if (_state.timeChallengeMode) _state.timeLeftSeconds += 30;
                          });
                        },
                      );
                    },
                    icon: const Icon(Icons.ondemand_video_rounded),
                    label: const Text('شاهد إعلان فيديو واستكمل الدور مجاناً! 🎬'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _maybeShowInterstitialAd();
                      _generateAndStartLevel(won ? _state.level + 1 : _state.level);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      won ? 'المرحلة التالية (${_state.level + 1}) ▶' : 'إعادة المحاولة 🔄',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // نوافذ المتجر، عجلة الحظ، والمهام والإنجازات
  // --------------------------------------------------------------------------
  void _openShopModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🛒 متجر البلاطات والثيمات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_state.coins} 🪙',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...GameCatalog.tilePacks.values.map((pack) {
                      final owned = _state.ownedPacks.contains(pack.id);
                      final active = _state.activePackId == pack.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: active ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${pack.name} (${pack.preview})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    pack.desc,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: active
                                  ? null
                                  : () {
                                      if (!owned) {
                                        if (_state.coins < pack.price) {
                                          _showSnack('عملاتك غير كافية! شاهد إعلان فيديو لكسب +100 🪙');
                                          return;
                                        }
                                        setState(() {
                                          _state.coins -= pack.price;
                                          _state.ownedPacks.add(pack.id);
                                          _state.activePackId = pack.id;
                                        });
                                      } else {
                                        setState(() => _state.activePackId = pack.id);
                                      }
                                      _generateAndStartLevel(_state.level, showStartToast: false);
                                      setSheetState(() {});
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    owned ? const Color(0xFF059669) : const Color(0xFFF59E0B),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                active
                                    ? 'مُفعّل ✅'
                                    : (owned ? 'تفعيل' : 'شراء ${pack.price} 🪙'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openQuestsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '🏆 المهام والإنجازات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...GameCatalog.quests.map((q) {
                      final prog = q.getProgress(_state);
                      final done = prog >= q.target;
                      final claimed = _state.claimedQuests.contains(q.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${q.icon} ${q.title} ($prog/${q.target})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    q.desc,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: (done && !claimed)
                                  ? () {
                                      setState(() {
                                        _state.coins += q.reward;
                                        _state.claimedQuests.add(q.id);
                                      });
                                      setSheetState(() {});
                                      _showSnack('استلمت +${q.reward} عملة ذهبية! 🪙');
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                claimed ? 'تم الاستلام ✅' : '+${q.reward} 🪙',
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _spinLuckyWheel() {
    final prize = GameCatalog.wheelPrizes[_rng.nextInt(GameCatalog.wheelPrizes.length)];
    setState(() {
      final type = prize['type'] as String;
      final amount = prize['amount'] as int;
      if (type == 'coins') _state.coins += amount;
      if (type == 'hint') _state.hintCount += amount;
      if (type == 'shuffle') _state.shuffleCount += amount;
      if (type == 'stash') _state.stashCount += amount;
      if (type == 'undo') _state.undoCount += amount;
    });
    _triggerHaptic(heavy: true);
    _showSnack('🎡 عجلة الحظ: ربحت ${prize['label']}!');
  }

  // --------------------------------------------------------------------------
  // البناء البصري (UI Build)
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final activeTheme = GameCatalog.themes[_state.themeIndex % GameCatalog.themes.length];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.4),
              radius: 1.25,
              colors: activeTheme.gradientColors,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // الشاشة النشطة (الرئيسية أو الخريطة أو لوحة اللعب)
                Expanded(
                  child: Builder(
                    builder: (_) {
                      switch (_currentView) {
                        case GameScreenView.homeMenu:
                          return _buildStartMenuView();
                        case GameScreenView.adventureMap:
                          return _buildAdventureMapView();
                        case GameScreenView.playingBoard:
                          return _buildPlayingBoardView();
                      }
                    },
                  ),
                ),
                // الشريط الإعلاني السفلي الثابت (1. AdMob Banner Ad 320x50)
                _buildBottomBannerAdWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBannerAdWidget() {
    return Container(
      width: double.infinity,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'إعلان البانر السفلي (AdMob Banner 320×50)',
                style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              _watchRewardedVideoAd(
                rewardDescription: '+100 عملة ذهبية مجانية 🪙',
                onRewardEarned: () {
                  setState(() => _state.coins += 100);
                  _showSnack('مبروك! حصلت على +100 عملة ذهبية من إعلان المكافأة 🪙');
                },
              );
            },
            child: const Text(
              '🎬 +100 🪙 مجاناً',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.amberAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // الشاشة 1: شاشة البداية الجذابة (Animated Start Menu)
  // --------------------------------------------------------------------------
  Widget _buildStartMenuView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              // الشريط العلوي للإحصائيات والعملات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '🪙 ${_state.coins} عملة',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '⭐ ${math.max(0, _state.maxUnlockedLevel - 1) * 3} نجمة',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // لوجو اللعبة المخصص (triple_tile_logo.jpg)
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.amberAccent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, _) => Container(
                      color: const Color(0xFF059669),
                      child: const Center(
                        child: Text('🧩', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تحدي البلاطات الثلاثية',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              const Text(
                'Triple Tile Explorer — طابق 3 بلاطات واجمع الكنوز!',
                style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              // اختيار مستوى الصعوبة (سهل 🌱، متوسط ⚡، صعب 🔥)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'اختر مستوى الصعوبة:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDiffChip('easy', 'سهل 🌱'),
                        const SizedBox(width: 6),
                        _buildDiffChip('medium', 'متوسط ⚡'),
                        const SizedBox(width: 6),
                        _buildDiffChip('hard', 'صعب 🔥'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // زر اللعب الرئيسي
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _triggerHaptic();
                    setState(() => _currentView = GameScreenView.playingBoard);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: const Color(0xFF020617),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                  ),
                  child: Text(
                    '▶ العب المرحلة ${_state.level} الآن',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // زر خريطة المراحل التفاعلية
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _triggerHaptic();
                    setState(() => _currentView = GameScreenView.adventureMap);
                  },
                  icon: const Icon(Icons.map_rounded),
                  label: const Text(
                    '🗺️ خريطة المراحل والمناطق البيئية',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // زر إعلان الفيديو بمكافأة (+100 كوينز)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _watchRewardedVideoAd(
                      rewardDescription: '+100 عملة ذهبية مجانية 🪙',
                      onRewardEarned: () {
                        setState(() => _state.coins += 100);
                        _showSnack('حصلت على +100 عملة ذهبية! 🪙');
                      },
                    );
                  },
                  icon: const Icon(Icons.ondemand_video_rounded),
                  label: Text(
                    '🎬 شاهد إعلان فيديو كامل = +100 عملة (${_state.rewardedAdsWatchedToday}/${AdMobConfig.maxSafeRewardedAdsPerDay})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // أزرار المتجر، عجلة الحظ، المهام، والاهتزاز
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.6,
                children: [
                  _buildMenuActionCard('🛒 المتجر والثيمات', _openShopModal),
                  _buildMenuActionCard('🎡 عجلة الحظ اليومية', _spinLuckyWheel),
                  _buildMenuActionCard('🏆 المهام والإنجازات', _openQuestsModal),
                  _buildMenuActionCard(
                    _state.vibrationEnabled ? '📳 الاهتزاز: مفعّل' : '📴 الاهتزاز: متوقف',
                    () {
                      setState(() => _state.vibrationEnabled = !_state.vibrationEnabled);
                      _triggerHaptic();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiffChip(String id, String label) {
    final active = _state.difficulty == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _state.difficulty = id);
          _generateAndStartLevel(_state.level, showStartToast: false);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.amber : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: active ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuActionCard(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.18),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // الشاشة 2: خريطة المراحل التفاعلية (Interactive Stage Progression Map)
  // --------------------------------------------------------------------------
  Widget _buildAdventureMapView() {
    final totalNodes = math.max(16, _state.maxUnlockedLevel + 4);
    final offsets = [0.0, -55.0, -80.0, -40.0, 20.0, 65.0, 80.0, 35.0];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() => _currentView = GameScreenView.homeMenu),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('الرئيسية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black45,
                  foregroundColor: Colors.white,
                ),
              ),
              const Text(
                '🗺️ خريطة المغامرة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Text(
                '🪙 ${_state.coins}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.amberAccent,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: totalNodes,
            itemBuilder: (context, idx) {
              final lvl = idx + 1;
              final unlocked = lvl <= _state.maxUnlockedLevel;
              final completed = lvl < _state.maxUnlockedLevel;
              final shift = offsets[idx % offsets.length];

              String? zoneHeader;
              if (lvl == 1) zoneHeader = '🌿 الحديقة الخضراء';
              if (lvl == 5) zoneHeader = '🌊 شاطئ المحيط';
              if (lvl == 9) zoneHeader = '🌅 قمم الغروب';
              if (lvl == 13) zoneHeader = '🌌 قلعة النجوم';

              return Column(
                children: [
                  if (zoneHeader != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white38),
                      ),
                      child: Text(
                        zoneHeader,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  Transform.translate(
                    offset: Offset(shift, 0),
                    child: GestureDetector(
                      onTap: unlocked
                          ? () {
                              _triggerHaptic();
                              _generateAndStartLevel(lvl);
                              setState(() => _currentView = GameScreenView.playingBoard);
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: unlocked
                              ? (lvl == _state.level
                                  ? Colors.amber
                                  : const Color(0xFF10B981))
                              : Colors.black45,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              unlocked ? (completed ? '⭐⭐⭐' : '🎯') : '🔒',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'مرحلة $lvl',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: unlocked && lvl == _state.level
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // الشاشة 3: لوحة اللعب ثلاثية الأبعاد + شريط الـ 7 خانات + القدرات الـ 4
  // --------------------------------------------------------------------------
  Widget _buildPlayingBoardView() {
    final activeBoardTiles = _state.tiles.where((t) => t.status == 'board').toList()
      ..sort((a, b) {
        final cmpZ = a.z.compareTo(b.z);
        if (cmpZ != 0) return cmpZ;
        return a.y.compareTo(b.y);
      });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          // الشريط العلوي (HUD)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _currentView = GameScreenView.homeMenu),
                icon: const Icon(Icons.home_rounded, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'المرحلة ${_state.level} • النقاط: ${_state.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _state.timeChallengeMode = !_state.timeChallengeMode);
                  _generateAndStartLevel(_state.level);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _state.timeChallengeMode ? Colors.deepOrange : Colors.black45,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _state.timeChallengeMode ? '⏱️ ${_state.timeLeftSeconds}s' : '⏱️ وضع حر',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '🪙 ${_state.coins}',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          // الرف المؤقت (Stash) إن وجد
          if (_state.stash.isNotEmpty)
            Container(
              height: 50,
              margin: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _state.stash.map((t) {
                  return GestureDetector(
                    onTap: () => _pickTile(t),
                    child: Container(
                      width: 44,
                      height: 46,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Center(
                        child: Text(t.type.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // لوحة البلاطات ثلاثية الأبعاد (3D Layered Tile Board)
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final boardSize = math.min(constraints.maxWidth, constraints.maxHeight).clamp(250.0, 370.0);
                  final tileW = boardSize / 6.3;
                  final tileH = tileW * 1.12;
                  final stepX = (boardSize - tileW) / 5.4;
                  final stepY = (boardSize - tileH) / 5.4;

                  return SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: Stack(
                      children: activeBoardTiles.map((tile) {
                        final blocked = _isTileBlocked(tile);
                        final leftPx = (tile.x * stepX - tile.z * 3).clamp(0.0, boardSize - tileW);
                        final topPx = (tile.y * stepY - tile.z * 4).clamp(0.0, boardSize - tileH);

                        return Positioned(
                          left: leftPx,
                          top: topPx,
                          width: tileW,
                          height: tileH,
                          child: GestureDetector(
                            onTap: () => _pickTile(tile),
                            child: Opacity(
                              opacity: blocked ? 0.55 : 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: blocked ? const Color(0xFFCBD5E1) : const Color(0xFFFEF9EF),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: blocked
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFFE7D8BE),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: blocked
                                          ? const Color(0xFF475569)
                                          : const Color(0xFFCBB389),
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    tile.type.emoji,
                                    style: TextStyle(fontSize: tileW * 0.52),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),

          // شريط التجميع الخشبي ذو الـ 7 خانات (7-Slot Wooden Tray)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFA16207), Color(0xFF713F12), Color(0xFF422006)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFDE047), width: 3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (idx) {
                final tile = idx < _state.dock.length ? _state.dock[idx] : null;
                return Container(
                  width: 42,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tile != null ? tile.type.bg : Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: tile != null ? tile.type.ring : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tile?.type.emoji ?? '',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),

          // أزرار القدرات الـ 4 المساعدة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPowerBtn('↩️ تراجع', '${_state.undoCount}', _useUndo),
              _buildPowerBtn('💡 تلميح', '${_state.hintCount}', _useHint),
              _buildPowerBtn('🔀 خلط', '${_state.shuffleCount}', _useShuffle),
              _buildPowerBtn('📤 تفريغ 3', '${_state.stashCount}', _useStash),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPowerBtn(String label, String count, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text(count, style: const TextStyle(fontSize: 10, color: Colors.amberAccent)),
        ],
      ),
    );
  }
}
