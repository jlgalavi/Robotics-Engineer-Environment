# Arquitectura

WezTerm es la capa visual: ventanas, pestañas, apariencia y teclas. Bash es la capa operativa: comandos, prompt y utilidades. ROS 2, Git, Docker y SSH son integraciones independientes encima de esas capas.

El futuro *context engine* detectará workspace, robot y herramientas activas, y será la única fuente de verdad del entorno. Las demás capas consumirán ese contexto; no volverán a detectarlo por su cuenta. Así se evita duplicar responsabilidades y se mantienen componentes pequeños y reemplazables.
