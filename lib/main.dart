import 'dart:math';

import 'package:chess/chess.dart' as chess;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const ChessApp());
}

const ink = Color(0xFF17211D);
const forest = Color(0xFF244B3C);
const cream = Color(0xFFF5F2E9);

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pocket Chess',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cream,
      fontFamily: 'Roboto',
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String difficulty = 'Medium';
  InterstitialAd? _interstitial;
  bool _showingInterstitial = false;
  bool _pendingHomeAd = true;
  static const bannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const interstitialId = 'ca-app-pub-3940256099942544/1033173712';

  @override
  void initState() {
    super.initState();
    _loadInterstitial();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showInterstitial());
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          if (_pendingHomeAd && mounted) {
            _pendingHomeAd = false;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _showInterstitial(),
            );
          }
        },
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  void _showInterstitial() {
    if (!mounted || _showingInterstitial) return;
    final ad = _interstitial;
    if (ad == null) return;
    _pendingHomeAd = false;
    _interstitial = null;
    _showingInterstitial = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showingInterstitial = false;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _showingInterstitial = false;
        _loadInterstitial();
      },
    );
    ad.show();
  }

  Future<void> _startGame(bool vsComputer) async {
    await _showBeforeNavigation();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GamePage(vsComputer: vsComputer, difficulty: difficulty),
      ),
    );
    if (mounted) {
      _pendingHomeAd = true;
      _showInterstitial();
    }
  }

  Future<void> _showBeforeNavigation() async {
    final ad = _interstitial;
    if (ad == null) return;
    _interstitial = null;
    _showingInterstitial = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showingInterstitial = false;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _showingInterstitial = false;
        _loadInterstitial();
      },
    );
    await ad.show();
    // The ad's full-screen callback resets this flag and requests the next ad.
    // Navigation can proceed immediately after showing begins.
  }

  @override
  void dispose() {
    _interstitial?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              color: forest,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.grid_4x4_rounded,
                              size: 52,
                              color: Color(0xFFF4E9C9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'POCKET CHESS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: forest,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your next move.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ink,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A little strategy goes a long way.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ink.withValues(alpha: .62),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 34),
                        _ModeButton(
                          icon: Icons.people_alt_rounded,
                          title: 'Human vs Human',
                          subtitle: 'Pass the phone and play together',
                          onTap: () => _startGame(false),
                        ),
                        const SizedBox(height: 12),
                        _ModeButton(
                          icon: Icons.smart_toy_rounded,
                          title: 'Computer vs Human',
                          subtitle: 'Take on the computer',
                          onTap: () => _startGame(true),
                          filled: true,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: forest.withValues(alpha: .12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF0E8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  color: forest,
                                ),
                              ),
                              const SizedBox(width: 13),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Difficulty',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: ink,
                                      ),
                                    ),
                                    Text(
                                      'For computer games',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: difficulty,
                                  items: const ['Easy', 'Medium', 'Hard']
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (d) {
                                    if (d != null) {
                                      setState(() => difficulty = d);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 19),
                        const Text(
                          '♙  White moves first    ·    No account needed',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const _BannerAd(),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool filled;
  @override
  Widget build(BuildContext context) => Material(
    color: filled ? forest : Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: filled ? forest : forest.withValues(alpha: .12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withValues(alpha: .14)
                    : const Color(0xFFEAF0E8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: filled ? Colors.white : forest),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: filled ? Colors.white : ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: filled ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: filled ? Colors.white : forest,
            ),
          ],
        ),
      ),
    ),
  );
}

class _BannerAd extends StatefulWidget {
  const _BannerAd();
  @override
  State<_BannerAd> createState() => _BannerAdState();
}

class _BannerAdState extends State<_BannerAd> {
  BannerAd? _ad;
  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: _HomePageState.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdFailedToLoad: (ad, _) => ad.dispose()),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 58,
    width: double.infinity,
    alignment: Alignment.center,
    color: Colors.white,
    child: _ad == null ? const SizedBox.shrink() : AdWidget(ad: _ad!),
  );
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.vsComputer,
    required this.difficulty,
  });
  final bool vsComputer;
  final String difficulty;
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final chess.Chess game = chess.Chess();
  String? selected;
  List<String> legalTargets = [];
  bool thinking = false;

  bool get computerTurn => widget.vsComputer && game.turn == chess.Color.BLACK;

  void _tapSquare(String square) {
    if (thinking || computerTurn || game.game_over) return;
    setState(() {
      if (selected != null && legalTargets.contains(square)) {
        game.move({'from': selected, 'to': square, 'promotion': 'q'});
        selected = null;
        legalTargets = [];
      } else {
        final piece = game.get(square);
        if (piece != null && piece.color == game.turn) {
          selected = square;
          final possible = game.moves({
            'square': square,
            'asObjects': true,
          }) as List<chess.Move>;
          legalTargets = possible.map((move) => move.toAlgebraic).toList();
        } else {
          selected = null;
          legalTargets = [];
        }
      }
    });
    if (widget.vsComputer &&
        game.turn == chess.Color.BLACK &&
        !game.game_over) {
      _computerMove();
    }
  }

  Future<void> _computerMove() async {
    setState(() => thinking = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted || game.game_over) return;
    final moves = List<chess.Move>.from(game.moves({'asObjects': true}));
    if (moves.isNotEmpty) {
      int value(chess.PieceType? piece) => switch (piece?.name) {
        'p' => 1,
        'n' || 'b' => 3,
        'r' => 5,
        'q' => 9,
        'k' => 20,
        _ => 0,
      };
      // Use capture/promotion value as a small, transparent strength ladder.
      final ordered = List<chess.Move>.from(moves)
        ..sort((a, b) {
          final scoreA = value(a.captured) * 10 + value(a.promotion) * 8;
          final scoreB = value(b.captured) * 10 + value(b.promotion) * 8;
          return scoreB.compareTo(scoreA);
        });
      final pickFrom = switch (widget.difficulty) {
        'Easy' => ordered.length,
        'Medium' => min(4, ordered.length),
        _ => 1,
      };
      final choice = ordered[Random().nextInt(pickFrom)];
      game.move(choice);
    }
    setState(() => thinking = false);
  }

  String get status {
    if (game.in_checkmate) {
      return '${game.turn == chess.Color.WHITE ? 'Black' : 'White'} wins by checkmate';
    }
    if (game.in_draw) return 'Draw game';
    if (thinking) return 'Computer is thinking…';
    final side = game.turn == chess.Color.WHITE ? 'White' : 'Black';
    return '$side to move${game.in_check ? ' · Check!' : ''}';
  }

  void _undo() {
    if (game.history.isEmpty) return;
    setState(() {
      game.undo();
      if (widget.vsComputer &&
          game.turn == chess.Color.BLACK &&
          game.history.isNotEmpty) {
        game.undo();
      }
      selected = null;
      legalTargets = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final ended = game.game_over;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cream,
        title: Text(
          widget.vsComputer
              ? 'VS COMPUTER · ${widget.difficulty.toUpperCase()}'
              : 'TWO PLAYERS',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: forest,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const _PlayerChip(label: 'BLACK', icon: '♚'),
                  const Spacer(),
                  Text(
                    '${game.history.length} moves',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                  const Spacer(),
                  const _PlayerChip(label: 'WHITE', icon: '♔'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AspectRatio(
                aspectRatio: 1,
                child: _Board(
                  game: game,
                  selected: selected,
                  targets: legalTargets,
                  onTap: _tapSquare,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ended ? Icons.emoji_events_rounded : Icons.circle,
                    size: 14,
                    color: ended ? const Color(0xFFBD8D36) : forest,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    status,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _undo,
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('Undo'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => setState(() {
                        game.reset();
                        selected = null;
                        legalTargets = [];
                      }),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('New game'),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({required this.label, required this.icon});
  final String label;
  final String icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20, color: ink)),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
            color: ink,
          ),
        ),
      ],
    ),
  );
}

class _Board extends StatelessWidget {
  const _Board({
    required this.game,
    required this.selected,
    required this.targets,
    required this.onTap,
  });
  final chess.Chess game;
  final String? selected;
  final List<String> targets;
  final ValueChanged<String> onTap;
  static const symbols = {
    'p': '♟',
    'r': '♜',
    'n': '♞',
    'b': '♝',
    'q': '♛',
    'k': '♚',
  };
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(5),
    child: Column(
      children: List.generate(
        8,
        (row) => Expanded(
          child: Row(
            children: List.generate(8, (col) {
              final square = '${String.fromCharCode(97 + col)}${8 - row}';
              final light = (row + col).isEven;
              final piece = game.get(square);
              final isSelected = selected == square;
              final target = targets.contains(square);
              final pieceSymbol =
                  piece?.color == chess.Color.WHITE &&
                      piece?.type == chess.PieceType.PAWN
                  ? '♙'
                  : symbols[piece?.type.name];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(square),
                  child: Container(
                    color: isSelected
                        ? const Color(0xFFB9C978)
                        : light
                        ? const Color(0xFFE8DFC8)
                        : const Color(0xFF789581),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (piece != null)
                          Text(
                            pieceSymbol ?? '',
                            style: TextStyle(
                              fontSize: 39,
                              height: 1,
                              color: piece.color == chess.Color.WHITE
                                  ? Colors.white
                                  : const Color(0xFF26322D),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: .36),
                                  blurRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        if (target && piece == null)
                          Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (target && piece != null)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFBA5E4B),
                                width: 4,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (col == 0)
                          Positioned(
                            left: 3,
                            top: 2,
                            child: Text(
                              '${8 - row}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: light
                                    ? const Color(0xFF789581)
                                    : const Color(0xFFE8DFC8),
                              ),
                            ),
                          ),
                        if (row == 7)
                          Positioned(
                            right: 3,
                            bottom: 0,
                            child: Text(
                              String.fromCharCode(97 + col),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: light
                                    ? const Color(0xFF789581)
                                    : const Color(0xFFE8DFC8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ),
  );
}
