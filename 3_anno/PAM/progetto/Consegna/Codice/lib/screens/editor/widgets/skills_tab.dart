import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/editor_provider.dart';
import '../../../core/utils/rules_engine.dart';

class SkillsTab extends StatelessWidget {
  const SkillsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final editor = Provider.of<EditorProvider>(context);
    final skillAbilities = RulesEngine.getSkillAbilities();
    final String charClass = editor.classCtrl.text;
    final List<String> availableSkills = RulesEngine.getClassSkills(charClass);
    final int allowedSkillCount = RulesEngine.getClassSkillCount(charClass);
    final int currentSkillCount = editor.proficiencies.length;
    
    final int allowedExpertiseCount = RulesEngine.getClassExpertiseCount(charClass, editor.level);
    final int currentExpertiseCount = editor.expertises.length;
    
    final sortedSkills = availableSkills..sort();
    final bool canExpertise = RulesEngine.canHaveExpertise(charClass, editor.level);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.redAccent.withValues(alpha: 0.1),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "SKILLS FOR ${charClass.toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                  ),
                  Text(
                    "P: $currentSkillCount / $allowedSkillCount",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: currentSkillCount > allowedSkillCount ? Colors.red : Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (canExpertise) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "E: $currentExpertiseCount / $allowedExpertiseCount",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: currentExpertiseCount > allowedExpertiseCount ? Colors.red : Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedSkills.length,
            itemBuilder: (context, index) {
              final skill = sortedSkills[index];
              final ability = skillAbilities[skill]!;
              final isProficient = editor.proficiencies.contains(skill);
              final isExpert = editor.expertises.contains(skill);

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(skill, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(ability, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _optionButton(
                        label: "P",
                        isActive: isProficient,
                        onTap: () {
                          if (!isProficient && currentSkillCount >= allowedSkillCount) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("You can only choose $allowedSkillCount skills for this class.")),
                            );
                            return;
                          }
                          editor.toggleProficiency(skill);
                        },
                        tooltip: "Proficiency",
                      ),
                      if (canExpertise) ...[
                        const SizedBox(width: 8),
                        _optionButton(
                          label: "E",
                          isActive: isExpert,
                          onTap: () {
                            if (!isExpert && currentExpertiseCount >= allowedExpertiseCount) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("You can only choose $allowedExpertiseCount expertises at this level.")),
                              );
                              return;
                            }
                            editor.toggleExpertise(skill);
                          },
                          tooltip: "Expertise",
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _optionButton({required String label, required bool isActive, required VoidCallback onTap, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? Colors.redAccent : Colors.transparent,
              border: Border.all(color: Colors.redAccent),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
