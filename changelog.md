📝 INKVENTORY Changelog
V[v0.3.0] - 2025-08-09

Agregados:
- Refactorización completa del módulo de login siguiendo el patrón 

MVVM:
- Separación de responsabilidades en models, views y viewmodels.
- Creación de LoginViewModel para manejar la lógica de autenticación y recuperación.
- Vista de login simplificada y enfocada exclusivamente en la interfaz.
- Integración de respuesta al teclado (Enter) para mejorar la experiencia de usuario.
- Mejora del flujo de recuperación de contraseña con mensajes seguros y genéricos.

Notas:
- La estructura del proyecto ahora es más escalable y mantenible.
- Se recomienda aplicar el mismo patrón MVVM a los siguientes módulos (Home, Libros, Dashboard).
- Listo para subir a GitHub como versión estable de login.

Tech Stack:
- Flutter Desktop
- Firebase Auth
- Arquitectura MVVM
