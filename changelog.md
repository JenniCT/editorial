📝 INKVENTORY Changelog
V[v0.2.0] - 2025-08-09

Agregados:
- Implementación del sistema de recuperación de contraseña:
- Generación de enlace único para restablecimiento.
- Envío automático de correo al usuario con plantilla HTML personalizada.
- Validación de token y redirección segura al formulario de nueva contraseña.
- Creación de plantilla HTML para correo de recuperación:
- Diseño responsivo y profesional con estilo moderno.
- Inclusión de ícono temporal de tintero como branding provisional.
- Variables dinámicas para %EMAIL% y %LINK%.

Notas:
- El sistema ya permite a los usuarios recuperar su acceso de forma segura.
- Se recomienda reemplazar el ícono temporal por el logo oficial en cuanto esté disponible.
- Próximo paso: agregar validaciones más robustas y expiración de tokens.

Tech Stack:
- Flutter Desktop
- Firebase (Auth + Core)
- HTML5 + CSS3


