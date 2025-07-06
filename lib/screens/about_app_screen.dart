import 'package:flutter/material.dart';
import 'package:mi_mana_diario/dependencies/app_colors_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de la App'),
        backgroundColor: AppColors.celesteCielo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(5),
        children: [
          const ListTile(
            title: Text('📱 Versión de la app'),
            subtitle: Text('1.0.0 (Beta)'),
          ),
          const Divider(),

          const ListTile(
            title: Text('👤 Desarrollador'),
            subtitle: Text('Jeremy Diaz Morales'),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Contáctame por correo'),
            onTap: () => _launchUrl(
              'mailto:jeredi3722@gmail.com?subject=Contacto App Maná',
            ),
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.green,
            ),
            title: const Text('WhatsApp'),
            onTap: () => _launchUrl('https://wa.me/+573166015580'),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Reportar un error o sugerencia'),
            onTap: () => _launchUrl('https://forms.gle/eENVuNxxtti2itX37'),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Política de privacidad'),
            onTap: () =>
                _launchUrl('https://mimanadiario.web.app/privacy.html'),
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Términos y condiciones'),
            onTap: () => _launchUrl('https://mimanadiario.web.app/terms.html'),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('🧪 Funciones experimentales'),
            subtitle: const Text(
              'Activa funciones en desarrollo o ideas nuevas',
            ),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚧 Esta función aún no está disponible.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
