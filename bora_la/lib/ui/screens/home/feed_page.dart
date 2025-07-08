import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/announcement_provider.dart';
import '../../../core/providers/topics_provider.dart';
import '../../../core/utils/constants.dart';
import '../announcements/announcement_detail_screen.dart';
import '../topics/topic_selection_screen.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/topic_card.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final announcementsProvider = context.watch<AnnouncementsProvider>();
    final topicsProvider = context.watch<TopicsProvider>();

    final isLoading =
        announcementsProvider.isLoading || topicsProvider.isLoading;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          // TODO: Implementar lógica de refresh
        },
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            Text(
              'Workshop',
              style: AppConstants.heading2.copyWith(
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Selecione um dos temas abaixo para o seu workshop.',
              style: AppConstants.caption,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TopicCard(
              title: 'Ver todos os temas',
              subtitle:
              '${topicsProvider.availableTopics.length} temas disponíveis',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TopicSelectionScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            Text(
              'Últimos Avisos',
              style: AppConstants.heading2.copyWith(
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            if (announcementsProvider.announcements.isEmpty)
              const Center(child: Text('Nenhum aviso no momento.'))
            else
              ...announcementsProvider.announcements.map((
                  announcement,
                  ) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.paddingMedium,
                  ),
                  child: AnnouncementCard(
                    announcement: announcement,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AnnouncementDetailScreen(
                            announcementId: announcement.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}