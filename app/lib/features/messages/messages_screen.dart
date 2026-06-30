import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/chat.dart';

({IconData icon, Color color}) _channelMeta(ChannelKind k, DsTokens t) => switch (k) {
      ChannelKind.global => (icon: Icons.public, color: t.info),
      ChannelKind.region => (icon: Icons.location_on_outlined, color: t.solar),
      ChannelKind.federation => (icon: Icons.groups_outlined, color: t.federation),
      ChannelKind.dm => (icon: Icons.chat_bubble_outline, color: FwPalette.rust600),
      ChannelKind.neighborhood => (icon: Icons.holiday_village_outlined, color: t.success),
    };

/// Sistema de Mensagens (GDD v29 §10): 5 canais (Global, Região, Federação,
/// Mensagem Privada, Vizinhança), denúncia por mensagem e indicação de idioma.
/// Drill-in do shell (mantém HUD/nav).
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  String? _selectedId;

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final chat = ref.watch(chatProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: chat.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(chatProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar as mensagens. Tocar para tentar de novo.'),
          ),
        ),
        data: (state) {
          if (state.channels.isEmpty) {
            return const Center(child: Text('Nenhum canal disponível.'));
          }
          final channel = state.channels.firstWhere(
            (c) => c.id == _selectedId,
            orElse: () => state.channels.first,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              _ChannelStrip(
                channels: state.channels,
                selectedId: channel.id,
                onSelect: (id) => setState(() => _selectedId = id),
              ),
              _ChannelInfo(channel: channel),
              Expanded(
                child: channel.messages.isEmpty
                    ? Center(child: Text('Sem mensagens neste canal.', style: TextStyle(color: t.textSecondary)))
                    : ListView(
                        padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space2),
                        children: [
                          for (final m in channel.messages)
                            _MessageBubble(message: m, onReport: () => _toast('Denúncia enviada ao Ministério das Reputações (§9) — em breve')),
                        ],
                      ),
              ),
              _Composer(channelName: channel.name, onSend: () => _toast('Mensagem enviada — em breve')),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space2),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/map'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          const Icon(Icons.forum_outlined, size: 22, color: FwPalette.rust600),
          SizedBox(width: t.space2),
          Text('Mensagens',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

class _ChannelStrip extends StatelessWidget {
  const _ChannelStrip({required this.channels, required this.selectedId, required this.onSelect});
  final List<ChatChannel> channels;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: t.space4),
        itemCount: channels.length,
        separatorBuilder: (_, __) => SizedBox(width: t.space2),
        itemBuilder: (_, i) {
          final c = channels[i];
          final meta = _channelMeta(c.kind, t);
          final selected = c.id == selectedId;
          return ChoiceChip(
            avatar: Icon(meta.icon, size: 16, color: meta.color),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.name),
                if (c.unread > 0) ...[
                  SizedBox(width: t.space1),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: const BoxDecoration(color: FwPalette.rust600, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text('${c.unread}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ],
            ),
            selected: selected,
            onSelected: (_) => onSelect(c.id),
          );
        },
      ),
    );
  }
}

class _ChannelInfo extends StatelessWidget {
  const _ChannelInfo({required this.channel});
  final ChatChannel channel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final moderationColor = channel.moderated ? t.success : t.warning;
    final moderationText = channel.moderated
        ? 'Moderação automática (§10.2)'
        : 'Sem filtro automático — só denúncia manual (§10.2)';
    return Container(
      margin: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tag, size: 14, color: t.textSecondary),
              SizedBox(width: t.space1),
              Expanded(
                child: Text(channel.scope,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FwPalette.gray900)),
              ),
              Icon(channel.moderated ? Icons.verified_outlined : Icons.shield_outlined,
                  size: 13, color: moderationColor),
              SizedBox(width: t.space1),
              Text(moderationText, style: TextStyle(fontSize: 10.5, color: moderationColor)),
            ],
          ),
          SizedBox(height: t.space1),
          Text(channel.description, style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onReport});
  final ChatMessage message;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final you = message.isYou;
    final foreign = message.language != 'pt';
    return Padding(
      padding: EdgeInsets.only(bottom: t.space2),
      child: Row(
        mainAxisAlignment: you ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!you) ...[
            _Avatar(initial: message.author.isNotEmpty ? message.author[0] : '?'),
            SizedBox(width: t.space2),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              padding: EdgeInsets.fromLTRB(t.space3, t.space2, t.space3, t.space2),
              decoration: BoxDecoration(
                color: you ? FwPalette.rust50 : scheme.surface,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(color: you ? FwPalette.rust200 : t.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${message.author} · ${message.sector}',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: you ? FwPalette.rust700 : FwPalette.gray800)),
                      SizedBox(width: t.space2),
                      if (foreign) ...[
                        _LangTag(language: message.language),
                        SizedBox(width: t.space1),
                      ],
                      Text(message.time, style: TextStyle(fontSize: 10, color: t.textSecondary)),
                    ],
                  ),
                  SizedBox(height: t.space1),
                  Text(message.text,
                      style: const TextStyle(fontSize: 13, height: 1.35, color: FwPalette.gray900)),
                  if (foreign)
                    Padding(
                      padding: EdgeInsets.only(top: t.space1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate, size: 11, color: t.textSecondary),
                          SizedBox(width: t.space1),
                          Text('mostrado no idioma do remetente (§10.4)',
                              style: TextStyle(fontSize: 9.5, color: t.textSecondary)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!you) ...[
            SizedBox(width: t.space1),
            IconButton(
              onPressed: onReport,
              icon: Icon(Icons.flag_outlined, size: 15, color: t.textSecondary),
              visualDensity: VisualDensity.compact,
              tooltip: 'Denunciar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});
  final String initial;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.surfaceSunken, shape: BoxShape.circle, border: Border.all(color: t.borderDefault)),
      child: Text(initial.toUpperCase(),
          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 13, color: FwPalette.gray700)),
    );
  }
}

class _LangTag extends StatelessWidget {
  const _LangTag({required this.language});
  final String language;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: FwPalette.teal600.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(language.toUpperCase(),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: FwPalette.teal700)),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.channelName, required this.onSend});
  final String channelName;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: t.borderDefault)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: t.controlLg,
              padding: EdgeInsets.symmetric(horizontal: t.space3),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                borderRadius: BorderRadius.circular(t.radiusButton),
                border: Border.all(color: t.borderDefault),
              ),
              child: Text('Mensagem em $channelName…', style: TextStyle(fontSize: 13, color: t.textSecondary)),
            ),
          ),
          SizedBox(width: t.space2),
          FilledButton(
            onPressed: onSend,
            style: FilledButton.styleFrom(
                backgroundColor: FwPalette.rust600, minimumSize: Size(t.controlLg, t.controlLg), padding: EdgeInsets.zero),
            child: const Icon(Icons.send, size: 18),
          ),
        ],
      ),
    );
  }
}
