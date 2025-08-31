import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:chatbot/theme/theme_cubit.dart';
import 'package:chatbot/system/auth.dart';
import 'package:chatbot/services/settings_service.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:chatbot/components/modern_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _apiKeyController;
  bool _obscure = true;
  
  // Settings state - only functional settings
  double _textScale = 1.0;
  bool _showTimestamps = true;
  double _temperature = 0.7;
  int _maxTokens = 2048;
  String _selectedModel = 'gemini-1.5-flash';

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: SettingsService.apiKey ?? '');
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _textScale = SettingsService.textScale;
      _showTimestamps = SettingsService.showTimestamps;
      _temperature = SettingsService.temperature;
      _maxTokens = SettingsService.maxTokens;
      _selectedModel = SettingsService.selectedModel;
    });
  }

  void _saveSetting(String key, dynamic value) {
    switch (key) {
      case 'textScale':
        SettingsService.textScale = value;
        // Trigger app rebuild for text scale changes
        _triggerAppRebuild();
        _showSettingChangedSnackBar('Text size updated');
        break;
      case 'showTimestamps':
        SettingsService.showTimestamps = value;
        _showSettingChangedSnackBar('Timestamp setting updated');
        break;
      case 'temperature':
        SettingsService.temperature = value;
        _showSettingChangedSnackBar('AI creativity updated');
        break;
      case 'maxTokens':
        SettingsService.maxTokens = value;
        _showSettingChangedSnackBar('Response length updated');
        break;
      case 'selectedModel':
        SettingsService.selectedModel = value;
        _showSettingChangedSnackBar('AI model changed to $value');
        break;
    }
  }

  void _showSettingChangedSnackBar(String message) {
    if (mounted) {
      _showModernChip(message, Icons.check_circle_rounded, Colors.green);
    }
  }

  void _showModernChip(String message, IconData icon, Color color) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ModernChipNotification(
        message: message,
        icon: icon,
        color: color,
        onDismiss: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _triggerAppRebuild() {
    // Force the app to rebuild by updating the theme state
    // This ensures text scale changes are applied immediately
    final themeCubit = context.read<ThemeCubit>();
    final currentMode = themeCubit.state.mode;
    if (currentMode == ThemeMode.light) {
      themeCubit.setLight();
    } else if (currentMode == ThemeMode.dark) {
      themeCubit.setDark();
    } else {
      themeCubit.setSystem();
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      _showModernChip('Please enter a valid API key', Icons.error_rounded, Colors.orange);
      return;
    }
    SettingsService.apiKey = key;
    // Re-init Gemini with the new key
    Gemini.init(apiKey: key);
    if (!mounted) return;
    _showModernChip('API key saved successfully', Icons.key_rounded, Colors.blue);
  }

  Future<void> _clearApiKey() async {
    SettingsService.apiKey = null;
    _apiKeyController.clear();
    if (!mounted) return;
    _showModernChip('API key cleared. Using default', Icons.refresh_rounded, Colors.purple);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Appearance',
            'Customize the look and feel',
            [
              _buildThemeSelector(),
              _buildSliderTile(
                'Text Size',
                'Adjust text scale throughout the app',
                _textScale,
                0.8,
                1.2,
                (value) {
                  setState(() => _textScale = value);
                  _saveSetting('textScale', value);
                },
                valueDisplay: '${(_textScale * 100).round()}%',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            'Chat Behavior',
            'Configure AI responses and interactions',
            [
              _buildDropdownTile(
                'AI Model',
                'Choose the Gemini model to use',
                Icons.psychology_rounded,
                _selectedModel,
                ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-pro'],
                (value) {
                  setState(() => _selectedModel = value!);
                  _saveSetting('selectedModel', value);
                },
              ),
              _buildSliderTile(
                'Creativity',
                'Control response randomness and creativity',
                _temperature,
                0.0,
                1.0,
                (value) {
                  setState(() => _temperature = value);
                  _saveSetting('temperature', value);
                },
                valueDisplay: _temperature < 0.3 ? 'Precise' : 
                            _temperature < 0.7 ? 'Balanced' : 'Creative',
              ),
              _buildSliderTile(
                'Response Length',
                'Maximum tokens in AI responses',
                _maxTokens.toDouble(),
                512.0,
                4096.0,
                (value) {
                  setState(() => _maxTokens = value.round());
                  _saveSetting('maxTokens', _maxTokens);
                },
                valueDisplay: '$_maxTokens tokens',
                divisions: 7,
              ),
              _buildSwitchTile(
                'Show Timestamps',
                'Display message timestamps in chat',
                Icons.schedule_rounded,
                _showTimestamps,
                (value) {
                  setState(() => _showTimestamps = value);
                  _saveSetting('showTimestamps', value);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            'API Configuration',
            'Manage your Gemini API settings',
            [
              _buildApiKeySection(),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            'Data Management',
            'Control your chat data',
            [
              _buildActionTile(
                'Clear All Chats',
                'Delete all conversation history',
                Icons.delete_outline_rounded,
                () => _clearChats(),
                isDestructive: true,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSection(
            'About',
            'App information',
            [
              _buildActionTile(
                'Version',
                'ChatBot Master v1.0.0',
                Icons.info_outline_rounded,
                () {},
                showArrow: false,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildRadioTile(
              'System',
              'Follow device theme',
              Icons.brightness_auto_rounded,
              ThemeMode.system,
              state.mode,
              (value) => context.read<ThemeCubit>().setSystem(),
            ),
            _buildRadioTile(
              'Light',
              'Always use light theme',
              Icons.brightness_7_rounded,
              ThemeMode.light,
              state.mode,
              (value) => context.read<ThemeCubit>().setLight(),
            ),
            _buildRadioTile(
              'Dark',
              'Always use dark theme',
              Icons.brightness_3_rounded,
              ThemeMode.dark,
              state.mode,
              (value) => context.read<ThemeCubit>().setDark(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRadioTile<T>(
    String title,
    String subtitle,
    IconData icon,
    T value,
    T groupValue,
    ValueChanged<T?> onChanged,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12),
      ),
      trailing: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onTap: () => onChanged(value),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    String? valueDisplay,
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (valueDisplay != null)
                Text(
                  valueDisplay,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool showArrow = true,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(
        icon,
        size: 20,
        color: isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Theme.of(context).colorScheme.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12),
      ),
      trailing: showArrow
          ? Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildApiKeySection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _apiKeyController,
            obscureText: _obscure,
            enableSuggestions: false,
            autocorrect: false,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Enter your Gemini API key',
              hintStyle: GoogleFonts.inter(fontSize: 14),
              prefixIcon: Icon(
                Icons.key_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show' : 'Hide',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveApiKey,
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearApiKey,
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _testApiKey,
                icon: const Icon(Icons.wifi_protected_setup_rounded, size: 16),
                label: const Text('Test'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _testApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      _showModernChip('Please enter an API key first', Icons.warning_rounded, Colors.orange);
      return;
    }
    
    // Simple test - try to initialize Gemini with the key
    try {
      Gemini.init(apiKey: key);
      if (!mounted) return;
      _showModernChip('API key is valid and working', Icons.verified_rounded, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showModernChip('API key test failed', Icons.error_rounded, Colors.red);
    }
  }

  void _clearChats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Chats'),
        content: const Text('Are you sure you want to delete all conversation history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear chat data from Hive
              Hive.box(boxName).clear();
              Navigator.pop(context);
              _showModernChip('All chats cleared successfully', Icons.delete_sweep_rounded, Colors.red);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ModernChipNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;

  const _ModernChipNotification({
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_ModernChipNotification> createState() => _ModernChipNotificationState();
}

class _ModernChipNotificationState extends State<_ModernChipNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
    HapticFeedback.mediumImpact(); // Haptic feedback when chip appears
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    HapticFeedback.lightImpact();
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
