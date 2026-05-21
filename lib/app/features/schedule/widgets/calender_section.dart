import 'package:flutter/material.dart';

class CalendarSection extends StatelessWidget {
  const CalendarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Month + Arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Icon(Icons.chevron_left),
            Column(
              children: [
                Text("January",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("2024", style: TextStyle(color: Colors.grey)),
              ],
            ),
            Icon(Icons.chevron_right),
          ],
        ),

        const SizedBox(height: 16),

        /// Days Grid (Mock)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 35,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (_, index) {
            final isSelected = index == 10;

            return Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F9D8A) : null,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
