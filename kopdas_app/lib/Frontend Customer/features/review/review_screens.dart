import '../../core/core.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final TextEditingController _rv;

  @override
  void initState() {
    super.initState();
    _rv = TextEditingController(text: context.read<OrderProvider>().review);
  }

  @override
  void dispose() {
    _rv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    return AppScaffold(
      title: 'Rating dan review',
      canPop: false,
      footer: AppButton(
        label: 'Kirim review',
        onPressed: o.rating > 0
            ? () {
                o.setReview(_rv.text);
                context.replace(Routes.end);
              }
            : null,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 18, children: [
        const SizedBox(height: 6),
        Text('Bagaimana kopi dari ${o.cart.name}?',
            textAlign: TextAlign.center, style: dsp(context, 24)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var n = 1; n <= 5; n++)
            IconButton(
              tooltip: '$n bintang',
              iconSize: 40,
              onPressed: () => o.setRating(n),
              icon: Icon(Icons.star_rounded, color: o.rating >= n ? p.sun : p.line),
            ),
        ]),
        Text(MockData.ratingLabels[o.rating],
            textAlign: TextAlign.center, style: body(context, w: FontWeight.w600, color: p.muted)),
        Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
          for (final t in MockData.reviewTags)
            AppChip(label: t, selected: o.tags.contains(t), onTap: () => o.toggleTag(t)),
        ]),
        AppField(
          label: 'Review (opsional)',
          controller: _rv,
          hint: 'Ceritakan rasa, antrean, atau pelayanannya',
          maxLines: 3,
        ),
      ]),
    );
  }
}

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final o = context.watch<OrderProvider>();
    final user = context.watch<AuthProvider>().userName;
    return AppScaffold(
      title: 'Selesai',
      canPop: false,
      footer: AppButton(
        label: 'Pesan lagi',
        onPressed: () {
          o.resetForNewOrder();
          context.backTo(Routes.home);
        },
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StatusHeader(
          badgeChild: const GerobakArt(width: 70),
          title: 'Terima kasih, $user',
          message: 'Review-mu untuk ${o.cart.name} sudah terkirim dan membantu pembeli lain memilih.',
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(spacing: 4, children: [
            Text(starsText(o.rating),
                style: TextStyle(color: p.sun, fontSize: 26, letterSpacing: 4)),
            if (o.tags.isNotEmpty) Text(o.tags.join(' · '), style: mut(context, 13)),
            if (o.review.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('“${o.review.trim()}”', textAlign: TextAlign.center, style: body(context)),
              ),
          ]),
        ),
      ]),
    );
  }
}
