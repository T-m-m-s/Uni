import 'package:flutter/material.dart';

class EditorSharedWidgets {
  static Widget customTextField(String label, TextEditingController ctrl, {int maxLines = 1, bool autofocus = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      autofocus: autofocus,
      decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
      ),
    );
  }

  static Widget interactiveTextField(String label, TextEditingController ctrl, Function onSelect) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final double screenWidth = MediaQuery.sizeOf(context).width;
        final double scale = (screenWidth / 390).clamp(0.8, 1.2);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2),
            ),
            SizedBox(height: 8 * scale),
            GestureDetector(
              onTap: () => onSelect(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 16 * scale),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4 * scale),
                  border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ctrl.text.isEmpty ? "Select..." : ctrl.text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16 * scale,
                          color: ctrl.text.isEmpty 
                              ? Colors.grey 
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down, 
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 24 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  static Widget statCounter(String label, int value, Function(int) onChange) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final double screenWidth = MediaQuery.sizeOf(context).width;
        final double scale = (screenWidth / 390).clamp(0.8, 1.2);
        final mod = (value - 10) ~/ 2;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white, 
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 6 * scale, left: 8 * scale, right: 8 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label.substring(0, 3), 
                      style: TextStyle(fontSize: 12 * scale, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
                    Text("${mod >= 0 ? '+' : ''}$mod", 
                      style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: Text("$value",
                      style: TextStyle(fontSize: 32 * scale, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleBtn(Icons.remove, () => onChange(value > 1 ? value - 1 : 1), scale, isDark),
                  _circleBtn(Icons.add, () => onChange(value < 30 ? value + 1 : 30), scale, isDark),
                ],
              ),
              SizedBox(height: 6 * scale),
            ],
          ),
        );
      }
    );
  }

  static Widget statCounterPointBuy(String label, int value, Function(int) onChange) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final double screenWidth = MediaQuery.sizeOf(context).width;
        final double scale = (screenWidth / 390).clamp(0.8, 1.2);
        final mod = (value - 10) ~/ 2;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white, 
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 6 * scale, left: 8 * scale, right: 8 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label.substring(0, 3), 
                      style: TextStyle(fontSize: 12 * scale, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
                    Text("${mod >= 0 ? '+' : ''}$mod", 
                      style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: Text("$value",
                      style: TextStyle(fontSize: 32 * scale, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleBtn(Icons.remove, () => onChange(value > 8 ? value - 1 : 8), scale, isDark),
                  _circleBtn(Icons.add, () => onChange(value < 15 ? value + 1 : 15), scale, isDark),
                ],
              ),
              SizedBox(height: 6 * scale),
            ],
          ),
        );
      }
    );
  }

  static Widget _circleBtn(IconData icon, VoidCallback onTap, double scale, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4 * scale),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
        child: Icon(icon, size: 20 * scale, color: isDark ? Colors.white70 : Colors.black54),
      ),
    );
  }

  static Widget statSelector(
    String label, 
    int? selectedIndex, 
    List<int> pool, 
    Map<String, int?> assignedIndices,
    Function(int?) onSelect
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final double screenWidth = MediaQuery.sizeOf(context).width;
        final double scale = (screenWidth / 390).clamp(0.8, 1.2);
        int? value = selectedIndex != null ? pool[selectedIndex] : null;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 4 * scale),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white, 
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 8 * scale, top: 4 * scale),
                  child: Text(
                    label.substring(0, 3), 
                    style: TextStyle(
                      fontSize: 14 * scale, 
                      color: isDark ? Colors.white38 : Colors.black38, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
              Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedIndex,
                    hint: Text("—", style: TextStyle(color: Colors.grey, fontSize: 24 * scale)),
                    dropdownColor: Colors.grey[900],
                    icon: Icon(Icons.arrow_drop_down, color: Colors.redAccent, size: 20 * scale),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87, 
                      fontSize: 26 * scale, 
                      fontWeight: FontWeight.bold
                    ),
                    items: [
                      DropdownMenuItem<int>(
                        value: null, 
                        child: Text("None", style: TextStyle(color: Colors.grey, fontSize: 16 * scale))
                      ),
                      ...List.generate(pool.length, (index) {
                        final v = pool[index];
                        final isAssignedElsewhere = assignedIndices.entries.any((e) => e.key != label && e.value == index);
                        
                        return DropdownMenuItem<int>(
                          value: index,
                          enabled: !isAssignedElsewhere,
                          child: Text(
                            "$v",
                            style: TextStyle(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.bold,
                              color: isAssignedElsewhere 
                                  ? (isDark ? Colors.white10 : Colors.grey[300]) 
                                  : (isDark ? Colors.white : Colors.black87),
                              decoration: isAssignedElsewhere ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        );
                      }),
                    ],
                    onChanged: onSelect,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2 * scale),
                  child: Text(
                    value != null 
                      ? "${(value - 10) ~/ 2 >= 0 ? '+' : ''}${(value - 10) ~/ 2}" 
                      : "-", 
                    style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent)
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
