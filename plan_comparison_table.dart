import 'package:flutter/material.dart';

import '../models/subscription_plan_model.dart';

class PlanComparisonTable extends StatelessWidget {
  final List<SubscriptionPlanModel> plans;

  const PlanComparisonTable({
    Key? key,
    required this.plans,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Define comparison features
    final features = [
      'Video Quality',
      'Ad-free Experience',
      'Download for Offline',
      'Number of Devices',
      'Premium Content',
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            theme.colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          columnSpacing: 24,
          horizontalMargin: 16,
          headingRowHeight: 48,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 64,
          border: TableBorder.all(
            color: theme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
          columns: [
            const DataColumn(
              label: Text('Features'),
            ),
            ...plans.map((plan) => DataColumn(
              label: Text(
                plan.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
          ],
          rows: [
            // Video Quality
            DataRow(
              cells: [
                const DataCell(Text('Video Quality')),
                ...plans.map((plan) => DataCell(
                  Text(_getQualityText(plan.maxQuality)),
                )),
              ],
            ),
            
            // Ad-free Experience
            DataRow(
              cells: [
                const DataCell(Text('Ad-free Experience')),
                ...plans.map((plan) => DataCell(
                  _buildCheckmark(!plan.hasAds, context),
                )),
              ],
            ),
            
            // Download for Offline
            DataRow(
              cells: [
                const DataCell(Text('Download for Offline')),
                ...plans.map((plan) => DataCell(
                  _buildCheckmark(plan.allowsDownloads, context),
                )),
              ],
            ),
            
            // Number of Devices
            DataRow(
              cells: [
                const DataCell(Text('Number of Devices')),
                ...plans.map((plan) => DataCell(
                  Text('${plan.maxDevices}'),
                )),
              ],
            ),
            
            // Premium Content
            DataRow(
              cells: [
                const DataCell(Text('Premium Content')),
                ...plans.map((plan) => DataCell(
                  _buildCheckmark(plan.price > 0, context),
                )),
              ],
            ),
            
            // Price
            DataRow(
              color: MaterialStateProperty.all(
                theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              cells: [
                DataCell(
                  Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...plans.map((plan) => DataCell(
                  Text(
                    plan.formattedPriceWithInterval,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckmark(bool isIncluded, BuildContext context) {
    final theme = Theme.of(context);
    
    return isIncluded
        ? Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: 20,
          )
        : Icon(
            Icons.cancel,
            color: Colors.grey,
            size: 20,
          );
  }

  String _getQualityText(String quality) {
    switch (quality) {
      case 'SD':
        return 'Standard (SD)';
      case 'HD':
        return 'High (HD)';
      case 'FHD':
        return 'Full HD (1080p)';
      case '4K':
        return 'Ultra HD (4K)';
      default:
        return quality;
    }
  }
}

