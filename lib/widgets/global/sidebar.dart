import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//=========================== WIDGET PRINCIPAL SIDEBAR ===========================//
// WIDGET QUE MUESTRA EL MENÚ LATERAL CON ICONOS, PERMISOS Y NAVEGACIÓN
class Sidebar extends StatefulWidget {
  final int selectedIndex; // ÍNDICE DEL ITEM SELECCIONADO
  final Function(int) onItemSelected; // CALLBACK CUANDO SE SELECCIONA UN ITEM
  final String userEmail; // CORREO DEL USUARIO
  final String userRole; // ROL DEL USUARIO
  final Map<String, bool> permisosModulos; // PERMISOS POR MÓDULO

  const Sidebar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userEmail,
    required this.userRole,
    required this.permisosModulos,
    super.key,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

//=========================== ESTADO DEL SIDEBAR ===========================//
// CONTROL DE EXPANSIÓN, HOVER Y LÓGICA DE ACCESO
class _SidebarState extends State<Sidebar> {
  bool isExpanded = true; // INDICA SI EL SIDEBAR ESTÁ EXPANDIDO
  int _hoveredIndex = -1; // ÍNDICE DEL ITEM SOBRE EL QUE SE HACE HOVER

  //=========================== MÉTODO DE TOGGLE ===========================//
  // PERMITE COLAPSAR O EXPANDIR EL SIDEBAR
  void toggleSidebar() {
    setState(() => isExpanded = !isExpanded);
  }

  //=========================== MÉTODO DE PERMISOS ===========================//
  // DEVUELVE TRUE SI EL USUARIO TIENE ACCESO AL ITEM
  bool _tieneAcceso(String label) {
    if (label == 'Dashboard' || label == 'Cerrar sesión') return true;
    return widget.permisosModulos[label] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = isExpanded ? 260.0 : 90.0;

    //=========================== ITEMS DEL MENÚ ===========================//
    // LISTA DE ITEMS CON ICONO Y ETIQUETA
    final menuItems = [
      _SidebarItem(icon: CupertinoIcons.home, label: 'Dashboard'),
      _SidebarItem(icon: CupertinoIcons.book, label: 'Inventario'),
      _SidebarItem(icon: CupertinoIcons.archivebox, label: 'Acervo'),
      _SidebarItem(icon: CupertinoIcons.cart, label: 'Ventas'),
      _SidebarItem(icon: CupertinoIcons.heart, label: 'Donaciones'),
      _SidebarItem(icon: CupertinoIcons.person_2, label: 'Usuarios'),
      _SidebarItem(icon: CupertinoIcons.square_arrow_right, label: 'Cerrar sesión'),
    ];

    //=========================== CONTENEDOR PRINCIPAL ===========================//
    // ANIMACIÓN DE EXPANSIÓN, FONDO OSCURO Y SOMBRA SUAVE
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF1C2532), // FONDO OSCURO PARA CONTRASTE
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          //=========================== CABECERA ===========================//
          // MUESTRA AVATAR, CORREO, ROL Y DIVISOR INICIAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFA9B4C6),
                  child: const Icon(CupertinoIcons.person_solid,
                      color: Color(0xFF1C2532), size: 30),
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.userEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userRole,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.6),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                  ),
                ],
              ],
            ),
          ),

          //=========================== LISTA DE ITEMS ===========================//
          // MOSTRADO EN UN LISTVIEW, CON HOVER, SELECCIÓN Y PERMISOS
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: isExpanded ? 0 : 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = index == widget.selectedIndex;
                final tieneAcceso = _tieneAcceso(item.label);

                // COLOR DE FONDO PARA ITEM SELECCIONADO O HOVER
                final Color bgColor = (isSelected)
                    ? const Color.fromRGBO(0, 97, 255, 0.15) // COLOR CELESTE SUAVE PARA SELECCIÓN
                    : (_hoveredIndex == index
                        ? const Color.fromRGBO(0, 97, 255, 0.10) // HOVER LIGERO
                        : Colors.transparent);

                //=========================== TOOLTIP Y GESTOS ===========================//
                return Tooltip(
                  message: tieneAcceso ? item.label : 'Sin permisos para ${item.label}',
                  child: MouseRegion(
                    cursor: tieneAcceso
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = -1),
                    child: GestureDetector(
                      onTap: tieneAcceso ? () => widget.onItemSelected(index) : null,
                      child: Stack(
                        children: [
                          //=========================== LÍNEA CELESTE EXTERNA ===========================//
                          if (isSelected)
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 3.5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4DC0E8),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),

                          //=========================== CONTENEDOR DEL ITEM ===========================//
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            padding: EdgeInsets.symmetric(
                              horizontal: isExpanded ? 12 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                if (!isExpanded)
                                  const SizedBox(width: 8), // ESPACIADO CUANDO ESTÁ COLAPSADO

                                // ICONO DEL ITEM
                                Expanded(
                                  flex: isExpanded ? 0 : 1,
                                  child: Align(
                                    alignment: isExpanded
                                        ? Alignment.centerLeft
                                        : Alignment.center,
                                    child: Icon(
                                      item.icon,
                                      size: 22,
                                      color: isSelected
                                          ? const Color(0xFF4DC0E8) // ICONO CELESTE SI SELECCIONADO
                                          : const Color(0xFFC6CEDD), // ICONO GRIS SI NO SELECCIONADO
                                    ),
                                  ),
                                ),

                                // TEXTO DEL ITEM, SOLO VISIBLE CUANDO EXPANDIDO
                                if (isExpanded) const SizedBox(width: 12),
                                if (isExpanded)
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF4DC0E8)
                                            : const Color(0xFFC6CEDD),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          //=========================== DIVISOR INFERIOR ===========================//
          Container(
            height: 1,
            color: const Color.fromRGBO(255, 255, 255, 0.1),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          //=========================== BOTÓN DE COLAPSAR ===========================//
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              icon: Icon(
                isExpanded ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.white70,
                size: 25,
              ),
              onPressed: toggleSidebar,
            ),
          ),
        ],
      ),
    );
  }
}

//=========================== MODELO DE ITEM DEL SIDEBAR ===========================//
// GUARDAR ICONO Y ETIQUETA DE CADA ITEM
class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}
