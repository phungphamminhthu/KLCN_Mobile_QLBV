import 'package:flutter/material.dart';

class BookingStepper extends StatelessWidget {
  final int currentStep;
  final Color primaryColor;
  final double circleSize;
  final EdgeInsetsGeometry padding;

  const BookingStepper({
    super.key,
    required this.currentStep,
    this.primaryColor = const Color(0xFF2563EB),
    this.circleSize = 42.0,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
  });

  static const List<String> labels = [
    'Chọn khoa',
    'Chọn ngày',
    'Chọn bác sĩ',
    'Xác nhận',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(labels.length, (index) {
              final isCompleted = index < currentStep;
              final isActive = index == currentStep;
              final isPassed = index <= currentStep;

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hàng chứa nửa đường nối trái - nút tròn - nửa đường nối phải
                    SizedBox(
                      height: circleSize,
                      child: Row(
                        children: [
                          // Nửa đoạn nối bên trái
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index == 0
                                  ? Colors.transparent
                                  : (isPassed
                                      ? primaryColor
                                      : const Color(0xFFE2E8F0)),
                            ),
                          ),

                          // Nút tròn
                          Container(
                            width: circleSize,
                            height: circleSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isCompleted || isActive)
                                  ? primaryColor
                                  : Colors.white,
                              border: Border.all(
                                color: (isCompleted || isActive)
                                    ? primaryColor
                                    : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                          ),

                          // Nửa đoạn nối bên phải
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index == labels.length - 1
                                  ? Colors.transparent
                                  : (index < currentStep
                                      ? primaryColor
                                      : const Color(0xFFE2E8F0)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Nhãn chữ căn giữa chuẩn dưới nút tròn
                    Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : (isCompleted ? FontWeight.w600 : FontWeight.w500),
                        color: (isActive || isCompleted)
                            ? primaryColor
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
